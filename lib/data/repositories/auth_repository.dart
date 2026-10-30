import 'dart:convert';
import 'package:products_list/core/constants/api_constants.dart';
import 'package:products_list/core/network/api_client.dart';
import 'package:products_list/core/storage/secure_storage_service.dart';
import 'package:products_list/data/models/auth_response_model.dart';
import 'package:products_list/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepository({
    ApiClient? apiClient,
    SecureStorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? SecureStorageService();

  Future<AuthResponse> login({
    required String username,
    required String password,
    int expiresInMins = 30,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {
        'username': username,
        'password': password,
        'expiresInMins': expiresInMins,
      },
    );

    final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);

    // Store token and user details securely
    await _storageService.saveAuthData(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      userDataJson: jsonEncode(authResponse.user.toJson()),
    );

    return authResponse;
  }

  Future<User?> getSavedUser() async {
    final userJsonStr = await _storageService.getUserDataJson();
    if (userJsonStr != null && userJsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(userJsonStr) as Map<String, dynamic>;
        return User.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
