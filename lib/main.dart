import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };

  // Handle platform dispatcher errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('Platform Error: $error');
      print('Stack trace: $stack');
    }
    return true;
  };

  try {
    if (kIsWeb) {
      // For web, Firebase is already initialized in index.html
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCoICMUV2znczj0xRJ5hclRIg0h8EhntsM",
          authDomain: "haki-yangu.firebaseapp.com",
          projectId: "haki-yangu",
          storageBucket: "haki-yangu.firebasestorage.app",
          messagingSenderId: "585197775156",
          appId: "1:585197775156:web:e026f30415bf65561a5d61",
        ),
      );
    } else {
      // For mobile platforms, use default initialization
      await Firebase.initializeApp();
    }

    if (kDebugMode) {
      print('Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
      print('Continuing without Firebase...');
    }
    // Continue running the app even if Firebase fails to initialize
    // This prevents the app from crashing completely
  }

  // Wrap the app in error handling
  runApp(const HakiYanguApp());
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
        // Better web support
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Small delay to ensure Firebase is properly initialized
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if Firebase is initialized
      try {
        if (Firebase.apps.isNotEmpty) {
          if (kDebugMode) {
            print('Firebase apps found: ${Firebase.apps.length}');
          }
        } else {
          if (kDebugMode) {
            print('No Firebase apps found, but continuing...');
          }
        }
      } catch (firebaseError) {
        if (kDebugMode) {
          print('Firebase check error: $firebaseError');
        }
        // Firebase not available, but app can still function
      }

      // Always continue - Firebase is not critical for basic app functionality
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('App initialization error: $e');
      }
      // Always continue with the app even if there are initialization issues
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1B5E20),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isInitialized = false;
                  });
                  _initializeApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1B5E20),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const SplashScreen();
    }

    return const SplashScreen();
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
    try {
      // Get onboarding status
      SharedPreferences? prefs;
      bool onboardingCompleted = false;

      try {
        prefs = await SharedPreferences.getInstance();
        onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      } catch (e) {
        if (kDebugMode) {
          print('Error accessing SharedPreferences: $e');
        }
        // Default to false if we can't access preferences
        onboardingCompleted = false;
      }

      // Check Firebase auth status
      User? user;
      try {
        if (Firebase.apps.isNotEmpty) {
          user = FirebaseAuth.instance.currentUser;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting current user: $e');
        }
        user = null;
      }

      if (mounted) {
        if (user != null) {
          // User is already signed in, go to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else if (onboardingCompleted) {
          // User has completed onboarding but not signed in, go to auth screen
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
    } catch (e) {
      if (kDebugMode) {
        print('Error in navigation: $e');
      }
      // Fallback to onboarding screen
      if (mounted) {
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                          width: kIsWeb ? 100 : 120,
                          height: kIsWeb ? 100 : 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.balance,
                            size: kIsWeb ? 50 : 60,
                            color: const Color(0xFF1B5E20),
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
                        child: Text(
                          'HAKI YANGU',
                          style: TextStyle(
                            fontSize: kIsWeb ? 28 : 32,
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
                    padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 100 : 50),
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
                            Opacity(
                              opacity: _progressAnimation.value.clamp(0.0, 1.0),
                              child: const Text(
                                'Loading...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
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
          ),
        ),
      ),
    );
  }
}
