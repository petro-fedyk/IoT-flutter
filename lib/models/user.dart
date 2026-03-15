/// User model for Smart Home application.
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of User with some fields replaced.
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    int? age,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert User to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'age': age,
    'gender': gender,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Create User from JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() =>
      'User(id: $id, email: $email, name: $firstName $lastName)';
}

/// DTO for user registration (input data).
class UserCreateData {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final int age;
  final String gender;

  const UserCreateData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.age,
    required this.gender,
  });

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'password': password,
    'age': age,
    'gender': gender,
  };
}
