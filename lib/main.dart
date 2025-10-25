import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'closet_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capsule Closet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/closet': (context) => const ClosetScreen(),
      },
    );
  }
}

// Remove the MyHomePage and _MyHomePageState classes as they are no longer needed
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   // ... rest of the class
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   // ... rest of the class
// }