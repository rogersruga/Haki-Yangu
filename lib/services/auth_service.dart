import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

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
      _googleSignIn ??= GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
      return _googleSignIn!;
    } catch (e) {
      if (kDebugMode) {
        print('Error accessing GoogleSignIn: $e');
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
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('🔵 Starting Google Sign-In process...');
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
}
