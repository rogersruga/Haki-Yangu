import 'package:flutter/material.dart';
import '../models/quiz.dart';
import 'quiz_taking_screen.dart';
import 'main_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final Quiz quiz;
  final int score;
  final int totalQuestions;
  final Duration timeSpent;
  final List<int?> userAnswers;
  final List<bool> correctAnswers;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
    required this.userAnswers,
    required this.correctAnswers,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: percentage,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scoreAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  double get percentage => (widget.score / widget.totalQuestions) * 100;
  bool get passed => percentage >= widget.quiz.passingScore;

  String get performanceMessage {
    if (percentage >= 80) return 'Excellent!';
    if (percentage >= 60) return 'Good job!';
    return 'Keep practicing!';
  }

  Color get performanceColor {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String get _formattedTime {
    final minutes = widget.timeSpent.inMinutes;
    final seconds = widget.timeSpent.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _navigateToQuizScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Quiz Results',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), // Reduced padding since SafeArea handles system UI
              child: Column(
                children: [
                  _buildScoreCard(),
                  const SizedBox(height: 24),
                  _buildStatsCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildQuestionReview(),
                  const SizedBox(height: 40), // Increased extra spacing at bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            performanceColor.withValues(alpha: 0.1),
            performanceColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: performanceColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.celebration : Icons.refresh,
            size: 64,
            color: performanceColor,
          ),
          const SizedBox(height: 16),
          Text(
            performanceMessage,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: performanceColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            passed ? 'You passed the quiz!' : 'You can retake the quiz',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Text(
                    '${_scoreAnimation.value.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: performanceColor,
                    ),
                  ),
                  Text(
                    '${widget.score} out of ${widget.totalQuestions} correct',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timer,
                  label: 'Time Spent',
                  value: _formattedTime,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.quiz,
                  label: 'Questions',
                  value: '${widget.totalQuestions}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Correct',
                  value: '${widget.score}',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.cancel,
                  label: 'Incorrect',
                  value: '${widget.totalQuestions - widget.score}',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _retakeQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Retake Quiz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _navigateToQuizScreen,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Back to Modules',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Question Review & Explanations',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.quiz.questions.length,
          itemBuilder: (context, index) {
            return _buildDetailedQuestionReview(index);
          },
        ),
      ],
    );
  }

  Widget _buildDetailedQuestionReview(int index) {
    final question = widget.quiz.questions[index];
    final userAnswer = widget.userAnswers[index];
    final isCorrect = widget.correctAnswers[index];
    final wasSkipped = userAnswer == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? Colors.green[300]!
              : wasSkipped
                  ? Colors.grey[300]!
                  : Colors.red[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green[50]
                  : wasSkipped
                      ? Colors.grey[50]
                      : Colors.red[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green
                        : wasSkipped
                            ? Colors.grey
                            : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCorrect
                        ? 'Correct'
                        : wasSkipped
                            ? 'Skipped'
                            : 'Incorrect',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCorrect
                          ? Colors.green[800]
                          : wasSkipped
                              ? Colors.grey[700]
                              : Colors.red[800],
                    ),
                  ),
                ),
                Icon(
                  isCorrect
                      ? Icons.check_circle
                      : wasSkipped
                          ? Icons.remove_circle
                          : Icons.cancel,
                  color: isCorrect
                      ? Colors.green
                      : wasSkipped
                          ? Colors.grey
                          : Colors.red,
                  size: 24,
                ),
              ],
            ),
          ),

          // Question Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Text
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Answer Options
                ...question.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final optionText = entry.value;
                  final isUserAnswer = userAnswer == optionIndex;
                  final isCorrectAnswer = optionIndex == question.correctAnswerIndex;

                  Color backgroundColor = Colors.grey[50]!;
                  Color borderColor = Colors.grey[300]!;
                  Color textColor = Colors.black87;
                  Widget? leadingIcon;

                  if (isCorrectAnswer) {
                    backgroundColor = Colors.green[50]!;
                    borderColor = Colors.green[300]!;
                    textColor = Colors.green[800]!;
                    leadingIcon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
                  } else if (isUserAnswer && !isCorrectAnswer) {
                    backgroundColor = Colors.red[50]!;
                    borderColor = Colors.red[300]!;
                    textColor = Colors.red[800]!;
                    leadingIcon = const Icon(Icons.cancel, color: Colors.red, size: 20);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        if (leadingIcon != null) ...[
                          leadingIcon,
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: (isCorrectAnswer || isUserAnswer)
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUserAnswer && !isCorrectAnswer)
                          Text(
                            'Your answer',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        if (isCorrectAnswer)
                          Text(
                            'Correct answer',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Explanation Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Explanation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.explanation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _retakeQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTakingScreen(quiz: widget.quiz),
      ),
    );
  }

  void _navigateToQuizScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 2)), // Index 2 is Quiz tab
      (route) => route.isFirst,
    );
  }
}
