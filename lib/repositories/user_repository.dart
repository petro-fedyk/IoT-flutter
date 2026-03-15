import 'package:lab1/models/user.dart';

/// Abstract repository for user operations.
/// UI and controllers depend on this interface, not on concrete
/// implementations.
abstract class UserRepository {
  /// Register a new user.
  /// Throws [EmailAlreadyExistsException] if email exists.
  /// Throws [ValidationException] if data is invalid.
  /// Throws [StorageException] if storage operation fails.
  Future<User> registerUser(UserCreateData data);

  /// Authenticate user with login and password.
  /// Returns the logged-in user.
  /// Returns null if user not found or credentials are invalid.
  /// Throws [StorageException] if storage operation fails.
  Future<User?> loginUser({required String email, required String password});

  /// Get currently logged-in user (if any).
  /// Returns null if no user is logged in.
  Future<User?> getCurrentUser();

  /// Update user profile data.
  /// Throws [UserNotFoundException] if user does not exist.
  /// Throws [StorageException] if storage operation fails.
  Future<void> updateUserData(User user);

  /// Delete a user and clear session.
  /// Throws [UserNotFoundException] if user does not exist.
  /// Throws [StorageException] if storage operation fails.
  Future<void> deleteUserData(String userId);

  /// Watch for changes to the current user.
  /// Emits updates whenever user data changes.
  /// Emits null if no user is logged in.
  Stream<User?> watchCurrentUser();

  /// Clear all stored data (useful for testing or logout with cleanup).
  Future<void> clearAll();
}
