import 'package:flutter/material.dart';

enum ActivityType {
  quizCompleted,
  moduleViewed,
  moduleCompleted,
  chatInteraction,
  profileUpdated,
  bookmarkAdded,
  searchPerformed,
}

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final IconData icon;
  final Color? accentColor;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
    required this.icon,
    this.accentColor,
  });

  // Factory constructors for different activity types
  factory Activity.quizCompleted({
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required Duration timeSpent,
    required DateTime timestamp,
  }) {
    return Activity(
      id: 'quiz_${timestamp.millisecondsSinceEpoch}',
      type: ActivityType.quizCompleted,
      title: 'Completed Quiz on $quizTitle',
      description: 'Score: $score/$totalQuestions · ${_formatTimeAgo(timestamp)}',
      timestamp: timestamp,
      metadata: {
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'timeSpent': timeSpent.inSeconds,
      },
      icon: Icons.quiz,
      accentColor: const Color(0xFF4CAF50), // Green for completed
    );
  }

  factory Activity.moduleViewed({
    required String moduleTitle,
    required DateTime timestamp,
  }) {
    return Activity(
      id: 'module_view_${timestamp.millisecondsSinceEpoch}',
      type: ActivityType.moduleViewed,
      title: 'Viewed $moduleTitle',
      description: 'Learning module · ${_formatTimeAgo(timestamp)}',
      timestamp: timestamp,
      metadata: {
        'moduleTitle': moduleTitle,
      },
      icon: Icons.menu_book,
      accentColor: const Color(0xFF2196F3), // Blue for viewing
    );
  }

  factory Activity.moduleCompleted({
    required String moduleTitle,
    required DateTime timestamp,
  }) {
    return Activity(
      id: 'module_complete_${timestamp.millisecondsSinceEpoch}',
      type: ActivityType.moduleCompleted,
      title: 'Completed $moduleTitle',
      description: 'Module finished · ${_formatTimeAgo(timestamp)}',
      timestamp: timestamp,
      metadata: {
        'moduleTitle': moduleTitle,
      },
      icon: Icons.check_circle,
      accentColor: const Color(0xFF4CAF50), // Green for completed
    );
  }

  factory Activity.chatInteraction({
    required String question,
    required DateTime timestamp,
  }) {
    return Activity(
      id: 'chat_${timestamp.millisecondsSinceEpoch}',
      type: ActivityType.chatInteraction,
      title: 'Asked Haki Assistant',
      description: '${question.length > 50 ? '${question.substring(0, 50)}...' : question} · ${_formatTimeAgo(timestamp)}',
      timestamp: timestamp,
      metadata: {
        'question': question,
      },
      icon: Icons.chat,
      accentColor: const Color(0xFFFF9800), // Orange for chat
    );
  }

  factory Activity.profileUpdated({
    required DateTime timestamp,
  }) {
    return Activity(
      id: 'profile_${timestamp.millisecondsSinceEpoch}',
      type: ActivityType.profileUpdated,
      title: 'Updated Profile',
      description: 'Profile information updated · ${_formatTimeAgo(timestamp)}',
      timestamp: timestamp,
      metadata: {},
      icon: Icons.person,
      accentColor: const Color(0xFF9C27B0), // Purple for profile
    );
  }

  factory Activity.bookmarkAdded({
    required String itemTitle,
    required DateTime timestamp,
  }) {
    return Activity(
      id: 'bookmark_${timestamp.millisecondsSinceEpoch}',
      type: ActivityType.bookmarkAdded,
      title: 'Bookmarked $itemTitle',
      description: 'Saved for later · ${_formatTimeAgo(timestamp)}',
      timestamp: timestamp,
      metadata: {
        'itemTitle': itemTitle,
      },
      icon: Icons.bookmark,
      accentColor: const Color(0xFFF44336), // Red for bookmarks
    );
  }

  factory Activity.searchPerformed({
    required String searchTerm,
    required int resultsCount,
    required DateTime timestamp,
  }) {
    return Activity(
      id: 'search_${timestamp.millisecondsSinceEpoch}',
      type: ActivityType.searchPerformed,
      title: 'Searched for "$searchTerm"',
      description: '$resultsCount results found · ${_formatTimeAgo(timestamp)}',
      timestamp: timestamp,
      metadata: {
        'searchTerm': searchTerm,
        'resultsCount': resultsCount,
      },
      icon: Icons.search,
      accentColor: const Color(0xFF607D8B), // Blue grey for search
    );
  }

  // Helper method to format time ago
  static String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() == 1 ? '' : 's'} ago';
    }
  }

  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    final type = ActivityType.values[json['type']];
    final timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
    
    return Activity(
      id: json['id'],
      type: type,
      title: json['title'],
      description: json['description'],
      timestamp: timestamp,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      icon: _getIconForType(type),
      accentColor: _getColorForType(type),
    );
  }

  static IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.quizCompleted:
        return Icons.quiz;
      case ActivityType.moduleViewed:
        return Icons.menu_book;
      case ActivityType.moduleCompleted:
        return Icons.check_circle;
      case ActivityType.chatInteraction:
        return Icons.chat;
      case ActivityType.profileUpdated:
        return Icons.person;
      case ActivityType.bookmarkAdded:
        return Icons.bookmark;
      case ActivityType.searchPerformed:
        return Icons.search;
    }
  }

  static Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.quizCompleted:
      case ActivityType.moduleCompleted:
        return const Color(0xFF4CAF50); // Green
      case ActivityType.moduleViewed:
        return const Color(0xFF2196F3); // Blue
      case ActivityType.chatInteraction:
        return const Color(0xFFFF9800); // Orange
      case ActivityType.profileUpdated:
        return const Color(0xFF9C27B0); // Purple
      case ActivityType.bookmarkAdded:
        return const Color(0xFFF44336); // Red
      case ActivityType.searchPerformed:
        return const Color(0xFF607D8B); // Blue grey
    }
  }
}
