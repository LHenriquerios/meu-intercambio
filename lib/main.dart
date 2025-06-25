import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Intercâmbio',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFC107), // policeYellow
          secondary: Color(0xFFFFA000), // amarelo mais escuro
          surface: Colors.white,
          error: Colors.redAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFC107), // policeYellow
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFF5F5F5), // cardColor
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)), // borderColor
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFFFC107), // policeYellow
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107), // policeYellow
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFC107), // policeYellow
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true, // Opcional: habilita Material 3
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}