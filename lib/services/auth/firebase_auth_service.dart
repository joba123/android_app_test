import 'package:einstellungstest_trainer/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Anmeldung über Firebase Auth mit Google und Apple.
///
/// Beide Verfahren laufen nach demselben Muster: Der Anbieter liefert ein
/// Token, daraus wird ein Firebase-Credential gebaut, damit wird angemeldet.
/// Nur so entsteht **ein** Konto, egal über welchen Weg – und die Cloud-Daten
/// hängen an genau einer Kennung.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    fb.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  bool get isAvailable => true;

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAuthUser);

  @override
  Future<AuthUser> signIn(AuthProviderKind provider) async {
    final credential = switch (provider) {
      AuthProviderKind.google => await _googleCredential(),
      AuthProviderKind.apple => await _appleCredential(),
    };

    try {
      final result = await _auth.signInWithCredential(credential);
      final user = _toAuthUser(result.user);
      if (user == null) {
        throw const AuthFailure('Anmeldung lieferte kein Konto zurück');
      }
      return user;
    } on fb.FirebaseAuthException catch (error) {
      throw AuthFailure(_describe(error));
    }
  }

  Future<fb.AuthCredential> _googleCredential() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw const AuthFailure.cancelled();

      final authentication = await account.authentication;
      return fb.GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw AuthFailure('Google-Anmeldung fehlgeschlagen: $error');
    }
  }

  Future<fb.AuthCredential> _appleCredential() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.fullName],
      );

      return fb.OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const AuthFailure.cancelled();
      }
      throw AuthFailure('Apple-Anmeldung fehlgeschlagen: ${error.message}');
    } catch (error) {
      throw AuthFailure('Apple-Anmeldung fehlgeschlagen: $error');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
    } on fb.FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        throw const AuthFailure(
          'Aus Sicherheitsgründen ist für das Löschen eine erneute Anmeldung '
          'nötig. Melde dich ab, wieder an und versuche es dann noch einmal.',
        );
      }
      throw AuthFailure(_describe(error));
    } finally {
      await _googleSignIn.signOut();
    }
  }

  AuthUser? _toAuthUser(fb.User? user) {
    if (user == null) return null;

    final providerId = user.providerData.isEmpty
        ? ''
        : user.providerData.first.providerId;

    return AuthUser(
      uid: user.uid,
      provider: providerId.contains('apple')
          ? AuthProviderKind.apple
          : AuthProviderKind.google,
      displayName: user.displayName,
    );
  }

  String _describe(fb.FirebaseAuthException error) {
    return switch (error.code) {
      'network-request-failed' =>
        'Keine Verbindung. Prüfe deine Internetverbindung.',
      'account-exists-with-different-credential' =>
        'Für diese Adresse gibt es bereits ein Konto mit einem anderen '
            'Anmeldeverfahren.',
      'invalid-credential' => 'Die Anmeldedaten wurden abgelehnt.',
      _ => error.message ?? 'Anmeldung fehlgeschlagen (${error.code})',
    };
  }
}
