import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lara_app/eula_page.dart';
import 'eula_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image Layer
          Positioned.fill(
            child: Image.asset('assets/road_bg.jpg', fit: BoxFit.cover),
          ),
          // 2. Gradient Overlay - Fixed the empty decoration
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xFF2F3953).withValues(alpha: 0.3),
                    const Color(0xFF326C7E).withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          // 3. Glassmorphic Card
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  //logo
                  Container(
                    height: 140,
                    width: 140,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Image(image: AssetImage('assets/lara_logo.png')),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Frosted Glass Rectangle
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 334,
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInput("Username"),
                            const SizedBox(height: 16),
                            _buildInput("Password", isPassword: true),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFFF4E7C6),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildGoldButton("Sign In"),
                            const SizedBox(height: 20),
                            const Text(
                              "or",
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialIcon('assets/google.png'),
                                const SizedBox(width: 15),
                                _socialIcon('assets/facebook.png'),
                                const SizedBox(width: 15),
                                _socialIcon('assets/apple.png'),
                              ],
                            ),
                            const SizedBox(height: 24),

                            //  navigate to registration page
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EulaPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Dont have account? Sign up",
                                style: TextStyle(
                                  color: Color(0xFFF4E7C6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String hint, {bool isPassword = false}) {
    return Container(
      width: 304,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFFF).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: InputBorder.none,
          suffixIcon: isPassword ? const Icon(Icons.visibility_outlined) : null,
        ),
      ),
    );
  }

  Widget _buildGoldButton(String text) {
    return Container(
      width: 92,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFE0B240),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF050B1A),
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(String path) {
    return Container(
      width: 52,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0B240), width: 1.5),
      ),
      child: Center(child: Image.asset(path, width: 24)),
    );
  }
}
