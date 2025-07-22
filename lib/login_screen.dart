import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'landing_page.dart';

class LoginScreen extends StatelessWidget {
  final auth = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Illustration
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/login_illustration.png',
              fit: BoxFit.cover,
            ),
          ),

          // Optional overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GetTogether',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Study smarter, together.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Google Sign-In Button
                    ElevatedButton.icon(
                      icon: Image.asset(
                        'lib/assets/images/google_icon.png',
                        height: 24,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () async {
                        print("🔵 Login button pressed");
                        final user = await auth.signInWithGoogle();
                        if (user != null) {
                          print("🟢 Login successful: ${user.email}");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LandingPage(uid: user.uid),
                            ),
                          );
                        } else {
                          print("🔴 Login failed");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black12),
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
    );
  }
}