import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_settings.dart';

class ErrorHandler {
  static void handleError(dynamic error, String operation, {BuildContext? context}) {
    if (kDebugMode) {
      print('Error in $operation: $error');
    }

    if (context != null) {
      final errorMessage = _getErrorMessage(error, operation);
      _showErrorSnackBar(context, errorMessage);
    }
  }

  static String _getErrorMessage(dynamic error, String operation) {
    if (error is FirebaseException) {
      final firestoreError = FirestoreError.fromException(error, operation);
      return firestoreError.userFriendlyMessage;
    }

    if (error is String) {
      return error;
    }

    // Default error messages based on operation
    switch (operation) {
      case 'getUserProfile':
      case 'updateUserProfile':
        return 'Unable to sync your profile. Your data is saved locally and will sync when you\'re back online.';
      case 'markLessonCompleted':
        return 'Lesson progress saved locally. It will sync when you\'re back online.';
      case 'saveQuizResult':
        return 'Quiz results saved locally. They will sync when you\'re back online.';
      case 'getLearningContent':
        return 'Unable to load new content. Showing cached content.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showOfflineMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white),
            SizedBox(width: 8),
            Text('You\'re offline. Data will sync when connection is restored.'),
          ],
        ),
        backgroundColor: Colors.grey[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction();
                },
                child: Text(actionLabel),
              ),
          ],
        );
      },
    );
  }

  static Widget buildErrorWidget({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildOfflineWidget({
    required String message,
    VoidCallback? onRetry,
  }) {
    return buildErrorWidget(
      message: message,
      onRetry: onRetry,
      icon: Icons.cloud_off,
    );
  }

  static Widget buildLoadingWidget({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Network connectivity helpers
  static bool isNetworkError(dynamic error) {
    if (error is FirebaseException) {
      return error.code.contains('network') || 
             error.code.contains('unavailable') ||
             error.message?.toLowerCase().contains('network') == true;
    }
    return false;
  }

  static bool isPermissionError(dynamic error) {
    if (error is FirebaseException) {
      return error.code.contains('permission') || 
             error.code.contains('unauthorized');
    }
    return false;
  }

  // Retry logic
  static Future<T?> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String operationName = 'operation',
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (kDebugMode) {
          print('Attempt $attempt of $operationName failed: $e');
        }
        
        if (attempt == maxRetries) {
          rethrow;
        }
        
        // Don't retry permission errors
        if (isPermissionError(e)) {
          rethrow;
        }
        
        await Future.delayed(delay * attempt);
      }
    }
    return null;
  }
}
