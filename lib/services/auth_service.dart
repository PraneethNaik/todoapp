import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth state
  Stream<User?> get user => _auth.authStateChanges();

  // SIGN IN
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // SIGN UP
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
