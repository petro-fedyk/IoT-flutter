import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lab1/models/user.dart';
import 'package:lab1/repositories/user_repository.dart';
import 'package:lab1/utils/exceptions.dart';

/// HomeController manages home/profile operations.
/// Handles user profile updates, deletions, and streams current user data.
class HomeController extends ChangeNotifier {
  final UserRepository _repository;

  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  HomeController({required UserRepository repository})
    : _repository = repository {
    _initialize();
    // Listen to repository current user stream so controller updates when
    // user logs in/out from other controllers (login/registration).
    _userSub = _repository.watchCurrentUser().listen((u) {
      _currentUser = u;
      notifyListeners();
    });
  }

  StreamSubscription<User?>? _userSub;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasUser => _currentUser != null;

  /// Initialize by loading current user
  Future<void> _initialize() async {
    try {
      final user = await _repository.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user data';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required int age,
    required String gender,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (firstName.isEmpty || lastName.isEmpty) {
        throw ValidationException('Name fields cannot be empty');
      }
      if (phone.isEmpty) {
        throw ValidationException('Phone cannot be empty');
      }
      // Phone must start with +380 (Ukraine country code)
      if (!phone.startsWith('+380')) {
        throw ValidationException('Phone number must start with +380');
      }

      final updatedUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        age: age,
        gender: gender,
      );

      await _repository.updateUserData(updatedUser);

      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.deleteUserData(userId);
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete account: $e';
      notifyListeners();
      return false;
    }
  }

  /// Watch for changes to current user
  Stream<User?> watchCurrentUser() => _repository.watchCurrentUser();

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Reload user data from storage
  Future<void> reloadUser() async {
    try {
      final user = await _repository.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reload user data';
      notifyListeners();
    }
  }
}
