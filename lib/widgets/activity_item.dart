import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityItem extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final bool showDivider;

  const ActivityItem({
    super.key,
    required this.activity,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Activity Icon
                  _buildActivityIcon(),
                  const SizedBox(width: 16),
                  
                  // Activity Content
                  Expanded(
                    child: _buildActivityContent(context),
                  ),
                  
                  // Chevron Icon
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Divider
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[200],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (activity.accentColor ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        activity.icon,
        color: activity.accentColor ?? Colors.grey,
        size: 20,
      ),
    );
  }

  Widget _buildActivityContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Activity Title
        Text(
          activity.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Activity Description
        Text(
          activity.description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class ActivityList extends StatelessWidget {
  final List<Activity> activities;
  final Function(Activity)? onActivityTap;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ActivityList({
    super.key,
    required this.activities,
    this.onActivityTap,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isLast = index == activities.length - 1;
        
        return ActivityItem(
          activity: activity,
          showDivider: !isLast,
          onTap: onActivityTap != null 
              ? () => onActivityTap!(activity)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring to see your activity here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final List<Activity> activities;
  final String title;
  final Function(Activity)? onActivityTap;
  final VoidCallback? onViewAll;
  final int maxItems;

  const ActivityCard({
    super.key,
    required this.activities,
    this.title = 'Recent Activity',
    this.onActivityTap,
    this.onViewAll,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayActivities = activities.take(maxItems).toList();

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (onViewAll != null && activities.length > maxItems)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Activity List
          if (displayActivities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
              child: ActivityList(
                activities: displayActivities,
                onActivityTap: onActivityTap,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ActivityList(
                activities: [],
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
        ],
      ),
    );
  }
}
