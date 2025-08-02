import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_sahara_program/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();
  User? _user;
  String? errorMessage;

  User? get user => _user;

  AuthProvider() {
    _user = _authService.currentUser;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name, String city,
      String dob, String phoneNo, userType) async {
    _user = await _authService.signUpWithEmail(
        email, password, name, city, dob, phoneNo, userType);
    notifyListeners();
  }

  Future<User?> signIn(String email, String password) async {
    try {
      _user = await _authService.signInWithEmail(email, password);
      errorMessage = null; // Reset error message if successful
      notifyListeners();
      return _user;
    } catch (e) {
      errorMessage = e.toString(); // Set error message on failure
      notifyListeners();
      return null;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}

