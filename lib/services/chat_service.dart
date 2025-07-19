import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Check for quick responses first
      final quickResponse = _openRouterService.getQuickResponse(userMessage);
      if (quickResponse != null) {
        final assistantMessage = ChatMessage.assistant(quickResponse);
        await _saveMessageToSession(sessionId, assistantMessage);
        return assistantMessage;
      }

      // Check if service is available
      final isAvailable = await _openRouterService.isServiceAvailable();
      if (!isAvailable) {
        final errorMessage = ChatMessage.assistant(
          'I\'m currently offline, but I can still help with basic questions. '
          'Try asking about fundamental rights, voting, or employment rights.',
        );
        await _saveMessageToSession(sessionId, errorMessage);
        return errorMessage;
      }

      // Get AI response
      final response = await _openRouterService.sendMessage(
        userMessage,
        conversationHistory,
      );

      ChatMessage assistantMessage;
      if (response.success) {
        assistantMessage = ChatMessage.assistant(response.content);
      } else {
        assistantMessage = ChatMessage.error(response.error ?? 'Unknown error');
      }

      // Save to Firestore
      await _saveMessageToSession(sessionId, assistantMessage);
      
      return assistantMessage;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      
      final errorMessage = ChatMessage.error(e.toString());
      await _saveMessageToSession(sessionId, errorMessage);
      return errorMessage;
    }
  }

  // Save a message to a chat session
  Future<void> _saveMessageToSession(String sessionId, ChatMessage message) async {
    try {
      final sessionRef = _chatsCollection.doc(sessionId);
      
      await _firestoreService.firestore.runTransaction((transaction) async {
        final sessionDoc = await transaction.get(sessionRef);
        
        if (sessionDoc.exists) {
          final session = ChatSession.fromFirestore(sessionDoc);
          final updatedMessages = [...session.messages, message];
          
          final updatedSession = session.copyWith(
            messages: updatedMessages,
            lastUpdated: DateTime.now(),
          );
          
          transaction.update(sessionRef, updatedSession.toFirestore());
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving message to session: $e');
      }
      // Store offline for later sync
      await _offlineService.storePendingOperation(
        'saveChatMessage',
        {
          'sessionId': sessionId,
          'message': message.toMap(),
        },
      );
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
      await _offlineService.storePendingOperation(
        'updateChatSession',
        {
          'sessionId': session.id,
          'session': session.toFirestore(),
        },
      );
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
      await _offlineService.storePendingOperation(
        'deleteChatSession',
        {'sessionId': sessionId},
      );
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
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatSession.fromFirestore(doc))
            .toList());
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
        final matchingMessages = session.messages.where((message) =>
            message.content.toLowerCase().contains(query.toLowerCase()));
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
        
        if (firstChatDate == null || session.createdAt.isBefore(firstChatDate)) {
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
        'averageMessagesPerSession': totalSessions > 0 ? totalMessages / totalSessions : 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting chat statistics: $e');
      }
      return {};
    }
  }
}
