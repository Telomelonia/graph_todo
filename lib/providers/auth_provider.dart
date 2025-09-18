import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      final user = await _firebaseService.signInWithEmailPassword(email, password);
      if (user == null) {
        throw Exception('Sign in failed');
      }
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<void> createUserWithEmailPassword(String email, String password) async {
    try {
      final user = await _firebaseService.createUserWithEmailPassword(email, password);
      if (user == null) {
        throw Exception('Account creation failed');
      }
    } catch (e) {
      throw Exception('Failed to create account: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
}