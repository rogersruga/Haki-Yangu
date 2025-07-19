import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final UserProgress progress;
  final UserPreferences preferences;
  final Map<String, dynamic> statistics;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    required this.progress,
    required this.preferences,
    this.statistics = const {},
  });

  // Convert from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progress: UserProgress.fromMap(data['progress'] ?? {}),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      statistics: Map<String, dynamic>.from(data['statistics'] ?? {}),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'progress': progress.toMap(),
      'preferences': preferences.toMap(),
      'statistics': statistics,
    };
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? lastLoginAt,
    UserProgress? progress,
    UserPreferences? preferences,
    Map<String, dynamic>? statistics,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      progress: progress ?? this.progress,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
    );
  }
}

class UserProgress {
  final int totalLessonsCompleted;
  final int totalQuizzesCompleted;
  final double averageQuizScore;
  final List<String> completedLessons;
  final List<String> completedQuizzes;
  final Map<String, QuizResult> quizResults;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  UserProgress({
    this.totalLessonsCompleted = 0,
    this.totalQuizzesCompleted = 0,
    this.averageQuizScore = 0.0,
    this.completedLessons = const [],
    this.completedQuizzes = const [],
    this.quizResults = const {},
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      totalLessonsCompleted: map['totalLessonsCompleted'] ?? 0,
      totalQuizzesCompleted: map['totalQuizzesCompleted'] ?? 0,
      averageQuizScore: (map['averageQuizScore'] ?? 0.0).toDouble(),
      completedLessons: List<String>.from(map['completedLessons'] ?? []),
      completedQuizzes: List<String>.from(map['completedQuizzes'] ?? []),
      quizResults: Map<String, QuizResult>.from(
        (map['quizResults'] ?? {}).map(
          (key, value) => MapEntry(key, QuizResult.fromMap(value)),
        ),
      ),
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastActivityDate: (map['lastActivityDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalQuizzesCompleted': totalQuizzesCompleted,
      'averageQuizScore': averageQuizScore,
      'completedLessons': completedLessons,
      'completedQuizzes': completedQuizzes,
      'quizResults': quizResults.map((key, value) => MapEntry(key, value.toMap())),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate != null ? Timestamp.fromDate(lastActivityDate!) : null,
    };
  }

  UserProgress copyWith({
    int? totalLessonsCompleted,
    int? totalQuizzesCompleted,
    double? averageQuizScore,
    List<String>? completedLessons,
    List<String>? completedQuizzes,
    Map<String, QuizResult>? quizResults,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
  }) {
    return UserProgress(
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalQuizzesCompleted: totalQuizzesCompleted ?? this.totalQuizzesCompleted,
      averageQuizScore: averageQuizScore ?? this.averageQuizScore,
      completedLessons: completedLessons ?? this.completedLessons,
      completedQuizzes: completedQuizzes ?? this.completedQuizzes,
      quizResults: quizResults ?? this.quizResults,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final DateTime completedAt;
  final Duration timeSpent;
  final List<int> incorrectQuestions;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    required this.timeSpent,
    this.incorrectQuestions = const [],
  });

  double get percentage => (score / totalQuestions) * 100;

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSpent: Duration(seconds: map['timeSpentSeconds'] ?? 0),
      incorrectQuestions: List<int>.from(map['incorrectQuestions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': Timestamp.fromDate(completedAt),
      'timeSpentSeconds': timeSpent.inSeconds,
      'incorrectQuestions': incorrectQuestions,
    };
  }
}

class UserPreferences {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String language;
  final String theme;
  final int dailyGoalMinutes;
  final List<String> favoriteTopics;
  final bool offlineModeEnabled;

  UserPreferences({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.language = 'en',
    this.theme = 'system',
    this.dailyGoalMinutes = 30,
    this.favoriteTopics = const [],
    this.offlineModeEnabled = true,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'system',
      dailyGoalMinutes: map['dailyGoalMinutes'] ?? 30,
      favoriteTopics: List<String>.from(map['favoriteTopics'] ?? []),
      offlineModeEnabled: map['offlineModeEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'language': language,
      'theme': theme,
      'dailyGoalMinutes': dailyGoalMinutes,
      'favoriteTopics': favoriteTopics,
      'offlineModeEnabled': offlineModeEnabled,
    };
  }

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? language,
    String? theme,
    int? dailyGoalMinutes,
    List<String>? favoriteTopics,
    bool? offlineModeEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      favoriteTopics: favoriteTopics ?? this.favoriteTopics,
      offlineModeEnabled: offlineModeEnabled ?? this.offlineModeEnabled,
    );
  }
}
