import 'package:flutter/foundation.dart';

import 'package:lab1/models/user.dart';
import 'package:lab1/repositories/user_repository.dart';
import 'package:lab1/utils/exceptions.dart';

/// State enum for registration controller
enum RegistrationState { idle, loading, success, error }

/// RegistrationController manages user registration.
/// Handles registration, validation, and post-registration state.
class RegistrationController extends ChangeNotifier {
  final UserRepository _repository;

  RegistrationState _state = RegistrationState.idle;
  String _errorMessage = '';
  User? _registeredUser;

  RegistrationController({required UserRepository repository})
    : _repository = repository;

  // Getters
  RegistrationState get state => _state;
  String get errorMessage => _errorMessage;
  User? get registeredUser => _registeredUser;
  bool get isSuccess => _state == RegistrationState.success;

  /// Perform user registration
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required int age,
    required String gender,
  }) async {
    _state = RegistrationState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Validate inputs
      if (firstName.isEmpty || lastName.isEmpty) {
        throw ValidationException('Name fields cannot be empty');
      }
      if (!email.contains('@')) {
        throw ValidationException('Invalid email format');
      }
      if (password.length < 6) {
        throw ValidationException('Password must be at least 6 characters');
      }
      if (phone.isEmpty) {
        throw ValidationException('Phone number cannot be empty');
      }
      // Phone must start with +380 (Ukraine country code) for this app
      if (!phone.startsWith('+380')) {
        throw ValidationException('Phone number must start with +380');
      }
      if (age < 1 || age > 150) {
        throw ValidationException('Age must be between 1 and 150');
      }

      final createData = UserCreateData(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        age: age,
        gender: gender,
      );

      final user = await _repository.registerUser(createData);

      _registeredUser = user;
      _state = RegistrationState.success;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _state = RegistrationState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on EmailAlreadyExistsException catch (e) {
      _state = RegistrationState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = RegistrationState.error;
      _errorMessage = 'Registration failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Reset state after successful registration
  void resetState() {
    _state = RegistrationState.idle;
    _errorMessage = '';
    _registeredUser = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
