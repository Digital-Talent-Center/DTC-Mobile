import 'package:flutter/material.dart';
// Import halaman login yang sudah dibuat di folder screens
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DTC Mobile',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "debug" di pojok kanan atas
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        primaryColor: const Color(0xFFEA8000),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFEA8000),
        ),
        // Kamu juga bisa setting Global Font di sini jika pakai package google_fonts
      ),
      home: const LoginScreen(), // Set halaman pertama yang muncul adalah Login
    );
  }
}