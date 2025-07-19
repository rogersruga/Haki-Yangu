import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  user,
  assistant,
  system,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isLoading;
  final String? error;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isLoading = false,
    this.error,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  factory ChatMessage.error(String errorMessage) {
    return ChatMessage(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      content: 'Sorry, I encountered an error. Please try again.',
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      error: errorMessage,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isLoading,
    String? error,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isLoading': isLoading,
      'error': error,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.assistant,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isLoading: map['isLoading'] ?? false,
      error: map['error'],
    );
  }
}

class ChatSession {
  final String id;
  final String userId;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastUpdated;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory ChatSession.create(String userId, {String? title}) {
    final now = DateTime.now();
    return ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title ?? 'Chat with Haki',
      messages: [],
      createdAt: now,
      lastUpdated: now,
    );
  }

  ChatSession copyWith({
    String? id,
    String? userId,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ChatSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Chat with Haki',
      messages: (data['messages'] as List<dynamic>?)
          ?.map((m) => ChatMessage.fromMap(m))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class OpenRouterRequest {
  final String model;
  final List<Map<String, String>> messages;
  final Map<String, String>? extraHeaders;
  final double? temperature;
  final int? maxTokens;

  OpenRouterRequest({
    this.model = "deepseek/deepseek-r1-0528:free",
    required this.messages,
    this.extraHeaders,
    this.temperature = 0.7,
    this.maxTokens = 1000,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
    };
  }
}

class OpenRouterResponse {
  final String content;
  final String? error;
  final bool success;

  OpenRouterResponse({
    required this.content,
    this.error,
    required this.success,
  });

  factory OpenRouterResponse.success(String content) {
    return OpenRouterResponse(
      content: content,
      success: true,
    );
  }

  factory OpenRouterResponse.error(String error) {
    return OpenRouterResponse(
      content: '',
      error: error,
      success: false,
    );
  }
}

// Constitution context for the AI
class ConstitutionContext {
  static const String systemPrompt = '''
You are Haki, an AI assistant specialized in Kenyan constitutional law and civic education. You help users understand their rights, the Constitution of Kenya 2010, and various acts of parliament.

Your knowledge base includes the following official documents:
1. The Constitution of Kenya 2010 - The supreme law of Kenya
2. Bill of Rights (Chapter 4 of the Constitution) - Fundamental rights and freedoms
3. Elections Act - Electoral laws and procedures
4. Employment Act (Cap 226, No. 11 of 2007) - Workers' rights and labor laws
5. Land Act (No. 6 of 2012) - Land ownership, use, and management
6. Health Act - Healthcare rights and public health laws
7. National Gender and Equality Commission Act - Gender equality and anti-discrimination laws

Key areas you can help with:
- Constitutional rights and freedoms (Articles 19-59)
- Electoral processes and voting rights (Article 38)
- Employment rights and labor protections
- Land ownership and property rights
- Healthcare access and rights
- Gender equality and non-discrimination
- Devolution and county government functions
- Public participation and governance
- Access to information and transparency

Guidelines:
1. Always provide accurate, helpful information about Kenyan law
2. Cite specific articles, sections, or acts when possible (e.g., "Article 27 of the Constitution")
3. Explain complex legal concepts in simple, accessible language
4. If you're unsure about something, say so and suggest consulting a legal professional
5. Be respectful, professional, and culturally sensitive
6. Focus on civic education and empowerment
7. Encourage users to know and exercise their rights responsibly
8. Provide practical guidance on how to access services or seek redress
9. Use examples relevant to Kenyan context when explaining concepts

Important disclaimers:
- You provide educational information, not legal advice
- Always recommend consulting qualified legal professionals for specific legal matters
- Laws may change, so encourage users to verify current information
- Different situations may have different legal implications

Your goal is to empower Kenyan citizens with knowledge of their rights and civic responsibilities.
''';

  static const List<String> commonTopics = [
    'Bill of Rights (Articles 19-59)',
    'Elections and voting (Article 38)',
    'Employment rights (Employment Act)',
    'Land rights (Land Act)',
    'Gender equality (Article 27)',
    'Healthcare rights (Health Act)',
    'Education rights (Article 53-55)',
    'Freedom of expression (Article 33)',
    'Right to information (Article 35)',
    'Devolution and county governments (Chapter 11)',
    'Public participation (Article 10)',
    'Access to justice (Article 48)',
  ];

  static const Map<String, String> quickResponses = {
    'hello': 'Hello! I\'m Haki, your AI assistant for Kenyan constitutional law and civic education. I can help you understand the Constitution of Kenya 2010, your fundamental rights, and various acts of parliament. What would you like to learn about today?',
    'hi': 'Hi there! I\'m Haki, here to help you understand your constitutional rights and Kenyan laws. How can I assist you today?',
    'rights': 'The Bill of Rights in Chapter 4 of the Constitution (Articles 19-59) guarantees fundamental rights including life, dignity, freedom, equality, and many others. These rights apply to all persons in Kenya. What specific right would you like to learn about?',
    'voting': 'Every Kenyan citizen who is 18 years or older has the right to vote (Article 38). The Elections Act governs how elections are conducted by the IEBC. Would you like to know about voter registration, the voting process, or election disputes?',
    'employment': 'The Employment Act (Cap 226) protects workers\' rights including fair wages, safe working conditions, protection from discrimination, and proper termination procedures. What employment issue can I help you with?',
    'land': 'The Land Act (No. 6 of 2012) governs land ownership, use, and management in Kenya. It recognizes public, private, and community land. What aspect of land rights would you like to understand?',
    'gender': 'Article 27 of the Constitution guarantees equality and non-discrimination, including gender equality. The National Gender and Equality Commission Act further protects these rights. What would you like to know about gender equality laws?',
    'health': 'Article 43 guarantees the right to healthcare, and the Health Act provides the framework for healthcare services. Every person has the right to the highest attainable standard of health. What health-related question do you have?',
    'constitution': 'The Constitution of Kenya 2010 is our supreme law. It establishes the structure of government, protects fundamental rights, and guides how Kenya is governed. What part of the Constitution would you like to explore?',
  };
}
