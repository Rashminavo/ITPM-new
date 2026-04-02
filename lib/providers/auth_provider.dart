import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  User? _currentUser;
  UserModel? _currentUserModel;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      _currentUserModel = await _authService.getUserProfile(user.uid);
      // Update FCM token on every login
      final token = await _notificationService.getToken();
      if (token != null) {
        await _authService.updateFcmToken(user.uid, token);
      }
    } else {
      _currentUserModel = null;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String faculty,
    required String hostel,
  }) async {
    _setLoading(true);
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        name: name,
        faculty: faculty,
        hostel: hostel,
      );
      _currentUserModel = user;
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.login(email, password);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    await _authService.updateProfile(_currentUser!.uid, data);
    _currentUserModel = await _authService.getUserProfile(_currentUser!.uid);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}