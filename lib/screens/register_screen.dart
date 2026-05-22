import 'package:flutter/material.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _agreedToTerms = false;

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
                      const CustomTextField(label: "FULL NAME", hintText: "Enter your full name", prefixIcon: Icons.person_outline),
                      const CustomTextField(label: "EMAIL ADDRESS", hintText: "name@university.ac.id", prefixIcon: Icons.email_outlined),
                      const CustomTextField(label: "NIM (STUDENT ID)", hintText: "Enter your student ID", prefixIcon: Icons.badge_outlined),
                      const CustomTextField(label: "FACULTY", hintText: "e.g. Informatika", prefixIcon: Icons.account_balance_outlined),
                      const CustomTextField(label: "STUDY PROGRAM", hintText: "e.g. S1 Informatika", prefixIcon: Icons.school_outlined),
                      const CustomTextField(label: "PASSWORD", hintText: "Enter your password", prefixIcon: Icons.lock_outline, isPassword: true),
                      const CustomTextField(label: "CONFIRM PASSWORD", hintText: "Repeat your password", prefixIcon: Icons.autorenew, isPassword: true),

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
                      PrimaryButton(text: "Create Account", onPressed: () {}),
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