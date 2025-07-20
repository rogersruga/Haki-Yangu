import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class ModuleCompletionButton extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final VoidCallback? onCompleted;

  const ModuleCompletionButton({
    super.key,
    required this.moduleId,
    required this.moduleName,
    this.onCompleted,
  });

  @override
  State<ModuleCompletionButton> createState() => _ModuleCompletionButtonState();
}

class _ModuleCompletionButtonState extends State<ModuleCompletionButton>
    with SingleTickerProviderStateMixin {
  final ProgressService _progressService = ProgressService();
  bool _isCompleted = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _checkCompletionStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkCompletionStatus() async {
    final isCompleted = await _progressService.isModuleCompleted(widget.moduleId);
    if (mounted) {
      setState(() {
        _isCompleted = isCompleted;
      });
    }
  }

  Future<void> _markAsCompleted() async {
    if (_isCompleted || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Animate button press
    await _animationController.forward();
    await _animationController.reverse();

    try {
      final success = await _progressService.markModuleCompleted(widget.moduleId);
      
      if (success && mounted) {
        setState(() {
          _isCompleted = true;
          _isLoading = false;
        });

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
                Expanded(
                  child: Text(
                    '${widget.moduleName} marked as complete!',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Call completion callback
        widget.onCompleted?.call();
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });

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
                    'Failed to mark module as complete. Please try again.',
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: ElevatedButton.icon(
                onPressed: _isCompleted ? null : _markAsCompleted,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isCompleted ? Colors.grey : Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                        size: 20,
                      ),
                label: Text(
                  _isCompleted ? 'Completed' : 'Mark as Complete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleted 
                      ? Colors.grey[300] 
                      : const Color(0xFF4CAF50),
                  foregroundColor: _isCompleted 
                      ? Colors.grey[600] 
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isCompleted ? 0 : 2,
                  shadowColor: _isCompleted
                      ? Colors.transparent
                      : const Color(0xFF4CAF50).withValues(alpha: 0.3),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
