import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKey =
      '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';
  static const String _model = 'tngtech/deepseek-r1t2-chimera:free';

  // Validate API key format
  static bool get _isApiKeyValid {
    final isValid =
        _apiKey.isNotEmpty &&
        _apiKey.startsWith('sk-or-v1-') &&
        _apiKey.length > 20;

    if (kDebugMode) {
      print('🔵 API Key validation:');
      print('  - Is empty: ${_apiKey.isEmpty}');
      print('  - Starts with sk-or-v1-: ${_apiKey.startsWith('sk-or-v1-')}');
      print('  - Length > 20: ${_apiKey.length > 20}');
      print('  - Final result: $isValid');
    }

    return isValid;
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
        print('🔵 Full API key: $_apiKey');
      }

      final uri = Uri.parse('$_baseUrl/chat/completions');
      final headers = _headers;
      final body = jsonEncode(requestBody);

      if (kDebugMode) {
        print('🔵 Request URI: $uri');
        print('🔵 Request headers: $headers');
        print('🔵 Full API key length: ${_apiKey.length}');
        print('🔵 API key format valid: ${_isApiKeyValid}');
      }

      // Add retry logic for network issues
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          final response = await http
              .post(uri, headers: headers, body: body)
              .timeout(const Duration(seconds: 15));

          if (kDebugMode) {
            print('OpenRouter response status: ${response.statusCode}');
            print('OpenRouter response body: ${response.body}');
          }

                if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            if (kDebugMode) {
              print('🟢 Full API response: $data');
            }

            if (data['choices'] != null && data['choices'].isNotEmpty) {
              final content = data['choices'][0]['message']['content'] as String;

              if (kDebugMode) {
                print(
                  '🟢 AI Response received: ${content.substring(0, content.length > 100 ? 100 : content.length)}...',
                );
              }

              return OpenRouterResponse.success(content.trim());
            } else {
              if (kDebugMode) {
                print('🔴 No choices in API response: $data');
              }
              return OpenRouterResponse.error(
                'No response from AI model - please try again',
              );
            }
          } else {
            if (kDebugMode) {
              print('🔴 HTTP Error ${response.statusCode}: ${response.body}');
            }

            String errorMessage;
            try {
              final errorData = jsonDecode(response.body);
              errorMessage =
                  errorData['error']?['message'] ?? 'Unknown error occurred';
            } catch (e) {
              errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
            }

            if (kDebugMode) {
              print('🔴 API Error ${response.statusCode}: $errorMessage');
            }

            // If it's a 401 error, don't retry as it's an authentication issue
            if (response.statusCode == 401) {
              return OpenRouterResponse.error(
                'Authentication failed. Please check your API key configuration.',
              );
            }
            
            // For other errors, retry if we haven't exceeded max retries
            if (retryCount < maxRetries - 1) {
              retryCount++;
              if (kDebugMode) {
                print('🔄 Retrying request (attempt ${retryCount + 1}/$maxRetries)...');
              }
              await Future.delayed(Duration(seconds: retryCount * 2)); // Exponential backoff
              continue;
            }
            
            // Provide more specific error messages for final attempt
            if (response.statusCode == 429) {
              return OpenRouterResponse.error(
                'Rate limit exceeded. Please try again later.',
              );
            } else if (response.statusCode == 500) {
              return OpenRouterResponse.error(
                'Server error. Please try again later.',
              );
            } else {
              return OpenRouterResponse.error('API Error: $errorMessage');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('🔴 Network error on attempt ${retryCount + 1}: $e');
          }
          
          if (retryCount < maxRetries - 1) {
            retryCount++;
            if (kDebugMode) {
              print('🔄 Retrying request (attempt ${retryCount + 1}/$maxRetries)...');
            }
            await Future.delayed(Duration(seconds: retryCount * 2)); // Exponential backoff
            continue;
          }
          
          // If all retries failed, throw the error
          rethrow;
        }
      }
      
      // This should never be reached, but just in case
      return OpenRouterResponse.error('Request failed after $maxRetries attempts');
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
    final systemContent =
        ConstitutionContext.systemPrompt +
        (topicContext.isNotEmpty ? '\n\n$topicContext' : '');

    messages.add({'role': 'system', 'content': systemContent});

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
    messages.add({'role': 'user', 'content': userMessage});

    if (kDebugMode) {
      print(
        '🔵 Sending ${messages.length} messages to AI (${historyToInclude.length} history + 1 system + 1 current)',
      );
      print('🔵 Conversation history:');
      for (int i = 0; i < historyToInclude.length; i++) {
        final msg = historyToInclude[i];
        print(
          '  ${i + 1}. ${msg.type.name}: ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...',
        );
      }
    }

    return messages;
  }

  // Quick response for common queries (only for initial greetings)
  String? getQuickResponse(
    String userMessage,
    List<ChatMessage> conversationHistory,
  ) {
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
    final greetings = [
      'hello',
      'hi',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
    ];
    for (final greeting in greetings) {
      if (message == greeting || message.startsWith('$greeting ')) {
        return ConstitutionContext.quickResponses[greeting] ??
            ConstitutionContext.quickResponses['hello'];
      }
    }

    return null; // Let AI handle everything else for better conversation flow
  }

  // Offline fallback responses for common topics
  String? getOfflineResponse(String userMessage) {
    final message = userMessage.toLowerCase().trim();

    // Basic offline responses for common constitutional topics
    if (message.contains('rights') || message.contains('constitution')) {
      return 'The Bill of Rights (Articles 19-59 of the Constitution) guarantees fundamental rights including equality, life, liberty, security, privacy, expression, assembly, movement, and property. These rights are protected and can only be limited in specific circumstances as provided by law.';
    }

    if (message.contains('vote') || message.contains('election')) {
      return 'Under Article 38 of the Constitution, every Kenyan citizen has the right to vote. You must register with IEBC, be 18 years or older, and have a valid ID. Elections are held every 5 years for President, Governors, MPs, and County Representatives.';
    }

    if (message.contains('employment') || message.contains('work')) {
      return 'The Employment Act protects workers\' rights including fair wages, safe working conditions, leave entitlements, and protection from unfair dismissal. Article 41 of the Constitution guarantees fair labor practices and the right to form trade unions.';
    }

    if (message.contains('land') || message.contains('property')) {
      return 'Land rights are protected under Chapter 5 of the Constitution and the Land Act. Kenyans have rights to own, use, and transfer land. The government can only acquire land for public use with fair compensation. Community land rights are also protected.';
    }

    if (message.contains('gender') || message.contains('women')) {
      return 'Article 27 guarantees equality and prohibits discrimination based on gender. The Constitution promotes women\'s representation in government and protects against gender-based violence. The two-thirds gender rule ensures women\'s participation in leadership.';
    }

    if (message.contains('health') || message.contains('medical')) {
      return 'Article 43 guarantees the right to healthcare. The Health Act provides for accessible, affordable, and quality healthcare services. The government must provide emergency treatment and essential health services to all Kenyans.';
    }

    return null; // Let the main error handling take over
  }

  // Check if the service is available
  Future<bool> isServiceAvailable() async {
    try {
      if (kDebugMode) {
        print('🔵 Checking OpenRouter service availability...');
      }

      // Try a simple chat completion test instead of models endpoint
      final testRequestBody = {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'max_tokens': 5,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: _headers,
            body: jsonEncode(testRequestBody),
          )
          .timeout(const Duration(seconds: 8));

      if (kDebugMode) {
        print('🔵 Service check response: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('🔵 Service check response body: ${response.body}');
        }
      }

      // Consider both 200 and 401 as "available" since 401 means the service is reachable
      // but there might be an auth issue that could be resolved
      return response.statusCode == 200 || response.statusCode == 401;
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

    if (message.contains('employment') ||
        message.contains('work') ||
        message.contains('job')) {
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

    if (message.contains('gender') ||
        message.contains('women') ||
        message.contains('equality')) {
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
          {'role': 'user', 'content': 'What is the meaning of life?'},
        ],
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

      final response = await http
          .post(
            Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      results['status_code'] = response.statusCode;
      results['response_body'] = response.body;

      if (kDebugMode) {
        print('🔵 Exact test response status: ${response.statusCode}');
        print('🔵 Exact test response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        results['success'] = true;
        results['content'] =
            data['choices']?[0]?['message']?['content'] ?? 'No content';
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

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: _headers,
            body: jsonEncode(testRequestBody),
          )
          .timeout(const Duration(seconds: 10));

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
        results['message'] =
            'API test failed with status ${response.statusCode}';
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

  // Simple test to verify API key and connection
  Future<Map<String, dynamic>> testSimpleConnection() async {
    final results = <String, dynamic>{};

    try {
      if (kDebugMode) {
        print('🔵 Testing simple connection with API key...');
        print('🔵 API Key (first 20 chars): ${_apiKey.substring(0, 20)}...');
      }

      // Very simple test request
      final testRequestBody = {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': 'Say hello'},
        ],
        'max_tokens': 10,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: _headers,
            body: jsonEncode(testRequestBody),
          )
          .timeout(const Duration(seconds: 10));

      results['status_code'] = response.statusCode;
      results['response_body'] = response.body;

      if (kDebugMode) {
        print('🔵 Simple test response status: ${response.statusCode}');
        print('🔵 Simple test response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        results['success'] = true;
        results['message'] = 'Simple connection test successful';

        if (data['choices'] != null && data['choices'].isNotEmpty) {
          results['test_response'] = data['choices'][0]['message']['content'];
        }
      } else {
        results['success'] = false;
        results['message'] =
            'Simple test failed with status ${response.statusCode}';
        results['error'] = response.body;
      }
    } catch (e) {
      results['success'] = false;
      results['error'] = e.toString();
      results['message'] = 'Simple connection test failed';

      if (kDebugMode) {
        print('🔴 Simple test error: $e');
      }
    }

    return results;
  }

  // Test API key authentication
  Future<Map<String, dynamic>> testApiKeyAuthentication() async {
    final results = <String, dynamic>{};

    try {
      if (kDebugMode) {
        print('🔵 Testing API key authentication...');
        print('🔵 API Key length: ${_apiKey.length}');
        print('🔵 API Key starts with: ${_apiKey.substring(0, 10)}...');
      }

      // Simple test with minimal request
      final testRequestBody = {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'max_tokens': 10,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: _headers,
            body: jsonEncode(testRequestBody),
          )
          .timeout(const Duration(seconds: 10));

      results['status_code'] = response.statusCode;
      results['response_body'] = response.body;

      if (kDebugMode) {
        print('🔵 Auth test response status: ${response.statusCode}');
        print('🔵 Auth test response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        results['success'] = true;
        results['message'] = 'API key authentication successful';

        if (data['choices'] != null && data['choices'].isNotEmpty) {
          results['test_response'] = data['choices'][0]['message']['content'];
        }
      } else if (response.statusCode == 401) {
        results['success'] = false;
        results['message'] = 'API key authentication failed - 401 Unauthorized';
        results['error'] = response.body;

        if (kDebugMode) {
          print('🔴 API key authentication failed');
          print('🔴 Check if API key is valid and has proper permissions');
        }
      } else {
        results['success'] = false;
        results['message'] =
            'API key test failed with status ${response.statusCode}';
        results['error'] = response.body;
      }
    } catch (e) {
      results['success'] = false;
      results['error'] = e.toString();
      results['message'] = 'API key authentication test failed';

      if (kDebugMode) {
        print('🔴 Auth test error: $e');
      }
    }

    return results;
  }
}
