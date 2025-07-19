import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKey = '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';
  static const String _model = 'deepseek/deepseek-r1-0528:free';
  
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
    'HTTP-Referer': 'https://haki-yangu.app',
    'X-Title': 'Haki Yangu - Civic Education App',
  };

  static final OpenRouterService _instance = OpenRouterService._internal();
  factory OpenRouterService() => _instance;
  OpenRouterService._internal();

  Future<OpenRouterResponse> sendMessage(
    String userMessage,
    List<ChatMessage> conversationHistory,
  ) async {
    try {
      // Build conversation context
      final messages = _buildMessages(userMessage, conversationHistory);
      
      final request = OpenRouterRequest(
        model: _model,
        messages: messages,
        temperature: 0.7,
        maxTokens: 1000,
      );

      if (kDebugMode) {
        print('Sending request to OpenRouter: ${request.toJson()}');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (kDebugMode) {
        print('OpenRouter response status: ${response.statusCode}');
        print('OpenRouter response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'] as String;
          return OpenRouterResponse.success(content.trim());
        } else {
          return OpenRouterResponse.error('No response from AI model');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error occurred';
        return OpenRouterResponse.error('API Error: $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calling OpenRouter API: $e');
      }
      return OpenRouterResponse.error('Network error: ${e.toString()}');
    }
  }

  List<Map<String, String>> _buildMessages(
    String userMessage,
    List<ChatMessage> conversationHistory,
  ) {
    final messages = <Map<String, String>>[];

    // Add system prompt with topic-specific context
    final topicContext = _getTopicContext(userMessage);
    final systemContent = ConstitutionContext.systemPrompt +
        (topicContext.isNotEmpty ? '\n\n$topicContext' : '');

    messages.add({
      'role': 'system',
      'content': systemContent,
    });

    // Add conversation history (last 10 messages to avoid token limits)
    final recentHistory = conversationHistory
        .where((msg) => !msg.isLoading && msg.error == null)
        .toList()
        .reversed
        .take(10)
        .toList()
        .reversed
        .toList();

    for (final message in recentHistory) {
      messages.add({
        'role': message.type == MessageType.user ? 'user' : 'assistant',
        'content': message.content,
      });
    }

    // Add current user message
    messages.add({
      'role': 'user',
      'content': userMessage,
    });

    return messages;
  }

  // Quick response for common queries
  String? getQuickResponse(String userMessage) {
    final message = userMessage.toLowerCase().trim();
    
    for (final entry in ConstitutionContext.quickResponses.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }

  // Check if the service is available
  Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Service availability check failed: $e');
      }
      return false;
    }
  }

  // Get suggested questions based on common topics
  List<String> getSuggestedQuestions() {
    return [
      'What are my fundamental rights under the Constitution?',
      'How do I register to vote in Kenya?',
      'What are my rights as an employee under the Employment Act?',
      'How does devolution work in Kenya?',
      'What is the Bill of Rights and how does it protect me?',
      'How can I access public information under Article 35?',
      'What are my land rights under the Land Act?',
      'How are elections conducted in Kenya by the IEBC?',
      'What does Article 27 say about gender equality?',
      'What healthcare rights do I have under the Health Act?',
      'How can I participate in public decision-making?',
      'What should I do if my constitutional rights are violated?',
      'How does the Constitution protect workers?',
      'What are the functions of county governments?',
      'How can I access justice under Article 48?',
    ];
  }

  // Enhanced context for specific topics
  String _getTopicContext(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('vote') || message.contains('election')) {
      return '''
Context: The user is asking about voting or elections. Refer to:
- Article 38 of the Constitution (right to vote)
- The Elections Act
- IEBC procedures
- Voter registration requirements
''';
    }

    if (message.contains('employment') || message.contains('work') || message.contains('job')) {
      return '''
Context: The user is asking about employment. Refer to:
- The Employment Act
- Article 41 of the Constitution (fair labor practices)
- Workers' rights and protections
- Dispute resolution mechanisms
''';
    }

    if (message.contains('land') || message.contains('property')) {
      return '''
Context: The user is asking about land rights. Refer to:
- Chapter 5 of the Constitution (Land)
- The Land Act
- Community land rights
- Land acquisition and compensation
''';
    }

    if (message.contains('gender') || message.contains('women') || message.contains('equality')) {
      return '''
Context: The user is asking about gender equality. Refer to:
- Article 27 of the Constitution (equality and non-discrimination)
- The two-thirds gender rule
- Women's rights and protections
- Gender-based violence laws
''';
    }

    return '';
  }

  // Format response with proper citations and structure
  String formatResponse(String rawResponse) {
    // Add any post-processing here if needed
    return rawResponse;
  }
}
