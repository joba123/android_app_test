/// Anmeldeverfahren, die die App anbietet.
enum AuthProviderKind {
  google(id: 'google', label: 'Mit Google anmelden'),
  apple(id: 'apple', label: 'Mit Apple anmelden');

  const AuthProviderKind({required this.id, required this.label});

  final String id;
  final String label;
}

/// Ein angemeldetes Konto – bewusst schmal gehalten.
///
/// Gespeichert wird nur, was die App wirklich braucht: die Kennung für die
/// Zuordnung der Cloud-Daten und optional ein Anzeigename für die Begrüßung.
/// Die E-Mail-Adresse wird nicht in die eigene Datenhaltung übernommen.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.provider,
    this.displayName,
  });

  final String uid;
  final AuthProviderKind provider;
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      other is AuthUser && other.uid == uid && other.provider == provider;

  @override
  int get hashCode => Object.hash(uid, provider);
}

/// Fehlschlag beim Anmelden.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.cancelled = false});

  /// Vom Nutzer abgebrochen – kein Grund, eine Fehlermeldung zu zeigen.
  const AuthFailure.cancelled()
      : message = 'Anmeldung abgebrochen',
        cancelled = true;

  final String message;
  final bool cancelled;

  @override
  String toString() => 'AuthFailure: $message';
}

/// Zugang zur Anmeldung.
///
/// Die Oberfläche kennt nur diese Schnittstelle. Dadurch bleibt die App ohne
/// Firebase-Konfiguration lauffähig und in Tests ohne Platform-Channels
/// prüfbar.
abstract class AuthService {
  /// `false`, wenn keine Firebase-Konfiguration vorliegt. Die Oberfläche
  /// blendet die Anmeldung dann aus, statt eine Schaltfläche anzubieten, die
  /// nur scheitern kann.
  bool get isAvailable;

  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();

  Future<AuthUser> signIn(AuthProviderKind provider);

  Future<void> signOut();

  /// Löscht das Konto beim Anbieter. Die Cloud-Daten räumt der Aufrufer
  /// vorher ab – siehe AccountController.
  Future<void> deleteAccount();
}

/// Auth im lokalen Modus: gibt es nicht.
///
/// Wird verwendet, solange keine Firebase-Konfiguration hinterlegt ist. Alle
/// Aufrufe scheitern kontrolliert statt mit einem Absturz.
class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  @override
  bool get isAvailable => false;

  @override
  AuthUser? get currentUser => null;

  @override
  // Ein Wert statt eines leeren Streams: Sonst bliebe der StreamProvider
  // dauerhaft im Ladezustand und die Oberflaeche wuerde nie fertig.
  Stream<AuthUser?> authStateChanges() => Stream.value(null);

  @override
  Future<AuthUser> signIn(AuthProviderKind provider) async {
    throw const AuthFailure(
      'Für diese App ist noch kein Firebase-Projekt hinterlegt. '
      'Der Fortschritt wird nur auf diesem Gerät gespeichert.',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}
}
