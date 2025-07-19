# Haki AI Chatbot Integration Guide

## Overview

The Haki AI Chatbot is an intelligent assistant specialized in Kenyan constitutional law and civic education. It uses OpenRouter's API to provide accurate, contextual responses about the Constitution of Kenya 2010 and various acts of parliament.

## Features

### 🤖 **AI-Powered Responses**
- Powered by DeepSeek R1 model via OpenRouter API
- Specialized in Kenyan constitutional law
- Context-aware responses based on user queries
- Quick responses for common questions

### 📚 **Knowledge Base**
The chatbot has comprehensive knowledge of:
- **Constitution of Kenya 2010** - Supreme law and governance
- **Bill of Rights** (Articles 19-59) - Fundamental rights and freedoms
- **Elections Act** - Electoral processes and voting rights
- **Employment Act** (Cap 226) - Workers' rights and labor laws
- **Land Act** (No. 6 of 2012) - Land ownership and management
- **Health Act** - Healthcare rights and public health
- **National Gender and Equality Commission Act** - Anti-discrimination laws

### 💬 **Chat Features**
- Real-time messaging interface
- Message history and session management
- Suggested questions for common topics
- Loading indicators and error handling
- Offline support with graceful degradation

### 🔒 **Security & Privacy**
- User authentication required
- Personal chat sessions stored in Firestore
- Secure API communication
- Data encryption and privacy protection

## Technical Implementation

### Architecture
```
User Interface (HakiChatScreen)
    ↓
Chat Service (ChatService)
    ↓
OpenRouter Service (OpenRouterService)
    ↓
OpenRouter API (DeepSeek R1 Model)
```

### Key Components

1. **HakiChatScreen** - Main chat interface
2. **ChatService** - Manages chat sessions and Firestore integration
3. **OpenRouterService** - Handles API communication
4. **ChatModels** - Data models for messages and sessions
5. **ConstitutionContext** - Specialized prompts and context

### API Configuration
- **Provider**: OpenRouter (https://openrouter.ai)
- **Model**: deepseek/deepseek-r1-0528:free
- **API Key**: Securely configured in OpenRouterService
- **Headers**: Includes app identification for rankings

## Usage

### Accessing Haki Chat
1. Navigate to Home Screen or Main Screen
2. Tap the "Ask Haki" button (orange chat icon)
3. Start asking questions about constitutional law

### Sample Questions
- "What are my fundamental rights under the Constitution?"
- "How do I register to vote in Kenya?"
- "What are my rights as an employee?"
- "How does devolution work in Kenya?"
- "What is the Bill of Rights?"
- "How can I access public information?"
- "What are my land rights?"
- "What should I do if my rights are violated?"

### Quick Responses
The system provides instant responses for common greetings and basic questions:
- Hello/Hi → Welcome message
- Rights → Bill of Rights overview
- Voting → Electoral information
- Employment → Workers' rights
- Land → Land Act information
- Gender → Equality laws
- Health → Healthcare rights

## Data Storage

### Chat Sessions
- Stored in Firestore under `/chats` collection
- Each user has their own chat sessions
- Real-time synchronization across devices
- Offline support with local caching

### Message Structure
```dart
{
  id: String,
  content: String,
  type: MessageType (user/assistant),
  timestamp: DateTime,
  isLoading: Boolean,
  error: String?
}
```

### Session Structure
```dart
{
  id: String,
  userId: String,
  title: String,
  messages: List<ChatMessage>,
  createdAt: DateTime,
  lastUpdated: DateTime
}
```

## Error Handling

### Network Issues
- Graceful degradation when API is unavailable
- Quick responses for basic questions when offline
- User-friendly error messages
- Retry mechanisms for failed requests

### API Errors
- Comprehensive error parsing
- Fallback responses for service issues
- Logging for debugging purposes
- User notification of temporary issues

## Security Rules

### Firestore Rules
```javascript
// Chat sessions - users can only access their own chats
match /chats/{chatId} {
  allow read, write: if request.auth != null && 
                     request.auth.uid == resource.data.userId;
  allow create: if request.auth != null && 
               request.auth.uid == request.resource.data.userId;
}
```

## Performance Optimization

### Message Limits
- Conversation history limited to last 10 messages
- Prevents token limit issues
- Maintains context while optimizing performance

### Caching
- Quick responses cached locally
- Session data cached for offline access
- Efficient message loading and display

### API Optimization
- Request batching where possible
- Timeout handling (10 seconds)
- Connection pooling and reuse

## Monitoring & Analytics

### Usage Tracking
- Chat session statistics
- Message count and frequency
- Popular topics and questions
- User engagement metrics

### Error Monitoring
- API failure rates
- Network connectivity issues
- User-reported problems
- Performance bottlenecks

## Future Enhancements

### Planned Features
- [ ] Voice input and output
- [ ] Document upload and analysis
- [ ] Multi-language support (Swahili)
- [ ] Advanced search in chat history
- [ ] Bookmarking important responses
- [ ] Integration with legal resources
- [ ] Offline AI model for basic queries
- [ ] Push notifications for legal updates

### Technical Improvements
- [ ] Response caching for common questions
- [ ] Advanced context understanding
- [ ] Integration with PDF documents
- [ ] Real-time collaboration features
- [ ] Advanced analytics dashboard

## Troubleshooting

### Common Issues

1. **Chat not loading**
   - Check internet connection
   - Verify user authentication
   - Check Firestore permissions

2. **API errors**
   - Verify OpenRouter API key
   - Check API service status
   - Review request format

3. **Slow responses**
   - Check network connectivity
   - Monitor API response times
   - Review message history size

### Debug Commands
```bash
flutter analyze                    # Check for code issues
flutter run --debug               # Run with debugging
flutter logs                      # View runtime logs
```

## Support

For issues related to the Haki chatbot:
1. Check the error logs in debug mode
2. Verify network connectivity and API status
3. Review Firestore security rules
4. Test with suggested questions
5. Monitor chat service status

## Legal Disclaimer

The Haki AI chatbot provides educational information about Kenyan law and is not a substitute for professional legal advice. Users should always consult qualified legal professionals for specific legal matters and verify current information as laws may change.
