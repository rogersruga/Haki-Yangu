import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';

/// Represents a single quiz question with multiple choice options
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String category;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'category': category,
    };
  }
}

/// Represents a complete quiz for a specific module
class Quiz {
  final String id;
  final String title;
  final String description;
  final String moduleId;
  final List<QuizQuestion> questions;
  final int timeLimit; // in minutes
  final int passingScore; // percentage

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.moduleId,
    required this.questions,
    this.timeLimit = 15,
    this.passingScore = 60,
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      moduleId: map['moduleId'] ?? '',
      questions: (map['questions'] as List<dynamic>?)
          ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
          .toList() ?? [],
      timeLimit: map['timeLimit'] ?? 15,
      passingScore: map['passingScore'] ?? 60,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'moduleId': moduleId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimit': timeLimit,
      'passingScore': passingScore,
    };
  }
}



/// Quiz statistics for a user
class QuizStats {
  final int totalQuizzesTaken;
  final int totalQuizzesPassed;
  final double averageScore;
  final int totalTimeSpent; // in seconds
  final Map<String, int> moduleScores; // moduleId -> best score percentage
  final DateTime? lastQuizDate;

  const QuizStats({
    this.totalQuizzesTaken = 0,
    this.totalQuizzesPassed = 0,
    this.averageScore = 0.0,
    this.totalTimeSpent = 0,
    this.moduleScores = const {},
    this.lastQuizDate,
  });

  factory QuizStats.fromMap(Map<String, dynamic> map) {
    return QuizStats(
      totalQuizzesTaken: map['totalQuizzesTaken'] ?? 0,
      totalQuizzesPassed: map['totalQuizzesPassed'] ?? 0,
      averageScore: (map['averageScore'] ?? 0.0).toDouble(),
      totalTimeSpent: map['totalTimeSpent'] ?? 0,
      moduleScores: Map<String, int>.from(map['moduleScores'] ?? {}),
      lastQuizDate: (map['lastQuizDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalQuizzesPassed': totalQuizzesPassed,
      'averageScore': averageScore,
      'totalTimeSpent': totalTimeSpent,
      'moduleScores': moduleScores,
      'lastQuizDate': lastQuizDate != null ? Timestamp.fromDate(lastQuizDate!) : null,
    };
  }

  QuizStats copyWith({
    int? totalQuizzesTaken,
    int? totalQuizzesPassed,
    double? averageScore,
    int? totalTimeSpent,
    Map<String, int>? moduleScores,
    DateTime? lastQuizDate,
  }) {
    return QuizStats(
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      totalQuizzesPassed: totalQuizzesPassed ?? this.totalQuizzesPassed,
      averageScore: averageScore ?? this.averageScore,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      moduleScores: moduleScores ?? this.moduleScores,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
    );
  }

  double get passRate {
    if (totalQuizzesTaken == 0) return 0.0;
    return (totalQuizzesPassed / totalQuizzesTaken) * 100;
  }
}
