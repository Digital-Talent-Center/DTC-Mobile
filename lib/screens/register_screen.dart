import 'package:flutter/material.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();
  final _studyProgramCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _agreedToTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _nimCtrl.dispose();
    _facultyCtrl.dispose();
    _studyProgramCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      _snack('Nama, email, dan password wajib diisi');
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      _snack('Password dan konfirmasi tidak cocok');
      return;
    }
    if (!_agreedToTerms) {
      _snack('Harap setujui Terms of Service & Privacy Policy');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
        nim: _nimCtrl.text.trim(),
        faculty: _facultyCtrl.text.trim(),
        studyProgram: _studyProgramCtrl.text.trim(),
      );

      // FCM: inisialisasi & kirim token ke backend.
      // Dibungkus try-catch terpisah agar error FCM tidak gagalkan register.
      try {
        await FcmService.instance.initialize();
        await FcmService.instance.registerToken();
      } catch (fcmErr) {
        debugPrint('[Register] FCM error (non-fatal): $fcmErr');
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
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
                const AuthHeader(subtitle: "Silahkan registrasi untuk membuat akun"),

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
                      CustomTextField(controller: _nameCtrl, label: "FULL NAME", hintText: "Enter your full name", prefixIcon: Icons.person_outline),
                      CustomTextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, label: "EMAIL ADDRESS", hintText: "name@university.ac.id", prefixIcon: Icons.email_outlined),
                      CustomTextField(controller: _nimCtrl, keyboardType: TextInputType.number, label: "NIM (STUDENT ID)", hintText: "Enter your student ID", prefixIcon: Icons.badge_outlined),
                      CustomTextField(controller: _facultyCtrl, label: "FACULTY", hintText: "e.g. Informatika", prefixIcon: Icons.account_balance_outlined),
                      CustomTextField(controller: _studyProgramCtrl, label: "STUDY PROGRAM", hintText: "e.g. S1 Informatika", prefixIcon: Icons.school_outlined),
                      CustomTextField(controller: _passwordCtrl, label: "PASSWORD", hintText: "Min. 8 characters", prefixIcon: Icons.lock_outline, isPassword: true),
                      CustomTextField(controller: _confirmCtrl, label: "CONFIRM PASSWORD", hintText: "Repeat your password", prefixIcon: Icons.autorenew, isPassword: true),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (val) => setState(() => _agreedToTerms = val!),
                              activeColor: const Color(0xFFEA8000),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
                                children: [
                                  TextSpan(text: "I agree to the "),
                                  TextSpan(text: "Terms of Service\n", style: TextStyle(color: Color(0xFFEA8000), fontWeight: FontWeight.bold)),
                                  TextSpan(text: "and "),
                                  TextSpan(text: "Privacy Policy", style: TextStyle(color: Color(0xFFEA8000), fontWeight: FontWeight.bold)),
                                  TextSpan(text: "."),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(text: "Create Account", isLoading: _loading, onPressed: _register),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Sign In",
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
