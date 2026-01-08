import 'package:capsule_closet_app/services/ai_service.dart';
import 'package:capsule_closet_app/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capsule_closet_app/screens/login_screen.dart';
import 'package:capsule_closet_app/screens/main_navigation_screen.dart';
import 'package:capsule_closet_app/services/auth_service.dart';
import 'package:capsule_closet_app/services/data_service.dart';
import 'package:capsule_closet_app/services/theme_service.dart';
import 'package:capsule_closet_app/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  // Note: Run 'flutterfire configure' to generate the correct firebase_options.dart
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue running app even if Firebase fails (for dev without config)
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, DataService>(
          create: (context) => DataService(null),
          update: (context, auth, previous) => DataService(auth),
        ),
        ChangeNotifierProvider(create: (_) => AIService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        Provider(create: (_) => WeatherService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Capsule Closet',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const LoginScreen(),
              '/closet': (context) =>
                  const MainNavigationScreen(), // Now goes to the main navigation screen
            },
          );
        },
      ),
    );
  }
}
