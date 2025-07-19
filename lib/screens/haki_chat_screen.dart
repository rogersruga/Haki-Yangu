import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../services/openrouter_service.dart';
import '../services/error_handler.dart';

class HakiChatScreen extends StatefulWidget {
  final String? sessionId;

  const HakiChatScreen({super.key, this.sessionId});

  @override
  State<HakiChatScreen> createState() => _HakiChatScreenState();
}

class _HakiChatScreenState extends State<HakiChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Please log in to use Haki chat');
        return;
      }

      if (widget.sessionId != null) {
        // Load existing session
        _currentSession = await _chatService.getChatSession(widget.sessionId!);
        if (_currentSession != null) {
          setState(() {
            _messages = _currentSession!.messages;
          });
        }
      } else {
        // Create new session
        _currentSession = await _chatService.createChatSession(user.uid);
        
        // Add welcome message
        final welcomeMessage = ChatMessage.assistant(
          'Hello! I\'m Haki, your AI assistant for Kenyan constitutional law and civic education. '
          'I can help you understand your rights, the Constitution, and various acts of parliament. '
          'What would you like to learn about today?'
        );
        
        setState(() {
          _messages = [welcomeMessage];
        });
      }
    } catch (e) {
      _showError('Failed to initialize chat: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isSending || _currentSession == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    // Add user message
    final userMessage = ChatMessage.user(messageText);
    setState(() {
      _messages.add(userMessage);
    });
    _scrollToBottom();

    // Add loading message
    final loadingMessage = ChatMessage.loading();
    setState(() {
      _messages.add(loadingMessage);
    });
    _scrollToBottom();

    try {
      // Get AI response with proper conversation history
      // Include all non-loading, non-error messages for context
      final conversationHistory = _messages
          .where((m) => !m.isLoading && m.error == null)
          .toList();

      final response = await _chatService.sendMessage(
        _currentSession!.id,
        messageText,
        conversationHistory,
      );

      // Remove loading message and add response
      setState(() {
        _messages.removeLast(); // Remove loading message
        _messages.add(response);
      });
      _scrollToBottom();
    } catch (e) {
      // Remove loading message and add error
      setState(() {
        _messages.removeLast(); // Remove loading message
        _messages.add(ChatMessage.error(e.toString()));
      });
      _scrollToBottom();
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (mounted) {
      ErrorHandler.handleError(message, 'chat', context: context);
    }
  }

  void _showSuggestedQuestions() {
    final suggestions = _chatService.getSuggestedQuestions();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suggested Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (kDebugMode)
                  TextButton(
                    onPressed: _runDiagnostics,
                    child: const Text('🔧 Diagnostics'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestions.map((question) => ListTile(
              title: Text(question),
              onTap: () {
                Navigator.pop(context);
                _messageController.text = question;
                _sendMessage();
              },
            )),
          ],
        ),
      ),
    );
  }

  // Debug method to test API and Firestore connectivity
  Future<void> _runDiagnostics() async {
    if (!kDebugMode) return;

    Navigator.pop(context); // Close the bottom sheet

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Running Diagnostics...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing API and database connectivity'),
          ],
        ),
      ),
    );

    try {
      // Test OpenRouter API with exact documentation format
      final exactResults = await OpenRouterService().testExactDocumentationFormat();

      // Test regular API connectivity
      final apiResults = await OpenRouterService().testApiConnectivity();

      // Test Firebase Auth
      final user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Diagnostic Results'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔐 User Auth: ${user != null ? "✅ Logged in as ${user.email}" : "❌ Not logged in"}'),
                  const SizedBox(height: 8),
                  Text('🧪 Exact Format Test: ${exactResults['success'] ? "✅" : "❌"} ${exactResults['message']}'),
                  if (exactResults['error'] != null) ...[
                    const SizedBox(height: 4),
                    Text('Exact Error: ${exactResults['error']}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 8),
                  Text('🤖 API Status: ${apiResults['success'] ? "✅" : "❌"} ${apiResults['message']}'),
                  if (apiResults['error'] != null) ...[
                    const SizedBox(height: 4),
                    Text('API Error: ${apiResults['error']}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 8),
                  Text('📱 Session: ${_currentSession?.id ?? "No session"}'),
                  const SizedBox(height: 8),
                  Text('💬 Messages: ${_messages.length}'),
                  const SizedBox(height: 8),
                  Text('🔧 Model: tngtech/deepseek-r1t2-chimera:free'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showError('Diagnostics failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF1B5E20),
              child: Text(
                'H',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haki',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AI Constitutional Assistant',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showSuggestedQuestions,
            tooltip: 'Suggested Questions',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                ),
                
                // Input area
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF1B5E20),
            child: Icon(
              Icons.chat,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to Haki Chat!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about Kenyan constitutional law,\nyour rights, and civic education.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showSuggestedQuestions,
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('See Suggested Questions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    final isLoading = message.isLoading;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF1B5E20),
              child: Text(
                'H',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1B5E20) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLoading
                  ? _buildLoadingIndicator()
                  : Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Haki is thinking...',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask Haki about your rights...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isSending,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF1B5E20),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
