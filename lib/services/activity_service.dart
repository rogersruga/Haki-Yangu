import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';

class ActivityService extends ChangeNotifier {
  static const String _activitiesKey = 'user_activities';
  static const int _maxActivities = 50; // Keep last 50 activities

  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  List<Activity> _activities = [];
  List<Activity> get activities => List.unmodifiable(_activities);

  // Initialize and load activities from storage
  Future<void> initialize() async {
    await _loadActivities();
  }

  // Add a new activity
  Future<void> addActivity(Activity activity) async {
    _activities.insert(0, activity); // Add to beginning (most recent first)

    // Keep only the most recent activities
    if (_activities.length > _maxActivities) {
      _activities = _activities.take(_maxActivities).toList();
    }

    await _saveActivities();
    notifyListeners(); // Notify UI to update
  }

  // Get recent activities (limited number)
  List<Activity> getRecentActivities({int limit = 10}) {
    return _activities.take(limit).toList();
  }

  // Get activities by type
  List<Activity> getActivitiesByType(ActivityType type, {int limit = 10}) {
    return _activities
        .where((activity) => activity.type == type)
        .take(limit)
        .toList();
  }

  // Get activities from today
  List<Activity> getTodayActivities() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return _activities
        .where((activity) => activity.timestamp.isAfter(startOfDay))
        .toList();
  }

  // Get activities from this week
  List<Activity> getWeekActivities() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return _activities
        .where((activity) => activity.timestamp.isAfter(weekAgo))
        .toList();
  }

  // Clear all activities
  Future<void> clearActivities() async {
    _activities.clear();
    await _saveActivities();
  }

  // Remove specific activity
  Future<void> removeActivity(String activityId) async {
    _activities.removeWhere((activity) => activity.id == activityId);
    await _saveActivities();
  }

  // Convenience methods for adding specific activity types
  Future<void> recordQuizCompletion({
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required Duration timeSpent,
  }) async {
    final activity = Activity.quizCompleted(
      quizTitle: quizTitle,
      score: score,
      totalQuestions: totalQuestions,
      timeSpent: timeSpent,
      timestamp: DateTime.now(),
    );
    await addActivity(activity);
  }

  Future<void> recordModuleView(String moduleTitle) async {
    final activity = Activity.moduleViewed(
      moduleTitle: moduleTitle,
      timestamp: DateTime.now(),
    );
    await addActivity(activity);
  }

  Future<void> recordModuleCompletion(String moduleTitle) async {
    final activity = Activity.moduleCompleted(
      moduleTitle: moduleTitle,
      timestamp: DateTime.now(),
    );
    await addActivity(activity);
  }

  Future<void> recordChatInteraction(String question) async {
    final activity = Activity.chatInteraction(
      question: question,
      timestamp: DateTime.now(),
    );
    await addActivity(activity);
  }

  Future<void> recordProfileUpdate() async {
    final activity = Activity.profileUpdated(
      timestamp: DateTime.now(),
    );
    await addActivity(activity);
  }

  Future<void> recordBookmark(String itemTitle) async {
    final activity = Activity.bookmarkAdded(
      itemTitle: itemTitle,
      timestamp: DateTime.now(),
    );
    await addActivity(activity);
  }

  Future<void> recordSearch(String searchTerm, int resultsCount) async {
    final activity = Activity.searchPerformed(
      searchTerm: searchTerm,
      resultsCount: resultsCount,
      timestamp: DateTime.now(),
    );
    await addActivity(activity);
  }

  // Private methods for persistence
  Future<void> _loadActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = prefs.getString(_activitiesKey);
      
      if (activitiesJson != null) {
        final List<dynamic> activitiesList = json.decode(activitiesJson);
        _activities = activitiesList
            .map((json) => Activity.fromJson(json))
            .toList();
      } else {
        // Add some sample activities for demonstration
        await _addSampleActivities();
      }
    } catch (e) {
      // If loading fails, start with sample activities
      await _addSampleActivities();
    }
  }

  Future<void> _saveActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = json.encode(
        _activities.map((activity) => activity.toJson()).toList(),
      );
      await prefs.setString(_activitiesKey, activitiesJson);
    } catch (e) {
      // Handle save error silently
    }
  }

  // Add sample activities for demonstration
  Future<void> _addSampleActivities() async {
    final now = DateTime.now();
    
    _activities = [
      Activity.quizCompleted(
        quizTitle: 'Human Rights',
        score: 8,
        totalQuestions: 10,
        timeSpent: const Duration(minutes: 5),
        timestamp: now.subtract(const Duration(minutes: 15)),
      ),
      Activity.moduleViewed(
        moduleTitle: 'Healthcare Rights',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      Activity.chatInteraction(
        question: 'What are my rights as a tenant?',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      Activity.moduleCompleted(
        moduleTitle: 'Bill of Rights',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      Activity.bookmarkAdded(
        itemTitle: 'Employment Law Guide',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      Activity.searchPerformed(
        searchTerm: 'voting rights',
        resultsCount: 12,
        timestamp: now.subtract(const Duration(days: 3)),
      ),
    ];
    
    await _saveActivities();
  }

  // Get activity statistics
  Map<String, int> getActivityStats() {
    final stats = <String, int>{};
    
    for (final type in ActivityType.values) {
      stats[type.toString()] = _activities
          .where((activity) => activity.type == type)
          .length;
    }
    
    return stats;
  }

  // Check if user has any activities
  bool get hasActivities => _activities.isNotEmpty;

  // Get total activities count
  int get totalActivitiesCount => _activities.length;
}
