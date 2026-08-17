import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:einstellungstest_trainer/services/sync/cloud_models.dart';
import 'package:einstellungstest_trainer/services/sync/cloud_sync_service.dart';

/// Cloud-Anbindung an Firestore.
///
/// Struktur:
///
/// ```
/// users/{uid}                   Profil, Testtermin, Fortschritt, Bestwerte
/// users/{uid}/sessions/{id}     abgeschlossene Sitzungen
/// ```
///
/// Die Dokument-ID einer Sitzung ist ihre bestehende lokale Kennung. Dadurch
/// ist ein erneuter Upload derselben Sitzung ein Überschreiben und keine
/// Dublette – die Grundlage für den idempotenten Abgleich.
class FirestoreSyncService implements CloudSyncService {
  FirestoreSyncService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Obergrenze für einen Schreibvorgang. Firestore erlaubt 500 Operationen
  /// pro Batch; darunter zu bleiben ist billiger als es auszureizen.
  static const int _batchLimit = 400;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _userDoc(uid).collection('sessions');

  @override
  Future<CloudProfile?> loadProfile(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;

      return CloudProfile.fromJson(data);
    } on FirebaseException catch (error) {
      throw SyncFailure(_describe(error));
    }
  }

  @override
  Future<void> saveProfile(String uid, CloudProfile profile) async {
    try {
      await _userDoc(uid).set(profile.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw SyncFailure(_describe(error));
    }
  }

  @override
  Future<Set<String>> loadSessionIds(String uid) async {
    try {
      // Nur die Dokument-IDs: kein Feld wird gelesen, der Abgleich bleibt
      // günstig auch bei vielen Sitzungen.
      final snapshot = await _sessions(uid).get();
      return snapshot.docs.map((doc) => doc.id).toSet();
    } on FirebaseException catch (error) {
      throw SyncFailure(_describe(error));
    }
  }

  @override
  Future<List<CloudSession>> loadSessions(String uid, {int limit = 100}) async {
    try {
      final snapshot = await _sessions(uid)
          .orderBy('finishedAt', descending: true)
          .limit(limit)
          .get();

      final sessions = <CloudSession>[];
      for (final doc in snapshot.docs) {
        // Ein beschädigter Einzeleintrag darf den Abgleich nicht kippen.
        final session = CloudSession.fromJson(doc.id, doc.data());
        if (session != null) sessions.add(session);
      }
      return sessions;
    } on FirebaseException catch (error) {
      throw SyncFailure(_describe(error));
    }
  }

  @override
  Future<void> uploadSessions(String uid, List<CloudSession> sessions) async {
    if (sessions.isEmpty) return;

    try {
      for (var start = 0; start < sessions.length; start += _batchLimit) {
        final slice = sessions.skip(start).take(_batchLimit);
        final batch = _firestore.batch();

        for (final session in slice) {
          batch.set(_sessions(uid).doc(session.id), session.toJson());
        }
        await batch.commit();
      }
    } on FirebaseException catch (error) {
      throw SyncFailure(_describe(error));
    }
  }

  @override
  Future<void> deleteEverything(String uid) async {
    try {
      // Firestore löscht Unterkollektionen nicht automatisch mit.
      while (true) {
        final snapshot = await _sessions(uid).limit(_batchLimit).get();
        if (snapshot.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await _userDoc(uid).delete();
    } on FirebaseException catch (error) {
      throw SyncFailure(_describe(error));
    }
  }

  String _describe(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => 'Kein Zugriff auf die Cloud-Daten.',
      'unavailable' =>
        'Die Cloud ist gerade nicht erreichbar. Der Fortschritt bleibt lokal '
            'gespeichert.',
      'deadline-exceeded' => 'Zeitüberschreitung beim Abgleich.',
      _ => error.message ?? 'Abgleich fehlgeschlagen (${error.code})',
    };
  }
}
