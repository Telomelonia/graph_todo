import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Authentication service using Auth0 for user login/logout and token management.
///
/// This service handles:
/// - User authentication via Auth0
/// - Secure token storage using flutter_secure_storage
/// - Token refresh logic
/// - User profile management
class AuthService {
  final Auth0 auth0;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _accessTokenKey = 'auth0_access_token';
  static const String _refreshTokenKey = 'auth0_refresh_token';
  static const String _userIdKey = 'auth0_user_id';
  static const String _userNameKey = 'auth0_user_name';
  static const String _userEmailKey = 'auth0_user_email';

  AuthService({required this.auth0});

  /// Factory constructor to create AuthService with Auth0 configuration.
  ///
  /// You need to provide your Auth0 domain and client ID.
  /// Get these from your Auth0 dashboard: https://manage.auth0.com/
  ///
  /// Example:
  /// ```dart
  /// final authService = AuthService.create(
  ///   domain: 'your-tenant.auth0.com',
  ///   clientId: 'your-client-id',
  /// );
  /// ```
  factory AuthService.create({
    required String domain,
    required String clientId,
  }) {
    final auth0 = Auth0(domain, clientId);
    return AuthService(auth0: auth0);
  }

  /// Check if user is currently authenticated.
  Future<bool> isAuthenticated() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Get the current user's ID (Auth0 sub claim).
  /// Returns null if not authenticated.
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Get the current user's name.
  /// Returns null if not authenticated or name not available.
  Future<String?> getUserName() async {
    return await _secureStorage.read(key: _userNameKey);
  }

  /// Get the current user's email.
  /// Returns null if not authenticated or email not available.
  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: _userEmailKey);
  }

  /// Get the current access token for API calls.
  /// Returns null if not authenticated.
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Login with Auth0 using web authentication.
  /// Opens a browser for the user to authenticate.
  ///
  /// Throws an exception if login fails.
  Future<void> login() async {
    try {
      final credentials = await auth0
          .webAuthentication(scheme: 'graphtodo')
          .login();

      // Store tokens securely
      await _secureStorage.write(
        key: _accessTokenKey,
        value: credentials.accessToken,
      );

      if (credentials.refreshToken != null) {
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: credentials.refreshToken!,
        );
      }

      // Fetch and store user profile
      final user = credentials.user;

      await _secureStorage.write(
        key: _userIdKey,
        value: user.sub,
      );

      if (user.name != null) {
        await _secureStorage.write(
          key: _userNameKey,
          value: user.name!,
        );
      }

      if (user.email != null) {
        await _secureStorage.write(
          key: _userEmailKey,
          value: user.email!,
        );
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout from Auth0 and clear all stored credentials.
  /// Clears local session without browser redirect.
  Future<void> logout() async {
    try {
      // Clear all stored credentials locally
      // We don't need to call Auth0 logout endpoint for mobile apps
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userNameKey);
      await _secureStorage.delete(key: _userEmailKey);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Refresh the access token using the refresh token.
  ///
  /// Call this when you receive a 401 Unauthorized response.
  /// Throws an exception if refresh fails (user needs to login again).
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final credentials = await auth0
          .api
          .renewCredentials(refreshToken: refreshToken);

      // Update stored access token
      await _secureStorage.write(
        key: _accessTokenKey,
        value: credentials.accessToken,
      );

      // Update refresh token if provided
      if (credentials.refreshToken != null) {
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: credentials.refreshToken!,
        );
      }
    } catch (e) {
      // Refresh failed, clear tokens and force re-login
      await logout();
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Get user profile information.
  /// Returns null if not authenticated.
  Future<Map<String, String?>?> getUserProfile() async {
    final isAuth = await isAuthenticated();
    if (!isAuth) return null;

    return {
      'id': await getUserId(),
      'name': await getUserName(),
      'email': await getUserEmail(),
    };
  }
}
