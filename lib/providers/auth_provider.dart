import 'package:flutter/foundation.dart';
import 'package:products_list/data/models/user_model.dart';
import 'package:products_list/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  String? _accessToken;
  String? get accessToken => _accessToken;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  // Check saved session on startup
  Future<void> checkAuthStatus() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final token = await _authRepository.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final savedUser = await _authRepository.getSavedUser();
        _accessToken = token;
        _user = savedUser;
      }
    } catch (_) {
      _accessToken = null;
      _user = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // Perform login
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authRepository.login(
        username: username,
        password: password,
      );

      _user = authResponse.user;
      _accessToken = authResponse.accessToken;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _authRepository.logout();
    _accessToken = null;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
