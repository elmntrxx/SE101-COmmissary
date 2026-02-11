// lib/app.dart
import 'package:flutter/material.dart';
import 'services/supabase_auth_service.dart';
import 'screens/auth/auth_gate_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';

class CommissaryApp extends StatelessWidget {
  const CommissaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicken Joo Commissary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Montserrat',
      ),
      // Start with auth gate which waits for bootstrap to complete
      home: const AuthGateScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/auth-gate': (context) => const AuthGateScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final user = settings.arguments as UserData?;

          if (user == null) {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }

          return MaterialPageRoute(
            builder: (context) => HomeScreen(signedInUser: user),
          );
        }
        return null;
      },
    );
  }
}
