import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/session.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';
import 'services/fcm_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi data locale Indonesia untuk format tanggal (DateFormat 'id_ID').
  await initializeDateFormatting('id_ID', null);
  // Inisialisasi Firebase sebelum app tampil.
  await Firebase.initializeApp();
  // Muat sesi login tersimpan (token Sanctum) sebelum app tampil.
  await Session.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FcmService.navigatorKey,
      title: 'DTC Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        primaryColor: const Color(0xFFEA8000),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFEA8000),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

/// Menentukan layar awal dengan aman:
/// - Tidak ada token → Login.
/// - Ada token → verifikasi & SEGARKAN data user ke server (/auth/me).
///   Jika token tidak valid/kedaluwarsa, sesi dibersihkan → Login.
/// Ini mencegah data akun lama yang ter-cache tetap tampil.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checking = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    if (!Session.instance.isLoggedIn) {
      setState(() {
        _checking = false;
        _authed = false;
      });
      return;
    }
    try {
      final user = await AuthService.instance.me();
      if (user == null) await Session.instance.clear();
      if (!mounted) return;
      if (user != null) {
        // Inisialisasi FCM dan pastikan token tersinkron ke backend
        // setiap kali app restart dengan sesi aktif.
        FcmService.instance.initialize().then((_) {
          FcmService.instance.registerToken();
        });
      }
      setState(() {
        _checking = false;
        _authed = user != null;
      });
    } on ApiException catch (e) {
      // 401 = token tidak valid/kedaluwarsa → bersihkan sesi.
      // Error lain (mis. server down) → tetap pakai sesi cache.
      final invalid = e.statusCode == 401;
      if (invalid) await Session.instance.clear();
      if (!mounted) return;
      setState(() {
        _checking = false;
        _authed = !invalid;
      });
    } catch (_) {
      // Gangguan jaringan → jangan paksa logout, pakai sesi cache.
      FcmService.instance.initialize().then((_) {
        FcmService.instance.registerToken();
      });
      if (!mounted) return;
      setState(() {
        _checking = false;
        _authed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFEA8000))),
      );
    }
    return _authed ? const DashboardScreen() : const LoginScreen();
  }
}
