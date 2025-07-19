import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';
import 'offline_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  final FirestoreService _firestoreService = FirestoreService();
  final OfflineService _offlineService = OfflineService();

  // Lazy initialization with error handling
  FirebaseAuth get auth {
    try {
      _auth ??= FirebaseAuth.instance;
      return _auth!;
    } catch (e) {
      if (kDebugMode) {
        print('Error accessing FirebaseAuth: $e');
      }
      rethrow;
    }
  }

  GoogleSignIn get googleSignIn {
    try {
      if (_googleSignIn == null) {
        _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
          // Add explicit configuration for better compatibility
          signInOption: SignInOption.standard,
        );

        if (kDebugMode) {
          print('🔵 GoogleSignIn instance created');
        }
      }
      return _googleSignIn!;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error accessing GoogleSignIn: $e');
      }
      rethrow;
    }
  }

  // Get current user
  User? get currentUser {
    try {
      return auth.currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user: $e');
      }
      return null;
    }
  }

  // Auth state stream
  Stream<User?> get authStateChanges {
    try {
      return auth.authStateChanges();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth state changes: $e');
      }
      return Stream.value(null);
    }
  }

  // Check if user is signed in
  bool get isSignedIn {
    try {
      return auth.currentUser != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking sign in status: $e');
      }
      return false;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(displayName);
      await result.user?.reload();

      // Create user profile in Firestore
      if (result.user != null) {
        await _createUserProfileInFirestore(result.user!, displayName);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time in Firestore
      if (result.user != null) {
        await _updateUserLastLogin(result.user!);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Check Google Play Services availability
  Future<bool> isGooglePlayServicesAvailable() async {
    try {
      if (kDebugMode) {
        print('🔵 Checking Google Play Services availability...');
      }

      // Try multiple checks to ensure Google Play Services is available

      // 1. Check if GoogleSignIn can be initialized
      final GoogleSignIn testSignIn = GoogleSignIn(
        scopes: ['email'],
        signInOption: SignInOption.standard,
      );

      // 2. Try to check sign-in status (this will fail if Google Play Services is not available)
      final bool isSignedIn = await testSignIn.isSignedIn();

      if (kDebugMode) {
        print('🔵 Google Sign-In status check: $isSignedIn');
      }

      // 3. Try to get the current user (this is another way to test availability)
      final GoogleSignInAccount? currentUser = testSignIn.currentUser;

      if (kDebugMode) {
        print('🔵 Current Google user: ${currentUser?.email ?? 'none'}');
      }

      if (kDebugMode) {
        print('🟢 Google Play Services check completed successfully');
      }

      return true; // If we get here, services are available
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Google Play Services not available: $e');
        print('🔴 Error type: ${e.runtimeType}');
      }

      // Check for specific error types that indicate Google Play Services issues
      String errorStr = e.toString().toLowerCase();
      if (errorStr.contains('google play services') ||
          errorStr.contains('play services') ||
          errorStr.contains('service_missing') ||
          errorStr.contains('service_version_update_required') ||
          errorStr.contains('service_disabled') ||
          errorStr.contains('service_invalid')) {
        return false;
      }

      // For other errors, assume services might be available but there's a different issue
      return false;
    }
  }

  // Sign in with Google with fallback mechanisms
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('🔵 Starting Google Sign-In process...');
      }

      // Check device compatibility first
      final Map<String, dynamic> compatibility = await checkDeviceCompatibility();
      if (!compatibility['isCompatible']) {
        String errorMessage = 'Google Sign-In is not available on this device.';

        if (compatibility['errorMessage'].isNotEmpty) {
          errorMessage += '\n\nError: ${compatibility['errorMessage']}';
        }

        if (compatibility['recommendations'].isNotEmpty) {
          errorMessage += '\n\nRecommendations:';
          for (String recommendation in compatibility['recommendations']) {
            errorMessage += '\n• $recommendation';
          }
        }

        throw errorMessage;
      }

      if (kDebugMode) {
        print('🟢 Device is compatible with Google Sign-In, proceeding...');
      }

      // Try to sign out first to clear any cached state
      try {
        await googleSignIn.signOut();
        if (kDebugMode) {
          print('🔵 Cleared previous Google Sign-In state');
        }
      } catch (e) {
        if (kDebugMode) {
          print('🟡 Could not clear previous state (this is normal): $e');
        }
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        if (kDebugMode) {
          print('🟡 User canceled Google Sign-In');
        }
        return null; // Return null instead of throwing error for cancellation
      }

      if (kDebugMode) {
        print('🟢 Google user obtained: ${googleUser.email}');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (kDebugMode) {
        print('🔵 Google auth tokens obtained');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        print('🔵 Signing in to Firebase...');
      }

      // Sign in to Firebase with the Google credential
      final UserCredential result = await auth.signInWithCredential(credential);

      if (kDebugMode) {
        print('🟢 Firebase sign-in successful: ${result.user?.email}');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Google Sign-In Error: $e');
        print('🔴 Error type: ${e.runtimeType}');
      }

      // Provide more specific error messages
      String errorMessage = 'Failed to sign in with Google.';
      String errorStr = e.toString().toLowerCase();

      if (errorStr.contains('network') || errorStr.contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
        errorMessage = 'Google Sign-In was canceled. Please try again.';
      } else if (errorStr.contains('platformexception')) {
        errorMessage = 'Google Sign-In service error. Please ensure Google Play Services is updated.';
      } else if (errorStr.contains('sign_in_failed')) {
        errorMessage = 'Google Sign-In failed. Please try again.';
      } else if (errorStr.contains('google_play_services') || errorStr.contains('play services')) {
        errorMessage = 'Google Play Services is not available or outdated. Please update Google Play Services from the Play Store and try again.';
      } else if (errorStr.contains('developer_error') || errorStr.contains('configuration')) {
        errorMessage = 'Google Sign-In configuration error. Please contact support.';
      } else if (errorStr.contains('internal_error')) {
        errorMessage = 'Internal Google Sign-In error. Please try again later.';
      } else if (errorStr.contains('service_disabled')) {
        errorMessage = 'Google Sign-In service is disabled. Please enable it in your device settings.';
      } else if (errorStr.contains('timeout')) {
        errorMessage = 'Google Sign-In timed out. Please check your internet connection and try again.';
      }

      throw errorMessage;
    }
  }

  // Test Google Sign-In configuration
  Future<bool> testGoogleSignInConfiguration() async {
    try {
      if (kDebugMode) {
        print('🔵 Testing Google Sign-In configuration...');
      }

      // First check if Google Play Services is available
      final bool servicesAvailable = await isGooglePlayServicesAvailable();
      if (!servicesAvailable) {
        if (kDebugMode) {
          print('🔴 Google Play Services not available');
        }
        return false;
      }

      // Check if we can access the service
      await googleSignIn.isSignedIn();

      if (kDebugMode) {
        print('🟢 Google Sign-In configuration test passed');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Google Sign-In configuration test failed: $e');
      }
      return false;
    }
  }

  // Check device compatibility for Google Sign-In
  Future<Map<String, dynamic>> checkDeviceCompatibility() async {
    try {
      if (kDebugMode) {
        print('🔵 Checking device compatibility for Google Sign-In...');
      }

      Map<String, dynamic> result = {
        'isCompatible': false,
        'hasGooglePlayServices': false,
        'errorMessage': '',
        'recommendations': <String>[],
      };

      try {
        // Try to create a basic GoogleSignIn instance
        final GoogleSignIn testSignIn = GoogleSignIn(scopes: ['email']);
        await testSignIn.isSignedIn();

        result['hasGooglePlayServices'] = true;
        result['isCompatible'] = true;

        if (kDebugMode) {
          print('🟢 Device is compatible with Google Sign-In');
        }
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print('🔴 Platform exception during compatibility check: ${e.code} - ${e.message}');
        }

        result['errorMessage'] = e.message ?? 'Unknown platform error';

        if (e.code.contains('SIGN_IN_REQUIRED') || e.code.contains('NETWORK_ERROR')) {
          result['hasGooglePlayServices'] = true;
          result['recommendations'].add('Check your internet connection');
        } else if (e.code.contains('SERVICE_MISSING') || e.code.contains('SERVICE_VERSION_UPDATE_REQUIRED')) {
          result['recommendations'].add('Update Google Play Services from the Play Store');
          result['recommendations'].add('Restart your device after updating');
        } else if (e.code.contains('SERVICE_DISABLED')) {
          result['recommendations'].add('Enable Google Play Services in device settings');
        } else {
          result['recommendations'].add('Ensure Google Play Services is installed and updated');
        }
      } catch (e) {
        if (kDebugMode) {
          print('🔴 General error during compatibility check: $e');
        }
        result['errorMessage'] = e.toString();
        result['recommendations'].add('Update Google Play Services and try again');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error in device compatibility check: $e');
      }
      return {
        'isCompatible': false,
        'hasGooglePlayServices': false,
        'errorMessage': e.toString(),
        'recommendations': ['Contact support for assistance'],
      };
    }
  }

  // Try alternative Google Sign-In configuration
  Future<GoogleSignIn?> createAlternativeGoogleSignIn() async {
    try {
      if (kDebugMode) {
        print('🔵 Trying alternative Google Sign-In configuration...');
      }

      // Try with minimal configuration
      final GoogleSignIn altSignIn = GoogleSignIn(
        scopes: ['email'],
        // Remove signInOption to use default
      );

      // Test if this configuration works
      await altSignIn.isSignedIn();

      if (kDebugMode) {
        print('🟢 Alternative Google Sign-In configuration works');
      }

      return altSignIn;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Alternative Google Sign-In configuration failed: $e');
      }
      return null;
    }
  }

  // Initialize Google Sign-In with proper error handling
  Future<bool> initializeGoogleSignIn() async {
    try {
      if (kDebugMode) {
        print('🔵 Initializing Google Sign-In...');
      }

      // Test the primary configuration
      bool configOk = await testGoogleSignInConfiguration();

      if (!configOk) {
        if (kDebugMode) {
          print('🟡 Primary configuration failed, trying alternative...');
        }

        // Try alternative configuration
        final GoogleSignIn? altSignIn = await createAlternativeGoogleSignIn();
        if (altSignIn != null) {
          _googleSignIn = altSignIn;
          configOk = true;
          if (kDebugMode) {
            print('🟢 Alternative Google Sign-In configuration successful');
          }
        }
      }

      if (kDebugMode) {
        if (configOk) {
          print('🟢 Google Sign-In initialized successfully');
        } else {
          print('🔴 Google Sign-In initialization failed');
        }
      }

      return configOk;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Google Sign-In initialization error: $e');
      }
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        auth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$').hasMatch(password);
  }

  // Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    return 'Strong password';
  }

  // Firestore integration methods
  Future<void> _createUserProfileInFirestore(User user, String displayName) async {
    try {
      final now = DateTime.now();
      final userProfile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        photoURL: user.photoURL,
        createdAt: now,
        lastLoginAt: now,
        progress: UserProgress(),
        preferences: UserPreferences(),
        statistics: {},
      );

      await _firestoreService.createUserProfile(userProfile);

      // Cache the profile for offline access
      await _offlineService.cacheUserProfile(userProfile);

      if (kDebugMode) {
        print('User profile created in Firestore: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile in Firestore: $e');
      }
      // Don't throw error to avoid disrupting the signup process
      // The profile can be created later when the user is online
    }
  }

  Future<void> _updateUserLastLogin(User user) async {
    try {
      // Try to get existing profile
      final existingProfile = await _firestoreService.getUserProfile(user.uid);

      if (existingProfile != null) {
        // Update existing profile
        final updatedProfile = existingProfile.copyWith(
          lastLoginAt: DateTime.now(),
        );
        await _firestoreService.updateUserProfile(updatedProfile);

        // Cache the updated profile
        await _offlineService.cacheUserProfile(updatedProfile);
      } else {
        // Create profile if it doesn't exist (for existing users)
        await _createUserProfileInFirestore(user, user.displayName ?? 'User');
      }

      if (kDebugMode) {
        print('User last login updated: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user last login: $e');
      }
      // Don't throw error to avoid disrupting the login process
    }
  }

  // Get user profile from Firestore or cache
  Future<UserProfile?> getUserProfile() async {
    final user = auth.currentUser;
    if (user == null) return null;

    try {
      // Try to get from Firestore first
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (profile != null) {
        // Cache for offline access
        await _offlineService.cacheUserProfile(profile);
        return profile;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting profile from Firestore, trying cache: $e');
      }
    }

    // Fallback to cached profile
    try {
      return await _offlineService.getCachedUserProfile();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached profile: $e');
      }
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestoreService.updateUserProfile(profile);
      await _offlineService.cacheUserProfile(profile);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile, storing offline: $e');
      }
      // Store for later sync
      await _offlineService.storePendingOperation(
        'updateUserProfile',
        {'uid': profile.uid, 'profile': profile.toFirestore()},
      );
    }
  }
}
