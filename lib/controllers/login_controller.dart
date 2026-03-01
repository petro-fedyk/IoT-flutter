import 'package:flutter/foundation.dart';

import 'package:lab1/models/user.dart';
import 'package:lab1/repositories/user_repository.dart';
import 'package:lab1/utils/exceptions.dart';

/// State enum for login controller
enum LoginState { idle, loading, success, error }

/// LoginController manages user authentication.
/// Handles login, logout, and tracks current user state.
class LoginController extends ChangeNotifier {
  final UserRepository _repository;

  LoginState _state = LoginState.idle;
  String _errorMessage = '';
  User? _currentUser;

  LoginController({required UserRepository repository})
    : _repository = repository {
    _initialize();
  }

  // Getters
  LoginState get state => _state;
  String get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Initialize by loading current user if already logged in
  Future<void> _initialize() async {
    try {
      final user = await _repository.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user session';
    }
  }

  /// Perform login with email and password
  Future<bool> login({required String email, required String password}) async {
    _state = LoginState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _repository.loginUser(
        email: email,
        password: password,
      );

      if (user == null) {
        _state = LoginState.error;
        _errorMessage = 'Login failed. Please check your credentials.';
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _state = LoginState.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _state = LoginState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = LoginState.error;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  /// Perform logout
  Future<void> logout() async {
    try {
      _state = LoginState.loading;
      notifyListeners();

      await _repository.clearAll();
      _currentUser = null;
      _state = LoginState.idle;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _state = LoginState.error;
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Watch for changes to current user
  Stream<User?> watchCurrentUser() => _repository.watchCurrentUser();
}
