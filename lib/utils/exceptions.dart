/// Base exception for repository operations.
abstract class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => message;
}

/// Thrown when user is not found.
class UserNotFoundException extends RepositoryException {
  UserNotFoundException(super.message);
}

/// Thrown when email already exists during registration.
class EmailAlreadyExistsException extends RepositoryException {
  EmailAlreadyExistsException(super.message);
}

/// Thrown when authentication fails (wrong password, etc).
class AuthException extends RepositoryException {
  AuthException(super.message);
}

/// Thrown when storage operation fails.
class StorageException extends RepositoryException {
  StorageException(super.message);
}

/// Thrown when validation fails.
class ValidationException extends RepositoryException {
  ValidationException(super.message);
}
