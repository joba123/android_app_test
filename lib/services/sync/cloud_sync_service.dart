import 'package:einstellungstest_trainer/services/sync/cloud_models.dart';

/// Fehlschlag beim Zugriff auf die Cloud.
class SyncFailure implements Exception {
  const SyncFailure(this.message);

  final String message;

  @override
  String toString() => 'SyncFailure: $message';
}

/// Zugriff auf die Cloud-Daten eines Kontos.
///
/// Die Schnittstelle bildet genau die abgestimmte Struktur ab:
///
/// ```
/// users/{uid}                     -> CloudProfile
/// users/{uid}/sessions/{id}       -> CloudSession
/// ```
abstract class CloudSyncService {
  Future<CloudProfile?> loadProfile(String uid);

  Future<void> saveProfile(String uid, CloudProfile profile);

  /// Nur die Kennungen – reicht, um zu entscheiden, was hochgeladen werden
  /// muss, und ist deutlich günstiger als alle Sitzungen zu laden.
  Future<Set<String>> loadSessionIds(String uid);

  Future<List<CloudSession>> loadSessions(String uid, {int limit});

  Future<void> uploadSessions(String uid, List<CloudSession> sessions);

  /// Löscht alle Cloud-Daten des Kontos (DSGVO Art. 17).
  Future<void> deleteEverything(String uid);
}

/// Cloud-Ersatz für Tests und den lokalen Modus.
class InMemoryCloudSyncService implements CloudSyncService {
  InMemoryCloudSyncService();

  final Map<String, CloudProfile> _profiles = {};
  final Map<String, Map<String, CloudSession>> _sessions = {};

  /// Zählt die Schreibvorgänge – Tests prüfen damit, dass ein zweiter
  /// Abgleich nichts Überflüssiges hochlädt.
  int uploadCalls = 0;
  int uploadedSessionCount = 0;

  @override
  Future<CloudProfile?> loadProfile(String uid) async => _profiles[uid];

  @override
  Future<void> saveProfile(String uid, CloudProfile profile) async {
    _profiles[uid] = profile;
  }

  @override
  Future<Set<String>> loadSessionIds(String uid) async =>
      (_sessions[uid] ?? const {}).keys.toSet();

  @override
  Future<List<CloudSession>> loadSessions(String uid, {int limit = 100}) async {
    final all = (_sessions[uid] ?? const <String, CloudSession>{})
        .values
        .toList()
      ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    return all.take(limit).toList();
  }

  @override
  Future<void> uploadSessions(String uid, List<CloudSession> sessions) async {
    uploadCalls++;
    uploadedSessionCount += sessions.length;

    final bucket = _sessions.putIfAbsent(uid, () => {});
    for (final session in sessions) {
      bucket[session.id] = session;
    }
  }

  @override
  Future<void> deleteEverything(String uid) async {
    _profiles.remove(uid);
    _sessions.remove(uid);
  }
}
