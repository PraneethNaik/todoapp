import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todolist/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _auth = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<User?> get user => _auth.user;

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signIn(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occured";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signUp(email, password);

      // logout after signup so user goes to login page
      await _auth.signOut();

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "An Unexpected error occured";
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
