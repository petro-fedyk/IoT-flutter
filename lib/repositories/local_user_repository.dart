import 'dart:async';
import 'dart:convert';

import 'package:lab1/models/user.dart';
import 'package:lab1/repositories/user_repository.dart';
import 'package:lab1/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LocalUserRepository implementation using SharedPreferences.
/// Stores user data locally with simple key-value storage.
class LocalUserRepository implements UserRepository {
  late final SharedPreferences _prefs;
  final _currentUserController = StreamController<User?>.broadcast();

  // Storage keys
  static const String _usersKey = 'users'; // JSON array of users
  static const String _currentUserIdKey = 'currentUserId';

  /// Initialize the repository (must be called before use).
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Emit initial current user state
    await _emitCurrentUser();
  }

  @override
  Future<User> registerUser(UserCreateData data) async {
    try {
      // Validate inputs
      if (data.firstName.isEmpty || data.lastName.isEmpty) {
        throw ValidationException('Name fields cannot be empty');
      }
      if (!data.email.contains('@')) {
        throw ValidationException('Invalid email format');
      }
      if (data.password.length < 6) {
        throw ValidationException('Password must be at least 6 characters');
      }
      // Phone must start with +380 for this app
      if (data.phone.isEmpty) {
        throw ValidationException('Phone number cannot be empty');
      }
      if (!data.phone.startsWith('+380')) {
        throw ValidationException('Phone number must start with +380');
      }

      // Check if email already exists (case-insensitive)
      final users = _getAllUsers();
      if (users.any((u) => u.email.toLowerCase() == data.email.toLowerCase())) {
        throw EmailAlreadyExistsException(
          'Email ${data.email} is already registered',
        );
      }

      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: data.firstName,
        lastName: data.lastName,
        email: data.email,
        phone: data.phone,
        age: data.age,
        gender: data.gender,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store user (password stored as-is for demo; in production use hashing)
      users.add(newUser);
      await _saveUsers(users);

      // Store password for demo authentication (keyed by lowercase email)
      await _storePassword(data.email.toLowerCase(), data.password);

      // Auto-login after registration
      await _setCurrentUserId(newUser.id);
      _currentUserController.add(newUser);

      return newUser;
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw StorageException('Failed to register user: $e');
    }
  }

  @override
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final users = _getAllUsers();

      // Find user by email (case-insensitive)
      User? user;
      try {
        user = users.firstWhere(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
        );
      } catch (e) {
        throw AuthException('User not found');
      }

      // For demo: simple password check (in production use proper hashing/comparison)
      final storedPassword = _getStoredPassword(email.toLowerCase());
      if (storedPassword != password) {
        throw AuthException('Invalid password');
      }

      // Set current user
      await _setCurrentUserId(user.id);
      _currentUserController.add(user);

      return user;
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw StorageException('Login failed: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userId = _prefs.getString(_currentUserIdKey);
      if (userId == null) return null;

      final users = _getAllUsers();
      return users.firstWhereOrNull((u) => u.id == userId);
    } catch (e) {
      throw StorageException('Failed to get current user: $e');
    }
  }

  @override
  Future<void> updateUserData(User user) async {
    try {
      final users = _getAllUsers();
      final index = users.indexWhere((u) => u.id == user.id);

      if (index == -1) {
        throw UserNotFoundException('User ${user.id} not found');
      }

      // Update user with new timestamp
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      users[index] = updatedUser;
      await _saveUsers(users);

      // Update stream if this is the current user
      final currentUserId = _prefs.getString(_currentUserIdKey);
      if (currentUserId == user.id) {
        _currentUserController.add(updatedUser);
      }
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw StorageException('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUserData(String userId) async {
    try {
      final users = _getAllUsers();
      users.removeWhere((u) => u.id == userId);
      await _saveUsers(users);

      // Clear current user if deleted
      final currentUserId = _prefs.getString(_currentUserIdKey);
      if (currentUserId == userId) {
        await _setCurrentUserId(null);
        _currentUserController.add(null);
      }

      // Also clear stored password (if we can find the deleted user's email)
      final deletedUserEmail = users
          .firstWhereOrNull((u) => u.id == userId)
          ?.email;
      if (deletedUserEmail != null) {
        await _prefs.remove('password_$deletedUserEmail');
      }
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw StorageException('Failed to delete user: $e');
    }
  }

  @override
  Stream<User?> watchCurrentUser() => _currentUserController.stream;

  @override
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
      _currentUserController.add(null);
    } catch (e) {
      throw StorageException('Failed to clear storage: $e');
    }
  }

  /// Private helper: Emit current user to stream
  Future<void> _emitCurrentUser() async {
    final currentUser = await getCurrentUser();
    _currentUserController.add(currentUser);
  }

  /// Private helper: Get all users from storage
  List<User> _getAllUsers() {
    final usersJson = _prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) return [];

    try {
      final list = jsonDecode(usersJson) as List;
      return list
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Private helper: Save all users to storage
  Future<void> _saveUsers(List<User> users) async {
    final json = jsonEncode(users.map((u) => u.toJson()).toList());
    await _prefs.setString(_usersKey, json);

    // Also store password separately for each user (in production, hash this!)
    // This is done in registerUser/loginUser caller context
  }

  /// Private helper: Set current user ID
  Future<void> _setCurrentUserId(String? userId) async {
    if (userId == null) {
      await _prefs.remove(_currentUserIdKey);
    } else {
      await _prefs.setString(_currentUserIdKey, userId);
    }
  }

  /// Private helper: Get stored password (demo only!)
  String? _getStoredPassword(String email) {
    return _prefs.getString('password_$email');
  }

  /// Store password after login/registration (demo only!)
  Future<void> _storePassword(String email, String password) async {
    await _prefs.setString('password_$email', password);
  }

  /// Dispose resources
  void dispose() {
    _currentUserController.close();
  }
}

/// Extension helper for firstWhereOrNull
extension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}
