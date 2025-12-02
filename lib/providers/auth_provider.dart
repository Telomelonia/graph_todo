import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

/// Provider for authentication state management.
///
/// This provider wraps the AuthService and provides reactive state
/// updates for the UI when authentication state changes.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isAuthenticated = false;
  bool _isGuestMode = false;
  bool _isLoading = false;
  String? _error;
  Map<String, String?>? _userProfile;

  static const String _guestModeKey = 'guest_mode';

  AuthProvider({required AuthService authService})
      : _authService = authService {
    _checkAuthStatus();
  }

  /// Whether the user is currently authenticated (includes guest mode).
  bool get isAuthenticated => _isAuthenticated || _isGuestMode;

  /// Whether the user is in guest mode.
  bool get isGuestMode => _isGuestMode;

  /// Whether an auth operation is in progress.
  bool get isLoading => _isLoading;

  /// Error message from the last auth operation, if any.
  String? get error => _error;

  /// User profile information (id, name, email).
  Map<String, String?>? get userProfile => _userProfile;

  /// User's ID (Auth0 sub claim).
  String? get userId => _userProfile?['id'];

  /// User's name.
  String? get userName => _isGuestMode ? 'Guest' : _userProfile?['name'];

  /// User's email.
  String? get userEmail => _userProfile?['email'];

  /// Whether cloud sync is configured in the app.
  bool get isCloudSyncConfigured => AppConfig.isCloudSyncConfigured;

  /// Get configuration status message.
  String get configStatus => AppConfig.getSetupStatus();

  /// Check authentication status on initialization.
  Future<void> _checkAuthStatus() async {
    try {
      // Check for guest mode first
      final prefs = await SharedPreferences.getInstance();
      _isGuestMode = prefs.getBool(_guestModeKey) ?? false;

      // Check Auth0 authentication
      _isAuthenticated = await _authService.isAuthenticated();
      if (_isAuthenticated) {
        _userProfile = await _authService.getUserProfile();
        // If authenticated with Auth0, clear guest mode
        _isGuestMode = false;
        await prefs.setBool(_guestModeKey, false);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to check auth status: $e';
      notifyListeners();
    }
  }

  /// Login with Auth0.
  ///
  /// Returns true if login was successful, false otherwise.
  Future<bool> login() async {
    if (!AppConfig.isAuth0Configured) {
      _error = 'Auth0 is not configured. Please update app_config.dart';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login();
      _isAuthenticated = true;
      _userProfile = await _authService.getUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Continue as guest (local storage only).
  ///
  /// This allows users to use the app without authentication.
  /// Data is stored locally and won't sync to cloud.
  Future<void> continueAsGuest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, true);
      _isGuestMode = true;
      _isAuthenticated = false;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to enable guest mode: $e';
      notifyListeners();
    }
  }

  /// Logout from Auth0 or exit guest mode.
  ///
  /// Returns true if logout was successful, false otherwise.
  Future<bool> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Always clear guest mode flag in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, false);

      if (_isGuestMode) {
        // Exit guest mode
        _isGuestMode = false;
      } else {
        // Logout from Auth0
        await _authService.logout();
        _isAuthenticated = false;
        _userProfile = null;
      }

      // Ensure both states are cleared
      _isGuestMode = false;
      _isAuthenticated = false;
      _userProfile = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh the access token.
  ///
  /// Call this if you get a 401 Unauthorized error.
  /// Returns true if refresh was successful, false otherwise.
  Future<bool> refreshToken() async {
    try {
      await _authService.refreshToken();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Token refresh failed: $e';
      _isAuthenticated = false;
      _userProfile = null;
      notifyListeners();
      return false;
    }
  }

  /// Clear any error messages.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
