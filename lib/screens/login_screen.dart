import 'package:flutter/material.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _snack('Email dan password wajib diisi');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.login(email: email, password: password);

      // FCM: inisialisasi & kirim token ke backend.
      // Dibungkus try-catch terpisah agar error FCM tidak gagalkan login.
      try {
        await FcmService.instance.initialize();
        await FcmService.instance.registerToken();
      } catch (fcmErr) {
        debugPrint('[Login] FCM error (non-fatal): $fcmErr');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('Gagal terhubung ke server. Periksa koneksi & alamat server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const AuthHeader(subtitle: "Silahkan login untuk mengakses aplikasi"),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        label: "EMAIL ADDRESS",
                        hintText: "name@university.ac.id",
                        prefixIcon: Icons.email_outlined,
                      ),
                      CustomTextField(
                        controller: _passwordCtrl,
                        label: "PASSWORD",
                        hintText: "Enter your password",
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24, height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (val) => setState(() => _rememberMe = val!),
                                  activeColor: const Color(0xFFEA8000),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text("Remember me", style: TextStyle(color: Colors.black54, fontSize: 14)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _snack('Hubungi admin untuk reset password.'),
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(color: Color(0xFFEA8000), fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        text: "Sign In",
                        isLoading: _loading,
                        onPressed: _login,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Color(0xFFEA8000), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
