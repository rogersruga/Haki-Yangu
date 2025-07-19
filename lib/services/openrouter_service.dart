import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKey = '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';
  static const String _model = 'tngtech/deepseek-r1t2-chimera:free';

  // Validate API key format
  static bool get _isApiKeyValid {
    return _apiKey.isNotEmpty &&
           _apiKey.startsWith('sk-or-v1-') &&
           _apiKey.length > 20;
  }

  // Headers following OpenRouter documentation format
  static Map<String, String> get _headers => {
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
      // Validate API key first
      if (!_isApiKeyValid) {
        if (kDebugMode) {
          print('🔴 Invalid API key format');
        }
        return OpenRouterResponse.error('Invalid API key configuration');
      }

      // Build conversation context
      final messages = _buildMessages(userMessage, conversationHistory);

      // Create request body following OpenRouter documentation exactly
      final requestBody = {
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1000,
      };

      if (kDebugMode) {
        print('🔵 Sending request to OpenRouter API');
        print('🔵 Model: $_model');
        print('🔵 Message count: ${messages.length}');
        print('🔵 API Key (first 20 chars): ${_apiKey.substring(0, 20)}...');
        print('🔵 Authorization header: Bearer ${_apiKey.substring(0, 20)}...');
      }

      final uri = Uri.parse('$_baseUrl/chat/completions');
      final headers = _headers;
      final body = jsonEncode(requestBody);

      if (kDebugMode) {
        print('🔵 Request URI: $uri');
        print('🔵 Request headers: $headers');
        print('🔵 Request body: $body');
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('OpenRouter response status: ${response.statusCode}');
        print('OpenRouter response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'] as String;

          if (kDebugMode) {
            print('🟢 AI Response received: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
          }

          return OpenRouterResponse.success(content.trim());
        } else {
          if (kDebugMode) {
            print('🔴 No choices in API response: $data');
          }
          return OpenRouterResponse.error('No response from AI model');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error occurred';

        if (kDebugMode) {
          print('🔴 API Error ${response.statusCode}: $errorMessage');
        }

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

    // Add conversation history (last 15 messages to provide better context)
    final recentHistory = conversationHistory
        .where((msg) => !msg.isLoading && msg.error == null)
        .toList();

    // Take the most recent messages, but ensure we have enough context
    final historyToInclude = recentHistory.length > 15
        ? recentHistory.sublist(recentHistory.length - 15)
        : recentHistory;

    for (final message in historyToInclude) {
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

    if (kDebugMode) {
      print('🔵 Sending ${messages.length} messages to AI (${historyToInclude.length} history + 1 system + 1 current)');
    }

    return messages;
  }

  // Quick response for common queries (only for initial greetings)
  String? getQuickResponse(String userMessage, List<ChatMessage> conversationHistory) {
    final message = userMessage.toLowerCase().trim();

    // Only provide quick responses for greetings if this is the start of conversation
    // or if there are very few messages (to avoid interrupting ongoing conversations)
    if (conversationHistory.length > 2) {
      return null; // Let AI handle follow-up questions in ongoing conversations
    }

    // Only respond to direct greetings, not keywords within longer messages
    if (message.length > 20) {
      return null; // Longer messages should go to AI for proper context understanding
    }

    // Check for exact greetings only
    final greetings = ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening'];
    for (final greeting in greetings) {
      if (message == greeting || message.startsWith('$greeting ')) {
        return ConstitutionContext.quickResponses[greeting] ?? ConstitutionContext.quickResponses['hello'];
      }
    }

    return null; // Let AI handle everything else for better conversation flow
  }

  // Check if the service is available
  Future<bool> isServiceAvailable() async {
    try {
      if (kDebugMode) {
        print('🔵 Checking OpenRouter service availability...');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5)); // Reduced timeout

      if (kDebugMode) {
        print('🔵 Service check response: ${response.statusCode}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Service availability check failed: $e');
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

  // Test with the exact format from OpenRouter documentation
  Future<Map<String, dynamic>> testExactDocumentationFormat() async {
    final results = <String, dynamic>{};

    try {
      if (kDebugMode) {
        print('🔵 Testing with exact OpenRouter documentation format...');
      }

      // Exact format from the documentation
      final requestBody = {
        'model': 'tngtech/deepseek-r1t2-chimera:free',
        'messages': [
          {
            'role': 'user',
            'content': 'What is the meaning of life?'
          }
        ]
      };

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://haki-yangu.app',
        'X-Title': 'Haki Yangu - Civic Education App',
      };

      if (kDebugMode) {
        print('🔵 Exact test headers: $headers');
        print('🔵 Exact test body: ${jsonEncode(requestBody)}');
      }

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      results['status_code'] = response.statusCode;
      results['response_body'] = response.body;

      if (kDebugMode) {
        print('🔵 Exact test response status: ${response.statusCode}');
        print('🔵 Exact test response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        results['success'] = true;
        results['content'] = data['choices']?[0]?['message']?['content'] ?? 'No content';
        results['message'] = 'Exact documentation format test successful';
      } else {
        results['success'] = false;
        final errorData = jsonDecode(response.body);
        results['error'] = errorData['error']?['message'] ?? 'Unknown error';
        results['message'] = 'Exact format test failed';
      }
    } catch (e) {
      results['success'] = false;
      results['error'] = e.toString();
      results['message'] = 'Exact format test failed with exception';

      if (kDebugMode) {
        print('🔴 Exact test error: $e');
      }
    }

    return results;
  }

  // Test API connectivity and authentication
  Future<Map<String, dynamic>> testApiConnectivity() async {
    final results = <String, dynamic>{};

    try {
      if (kDebugMode) {
        print('🔵 Testing OpenRouter API connectivity...');
      }

      // Simple test request following OpenRouter format exactly
      final testRequestBody = {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': 'Hello, this is a test message.'},
        ],
        'temperature': 0.7,
        'max_tokens': 50,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: jsonEncode(testRequestBody),
      ).timeout(const Duration(seconds: 10));

      results['status_code'] = response.statusCode;
      results['response_body'] = response.body;

      if (kDebugMode) {
        print('🔵 Test response status: ${response.statusCode}');
        print('🔵 Test response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        results['success'] = true;
        results['model_used'] = data['model'] ?? 'unknown';
        results['message'] = 'API connectivity test successful';

        if (data['choices'] != null && data['choices'].isNotEmpty) {
          results['test_response'] = data['choices'][0]['message']['content'];
        }
      } else {
        results['success'] = false;
        final errorData = jsonDecode(response.body);
        results['error'] = errorData['error']?['message'] ?? 'Unknown error';
        results['message'] = 'API test failed with status ${response.statusCode}';
      }
    } catch (e) {
      results['success'] = false;
      results['error'] = e.toString();
      results['message'] = 'API connectivity test failed';

      if (kDebugMode) {
        print('🔴 Test API error: $e');
      }
    }

    return results;
  }
}
