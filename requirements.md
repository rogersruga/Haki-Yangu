**Product Requirements Document (PRD)**

### 1. **Overview**

**Purpose:**
Haki Yangu is a civic education mobile application designed to simplify legal and civic knowledge for Kenyan citizens. It aims to empower users through accessible rights information, civic quizzes, a legal assistant chatbot, and personalized learning experiences.

**Target Audience:**

* Kenyan youth (ages 15–35)
* General public interested in civic empowerment
* NGOs, civic educators, and government institutions

**Platforms:** Android & iOS (developed in Flutter)

**Backend:** Neon.tech (PostgreSQL serverless backend)

**Authentication:** Firebase Authentication

**AI Integration:** OpenRouter API for AI assistant/chatbot

---

### 2. **Core Functionalities**

#### 2.1 Splash Screen + first-time onboarding

* Branded splash screen using flutter_native_splash.
* Intro onboarding screens with swipe-through interface(images+text).
* App logo (circular container with balance/justice icon)
* Tagline: "Know. Protect. Defend."
* "Get Started" button redirects to signup/ login screen.
* Onboarding state stored using shared_preferences or hive.


#### 2.2 User Authentication (Firebase)

* Email/Password sign-up & login
* Password reset via email
* Firebase Authentication integration
* Basic email validation and form feedback

#### 2.3 Home Screen

* Navigation buttons/cards:

  * Justice Simplified
  * Civic Quiz
  * Profile
  * Haki Assistant (Chatbot)
* Bottom navigation bar
* Greeting message and app branding

#### 2.4 Justice Simplified (Legal Library)

* Category cards (e.g., Land, Labor, Gender Rights)
* Search functionality
* Detail pages with expandable sections
* Voice narration support (TTS)

#### 2.5 Civic Quiz

* Quiz categories with user progress
* Gamified layout with badges and achievements
* One-question-per-screen format
* Correct answer feedback and tips
* Score tracking and learning analytics

#### 2.6 Haki Assistant (AI Legal Chatbot)

* Integrated via OpenRouter API
* Handles basic civic questions (e.g., "What are my tenant rights?")
* Chat interface with text input, suggestion prompts, and friendly avatar
* Safety disclaimer on outputs

#### 2.7 User Profile

* View and edit user details
* Progress tracking (quizzes completed, badges earned)
* Learning milestones

#### 2.8 App Settings

* Notification toggle
* Language toggle (English/Swahili)
* Text size accessibility options
* Clear cache/log out

#### 2.9 Push Notifications

* Powered via Firebase Cloud Messaging (FCM)
* Reminders for daily learning
* Updates on civic holidays, legal news, new content packs

#### 2.10 Admin Dashboard (Optional Future Phase)

* Partner dashboard for NGOs or institutions
* Upload content, view usage stats (via Supabase or Firebase Console)
* Manage chatbot question suggestions

---

### 3. **Technical Stack**

| Layer              | Tool/Service                |
| ------------------ | --------------------------- |
| Frontend           | Flutter                     |
| Backend            | Neon.tech (PostgreSQL)      |
| Auth               | Firebase Authentication     |
| Push Notifications | Firebase Cloud Messaging    |
| AI Integration     | OpenRouter API              |
| Storage (optional) | Firebase Storage / Supabase |

---

### 4. **Non-Functional Requirements**

* **Performance:** App should load in <2 seconds
* **Security:** Firebase rules + encryption for sensitive data
* **Scalability:** Built to support 100,000+ users
* **Offline Access:** Caching for key legal texts and quizzes

---

### 5. **Open Questions / To Be Decided**

* Should users be allowed to bookmark/save legal articles?
* Do we implement Swahili voice narration in MVP?
* Will there be multi-role accounts (e.g., learner, educator)?
* Will analytics be stored on Firebase, Supabase, or custom dashboard?

---

### 6. **MVP Milestones**

* UI/UX Design complete – August 2025
* Firebase Auth & Splash Screen – August 2025
* Legal content upload + quiz engine – September 2025
* Haki Assistant integration – September 2025
* Final Testing & Launch – October 2025

---

**End of PRD Document**
