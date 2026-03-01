import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lab1/repositories/local_user_repository.dart';
import 'package:lab1/models/user.dart';

void main() {
  late LocalUserRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = LocalUserRepository();
    await repo.init();
  });

  test('register -> login -> update -> delete user', () async {
    final create = UserCreateData(
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phone: '+380501234567',
      password: 'password',
      age: 30,
      gender: 'other',
    );

    final user = await repo.registerUser(create);
    expect(user.email, 'test@example.com');

    // Login with correct credentials
    final logged = await repo.loginUser(
      email: 'test@example.com',
      password: 'password',
    );
    expect(logged, isNotNull);
    expect(logged!.email, 'test@example.com');

    // Login with wrong password -> should throw
    try {
      await repo.loginUser(email: 'test@example.com', password: 'badpass');
      fail('Expected login with wrong password to throw');
    } catch (e) {
      expect(e, isA<Exception>());
    }

    // Update profile
    final updated = user.copyWith(firstName: 'Changed');
    await repo.updateUserData(updated);
    final current = await repo.getCurrentUser();
    expect(current?.firstName, 'Changed');

    // Delete user
    await repo.deleteUserData(user.id);
    final after = await repo.getCurrentUser();
    expect(after, isNull);
  });
}
