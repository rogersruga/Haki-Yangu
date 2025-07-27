import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'quiz_result_screen.dart';

class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizTakingScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen>
    with TickerProviderStateMixin {
  final QuizService _quizService = QuizService();
  
  int currentQuestionIndex = 0;
  List<int?> userAnswers = [];
  List<bool> correctAnswers = [];
  bool isAnswerSelected = false;
  int? selectedAnswerIndex;
  
  late DateTime startTime;
  Timer? quizTimer;
  int remainingSeconds = 0;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    remainingSeconds = widget.quiz.timeLimit * 60; // Convert minutes to seconds
    
    // Initialize user answers list
    userAnswers = List.filled(widget.quiz.questions.length, null);
    correctAnswers = List.filled(widget.quiz.questions.length, false);
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
    _startTimer();
  }

  @override
  void dispose() {
    quizTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        _submitQuiz(); // Auto-submit when time runs out
      }
    });
  }

  String get _formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[currentQuestionIndex];
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmation();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.quiz.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _skipQuestion,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildQuestionContent(question),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final progress = (currentQuestionIndex + 1) / widget.quiz.questions.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(QuizQuestion question) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return _buildAnswerOption(question, index);
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildAnswerOption(QuizQuestion question, int index) {
    final isSelected = selectedAnswerIndex == index;

    Color backgroundColor = Colors.grey[50]!;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.black87;

    if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
      borderColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.primary;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ScaleTransition(
        scale: isSelected ? _scaleAnimation :
               const AlwaysStoppedAnimation(1.0),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _selectAnswer(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question.options[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), // Added extra bottom padding
      child: Row(
        children: [
          if (currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isAnswerSelected ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                currentQuestionIndex == widget.quiz.questions.length - 1
                    ? 'Finish Quiz'
                    : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    final question = widget.quiz.questions[currentQuestionIndex];
    final isCorrect = answerIndex == question.correctAnswerIndex;

    setState(() {
      selectedAnswerIndex = answerIndex;
      isAnswerSelected = true;
      userAnswers[currentQuestionIndex] = answerIndex;
      correctAnswers[currentQuestionIndex] = isCorrect;
    });

    // Animate button press
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
      _fadeController.reset();
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = userAnswers[currentQuestionIndex];
        isAnswerSelected = selectedAnswerIndex != null;
      });
      _fadeController.forward();
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      _fadeController.reset();
      setState(() {
        currentQuestionIndex--;
        selectedAnswerIndex = userAnswers[currentQuestionIndex];
        isAnswerSelected = selectedAnswerIndex != null;
      });
      _fadeController.forward();
    }
  }

  void _skipQuestion() {
    setState(() {
      userAnswers[currentQuestionIndex] = null;
      correctAnswers[currentQuestionIndex] = false;
    });
    _nextQuestion();
  }

  Future<void> _submitQuiz() async {
    quizTimer?.cancel();

    final endTime = DateTime.now();
    final timeSpent = endTime.difference(startTime);

    // Calculate score
    final score = correctAnswers.where((correct) => correct).length;

    // Submit result
    final success = await _quizService.submitQuizResult(
      quizId: widget.quiz.id,
      moduleId: widget.quiz.moduleId,
      score: score,
      totalQuestions: widget.quiz.questions.length,
      userAnswers: userAnswers.map((answer) => answer ?? -1).toList(),
      correctAnswers: correctAnswers,
      timeSpent: timeSpent,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              quiz: widget.quiz,
              score: score,
              totalQuestions: widget.quiz.questions.length,
              timeSpent: timeSpent,
              userAnswers: userAnswers,
              correctAnswers: correctAnswers,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit quiz. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }
}
