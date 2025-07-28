import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Module identifiers
  static const String billOfRights = 'bill_of_rights';
  static const String electionsAct = 'elections_act';
  static const String employmentLaw = 'employment_law';
  static const String genderEquality = 'gender_equality';
  static const String healthcareRights = 'healthcare_rights';
  static const String landRights = 'land_rights';

  // All available modules
  static const List<String> allModules = [
    billOfRights,
    electionsAct,
    employmentLaw,
    genderEquality,
    healthcareRights,
    landRights,
  ];

  // Module display names
  static const Map<String, String> moduleNames = {
    billOfRights: 'Bill of Rights',
    electionsAct: 'Elections Act',
    employmentLaw: 'Employment Law',
    genderEquality: 'Gender Equality',
    healthcareRights: 'Healthcare Rights',
    landRights: 'Land Rights',
  };

  // Stream for real-time progress updates
  Stream<UserProgress?> getUserProgressStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestoreService.usersCollection
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserProgress.fromMap(data['progress'] ?? {});
      }
      return null;
    });
  }

  // Get current user progress
  Future<UserProgress?> getUserProgress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final profile = await _firestoreService.getUserProfile(user.uid);
      return profile?.progress;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user progress: $e');
      }
      return null;
    }
  }

  // Check if a specific module is completed
  Future<bool> isModuleCompleted(String moduleId) async {
    try {
      final progress = await getUserProgress();
      return progress?.completedLessons.contains(moduleId) ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking module completion: $e');
      }
      return false;
    }
  }

  // Mark a module as completed
  Future<bool> markModuleCompleted(String moduleId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('No authenticated user found');
        }
        return false;
      }

      // Validate module ID
      if (!allModules.contains(moduleId)) {
        if (kDebugMode) {
          print('Invalid module ID: $moduleId');
        }
        return false;
      }

      // Get current user profile
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (profile == null) {
        if (kDebugMode) {
          print('User profile not found');
        }
        return false;
      }

      // Check if already completed
      if (profile.progress.completedLessons.contains(moduleId)) {
        if (kDebugMode) {
          print('Module $moduleId already completed');
        }
        return true; // Already completed, return success
      }

      // Add module to completed lessons
      final updatedCompletedLessons = List<String>.from(profile.progress.completedLessons)
        ..add(moduleId);

      // Update progress
      final updatedProgress = profile.progress.copyWith(
        completedLessons: updatedCompletedLessons,
        totalLessonsCompleted: updatedCompletedLessons.length,
        lastActivityDate: DateTime.now(),
      );

      // Update user profile
      final updatedProfile = profile.copyWith(
        progress: updatedProgress,
        lastLoginAt: DateTime.now(),
      );

      await _firestoreService.updateUserProfile(updatedProfile);

      // Log completion activity
      await _logModuleCompletion(user.uid, moduleId);

      if (kDebugMode) {
        print('Module $moduleId marked as completed successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking module as completed: $e');
      }
      return false;
    }
  }

  // Get completion statistics
  Future<Map<String, dynamic>> getCompletionStats() async {
    try {
      final progress = await getUserProgress();
      if (progress == null) {
        return {
          'totalModules': allModules.length,
          'completedModules': 0,
          'completionPercentage': 0.0,
          'completedModuleIds': <String>[],
        };
      }

      final completedModules = progress.completedLessons
          .where((lesson) => allModules.contains(lesson))
          .toList();

      return {
        'totalModules': allModules.length,
        'completedModules': completedModules.length,
        'completionPercentage': (completedModules.length / allModules.length) * 100,
        'completedModuleIds': completedModules,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting completion stats: $e');
      }
      return {
        'totalModules': allModules.length,
        'completedModules': 0,
        'completionPercentage': 0.0,
        'completedModuleIds': <String>[],
      };
    }
  }

  // Log module completion activity
  Future<void> _logModuleCompletion(String userId, String moduleId) async {
    try {
      await _firestoreService.activitiesCollection.add({
        'userId': userId,
        'activityType': 'module_completed',
        'contentId': moduleId,
        'contentTitle': moduleNames[moduleId] ?? moduleId,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': {
          'moduleId': moduleId,
          'completedAt': DateTime.now().toIso8601String(),
        },
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error logging module completion: $e');
      }
      // Don't throw error for logging failures
    }
  }

  // Get module display name
  String getModuleName(String moduleId) {
    return moduleNames[moduleId] ?? moduleId;
  }

  // Reset progress (for testing purposes)
  Future<bool> resetProgress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final profile = await _firestoreService.getUserProfile(user.uid);
      if (profile == null) return false;

      final resetProgress = profile.progress.copyWith(
        completedLessons: [],
        totalLessonsCompleted: 0,
        lastActivityDate: DateTime.now(),
      );

      final updatedProfile = profile.copyWith(progress: resetProgress);
      await _firestoreService.updateUserProfile(updatedProfile);

      if (kDebugMode) {
        print('Progress reset successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting progress: $e');
      }
      return false;
    }
  }

  // Get quiz statistics for display
  Future<Map<String, dynamic>> getQuizStats() async {
    try {
      final progress = await getUserProgress();
      if (progress == null) {
        return {
          'totalQuizzesTaken': 0,
          'averageScore': 0.0,
          'bestScore': 0.0,
          'quizzesCompleted': 0,
        };
      }

      final quizResults = progress.quizResults.values.toList();
      if (quizResults.isEmpty) {
        return {
          'totalQuizzesTaken': 0,
          'averageScore': 0.0,
          'bestScore': 0.0,
          'quizzesCompleted': 0,
        };
      }

      final scores = quizResults.map((r) => r.percentage).toList();
      final averageScore = scores.reduce((a, b) => a + b) / scores.length;
      final bestScore = scores.reduce((a, b) => a > b ? a : b);

      return {
        'totalQuizzesTaken': progress.totalQuizzesCompleted,
        'averageScore': averageScore,
        'bestScore': bestScore,
        'quizzesCompleted': progress.completedQuizzes.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting quiz stats: $e');
      }
      return {
        'totalQuizzesTaken': 0,
        'averageScore': 0.0,
        'bestScore': 0.0,
        'quizzesCompleted': 0,
      };
    }
  }

  // Get combined learning and quiz statistics
  Future<Map<String, dynamic>> getCombinedStats() async {
    try {
      final completionStats = await getCompletionStats();
      final quizStats = await getQuizStats();

      return {
        ...completionStats,
        ...quizStats,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting combined stats: $e');
      }
      return {
        'totalModules': allModules.length,
        'completedModules': 0,
        'completionPercentage': 0.0,
        'totalQuizzesTaken': 0,
        'averageScore': 0.0,
        'bestScore': 0.0,
        'quizzesCompleted': 0,
      };
    }
  }
}
