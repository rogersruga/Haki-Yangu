import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  final String version;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final List<String> supportedLanguages;
  final Map<String, dynamic> features;
  final DateTime lastUpdated;

  AppSettings({
    required this.version,
    this.maintenanceMode = false,
    this.maintenanceMessage = '',
    this.supportedLanguages = const ['en', 'sw'],
    this.features = const {},
    required this.lastUpdated,
  });

  factory AppSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppSettings(
      version: data['version'] ?? '1.0.0',
      maintenanceMode: data['maintenanceMode'] ?? false,
      maintenanceMessage: data['maintenanceMessage'] ?? '',
      supportedLanguages: List<String>.from(data['supportedLanguages'] ?? ['en', 'sw']),
      features: Map<String, dynamic>.from(data['features'] ?? {}),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'version': version,
      'maintenanceMode': maintenanceMode,
      'maintenanceMessage': maintenanceMessage,
      'supportedLanguages': supportedLanguages,
      'features': features,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

class UserActivity {
  final String userId;
  final String activityType;
  final String contentId;
  final String contentTitle;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  UserActivity({
    required this.userId,
    required this.activityType,
    required this.contentId,
    required this.contentTitle,
    required this.timestamp,
    this.metadata = const {},
  });

  factory UserActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserActivity(
      userId: data['userId'] ?? '',
      activityType: data['activityType'] ?? '',
      contentId: data['contentId'] ?? '',
      contentTitle: data['contentTitle'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'activityType': activityType,
      'contentId': contentId,
      'contentTitle': contentTitle,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}

// Activity types
class ActivityType {
  static const String lessonStarted = 'lesson_started';
  static const String lessonCompleted = 'lesson_completed';
  static const String quizStarted = 'quiz_started';
  static const String quizCompleted = 'quiz_completed';
  static const String profileUpdated = 'profile_updated';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String appOpened = 'app_opened';
}

class OfflineData {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool synced;

  OfflineData({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.synced = false,
  });

  factory OfflineData.fromMap(Map<String, dynamic> map) {
    return OfflineData(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      synced: map['synced'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'synced': synced,
    };
  }

  OfflineData copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? synced,
  }) {
    return OfflineData(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }
}

// Offline data types
class OfflineDataType {
  static const String userProgress = 'user_progress';
  static const String quizResult = 'quiz_result';
  static const String lessonCompletion = 'lesson_completion';
  static const String userPreferences = 'user_preferences';
  static const String userActivity = 'user_activity';
}

class SyncStatus {
  final bool isOnline;
  final DateTime lastSyncTime;
  final int pendingUploads;
  final int pendingDownloads;
  final List<String> failedOperations;

  SyncStatus({
    this.isOnline = false,
    required this.lastSyncTime,
    this.pendingUploads = 0,
    this.pendingDownloads = 0,
    this.failedOperations = const [],
  });

  factory SyncStatus.initial() {
    return SyncStatus(
      lastSyncTime: DateTime.now(),
    );
  }

  SyncStatus copyWith({
    bool? isOnline,
    DateTime? lastSyncTime,
    int? pendingUploads,
    int? pendingDownloads,
    List<String>? failedOperations,
  }) {
    return SyncStatus(
      isOnline: isOnline ?? this.isOnline,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingUploads: pendingUploads ?? this.pendingUploads,
      pendingDownloads: pendingDownloads ?? this.pendingDownloads,
      failedOperations: failedOperations ?? this.failedOperations,
    );
  }
}

class FirestoreError {
  final String code;
  final String message;
  final DateTime timestamp;
  final String operation;

  FirestoreError({
    required this.code,
    required this.message,
    required this.timestamp,
    required this.operation,
  });

  factory FirestoreError.fromException(dynamic exception, String operation) {
    String code = 'unknown';
    String message = exception.toString();

    if (exception is FirebaseException) {
      code = exception.code;
      message = exception.message ?? exception.toString();
    }

    return FirestoreError(
      code: code,
      message: message,
      timestamp: DateTime.now(),
      operation: operation,
    );
  }

  bool get isNetworkError => 
      code.contains('network') || 
      code.contains('unavailable') ||
      message.toLowerCase().contains('network');

  bool get isPermissionError => 
      code.contains('permission') || 
      code.contains('unauthorized');

  String get userFriendlyMessage {
    switch (code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'unavailable':
        return 'Service is temporarily unavailable. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'quota-exceeded':
        return 'Daily usage limit exceeded. Please try again tomorrow.';
      default:
        if (isNetworkError) {
          return 'Network error. Please check your internet connection and try again.';
        }
        return 'An error occurred. Please try again later.';
    }
  }
}
