import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sincroniza el usuario Firebase a la tabla users de Supabase.
  Future<void> _upsertUser(User user) async {
    try {
      await Supabase.instance.client.from('users').upsert({
        'id': user.uid,
        'email': user.email,
        'display_name': user.displayName,
        'last_login': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (_) {
      // No bloquear el login si falla la sincronización
    }
  }

  /// Inicia sesión con email y contraseña.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) await _upsertUser(cred.user!);
    return cred;
  }

  /// Crea una cuenta nueva con email y contraseña.
  Future<UserCredential> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) await _upsertUser(cred.user!);
    return cred;
  }

  /// Envía email de recuperación de contraseña.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Inicia sesión con Google usando Firebase Auth.
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    if (cred.user != null) await _upsertUser(cred.user!);
    return cred;
  }

  /// Cierra sesión en Firebase y Google.
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }
}
