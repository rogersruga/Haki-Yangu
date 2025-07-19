import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/learning_content.dart';
import '../models/app_settings.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? _firestore;
  
  // Lazy initialization with error handling
  FirebaseFirestore get firestore {
    try {
      _firestore ??= FirebaseFirestore.instance;
      return _firestore!;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firestore: $e');
      }
      rethrow;
    }
  }

  // Collection references
  CollectionReference get usersCollection => firestore.collection('users');
  CollectionReference get contentCollection => firestore.collection('content');
  CollectionReference get quizzesCollection => firestore.collection('quizzes');
  CollectionReference get categoriesCollection => firestore.collection('categories');
  CollectionReference get activitiesCollection => firestore.collection('activities');
  CollectionReference get settingsCollection => firestore.collection('settings');

  // Initialize Firestore settings
  Future<void> initialize() async {
    try {
      // Enable offline persistence using the new method
      firestore.settings = const Settings(persistenceEnabled: true);

      if (kDebugMode) {
        print('Firestore initialized successfully with offline persistence');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firestore: $e');
      }
      // Continue without offline persistence if it fails
    }
  }

  // User Profile Operations
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      throw FirestoreError.fromException(e, 'getUserProfile');
    }
  }

  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await usersCollection.doc(profile.uid).set(profile.toFirestore());
      
      // Log user creation activity
      await _logActivity(
        profile.uid,
        ActivityType.profileUpdated,
        'profile',
        'User Profile Created',
        {'action': 'create'},
      );
      
      if (kDebugMode) {
        print('User profile created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
      throw FirestoreError.fromException(e, 'createUserProfile');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await usersCollection.doc(profile.uid).update(profile.toFirestore());
      
      // Log profile update activity
      await _logActivity(
        profile.uid,
        ActivityType.profileUpdated,
        'profile',
        'User Profile Updated',
        {'action': 'update'},
      );
      
      if (kDebugMode) {
        print('User profile updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      throw FirestoreError.fromException(e, 'updateUserProfile');
    }
  }

  Future<void> updateUserProgress(String uid, UserProgress progress) async {
    try {
      await usersCollection.doc(uid).update({
        'progress': progress.toMap(),
      });
      
      if (kDebugMode) {
        print('User progress updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user progress: $e');
      }
      throw FirestoreError.fromException(e, 'updateUserProgress');
    }
  }

  Future<void> updateUserPreferences(String uid, UserPreferences preferences) async {
    try {
      await usersCollection.doc(uid).update({
        'preferences': preferences.toMap(),
      });
      
      if (kDebugMode) {
        print('User preferences updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user preferences: $e');
      }
      throw FirestoreError.fromException(e, 'updateUserPreferences');
    }
  }

  // Learning Content Operations
  Future<List<LearningContent>> getLearningContent({
    String? category,
    ContentType? type,
    int limit = 50,
  }) async {
    try {
      Query query = contentCollection
          .where('isPublished', isEqualTo: true)
          .orderBy('order')
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => LearningContent.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting learning content: $e');
      }
      throw FirestoreError.fromException(e, 'getLearningContent');
    }
  }

  Future<LearningContent?> getLearningContentById(String id) async {
    try {
      final doc = await contentCollection.doc(id).get();
      if (doc.exists) {
        return LearningContent.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting learning content by ID: $e');
      }
      throw FirestoreError.fromException(e, 'getLearningContentById');
    }
  }

  // Quiz Operations
  Future<List<Quiz>> getQuizzes({String? category, int limit = 20}) async {
    try {
      Query query = quizzesCollection
          .where('isPublished', isEqualTo: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting quizzes: $e');
      }
      throw FirestoreError.fromException(e, 'getQuizzes');
    }
  }

  Future<Quiz?> getQuizById(String id) async {
    try {
      final doc = await quizzesCollection.doc(id).get();
      if (doc.exists) {
        return Quiz.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting quiz by ID: $e');
      }
      throw FirestoreError.fromException(e, 'getQuizById');
    }
  }

  // Progress Tracking
  Future<void> markLessonCompleted(String uid, String lessonId, String lessonTitle) async {
    try {
      final userRef = usersCollection.doc(uid);
      
      await firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        final userData = userDoc.data() as Map<String, dynamic>;
        final progress = UserProgress.fromMap(userData['progress'] ?? {});
        
        // Update completed lessons if not already completed
        if (!progress.completedLessons.contains(lessonId)) {
          final updatedLessons = List<String>.from(progress.completedLessons)..add(lessonId);
          final updatedProgress = progress.copyWith(
            completedLessons: updatedLessons,
            totalLessonsCompleted: updatedLessons.length,
            lastActivityDate: DateTime.now(),
          );

          transaction.update(userRef, {
            'progress': updatedProgress.toMap(),
          });
        }
      });

      // Log lesson completion activity
      await _logActivity(
        uid,
        ActivityType.lessonCompleted,
        lessonId,
        lessonTitle,
        {'completedAt': DateTime.now().toIso8601String()},
      );

      if (kDebugMode) {
        print('Lesson marked as completed: $lessonId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking lesson completed: $e');
      }
      throw FirestoreError.fromException(e, 'markLessonCompleted');
    }
  }

  Future<void> saveQuizResult(String uid, String quizId, String quizTitle, QuizResult result) async {
    try {
      final userRef = usersCollection.doc(uid);
      
      await firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        final userData = userDoc.data() as Map<String, dynamic>;
        final progress = UserProgress.fromMap(userData['progress'] ?? {});
        
        // Update quiz results and progress
        final updatedQuizResults = Map<String, QuizResult>.from(progress.quizResults);
        updatedQuizResults[quizId] = result;
        
        final updatedQuizzes = List<String>.from(progress.completedQuizzes);
        if (!updatedQuizzes.contains(quizId)) {
          updatedQuizzes.add(quizId);
        }

        // Calculate new average score
        final allScores = updatedQuizResults.values.map((r) => r.percentage).toList();
        final newAverage = allScores.isNotEmpty 
            ? allScores.reduce((a, b) => a + b) / allScores.length 
            : 0.0;

        final updatedProgress = progress.copyWith(
          quizResults: updatedQuizResults,
          completedQuizzes: updatedQuizzes,
          totalQuizzesCompleted: updatedQuizzes.length,
          averageQuizScore: newAverage,
          lastActivityDate: DateTime.now(),
        );

        transaction.update(userRef, {
          'progress': updatedProgress.toMap(),
        });
      });

      // Log quiz completion activity
      await _logActivity(
        uid,
        ActivityType.quizCompleted,
        quizId,
        quizTitle,
        {
          'score': result.score,
          'totalQuestions': result.totalQuestions,
          'percentage': result.percentage,
          'completedAt': result.completedAt.toIso8601String(),
        },
      );

      if (kDebugMode) {
        print('Quiz result saved: $quizId - ${result.percentage}%');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving quiz result: $e');
      }
      throw FirestoreError.fromException(e, 'saveQuizResult');
    }
  }

  // Activity Logging
  Future<void> _logActivity(
    String userId,
    String activityType,
    String contentId,
    String contentTitle,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final activity = UserActivity(
        userId: userId,
        activityType: activityType,
        contentId: contentId,
        contentTitle: contentTitle,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      await activitiesCollection.add(activity.toFirestore());
    } catch (e) {
      // Don't throw errors for activity logging to avoid disrupting main operations
      if (kDebugMode) {
        print('Error logging activity: $e');
      }
    }
  }

  // Categories
  Future<List<LearningCategory>> getCategories() async {
    try {
      final snapshot = await categoriesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();
      
      return snapshot.docs
          .map((doc) => LearningCategory.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting categories: $e');
      }
      throw FirestoreError.fromException(e, 'getCategories');
    }
  }

  // App Settings
  Future<AppSettings?> getAppSettings() async {
    try {
      final doc = await settingsCollection.doc('app').get();
      if (doc.exists) {
        return AppSettings.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting app settings: $e');
      }
      throw FirestoreError.fromException(e, 'getAppSettings');
    }
  }

  // Utility Methods
  Future<bool> isOnline() async {
    try {
      // Try to read a small document to check connectivity
      await settingsCollection.doc('connectivity_test').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Stream subscriptions for real-time updates
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  Stream<List<LearningContent>> getLearningContentStream({
    String? category,
    ContentType? type,
    int limit = 50,
  }) {
    Query query = contentCollection
        .where('isPublished', isEqualTo: true)
        .orderBy('order')
        .limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => LearningContent.fromFirestore(doc)).toList());
  }

  // Batch operations for better performance
  Future<void> batchUpdateUserData(String uid, Map<String, dynamic> updates) async {
    try {
      final batch = firestore.batch();
      final userRef = usersCollection.doc(uid);

      batch.update(userRef, updates);

      await batch.commit();

      if (kDebugMode) {
        print('Batch update completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in batch update: $e');
      }
      throw FirestoreError.fromException(e, 'batchUpdateUserData');
    }
  }

  // Clean up old activities (for performance)
  Future<void> cleanupOldActivities(String userId, {int daysToKeep = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final query = activitiesCollection
          .where('userId', isEqualTo: userId)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate));

      final snapshot = await query.get();
      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        if (kDebugMode) {
          print('Cleaned up ${snapshot.docs.length} old activities');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old activities: $e');
      }
      // Don't throw error for cleanup operations
    }
  }
}
