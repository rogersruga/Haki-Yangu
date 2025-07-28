import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/quiz.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Get all available quizzes
  Future<List<Quiz>> getAllQuizzes() async {
    try {
      // For now, return hardcoded quizzes based on modules
      // In a real app, these would be stored in Firestore
      return _getHardcodedQuizzes();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting quizzes: $e');
      }
      return [];
    }
  }

  /// Get quiz by module ID
  Future<Quiz?> getQuizByModuleId(String moduleId) async {
    try {
      final quizzes = await getAllQuizzes();
      return quizzes.firstWhere(
        (quiz) => quiz.moduleId == moduleId,
        orElse: () => throw Exception('Quiz not found'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting quiz for module $moduleId: $e');
      }
      return null;
    }
  }

  /// Submit quiz result and update user progress
  Future<bool> submitQuizResult({
    required String quizId,
    required String moduleId,
    required int score,
    required int totalQuestions,
    required List<int> userAnswers,
    required List<bool> correctAnswers,
    required Duration timeSpent,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final percentage = (score / totalQuestions) * 100;
      final passed = percentage >= 60; // 60% passing score

      // Create quiz result
      final quizResult = QuizResult(
        score: score,
        totalQuestions: totalQuestions,
        completedAt: DateTime.now(),
        timeSpent: timeSpent,
        incorrectQuestions: _getIncorrectQuestionIndices(correctAnswers),
        moduleId: moduleId,
        quizId: quizId,
        passed: passed,
      );

      // Update user progress
      await _updateUserProgress(user.uid, moduleId, quizResult);

      if (kDebugMode) {
        print('Quiz result submitted successfully: $score/$totalQuestions (${percentage.toStringAsFixed(1)}%)');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting quiz result: $e');
      }
      return false;
    }
  }

  /// Update user progress with quiz result
  Future<void> _updateUserProgress(String userId, String moduleId, QuizResult quizResult) async {
    try {
      final userProfile = await _firestoreService.getUserProfile(userId);
      if (userProfile == null) return;

      final currentProgress = userProfile.progress;
      
      // Update quiz results map
      final updatedQuizResults = Map<String, QuizResult>.from(currentProgress.quizResults);
      updatedQuizResults[moduleId] = quizResult;

      // Update completed quizzes list
      final updatedCompletedQuizzes = List<String>.from(currentProgress.completedQuizzes);
      if (!updatedCompletedQuizzes.contains(moduleId)) {
        updatedCompletedQuizzes.add(moduleId);
      }

      // Calculate new average score
      final allScores = updatedQuizResults.values.map((r) => r.percentage).toList();
      final newAverageScore = allScores.isNotEmpty 
          ? allScores.reduce((a, b) => a + b) / allScores.length 
          : 0.0;

      // Create updated progress
      final updatedProgress = currentProgress.copyWith(
        totalQuizzesCompleted: updatedCompletedQuizzes.length,
        averageQuizScore: newAverageScore,
        completedQuizzes: updatedCompletedQuizzes,
        quizResults: updatedQuizResults,
        lastActivityDate: DateTime.now(),
      );

      // Update user profile
      final updatedProfile = userProfile.copyWith(progress: updatedProgress);
      await _firestoreService.updateUserProfile(updatedProfile);

      if (kDebugMode) {
        print('User progress updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user progress: $e');
      }
    }
  }

  /// Get incorrect question indices from correct answers list
  List<int> _getIncorrectQuestionIndices(List<bool> correctAnswers) {
    final incorrectIndices = <int>[];
    for (int i = 0; i < correctAnswers.length; i++) {
      if (!correctAnswers[i]) {
        incorrectIndices.add(i);
      }
    }
    return incorrectIndices;
  }

  /// Get user's quiz statistics
  Future<QuizStats> getUserQuizStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const QuizStats();

      final userProfile = await _firestoreService.getUserProfile(user.uid);
      if (userProfile?.progress == null) return const QuizStats();

      final progress = userProfile!.progress;
      
      // Calculate module scores
      final moduleScores = <String, int>{};
      for (final entry in progress.quizResults.entries) {
        moduleScores[entry.key] = entry.value.percentage.round();
      }

      // Calculate total time spent
      final totalTimeSpent = progress.quizResults.values
          .map((r) => r.timeSpent.inSeconds)
          .fold(0, (a, b) => a + b);

      // Count passed quizzes
      final passedQuizzes = progress.quizResults.values
          .where((r) => r.passed)
          .length;

      return QuizStats(
        totalQuizzesTaken: progress.totalQuizzesCompleted,
        totalQuizzesPassed: passedQuizzes,
        averageScore: progress.averageQuizScore,
        totalTimeSpent: totalTimeSpent,
        moduleScores: moduleScores,
        lastQuizDate: progress.lastActivityDate,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting quiz stats: $e');
      }
      return const QuizStats();
    }
  }

  /// Get hardcoded quizzes for each module
  List<Quiz> _getHardcodedQuizzes() {
    return [
      // Constitutional Rights Quiz
      Quiz(
        id: 'constitutional_rights_quiz',
        title: 'Constitutional Rights Quiz',
        description: 'Test your knowledge of constitutional rights and freedoms',
        moduleId: 'constitutionalRights',
        questions: _getConstitutionalRightsQuestions(),
      ),
      
      // Judicial System Quiz
      Quiz(
        id: 'judicial_system_quiz',
        title: 'Judicial System Quiz',
        description: 'Test your understanding of the judicial system',
        moduleId: 'judicialSystem',
        questions: _getJudicialSystemQuestions(),
      ),
      
      // Electoral Process Quiz
      Quiz(
        id: 'electoral_process_quiz',
        title: 'Electoral Process Quiz',
        description: 'Test your knowledge of the electoral process',
        moduleId: 'electoralProcess',
        questions: _getElectoralProcessQuestions(),
      ),
      
      // Government Structure Quiz
      Quiz(
        id: 'government_structure_quiz',
        title: 'Government Structure Quiz',
        description: 'Test your understanding of government structure',
        moduleId: 'governmentStructure',
        questions: _getGovernmentStructureQuestions(),
      ),
      
      // Citizen Participation Quiz
      Quiz(
        id: 'citizen_participation_quiz',
        title: 'Citizen Participation Quiz',
        description: 'Test your knowledge of citizen participation',
        moduleId: 'citizenParticipation',
        questions: _getCitizenParticipationQuestions(),
      ),
      
      // Rule of Law Quiz
      Quiz(
        id: 'rule_of_law_quiz',
        title: 'Rule of Law Quiz',
        description: 'Test your understanding of the rule of law',
        moduleId: 'ruleOfLaw',
        questions: _getRuleOfLawQuestions(),
      ),
      
      // Human Rights Quiz
      Quiz(
        id: 'human_rights_quiz',
        title: 'Human Rights Quiz',
        description: 'Test your knowledge of human rights',
        moduleId: 'humanRights',
        questions: _getHumanRightsQuestions(),
      ),
      
      // Economic Rights Quiz
      Quiz(
        id: 'economic_rights_quiz',
        title: 'Economic Rights Quiz',
        description: 'Test your understanding of economic rights',
        moduleId: 'economicRights',
        questions: _getEconomicRightsQuestions(),
      ),
      
      // Environmental Rights Quiz
      Quiz(
        id: 'environmental_rights_quiz',
        title: 'Environmental Rights Quiz',
        description: 'Test your knowledge of environmental rights',
        moduleId: 'environmentalRights',
        questions: _getEnvironmentalRightsQuestions(),
      ),
      
      // Healthcare Rights Quiz
      Quiz(
        id: 'healthcare_rights_quiz',
        title: 'Healthcare Rights Quiz',
        description: 'Test your understanding of healthcare rights',
        moduleId: 'healthcareRights',
        questions: _getHealthcareRightsQuestions(),
      ),
      
      // Land Rights Quiz
      Quiz(
        id: 'land_rights_quiz',
        title: 'Land Rights Quiz',
        description: 'Test your knowledge of land rights',
        moduleId: 'landRights',
        questions: _getLandRightsQuestions(),
      ),
    ];
  }

  /// Constitutional Rights Questions
  List<QuizQuestion> _getConstitutionalRightsQuestions() {
    return [
      QuizQuestion(
        id: 'cr_1',
        question: 'Which article of the Kenyan Constitution deals with the Bill of Rights?',
        options: ['Article 19', 'Article 26', 'Chapter 4', 'Article 40'],
        correctAnswerIndex: 2,
        explanation: 'Chapter 4 of the Kenyan Constitution contains the Bill of Rights.',
        category: 'constitutionalRights',
      ),
      QuizQuestion(
        id: 'cr_2',
        question: 'What is the right to life as defined in the Constitution?',
        options: [
          'The right to live without interference',
          'The right to be protected from death',
          'The right to life begins at conception and includes the right not to be deprived of life arbitrarily',
          'The right to healthcare'
        ],
        correctAnswerIndex: 2,
        explanation: 'The right to life is fundamental and includes protection from arbitrary deprivation of life.',
        category: 'constitutionalRights',
      ),
      QuizQuestion(
        id: 'cr_3',
        question: 'Which of the following is NOT a fundamental freedom in Kenya?',
        options: [
          'Freedom of expression',
          'Freedom of assembly',
          'Freedom to own unlimited property',
          'Freedom of association'
        ],
        correctAnswerIndex: 2,
        explanation: 'Property rights exist but are not unlimited and must be balanced with public interest.',
        category: 'constitutionalRights',
      ),
      QuizQuestion(
        id: 'cr_4',
        question: 'What does the right to human dignity entail?',
        options: [
          'Right to respect and worth',
          'Right to privacy only',
          'Right to property only',
          'Right to education only'
        ],
        correctAnswerIndex: 0,
        explanation: 'Human dignity encompasses the inherent worth and respect due to every person.',
        category: 'constitutionalRights',
      ),
      QuizQuestion(
        id: 'cr_5',
        question: 'Under what circumstances can fundamental rights be limited?',
        options: [
          'Never',
          'Only during emergencies',
          'When reasonable and justifiable in an open and democratic society',
          'At the discretion of government'
        ],
        correctAnswerIndex: 2,
        explanation: 'Rights can be limited only when reasonable and justifiable in an open and democratic society.',
        category: 'constitutionalRights',
      ),
      QuizQuestion(
        id: 'cr_6',
        question: 'What is the role of the Kenya National Human Rights Commission?',
        options: [
          'To make laws',
          'To promote and protect human rights',
          'To prosecute criminals',
          'To manage elections'
        ],
        correctAnswerIndex: 1,
        explanation: 'The KNHRC is mandated to promote and protect human rights in Kenya.',
        category: 'constitutionalRights',
      ),
      QuizQuestion(
        id: 'cr_7',
        question: 'Which court has the final authority on constitutional matters?',
        options: [
          'High Court',
          'Court of Appeal',
          'Supreme Court',
          'Constitutional Court'
        ],
        correctAnswerIndex: 2,
        explanation: 'The Supreme Court is the final arbiter of constitutional matters in Kenya.',
        category: 'constitutionalRights',
      ),
      QuizQuestion(
        id: 'cr_8',
        question: 'What does the right to fair administrative action include?',
        options: [
          'Right to be heard before adverse action',
          'Right to reasons for decisions',
          'Right to appeal or review',
          'All of the above'
        ],
        correctAnswerIndex: 3,
        explanation: 'Fair administrative action includes being heard, receiving reasons, and having appeal rights.',
        category: 'constitutionalRights',
      ),
    ];
  }

  /// Judicial System Questions
  List<QuizQuestion> _getJudicialSystemQuestions() {
    return [
      QuizQuestion(
        id: 'js_1',
        question: 'What is the highest court in Kenya?',
        options: ['High Court', 'Court of Appeal', 'Supreme Court', 'Constitutional Court'],
        correctAnswerIndex: 2,
        explanation: 'The Supreme Court is the highest court in Kenya\'s judicial hierarchy.',
        category: 'judicialSystem',
      ),
      QuizQuestion(
        id: 'js_2',
        question: 'How many judges sit in the Supreme Court?',
        options: ['5', '7', '9', '11'],
        correctAnswerIndex: 1,
        explanation: 'The Supreme Court consists of the Chief Justice and six other judges.',
        category: 'judicialSystem',
      ),
      QuizQuestion(
        id: 'js_3',
        question: 'What is the role of the Judicial Service Commission?',
        options: [
          'To hear cases',
          'To appoint and discipline judges',
          'To make laws',
          'To represent the government'
        ],
        correctAnswerIndex: 1,
        explanation: 'The JSC is responsible for appointing judges and ensuring judicial accountability.',
        category: 'judicialSystem',
      ),
      QuizQuestion(
        id: 'js_4',
        question: 'Which principle ensures judges can make decisions without external pressure?',
        options: [
          'Judicial accountability',
          'Judicial independence',
          'Judicial review',
          'Judicial precedent'
        ],
        correctAnswerIndex: 1,
        explanation: 'Judicial independence protects judges from external interference in their decisions.',
        category: 'judicialSystem',
      ),
      QuizQuestion(
        id: 'js_5',
        question: 'What type of cases does the Environment and Land Court handle?',
        options: [
          'Criminal cases only',
          'Environmental and land disputes',
          'Family matters only',
          'Commercial disputes only'
        ],
        correctAnswerIndex: 1,
        explanation: 'The Environment and Land Court specializes in environmental and land-related disputes.',
        category: 'judicialSystem',
      ),
      QuizQuestion(
        id: 'js_6',
        question: 'What is the doctrine of separation of powers?',
        options: [
          'Courts can make laws',
          'Executive, legislature, and judiciary have distinct roles',
          'All power belongs to the president',
          'Parliament controls all branches'
        ],
        correctAnswerIndex: 1,
        explanation: 'Separation of powers ensures each branch of government has distinct and independent roles.',
        category: 'judicialSystem',
      ),
      QuizQuestion(
        id: 'js_7',
        question: 'What is judicial review?',
        options: [
          'Reviewing judges\' performance',
          'Courts examining the constitutionality of laws and actions',
          'Reviewing court decisions',
          'Reviewing legal procedures'
        ],
        correctAnswerIndex: 1,
        explanation: 'Judicial review allows courts to examine whether laws and government actions comply with the Constitution.',
        category: 'judicialSystem',
      ),
      QuizQuestion(
        id: 'js_8',
        question: 'Who is the head of the Kenyan judiciary?',
        options: [
          'Attorney General',
          'Chief Justice',
          'President',
          'Speaker of Parliament'
        ],
        correctAnswerIndex: 1,
        explanation: 'The Chief Justice is the head of the judiciary and president of the Supreme Court.',
        category: 'judicialSystem',
      ),
    ];
  }

  /// Placeholder methods for other modules (to be implemented)
  List<QuizQuestion> _getElectoralProcessQuestions() => [];
  List<QuizQuestion> _getGovernmentStructureQuestions() => [];
  List<QuizQuestion> _getCitizenParticipationQuestions() => [];
  List<QuizQuestion> _getRuleOfLawQuestions() => [];
  List<QuizQuestion> _getHumanRightsQuestions() => [];
  List<QuizQuestion> _getEconomicRightsQuestions() => [];
  List<QuizQuestion> _getEnvironmentalRightsQuestions() => [];
  List<QuizQuestion> _getHealthcareRightsQuestions() => [];
  List<QuizQuestion> _getLandRightsQuestions() => [];
}
