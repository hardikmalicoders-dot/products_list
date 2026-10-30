import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';

  // Save tokens and user data
  Future<void> saveAuthData({
    required String accessToken,
    String? refreshToken,
    String? userDataJson,
  }) async {
    try {
      await _storage.write(key: _keyAccessToken, value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: _keyRefreshToken, value: refreshToken);
      }
      if (userDataJson != null) {
        await _storage.write(key: _keyUserData, value: userDataJson);
      }
    } catch (e) {
      // Fallback in memory or log error if secure storage fails
    }
  }

  // Get Access Token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (e) {
      return null;
    }
  }

  // Get Refresh Token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      return null;
    }
  }

  // Get Saved User Data JSON
  Future<String?> getUserDataJson() async {
    try {
      return await _storage.read(key: _keyUserData);
    } catch (e) {
      return null;
    }
  }

  // Clear all stored data (Logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      // Delete individually if deleteAll fails
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyUserData);
    }
  }
}
