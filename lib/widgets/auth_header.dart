import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String subtitle;
  const AuthHeader({Key? key, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  Positioned(
                    top: 0, left: 0,
                    child: Container(width: 25, height: 25, color: const Color(0xFF1A1D20)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(width: 25, height: 25, color: const Color(0xFFFFC000)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
                children: [
                  TextSpan(text: 'PRO', style: TextStyle(color: Color(0xFF0F1419))),
                  TextSpan(text: 'DIGI', style: TextStyle(color: Color(0xFFFFC000), fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          "Inspire Through Creation.",
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 40),
        const Text(
          "DTC Mobile",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}