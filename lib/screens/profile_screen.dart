import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/progress_service.dart';
import '../services/refresh_service.dart';
import '../services/activity_service.dart';
import '../models/user_profile.dart';
import '../widgets/robust_profile_image.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final ProgressService _progressService = ProgressService();
  final RefreshService _refreshService = RefreshService();
  final ActivityService _activityService = ActivityService();
  UserProfile? userProfile;
  User? currentUser; // Add this to track user state
  bool isLoading = true;
  bool isResetting = false;
  bool isUpdatingProfile = false;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Profile management methods
  Future<void> _updateProfilePicture() async {
    try {
      if (kDebugMode) {
        print('🔵 Profile picture update started...');
      }

      final ImageSource? source = await _profileService.showImageSourceDialog(context);
      if (source == null) {
        if (kDebugMode) {
          print('🔵 User cancelled image source selection');
        }
        return;
      }

      setState(() {
        isUploadingImage = true;
      });

      if (kDebugMode) {
        print('🔵 Picking image from $source...');
      }

      final XFile? image = await _profileService.pickImage(source: source);
      if (image == null) {
        if (kDebugMode) {
          print('🔵 No image selected');
        }
        setState(() {
          isUploadingImage = false;
        });
        return;
      }

      if (kDebugMode) {
        print('🔵 Image selected: ${image.path}');
        print('🔵 Starting profile picture update...');
      }

      // Add timeout to the entire update process to prevent infinite hanging
      final success = await _profileService.updateProfilePicture(image).timeout(
        const Duration(minutes: 1), // Total timeout for the entire process
        onTimeout: () {
          if (kDebugMode) {
            print('❌ Profile picture update timed out after 1 minute');
          }
          throw Exception('Upload timed out. Please check your internet connection and try again.');
        },
      );

      if (success && mounted) {
        if (kDebugMode) {
          print('✅ Profile picture update completed successfully');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Log profile update activity
        await _activityService.recordProfileUpdate();

        // Reload user data to show updated picture
        await _loadUserProfile();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Profile picture update failed: $e');
      }
      if (mounted) {
        String errorMessage = 'Error updating profile picture';

        // Provide user-friendly error messages
        if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
          errorMessage = 'Upload timed out. Please check your internet connection and try again.';
        } else if (e.toString().contains('storage/unauthorized')) {
          errorMessage = 'Permission denied. Please contact support.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('decode')) {
          errorMessage = 'Invalid image format. Please try a different image.';
        } else if (e.toString().contains('compression')) {
          errorMessage = 'Image processing failed. Please try a smaller image.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
        if (kDebugMode) {
          print('🔵 Profile picture update process completed (finally block)');
        }
      }
    }
  }

  Future<void> _updateDisplayName() async {
    final TextEditingController controller = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null) {
      controller.text = user!.displayName!;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Display Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'Enter your new display name',
            ),
            maxLength: 50,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.of(context).pop(newName);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        setState(() {
          isUpdatingProfile = true;
        });

        final success = await _profileService.updateDisplayName(result);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Display name updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Log profile update activity
          await _activityService.recordProfileUpdate();

          await _loadUserProfile();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating display name: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isUpdatingProfile = false;
          });
        }
      }
    }
  }

  Future<void> _updatePassword() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (currentPassword.isNotEmpty &&
                    newPassword.isNotEmpty &&
                    newPassword == confirmPassword &&
                    newPassword.length >= 6) {
                  Navigator.of(context).pop({
                    'current': currentPassword,
                    'new': newPassword,
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please check your password requirements'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        setState(() {
          isUpdatingProfile = true;
        });

        final success = await _profileService.updatePassword(
          result['current']!,
          result['new']!,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating password: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isUpdatingProfile = false;
          });
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final TextEditingController passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Enter your password to confirm',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text.isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        setState(() {
          isUpdatingProfile = true;
        });

        final success = await _profileService.deleteAccount(passwordController.text);

        if (success && mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isUpdatingProfile = false;
          });
        }
      }
    }
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

      // Reload user profile if successful
      if (results[0].isSuccess) {
        await _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        RefreshService.showRefreshFeedback(
          context,
          RefreshResult.error(
            message: 'Failed to refresh profile data',
            error: e,
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      if (kDebugMode) {
        print('🔵 PROFILE: Loading user profile...');
      }

      // Get fresh user data from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload(); // Force refresh from server
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (kDebugMode) {
        print('🔵 PROFILE: Current user photoURL: ${refreshedUser?.photoURL}');
      }

      // Get profile from Firestore
      final profile = await authService.getUserProfile();

      if (mounted) {
        setState(() {
          currentUser = refreshedUser; // Update the user state
          userProfile = profile;
          isLoading = false;
        });

        if (kDebugMode) {
          print('🔵 PROFILE: UI updated with new user data');
          print('🔵 PROFILE: Profile photoURL: ${profile?.photoURL}');
          print('🔵 PROFILE: Auth photoURL: ${refreshedUser?.photoURL}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PROFILE: Error loading profile: $e');
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    // Use the tracked user state instead of direct Firebase call
    final user = currentUser ?? FirebaseAuth.instance.currentUser;
    final userName = userProfile?.displayName ??
                     user?.displayName ??
                     user?.email?.split('@')[0] ??
                     'User';

    if (kDebugMode && user?.photoURL != null) {
      print('🔵 BUILD: Rendering with photoURL: ${user!.photoURL}');
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Header Section
                    _buildHeaderSection(userName),

                    const SizedBox(height: 24),

                    // Stats/Progress Overview with real-time updates
                    StreamBuilder<UserProgress?>(
                      stream: _progressService.getUserProgressStream(),
                      builder: (context, snapshot) {
                        return _buildStatsSection(snapshot.data);
                      },
                    ),
              
              const SizedBox(height: 24),
              
              // Badges & Rewards Section
              _buildBadgesSection(),
              
              const SizedBox(height: 24),
              
              // Settings/Navigation Section
              _buildSettingsSection(),
              
              const SizedBox(height: 100), // Space for bottom navigation
                    ],
                  ),
                ),
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
          children: [
            // Top row with title and more options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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
            
            const SizedBox(height: 32),
            
            // Profile picture with camera icon
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: isUploadingImage
                      ? const CircularProgressIndicator()
                      : RobustProfileImage(
                          user: user,
                          size: 50,
                          iconColor: Theme.of(context).colorScheme.primary,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: isUploadingImage ? null : _updateProfilePicture,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // User name
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // User role/status
            const Text(
              'Civic Education Learner',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
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
    final progressPercentage = totalModules > 0 ? completedModules / totalModules : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with view all
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Milestones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View all milestones coming soon!')),
                  );
                },
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Achievement card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Congratulations!!!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete 2 more quizzes to unlock a badge',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Progress indicator
                Row(
                  children: [
                    Text(
                      '$completedModules of $totalModules modules completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressPercentage.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats cards grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                userProfile?.progress.totalQuizzesCompleted.toString() ?? '0',
                'Quizzes\nCompleted',
                Icons.quiz,
              ),
              _buildStatCard(
                '${userProfile?.progress.totalLessonsCompleted ?? 0}',
                'Lessons\nCompleted',
                Icons.school,
              ),
              _buildStatCard(
                '${userProfile?.progress.averageQuizScore.toStringAsFixed(0) ?? '0'}%',
                'Average\nScore',
                Icons.trending_up,
              ),
              _buildStatCard(
                userProfile?.progress.currentStreak.toString() ?? '0',
                'Daily\nStreak',
                Icons.local_fire_department,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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

  Widget _buildBadgesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with view all
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Badges & Reward',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View all badges coming soon!')),
                  );
                },
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Badges grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildBadgeItem(Icons.star, Colors.orange, false),
              _buildBadgeItem(Icons.chat_bubble, Colors.blue, false),
              _buildBadgeItem(Icons.shopping_cart, Colors.green, false),
              _buildBadgeItem(Icons.chat, Theme.of(context).colorScheme.primary, false),
              _buildBadgeItem(Icons.favorite, Colors.red, false),
              _buildBadgeItem(Icons.send, Colors.blue, false),
            ],
          ),

          const SizedBox(height: 20),

          // View all badges button
          Center(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all badges coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'View my all Badges',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(IconData icon, Color color, bool isEarned) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isEarned ? color : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: isEarned ? Colors.white : Colors.grey[500],
        size: 24,
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Profile Management Section
          _buildSettingsItem(
            icon: Icons.edit,
            title: 'Edit Display Name',
            subtitle: 'Update your display name',
            onTap: isUpdatingProfile ? null : () => _updateDisplayName(),
          ),
          _buildSettingsItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: isUpdatingProfile ? null : () => _updatePassword(),
          ),
          _buildSettingsItem(
            icon: Icons.photo_camera,
            title: 'Profile Picture',
            subtitle: 'Update your profile picture',
            onTap: isUploadingImage ? null : () => _updateProfilePicture(),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),

          // App Features Section
          _buildSettingsItem(
            icon: Icons.trending_up,
            title: 'Show Progress',
            subtitle: 'Show off your achievements',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress details coming soon!')),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.history,
            title: 'Quiz History',
            subtitle: 'Review your quiz history',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz history coming soon!')),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.refresh,
            title: 'Reset Progress',
            subtitle: 'Start from zero again',
            onTap: () {
              _showResetDialog();
            },
            hasWarning: true,
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),

          // Danger Zone
          _buildSettingsItem(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: isUpdatingProfile ? null : () => _deleteAccount(),
            hasWarning: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool hasWarning = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasWarning)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.question_mark,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            if (hasWarning) const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text('Reset Progress'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you sure you want to reset all your progress?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This will:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildResetItem('• Clear all completed modules'),
                  _buildResetItem('• Reset progress counters to 0/6'),
                  _buildResetItem('• Reset all completion buttons'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This action cannot be undone!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isResetting ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isResetting ? null : () async {
                    final navigator = Navigator.of(context);
                    setState(() {
                      isResetting = true;
                    });
                    await _performReset();
                    if (mounted) {
                      navigator.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isResetting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Reset Progress'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildResetItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Future<void> _performReset() async {
    try {
      // Show loading state
      setState(() {
        isResetting = true;
      });

      // Call the reset progress method
      final success = await _progressService.resetProgress();

      if (success && mounted) {
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Progress reset successfully! All modules are now available to complete again.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (mounted) {
        // Show error feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Failed to reset progress. Please try again.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error feedback for exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'An error occurred while resetting progress. Please try again.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isResetting = false;
        });
      }
    }
  }
}
