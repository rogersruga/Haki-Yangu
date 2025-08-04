# Haki Yangu 🛡️🇰🇪

**Haki Yangu** (My Rights) is a comprehensive civic education mobile application built with Flutter that empowers Kenyan citizens with constitutional knowledge and legal awareness. The app transforms complex legal documents into accessible, interactive learning experiences.

---

## 🌐 Live Demo

You can view and use the Haki Yangu app online:

👉 **[https://haki-yangu.vercel.app/](https://haki-yangu.vercel.app/)**

The app is deployed on Vercel. Open the link above to explore all features directly in your browser!

## 📱 About the Project

Haki Yangu bridges the gap between citizens and their constitutional rights by providing:

- 📚 **Interactive Learning Modules** – Constitution of Kenya 2010, Bill of Rights, Employment Law, Healthcare Rights, Land Rights, Gender Equality, and Elections Act
- 🎯 **Dynamic Quiz System** – Comprehensive quizzes with real-time scoring and progress tracking
- 🤖 **AI Constitutional Assistant (Haki)** – Powered by OpenRouter API with Google Gemini for instant legal guidance
- 📊 **Progress Tracking** – Real-time activity logging and learning journey visualization
- 👤 **Profile Management** – Secure Firebase authentication with Google Sign-In support
- 🔄 **Offline Capability** – Core content accessible without internet connection

The app features a modern, accessible design with pull-to-refresh functionality and comprehensive navigation patterns.

---

## ✅ Current Features (Fully Implemented)

### 🏠 **Core Navigation & UI**
- [x] Splash screen with animated balance logo
- [x] Bottom navigation with Home, Learn, Quiz, Profile tabs
- [x] Responsive design with consistent green theme (#1B5E20)
- [x] Pull-to-refresh functionality across all screens

### 📖 **Learning Modules**
- [x] **Healthcare Rights** – Comprehensive guide to medical rights and healthcare access
- [x] **Bill of Rights** – Interactive exploration of fundamental freedoms (Articles 19-59)
- [x] **Employment Law** – Workers' rights, labor laws, and workplace protections
- [x] **Land Rights** – Property ownership, community land, and acquisition laws
- [x] **Gender Equality** – Anti-discrimination laws and gender-based protections
- [x] **Elections Act** – Voting rights, IEBC procedures, and electoral processes

### 🎯 **Quiz System**
- [x] Module-specific quizzes with 8-10 questions each
- [x] Real-time scoring and progress tracking
- [x] Detailed explanations for correct answers
- [x] Celebration animations for achievements
- [x] Quiz history and performance analytics

### 🤖 **AI Assistant (Haki)**
- [x] OpenRouter API integration with Google Gemini 2.0 Flash
- [x] Constitutional law expertise with document references
- [x] Context-aware responses for legal queries
- [x] Conversation history and session management
- [x] Offline fallback responses for common topics

### 📊 **Activity Tracking**
- [x] Real-time activity logging (quiz completion, module views, chat interactions)
- [x] Dynamic recent activity section with live updates
- [x] Interactive activity cards with navigation
- [x] Persistent storage with SharedPreferences

### 👤 **User Management**
- [x] Firebase Authentication with email/password and Google Sign-In
- [x] Profile picture upload and management
- [x] Secure account deletion with re-authentication
- [x] Cross-screen profile synchronization

---

## 🛠️ Tech Stack

### **Frontend**
- **Flutter 3.8.1+** – Cross-platform mobile framework
- **Dart** – Programming language
- **Material Design 3** – Modern UI components and theming

### **Backend & Services**
- **Firebase Core** – Backend infrastructure
- **Firebase Auth** – User authentication and management
- **Firebase Storage** – Profile picture and file storage
- **Cloud Firestore** – Real-time database for user data and chat sessions

### **AI & APIs**
- **OpenRouter API** – AI service provider
- **Google Gemini 2.0 Flash** – Large language model for constitutional assistance
- **HTTP Client** – API communication and error handling

### **State Management & Storage**
- **SharedPreferences** – Local data persistence
- **Provider Pattern** – State management for real-time updates
- **ChangeNotifier** – Activity tracking and UI updates

### **UI/UX Enhancements**
- **Google Fonts** – Typography and visual consistency
- **Confetti** – Celebration animations for achievements
- **Image Picker** – Profile picture selection and upload
- **Connectivity Plus** – Network status monitoring

---

## 🏗️ Architecture & Design Patterns

### **Project Structure**
```
lib/
├── models/          # Data models (Activity, Quiz, UserProfile, ChatModels)
├── screens/         # UI screens and pages
├── services/        # Business logic and API services
├── widgets/         # Reusable UI components
└── main.dart        # App entry point with splash screen
```

### **Key Design Patterns**
- **Service Layer Architecture** – Separation of business logic from UI
- **Repository Pattern** – Data access abstraction
- **Observer Pattern** – Real-time activity tracking with ChangeNotifier
- **Singleton Pattern** – Service instances and API clients
- **Factory Pattern** – Model creation and data transformation

---

## 🔐 Firebase Setup (Required to Run)

This project uses comprehensive Firebase services for backend functionality.

### **Required Configuration Files:**
- `android/app/google-services.json` – Android Firebase configuration
- `ios/Runner/GoogleService-Info.plist` – iOS Firebase configuration (if building for iOS)

### **Setup Steps:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new Firebase project
3. Enable the following services:
   - **Authentication** (Email/Password + Google Sign-In)
   - **Cloud Firestore** (for chat sessions and user data)
   - **Storage** (for profile pictures)
4. Register your Android app with package name: `com.innoloom.hakiyangu`
5. Download configuration files and place them in the correct directories
6. Update Firebase security rules for Firestore and Storage

### **Environment Variables:**
- OpenRouter API Key is configured in `lib/services/openrouter_service.dart`
- Update with your own API key for AI functionality

---

## 📦 Getting Started

### **Prerequisites**
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase project with required services enabled

### **Installation**
```bash
# Clone the repository
git clone <repository-url>
cd haki_yangu

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Building for Production**
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

---

## 🧪 Testing

### **Current Test Coverage**
- Widget tests for splash screen functionality
- Animation testing for logo and progress indicators
- Navigation flow testing

### **Running Tests**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 🚀 Deployment

### **Android**
- Configured for Google Play Store deployment
- App signing and release configuration ready
- Adaptive icons and splash screens implemented

### **Web (PWA Ready)**
- Progressive Web App configuration
- Service worker for offline functionality
- Web manifest with proper icons and theming

---

## 🤝 Contributing

This project is actively maintained and welcomes contributions!

### **How to Contribute**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Guidelines**
- Follow Flutter/Dart style guidelines
- Add tests for new features
- Update documentation for significant changes
- Ensure Firebase security rules are properly configured

---

## 📄 License

MIT License *(To be confirmed)*

---

## 🙌 Acknowledgements

- Community civic educators
- Open-source Flutter packages
- Grassroots justice initiatives in Kenya

---

## ✉️ Contact

**Developed by:** Rogers Ruga
📧 rogersruga@gmail.com
📍 Nairobi, Kenya
🗣️ English Supported

> *“Haki Yangu – Know. Protect. Defend.”*

---

## 🔮 Future Enhancements

### **Planned Features**
- [ ] **Multilingual Support** – Swahili translations for all content
- [ ] **Offline Quiz Mode** – Complete quiz functionality without internet
- [ ] **Push Notifications** – Reminders for learning goals and new content
- [ ] **Social Features** – Community discussions and knowledge sharing
- [ ] **Advanced Analytics** – Detailed learning progress and insights
- [ ] **Voice Assistant** – Audio-based constitutional guidance

### **Technical Improvements**
- [ ] **Performance Optimization** – Lazy loading and caching strategies
- [ ] **Accessibility** – Screen reader support and accessibility features
- [ ] **Dark Mode** – Complete dark theme implementation
- [ ] **Tablet Support** – Responsive design for larger screens


---

## 🎯 Mission Statement

**⚖️ Making Constitutional Rights Accessible to All Kenyans 🇰🇪**

Empowering every Kenyan citizen with constitutional knowledge and legal awareness through accessible, interactive, and AI-powered civic education. Building a more informed society where everyone understands their rights and responsibilities.