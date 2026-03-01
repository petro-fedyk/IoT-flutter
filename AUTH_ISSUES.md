# Auth bug and fix

Issue:
- The Register screen previously validated inputs but did not persist the created user via repository/controller. That made login always fail with "User not found" because SharedPreferences had no user stored.

Fixes applied:
- `RegisterScreen` now calls `RegistrationController.register(...)` which persists the user via `LocalUserRepository.registerUser`.
- Email comparisons and stored password keys are normalized to lowercase in `LocalUserRepository` to avoid case-sensitivity mismatches.

Notes:
- Passwords are stored in SharedPreferences in plaintext for demonstration only. For production, migrate to hashed passwords and secure storage.
- Devices are stored per-user under `devices_<userId>` key in SharedPreferences.
