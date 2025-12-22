import 'package:capsule_closet_app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart'; // This is now the main screen after login
import 'services/auth_service.dart';
import 'services/data_service.dart';
import 'services/ai_service.dart';
import 'services/weather_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
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