import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import '../services/refresh_service.dart';
import '../services/activity_service.dart';
import '../models/user_profile.dart';
import '../models/activity.dart';
import '../widgets/robust_profile_image.dart';
import '../widgets/activity_item.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'learn_screen.dart';
import 'quiz_screen.dart';
import 'haki_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final authService = AuthService();
  final ProgressService _progressService = ProgressService();
  final RefreshService _refreshService = RefreshService();
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    _initializeActivityService();
    // Listen to activity changes
    _activityService.addListener(_onActivityChanged);
  }

  @override
  void dispose() {
    _activityService.removeListener(_onActivityChanged);
    super.dispose();
  }

  void _onActivityChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when activities change
      });
    }
  }

  Future<void> _initializeActivityService() async {
    await _activityService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildHomeContent(userName)
            : _selectedIndex == 3
                ? const ProfileScreen()
                : _buildPlaceholderContent(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Future<void> _onRefresh() async {
    try {
      // Refresh both user profile and progress data
      final results = await Future.wait([
        _refreshService.refreshUserProfile(),
        _refreshService.refreshProgressData(),
      ]);

      // Show feedback only if there are errors or warnings
      for (final result in results) {
        if (result.showFeedback && mounted) {
          RefreshService.showRefreshFeedback(context, result);
          break; // Show only the first feedback message
        }
      }
    } catch (e) {
      if (mounted) {
        RefreshService.showRefreshFeedback(
          context,
          RefreshResult.error(
            message: 'Failed to refresh data',
            error: e,
          ),
        );
      }
    }
  }

  Widget _buildHomeContent(String userName) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header Section with gradient
          _buildHeaderSection(userName),

          const SizedBox(height: 24),

          // User Stats Overview with real-time progress
          StreamBuilder<UserProgress?>(
            stream: _progressService.getUserProgressStream(),
            builder: (context, snapshot) {
              return _buildStatsSection(snapshot.data);
            },
          ),

          const SizedBox(height: 24),

          // Explore Features Section
          _buildFeaturesSection(),

          const SizedBox(height: 24),

          // Recent Activity Feed
          _buildRecentActivitySection(),

          const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }
  Widget _buildHeaderSection(String userName) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with logo and notification
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.balance,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Haki Yangu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Implement notifications
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications coming soon!')),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) async {
                        if (value == 'logout') {
                          try {
                            await authService.signOut();
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const AuthScreen()),
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error signing out: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Sign Out'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Greeting section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: RobustProfileImage(
                    user: user,
                    size: 30,
                    iconColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ready to explore your rights?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(UserProgress? progress) {
    // Calculate module completion stats
    final completedModules = progress?.completedLessons
        .where((lesson) => ProgressService.allModules.contains(lesson))
        .length ?? 0;
    final totalModules = ProgressService.allModules.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Modules Done',
              value: '$completedModules/$totalModules',
              icon: Icons.school,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Quiz Score',
              value: '${progress?.averageQuizScore.toInt() ?? 0}%',
              icon: Icons.quiz,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Streak Days',
              value: '${progress?.currentStreak ?? 0}',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Features',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            title: 'Justice Simplified',
            subtitle: 'Learn rights in a simplified way',
            icon: Icons.menu_book,
            color: const Color(0xFF7B1FA2), // Purple
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LearnScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            title: 'Test Your Knowledge',
            subtitle: 'Take a Civic quiz',
            icon: Icons.quiz,
            color: const Color(0xFF388E3C), // Green
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            title: 'Profile',
            subtitle: 'Access to user progress and badges',
            icon: Icons.person,
            color: const Color(0xFFE91E63), // Pink
            onTap: () {
              setState(() {
                _selectedIndex = 3; // Navigate to profile tab
              });
            },
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            title: 'Ask Haki',
            subtitle: 'AI chatbot for constitutional law questions',
            icon: Icons.chat,
            color: const Color(0xFFFF9800), // Orange
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HakiChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ActivityCard(
        activities: _activityService.getRecentActivities(limit: 5),
        title: 'Recent Activity',
        onActivityTap: _handleActivityTap,
        onViewAll: () {
          _showAllActivities();
        },
        maxItems: 5,
      ),
    );
  }

  void _handleActivityTap(Activity activity) {
    // Handle activity tap based on activity type
    switch (activity.type) {
      case ActivityType.quizCompleted:
        // Navigate to quiz screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QuizScreen(),
          ),
        );
        break;
      case ActivityType.moduleViewed:
      case ActivityType.moduleCompleted:
        // Navigate to learn screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LearnScreen(),
          ),
        );
        break;
      case ActivityType.chatInteraction:
        // Navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HakiChatScreen(),
          ),
        );
        break;
      case ActivityType.profileUpdated:
        // Navigate to profile
        setState(() {
          _selectedIndex = 3; // Profile tab
        });
        break;
      default:
        // Default action - show activity details
        _showActivityDetails(activity);
        break;
    }
  }

  void _showAllActivities() {
    // Show a bottom sheet with all activities
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Activity list
              Expanded(
                child: ActivityList(
                  activities: _activityService.activities,
                  onActivityTap: (activity) {
                    Navigator.pop(context);
                    _handleActivityTap(activity);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Text(activity.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    String title = '';
    String subtitle = '';
    IconData icon = Icons.home;

    switch (_selectedIndex) {
      case 1:
        title = 'Learn';
        subtitle = 'Educational content coming soon';
        icon = Icons.school;
        break;
      case 2:
        title = 'Quiz';
        subtitle = 'Interactive quizzes coming soon';
        icon = Icons.quiz;
        break;
      case 3:
        title = 'Profile';
        subtitle = 'User profile coming soon';
        icon = Icons.person;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withValues(alpha: 0.7),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }


}
