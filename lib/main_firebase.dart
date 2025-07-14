import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseOptions;
import 'package:flutter/foundation.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: _getFirebaseOptions(),
    );
  } catch (e) {
    // Firebase initialization failed, but app should still run
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const HakiYanguApp());
}

// Firebase options configuration
FirebaseOptions _getFirebaseOptions() {
  if (kIsWeb) {
    // Web configuration
    return const FirebaseOptions(
      apiKey: 'demo-api-key-web',
      appId: '1:123456789:web:abcdef123456',
      messagingSenderId: '123456789',
      projectId: 'haki-yangu-demo',
      authDomain: 'haki-yangu-demo.firebaseapp.com',
      storageBucket: 'haki-yangu-demo.appspot.com',
    );
  } else {
    // Android configuration
    return const FirebaseOptions(
      apiKey: 'demo-api-key-android',
      appId: '1:123456789:android:abcdef123456',
      messagingSenderId: '123456789',
      projectId: 'haki-yangu-demo',
      storageBucket: 'haki-yangu-demo.appspot.com',
    );
  }
}

class HakiYanguApp extends StatelessWidget {
  const HakiYanguApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haki Yangu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Green theme for civic app
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create animations
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Wait a bit then start progress animation
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();

    // Navigate after splash completes
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      await _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (mounted) {
      if (onboardingCompleted) {
        // User has completed onboarding, go to auth screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      } else {
        // First time user, show onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Logo Animation
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value.clamp(0.0, 1.0),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.balance,
                      size: 60,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // App Name
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoAnimation.value.clamp(0.0, 1.0),
                  child: const Text(
                    'HAKI YANGU',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Tagline
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoAnimation.value.clamp(0.0, 1.0),
                  child: const Text(
                    'Know. Protect. Defend.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              },
            ),

            const Spacer(flex: 2),

            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: _progressAnimation.value.clamp(0.0, 1.0)),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
