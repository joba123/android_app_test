import 'package:firebase_core/firebase_core.dart';

/// Platzhalter für die von der FlutterFire CLI erzeugte Konfiguration.
///
/// Solange hier keine echten Werte stehen, startet die App im **lokalen
/// Modus**: Sie funktioniert vollständig, nur Login und Cloud-Sync sind
/// deaktiviert.
///
/// Ersetzt wird diese Datei durch:
///
/// ```bash
/// dart pub global activate flutterfire_cli
/// flutterfire configure --project=<projekt-id>
/// ```
///
/// Beim Anlegen des Firebase-Projekts unbedingt beachten:
///
/// * **Firestore-Region auf Europa setzen** (`eur3` oder `europe-west3`).
///   Die Wahl ist endgültig und lässt sich nur durch ein neues Projekt ändern.
/// * SHA-1-Fingerprint des Signaturschlüssels in der Firebase-Konsole
///   hinterlegen, sonst schlägt Google Sign-In auf Android fehl.
/// * Für Apple Sign-In werden eine Apple-Developer-Mitgliedschaft, eine
///   Service ID und ein Auth-Key benötigt.
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase ist für dieses Projekt noch nicht konfiguriert. '
      'Führe "flutterfire configure" aus, um lib/firebase_options.dart zu '
      'erzeugen. Bis dahin läuft die App im lokalen Modus.',
    );
  }
}
