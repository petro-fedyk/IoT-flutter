import 'package:flutter/material.dart';
import 'package:lab1/controllers/connectivity_controller.dart';
import 'package:lab1/controllers/device_controller.dart';
import 'package:lab1/controllers/home_controller.dart';
import 'package:lab1/controllers/login_controller.dart';
import 'package:lab1/controllers/lock_controller.dart';
import 'package:lab1/controllers/power_station_controller.dart';
import 'package:lab1/controllers/registration_controller.dart';
import 'package:lab1/repositories/local_device_repository.dart';
import 'package:lab1/repositories/local_user_repository.dart';
import 'package:lab1/screens/edit_profile_screen.dart';
import 'package:lab1/screens/home_screen.dart';
import 'package:lab1/screens/login_screen.dart';
import 'package:lab1/screens/lock_screen.dart';
import 'package:lab1/screens/power_station_screen.dart';
import 'package:lab1/screens/profile_screen.dart';
import 'package:lab1/screens/register_screen.dart';
import 'package:lab1/screens/welcome_screen.dart';
import 'package:lab1/theme/theme_controller.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = LocalUserRepository();
  try {
    await repository.init();
  } catch (e) {
    debugPrint('Warning: repository.init() failed: $e');
  }

  final deviceRepo = LocalDeviceRepository();
  await deviceRepo.init();

  runApp(MyApp(repository: repository, deviceRepository: deviceRepo));
}

class MyApp extends StatelessWidget {
  final LocalUserRepository repository;
  final LocalDeviceRepository deviceRepository;

  const MyApp({
    required this.repository,
    required this.deviceRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalUserRepository>(create: (_) => repository),
        Provider<LocalDeviceRepository>(create: (_) => deviceRepository),
        ChangeNotifierProvider(
          create: (_) => LoginController(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistrationController(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeController(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => DeviceController(repo: deviceRepository),
        ),
        ChangeNotifierProvider(create: (_) => ConnectivityController()),
        ChangeNotifierProvider(
          create: (_) => LockController(
            apiUrl: 'http://192.168.31.114:5000/api/shafa_data/',
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PowerStationController(
            brokerHost: '192.168.10.216',
            topic: 'scada/lab3/test',
          ),
        ),
      ],
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Home',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF7FBFF),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeController.mode,
            initialRoute: '/welcome',
            routes: {
              '/welcome': (_) => const WelcomeScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const HomeScreen(),
              '/profile': (_) => const ProfileScreen(),
              '/profile/edit': (_) => const EditProfileScreen(),
              '/power-station': (_) => const PowerStationScreen(),
              '/lock': (_) => const LockScreen(),
            },
          );
        },
      ),
    );
  }
}
