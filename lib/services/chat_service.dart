import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import 'firestore_service.dart';
import 'openrouter_service.dart';
import 'offline_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final OpenRouterService _openRouterService = OpenRouterService();
  final OfflineService _offlineService = OfflineService();

  // Collection reference for chat sessions
  CollectionReference get _chatsCollection =>
      _firestoreService.firestore.collection('chats');

  // Create a new chat session
  Future<ChatSession> createChatSession(String userId) async {
    try {
      final session = ChatSession.create(userId);

      // Save to Firestore
      await _chatsCollection.doc(session.id).set(session.toFirestore());

      if (kDebugMode) {
        print('Created new chat session: ${session.id}');
      }

      return session;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating chat session: $e');
      }
      // Return session anyway for offline use
      return ChatSession.create(userId);
    }
  }

  // Get user's chat sessions
  Future<List<ChatSession>> getUserChatSessions(String userId) async {
    try {
      final snapshot = await _chatsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('lastUpdated', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ChatSession.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting chat sessions: $e');
      }
      return [];
    }
  }

  // Get a specific chat session
  Future<ChatSession?> getChatSession(String sessionId) async {
    try {
      final doc = await _chatsCollection.doc(sessionId).get();
      if (doc.exists) {
        return ChatSession.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting chat session: $e');
      }
      return null;
    }
  }

  // Send a message and get AI response
  Future<ChatMessage> sendMessage(
    String sessionId,
    String userMessage,
    List<ChatMessage> conversationHistory,
  ) async {
    try {
      if (kDebugMode) {
        print('🔵 ChatService: Processing message for session $sessionId');
      }

      // Check for quick responses first (only for greetings in new conversations)
      final quickResponse = _openRouterService.getQuickResponse(
        userMessage,
        conversationHistory,
      );
      if (quickResponse != null) {
        if (kDebugMode) {
          print('🟡 Using quick response for greeting');
        }
        final assistantMessage = ChatMessage.assistant(quickResponse);
        // Save quick response in background, don't block on it
        _saveMessageToSession(sessionId, assistantMessage).catchError((e) {
          if (kDebugMode) {
            print('🔴 Failed to save quick response: $e');
          }
        });
        return assistantMessage;
      }

            // Check if service is available
      final isAvailable = await _openRouterService.isServiceAvailable();
      if (!isAvailable) {
        if (kDebugMode) {
          print('🔴 OpenRouter service unavailable');
        }
        
        // Try to provide offline response for common topics
        final offlineResponse = _openRouterService.getOfflineResponse(
          userMessage,
        );
        if (offlineResponse != null) {
          if (kDebugMode) {
            print('🟡 Using offline response for topic');
          }
          final assistantMessage = ChatMessage.assistant(offlineResponse);
          // Save offline response in background
          _saveMessageToSession(sessionId, assistantMessage).catchError((e) {
            if (kDebugMode) {
              print('🔴 Failed to save offline response: $e');
            }
          });
          return assistantMessage;
        }
        
        final errorMessage = ChatMessage.assistant(
          'I\'m currently experiencing connectivity issues, but I can still help with basic questions about the Constitution. '
          'Try asking about fundamental rights, voting, employment, or land rights. '
          'I\'ll try to reconnect automatically for your next question.',
        );
        // Save offline message in background
        _saveMessageToSession(sessionId, errorMessage).catchError((e) {
          if (kDebugMode) {
            print('🔴 Failed to save offline message: $e');
          }
        });
        return errorMessage;
      }

      if (kDebugMode) {
        print('🔵 Sending message to OpenRouter API');
      }

      // Get AI response
      final response = await _openRouterService.sendMessage(
        userMessage,
        conversationHistory,
      );

      ChatMessage assistantMessage;
      if (response.success) {
        assistantMessage = ChatMessage.assistant(response.content);
        if (kDebugMode) {
          print('🟢 Received successful AI response');
        }
      } else {
        // Try offline response before showing error
        final offlineResponse = _openRouterService.getOfflineResponse(
          userMessage,
        );
        if (offlineResponse != null) {
          if (kDebugMode) {
            print('🟡 Using offline response due to API error');
          }
          assistantMessage = ChatMessage.assistant(offlineResponse);
        } else {
          assistantMessage = ChatMessage.error(
            response.error ?? 'Unknown error',
          );
          if (kDebugMode) {
            print('🔴 AI response error: ${response.error}');
          }
        }
      }

      // Save to Firestore in background, don't block the response
      _saveMessageToSession(sessionId, assistantMessage).catchError((e) {
        if (kDebugMode) {
          print('🔴 Failed to save AI response: $e');
        }
      });

      return assistantMessage;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error in sendMessage: $e');
        print('🔴 Stack trace: ${StackTrace.current}');
      }

      final errorMessage = ChatMessage.error(
        'I\'m having trouble connecting to my AI service right now. Please check your internet connection and try again. If the problem persists, you can still ask me basic questions about the Constitution and I\'ll do my best to help.',
      );

      // Try to save error message, but don't block on it
      _saveMessageToSession(sessionId, errorMessage).catchError((saveError) {
        if (kDebugMode) {
          print('🔴 Failed to save error message: $saveError');
        }
      });

      return errorMessage;
    }
  }

  // Save a message to a chat session
  Future<void> _saveMessageToSession(
    String sessionId,
    ChatMessage message,
  ) async {
    try {
      if (kDebugMode) {
        print('🔵 Attempting to save message to session: $sessionId');
      }

      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('🔴 User not authenticated, cannot save to Firestore');
        }
        // Store offline for later sync when user logs in
        await _offlineService.storePendingOperation('saveChatMessage', {
          'sessionId': sessionId,
          'message': message.toMap(),
        });
        return;
      }

      final sessionRef = _chatsCollection.doc(sessionId);

      // Use a simpler approach instead of transaction for better reliability
      final sessionDoc = await sessionRef.get();

      if (sessionDoc.exists) {
        final session = ChatSession.fromFirestore(sessionDoc);
        final updatedMessages = [...session.messages, message];

        final updatedSession = session.copyWith(
          messages: updatedMessages,
          lastUpdated: DateTime.now(),
        );

        await sessionRef.update(updatedSession.toFirestore());

        if (kDebugMode) {
          print('🟢 Message saved successfully to Firestore');
        }
      } else {
        if (kDebugMode) {
          print('🔴 Session document does not exist: $sessionId');
        }
        // Store offline for later sync
        await _offlineService.storePendingOperation('saveChatMessage', {
          'sessionId': sessionId,
          'message': message.toMap(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error saving message to session: $e');
        print('🔴 Error type: ${e.runtimeType}');
      }

      // Store offline for later sync
      try {
        await _offlineService.storePendingOperation('saveChatMessage', {
          'sessionId': sessionId,
          'message': message.toMap(),
        });
        if (kDebugMode) {
          print('🟡 Stored pending operation: saveChatMessage');
        }
      } catch (offlineError) {
        if (kDebugMode) {
          print('🔴 Failed to store offline operation: $offlineError');
        }
      }
    }
  }

  // Update chat session
  Future<void> updateChatSession(ChatSession session) async {
    try {
      await _chatsCollection.doc(session.id).update(session.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating chat session: $e');
      }
      // Store offline for later sync
      await _offlineService.storePendingOperation('updateChatSession', {
        'sessionId': session.id,
        'session': session.toFirestore(),
      });
    }
  }

  // Delete a chat session
  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _chatsCollection.doc(sessionId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting chat session: $e');
      }
      // Store offline for later sync
      await _offlineService.storePendingOperation('deleteChatSession', {
        'sessionId': sessionId,
      });
    }
  }

  // Get chat session stream for real-time updates
  Stream<ChatSession?> getChatSessionStream(String sessionId) {
    return _chatsCollection.doc(sessionId).snapshots().map((doc) {
      if (doc.exists) {
        return ChatSession.fromFirestore(doc);
      }
      return null;
    });
  }

  // Get user's chat sessions stream
  Stream<List<ChatSession>> getUserChatSessionsStream(String userId) {
    return _chatsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('lastUpdated', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatSession.fromFirestore(doc))
              .toList(),
        );
  }

  // Get suggested questions
  List<String> getSuggestedQuestions() {
    return _openRouterService.getSuggestedQuestions();
  }

  // Search chat history
  Future<List<ChatMessage>> searchChatHistory(
    String userId,
    String query,
  ) async {
    try {
      final sessions = await getUserChatSessions(userId);
      final allMessages = <ChatMessage>[];

      for (final session in sessions) {
        final matchingMessages = session.messages.where(
          (message) =>
              message.content.toLowerCase().contains(query.toLowerCase()),
        );
        allMessages.addAll(matchingMessages);
      }

      // Sort by timestamp, most recent first
      allMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allMessages.take(50).toList(); // Limit to 50 results
    } catch (e) {
      if (kDebugMode) {
        print('Error searching chat history: $e');
      }
      return [];
    }
  }

  // Get chat statistics
  Future<Map<String, dynamic>> getChatStatistics(String userId) async {
    try {
      final sessions = await getUserChatSessions(userId);

      int totalMessages = 0;
      int totalSessions = sessions.length;
      DateTime? firstChatDate;
      DateTime? lastChatDate;

      for (final session in sessions) {
        totalMessages += session.messages.length;

        if (firstChatDate == null ||
            session.createdAt.isBefore(firstChatDate)) {
          firstChatDate = session.createdAt;
        }

        if (lastChatDate == null || session.lastUpdated.isAfter(lastChatDate)) {
          lastChatDate = session.lastUpdated;
        }
      }

      return {
        'totalSessions': totalSessions,
        'totalMessages': totalMessages,
        'firstChatDate': firstChatDate,
        'lastChatDate': lastChatDate,
        'averageMessagesPerSession': totalSessions > 0
            ? totalMessages / totalSessions
            : 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting chat statistics: $e');
      }
      return {};
    }
  }
}
