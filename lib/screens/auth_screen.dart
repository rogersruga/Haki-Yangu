import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.balance,
                  size: 50,
                  color: Color(0xFF1B5E20),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // App name
              const Text(
                'HAKI YANGU',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Tagline
              const Text(
                'Know. Protect. Defend.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Sign Up button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to sign up screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sign Up functionality will be implemented next'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Login button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to login screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login functionality will be implemented next'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Terms and privacy
              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
