import 'package:cloud_firestore/cloud_firestore.dart';

class LearningContent {
  final String id;
  final String title;
  final String description;
  final String category;
  final ContentType type;
  final int estimatedMinutes;
  final DifficultyLevel difficulty;
  final List<String> tags;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int order;
  final List<String> prerequisites;

  LearningContent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.estimatedMinutes,
    required this.difficulty,
    this.tags = const [],
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = true,
    this.order = 0,
    this.prerequisites = const [],
  });

  factory LearningContent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return LearningContent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      type: ContentType.values.firstWhere(
        (e) => e.toString() == 'ContentType.${data['type']}',
        orElse: () => ContentType.lesson,
      ),
      estimatedMinutes: data['estimatedMinutes'] ?? 0,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == 'DifficultyLevel.${data['difficulty']}',
        orElse: () => DifficultyLevel.beginner,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? true,
      order: data['order'] ?? 0,
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'type': type.name,
      'estimatedMinutes': estimatedMinutes,
      'difficulty': difficulty.name,
      'tags': tags,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'order': order,
      'prerequisites': prerequisites,
    };
  }
}

enum ContentType {
  lesson,
  quiz,
  video,
  article,
  interactive,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<QuizQuestion> questions;
  final int timeLimit; // in minutes, 0 for no limit
  final int passingScore; // percentage
  final bool shuffleQuestions;
  final bool showCorrectAnswers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
    this.timeLimit = 0,
    this.passingScore = 70,
    this.shuffleQuestions = true,
    this.showCorrectAnswers = true,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = true,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
          ?.map((q) => QuizQuestion.fromMap(q))
          .toList() ?? [],
      timeLimit: data['timeLimit'] ?? 0,
      passingScore: data['passingScore'] ?? 70,
      shuffleQuestions: data['shuffleQuestions'] ?? true,
      showCorrectAnswers: data['showCorrectAnswers'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimit': timeLimit,
      'passingScore': passingScore,
      'shuffleQuestions': shuffleQuestions,
      'showCorrectAnswers': showCorrectAnswers,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final QuestionType type;
  final int points;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
    this.type = QuestionType.multipleChoice,
    this.points = 1,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == 'QuestionType.${map['type']}',
        orElse: () => QuestionType.multipleChoice,
      ),
      points: map['points'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'type': type.name,
      'points': points,
    };
  }
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInTheBlank,
}

class LearningCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String color;
  final int order;
  final bool isActive;
  final List<String> subcategories;

  LearningCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    this.order = 0,
    this.isActive = true,
    this.subcategories = const [],
  });

  factory LearningCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return LearningCategory(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'] ?? '',
      color: data['color'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      subcategories: List<String>.from(data['subcategories'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'color': color,
      'order': order,
      'isActive': isActive,
      'subcategories': subcategories,
    };
  }
}
