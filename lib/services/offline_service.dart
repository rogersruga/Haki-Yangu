import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  SharedPreferences? _prefs;

  // Keys for offline storage
  static const String _offlineDataKey = 'offline_data';
  static const String _syncStatusKey = 'sync_status';
  static const String _cachedUserProfileKey = 'cached_user_profile';
  static const String _pendingOperationsKey = 'pending_operations';

  // Initialize offline service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (kDebugMode) {
        print('Offline service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing offline service: $e');
      }
      rethrow;
    }
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('OfflineService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Offline data management
  Future<void> storeOfflineData(OfflineData data) async {
    try {
      final existingData = await getOfflineData();
      existingData.add(data);
      
      final jsonList = existingData.map((item) => item.toMap()).toList();
      await prefs.setString(_offlineDataKey, jsonEncode(jsonList));
      
      if (kDebugMode) {
        print('Stored offline data: ${data.type}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing offline data: $e');
      }
    }
  }

  Future<List<OfflineData>> getOfflineData() async {
    try {
      final jsonString = prefs.getString(_offlineDataKey);
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((item) => OfflineData.fromMap(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting offline data: $e');
      }
      return [];
    }
  }

  Future<void> clearOfflineData() async {
    try {
      await prefs.remove(_offlineDataKey);
      if (kDebugMode) {
        print('Cleared offline data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing offline data: $e');
      }
    }
  }

  // Sync status management
  Future<void> updateSyncStatus(SyncStatus status) async {
    try {
      final statusMap = {
        'isOnline': status.isOnline,
        'lastSyncTime': status.lastSyncTime.millisecondsSinceEpoch,
        'pendingUploads': status.pendingUploads,
        'pendingDownloads': status.pendingDownloads,
        'failedOperations': status.failedOperations,
      };
      
      await prefs.setString(_syncStatusKey, jsonEncode(statusMap));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating sync status: $e');
      }
    }
  }

  Future<SyncStatus> getSyncStatus() async {
    try {
      final jsonString = prefs.getString(_syncStatusKey);
      if (jsonString == null) return SyncStatus.initial();
      
      final statusMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return SyncStatus(
        isOnline: statusMap['isOnline'] ?? false,
        lastSyncTime: DateTime.fromMillisecondsSinceEpoch(
          statusMap['lastSyncTime'] ?? DateTime.now().millisecondsSinceEpoch,
        ),
        pendingUploads: statusMap['pendingUploads'] ?? 0,
        pendingDownloads: statusMap['pendingDownloads'] ?? 0,
        failedOperations: List<String>.from(statusMap['failedOperations'] ?? []),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sync status: $e');
      }
      return SyncStatus.initial();
    }
  }

  // Cache user profile for offline access
  Future<void> cacheUserProfile(UserProfile profile) async {
    try {
      final profileMap = {
        'uid': profile.uid,
        'email': profile.email,
        'displayName': profile.displayName,
        'photoURL': profile.photoURL,
        'createdAt': profile.createdAt.millisecondsSinceEpoch,
        'lastLoginAt': profile.lastLoginAt.millisecondsSinceEpoch,
        'progress': profile.progress.toMap(),
        'preferences': profile.preferences.toMap(),
        'statistics': profile.statistics,
      };

      await prefs.setString(_cachedUserProfileKey, jsonEncode(profileMap));

      if (kDebugMode) {
        print('Cached user profile for offline access');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching user profile: $e');
      }
    }
  }

  Future<UserProfile?> getCachedUserProfile() async {
    try {
      final jsonString = prefs.getString(_cachedUserProfileKey);
      if (jsonString == null) return null;

      final profileMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final uid = profileMap['uid'] as String;

      // Create UserProfile directly from cached data
      return UserProfile(
        uid: uid,
        email: profileMap['email'] ?? '',
        displayName: profileMap['displayName'],
        photoURL: profileMap['photoURL'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(profileMap['createdAt'] ?? 0),
        lastLoginAt: DateTime.fromMillisecondsSinceEpoch(profileMap['lastLoginAt'] ?? 0),
        progress: UserProgress.fromMap(profileMap['progress'] ?? {}),
        preferences: UserPreferences.fromMap(profileMap['preferences'] ?? {}),
        statistics: Map<String, dynamic>.from(profileMap['statistics'] ?? {}),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached user profile: $e');
      }
      return null;
    }
  }

  // Store pending operations for later sync
  Future<void> storePendingOperation(String operation, Map<String, dynamic> data) async {
    try {
      final pendingOps = await getPendingOperations();
      pendingOps.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'operation': operation,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      await prefs.setString(_pendingOperationsKey, jsonEncode(pendingOps));
      
      if (kDebugMode) {
        print('Stored pending operation: $operation');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing pending operation: $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    try {
      final jsonString = prefs.getString(_pendingOperationsKey);
      if (jsonString == null) return [];
      
      return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pending operations: $e');
      }
      return [];
    }
  }

  Future<void> removePendingOperation(String operationId) async {
    try {
      final pendingOps = await getPendingOperations();
      pendingOps.removeWhere((op) => op['id'] == operationId);
      
      await prefs.setString(_pendingOperationsKey, jsonEncode(pendingOps));
    } catch (e) {
      if (kDebugMode) {
        print('Error removing pending operation: $e');
      }
    }
  }

  // Sync pending operations when online
  Future<void> syncPendingOperations() async {
    try {
      final isOnline = await _firestoreService.isOnline();
      if (!isOnline) return;

      final pendingOps = await getPendingOperations();
      final failedOps = <String>[];

      for (final op in pendingOps) {
        try {
          await _executePendingOperation(op);
          await removePendingOperation(op['id']);
        } catch (e) {
          failedOps.add(op['operation']);
          if (kDebugMode) {
            print('Failed to sync operation ${op['operation']}: $e');
          }
        }
      }

      // Update sync status
      final currentStatus = await getSyncStatus();
      final newStatus = currentStatus.copyWith(
        isOnline: true,
        lastSyncTime: DateTime.now(),
        pendingUploads: pendingOps.length - (pendingOps.length - failedOps.length),
        failedOperations: failedOps,
      );
      
      await updateSyncStatus(newStatus);
      
      if (kDebugMode) {
        print('Sync completed. ${pendingOps.length - failedOps.length} operations synced, ${failedOps.length} failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing pending operations: $e');
      }
    }
  }

  Future<void> _executePendingOperation(Map<String, dynamic> operation) async {
    final opType = operation['operation'] as String;
    final data = operation['data'] as Map<String, dynamic>;

    switch (opType) {
      case 'updateUserProgress':
        final uid = data['uid'] as String;
        final progress = UserProgress.fromMap(data['progress']);
        await _firestoreService.updateUserProgress(uid, progress);
        break;
        
      case 'updateUserPreferences':
        final uid = data['uid'] as String;
        final preferences = UserPreferences.fromMap(data['preferences']);
        await _firestoreService.updateUserPreferences(uid, preferences);
        break;
        
      case 'markLessonCompleted':
        await _firestoreService.markLessonCompleted(
          data['uid'],
          data['lessonId'],
          data['lessonTitle'],
        );
        break;
        
      case 'saveQuizResult':
        final result = QuizResult.fromMap(data['result']);
        await _firestoreService.saveQuizResult(
          data['uid'],
          data['quizId'],
          data['quizTitle'],
          result,
        );
        break;
        
      default:
        if (kDebugMode) {
          print('Unknown pending operation type: $opType');
        }
    }
  }

  // Check if device is online
  Future<bool> isOnline() async {
    return await _firestoreService.isOnline();
  }
}


