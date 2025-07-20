import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'progress_service.dart';
import 'chat_service.dart';
import '../models/user_profile.dart';
import '../models/chat_models.dart';

/// Service to handle refresh operations across all screens
/// Provides consistent refresh patterns and error handling
class RefreshService {
  static final RefreshService _instance = RefreshService._internal();
  factory RefreshService() => _instance;
  RefreshService._internal();

  final AuthService _authService = AuthService();
  final ProgressService _progressService = ProgressService();
  final ChatService _chatService = ChatService();

  /// Standard refresh duration for consistent UX
  static const Duration refreshDuration = Duration(milliseconds: 1500);

  /// Refresh user profile data
  /// Used by: Profile Screen, Main Screen, Home Screen
  Future<RefreshResult> refreshUserProfile() async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing user profile data...');
      }

      // Simulate minimum refresh time for better UX
      final futures = await Future.wait([
        _authService.getUserProfile(),
        Future.delayed(refreshDuration),
      ]);

      final userProfile = futures[0] as UserProfile?;

      if (userProfile != null) {
        if (kDebugMode) {
          print('✅ User profile refreshed successfully');
        }
        return RefreshResult.success(
          message: 'Profile updated successfully',
          data: userProfile,
        );
      } else {
        if (kDebugMode) {
          print('⚠️ No user profile found during refresh');
        }
        return RefreshResult.warning(
          message: 'Unable to load profile data',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing user profile: $e');
      }
      return RefreshResult.error(
        message: 'Failed to refresh profile data',
        error: e,
      );
    }
  }

  /// Refresh progress data
  /// Used by: Main Screen, Home Screen, Profile Screen
  Future<RefreshResult> refreshProgressData() async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing progress data...');
      }

      final futures = await Future.wait([
        _progressService.getCompletionStats(),
        Future.delayed(refreshDuration),
      ]);

      final stats = futures[0] as Map<String, dynamic>;

      if (kDebugMode) {
        print('✅ Progress data refreshed: ${stats['completedModules']}/${stats['totalModules']} modules');
      }

      return RefreshResult.success(
        message: 'Progress updated successfully',
        data: stats,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing progress data: $e');
      }
      return RefreshResult.error(
        message: 'Failed to refresh progress data',
        error: e,
      );
    }
  }

  /// Refresh chat data
  /// Used by: Chat Screen
  Future<RefreshResult> refreshChatData(String sessionId) async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing chat data for session: $sessionId');
      }

      final futures = await Future.wait([
        _chatService.getChatSession(sessionId),
        Future.delayed(refreshDuration),
      ]);

      final session = futures[0] as ChatSession?;

      if (session != null) {
        if (kDebugMode) {
          print('✅ Chat data refreshed: ${session.messages.length} messages loaded');
        }

        return RefreshResult.success(
          message: 'Chat history updated',
          data: session.messages,
        );
      } else {
        if (kDebugMode) {
          print('⚠️ No chat session found during refresh');
        }
        return RefreshResult.warning(
          message: 'Chat session not found',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing chat data: $e');
      }
      return RefreshResult.error(
        message: 'Failed to refresh chat history',
        error: e,
      );
    }
  }

  /// Refresh module completion status
  /// Used by: Detail Screens
  Future<RefreshResult> refreshModuleStatus(String moduleId) async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing module status for: $moduleId');
      }

      final futures = await Future.wait([
        _progressService.isModuleCompleted(moduleId),
        Future.delayed(refreshDuration),
      ]);

      final isCompleted = futures[0] as bool;

      if (kDebugMode) {
        print('✅ Module status refreshed: $moduleId - ${isCompleted ? 'Completed' : 'Not completed'}');
      }

      return RefreshResult.success(
        message: 'Module status updated',
        data: isCompleted,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing module status: $e');
      }
      return RefreshResult.error(
        message: 'Failed to refresh module status',
        error: e,
      );
    }
  }

  /// Refresh learning content
  /// Used by: Learn Screen
  Future<RefreshResult> refreshLearningContent() async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing learning content...');
      }

      // Simulate content refresh (in a real app, this would fetch from API/Firestore)
      await Future.delayed(refreshDuration);

      if (kDebugMode) {
        print('✅ Learning content refreshed successfully');
      }

      return RefreshResult.success(
        message: 'Content updated successfully',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing learning content: $e');
      }
      return RefreshResult.error(
        message: 'Failed to refresh content',
        error: e,
      );
    }
  }

  /// Show refresh feedback to user
  static void showRefreshFeedback(BuildContext context, RefreshResult result) {
    if (!result.showFeedback) return;

    Color backgroundColor;
    IconData icon;

    switch (result.type) {
      case RefreshResultType.success:
        backgroundColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
        break;
      case RefreshResultType.warning:
        backgroundColor = const Color(0xFFFF9800);
        icon = Icons.warning;
        break;
      case RefreshResultType.error:
        backgroundColor = const Color(0xFFF44336);
        icon = Icons.error_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Result class for refresh operations
class RefreshResult {
  final RefreshResultType type;
  final String message;
  final dynamic data;
  final dynamic error;
  final bool showFeedback;

  const RefreshResult._({
    required this.type,
    required this.message,
    this.data,
    this.error,
    this.showFeedback = false,
  });

  factory RefreshResult.success({
    required String message,
    dynamic data,
    bool showFeedback = false,
  }) {
    return RefreshResult._(
      type: RefreshResultType.success,
      message: message,
      data: data,
      showFeedback: showFeedback,
    );
  }

  factory RefreshResult.warning({
    required String message,
    dynamic data,
    bool showFeedback = true,
  }) {
    return RefreshResult._(
      type: RefreshResultType.warning,
      message: message,
      data: data,
      showFeedback: showFeedback,
    );
  }

  factory RefreshResult.error({
    required String message,
    dynamic error,
    bool showFeedback = true,
  }) {
    return RefreshResult._(
      type: RefreshResultType.error,
      message: message,
      error: error,
      showFeedback: showFeedback,
    );
  }

  bool get isSuccess => type == RefreshResultType.success;
  bool get isWarning => type == RefreshResultType.warning;
  bool get isError => type == RefreshResultType.error;
}

enum RefreshResultType {
  success,
  warning,
  error,
}
