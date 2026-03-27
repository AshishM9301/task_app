import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user.dart';
import '../../widgets/custom_circular_progress.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = User(
      id: '1',
      name: 'John',
      email: 'john@example.com',
      avatarUrl: null,
    );

    return Scaffold(
      backgroundColor: AppConstants.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 24),

              _buildProgressCard(),
              const SizedBox(height: 24),
              _buildInProgressTasks(),
              const SizedBox(height: 24),
              _buildTaskGroups(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppConstants.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.secondaryColor,
                  ),
                ),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.blackColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications),
          color: AppConstants.blackColor,
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${dayNames[now.weekday - 1]}, ${monthNames[now.month - 1]} ${now.day}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.blackColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getOrdinalSuffix(now.day),
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.secondaryColor,
          ),
        ),
      ],
    );
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  Widget _buildProgressCard() {
    final completed = 12;
    final inProgress = 5;
    final pending = 3;
    final total = completed + inProgress + pending;
    final progressPercent = total > 0 ? (completed / total * 100).round() : 0;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppConstants.primaryColor, Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskTitle(),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('View Task'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              CustomCircularProgress(
                progressPercent: progressPercent.toDouble(),
                size: 100,
                strokeWidth: 10,
                progressColor: AppConstants.whiteColor,
                backgroundColor: Colors.white.withOpacity(0.3),
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.whiteColor,
                ),
              ),
              const SizedBox(),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildInProgressTasks() {
    final tasks = [
      {
        'title': 'Design UI Mockups',
        'time': '10:00 AM',
        'category': 'Design',
        'color': const Color(0xFF10B981),
        'progress': 0.65,
      },
      {
        'title': 'Team Meeting',
        'time': '2:00 PM',
        'category': 'Meeting',
        'color': const Color(0xFFF59E0B),
        'progress': 0.40,
      },
      {
        'title': 'Code Review',
        'time': '4:30 PM',
        'category': 'Development',
        'color': const Color(0xFF3B82F6),
        'progress': 0.80,
      },
      {
        'title': 'API Integration',
        'time': '5:00 PM',
        'category': 'Development',
        'color': const Color(0xFF8B5CF6),
        'progress': 0.55,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'In Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.blackColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: const Text(
                  '6',
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: tasks.map((task) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                    left: task == tasks.first ? 0 : 0,
                  ),
                  child: _buildInProgressCard(
                    title: task['title'] as String,
                    time: task['time'] as String,
                    category: task['category'] as String,
                    color: task['color'] as Color,
                    progress: task['progress'] as double,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressCard({
    required String title,
    required String time,
    required String category,
    required Color color,
    required double progress,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.blackColor.withOpacity(0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(_getCategoryIcon(category), color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConstants.blackColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String time,
    required String category,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCategoryIcon(category), color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.blackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppConstants.secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Design':
        return Icons.brush_outlined;
      case 'Meeting':
        return Icons.people_outline;
      case 'Development':
        return Icons.code_outlined;
      default:
        return Icons.task_alt;
    }
  }

  Widget _buildTaskTitle() {
    final completed = 12;
    final inProgress = 5;
    final pending = 3;
    final total = completed + inProgress + pending;
    final progress = total > 0 ? completed / total : 0.0;

    String message;
    if (progress == 0) {
      message = "Let's get started! You have tasks to complete today.";
    } else if (progress < 0.25) {
      message = "Great start! Keep going with your tasks.";
    } else if (progress < 0.50) {
      message = "You're making good progress!";
    } else if (progress < 0.75) {
      message = "You're doing great! More than halfway there.";
    } else if (progress < 1.0) {
      message = "Almost there! Just a few more tasks.";
    } else {
      message = "Congratulations! All tasks completed!";
    }

    return Text(
      message,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppConstants.whiteColor,
      ),
    );
  }

  Widget _buildTaskGroups() {
    final taskGroups = [
      {
        'name': 'Work',
        'totalTasks': 12,
        'completedTasks': 8,
        'color': const Color(0xFF3B82F6),
        'icon': Icons.work,
      },
      {
        'name': 'Personal',
        'totalTasks': 8,
        'completedTasks': 5,
        'color': const Color(0xFF10B981),
        'icon': Icons.person,
      },
      {
        'name': 'Shopping',
        'totalTasks': 6,
        'completedTasks': 2,
        'color': const Color(0xFFF59E0B),
        'icon': Icons.shopping_bag,
      },
      {
        'name': 'Health',
        'totalTasks': 4,
        'completedTasks': 4,
        'color': const Color(0xFFEF4444),
        'icon': Icons.health_and_safety,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Groups',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        ...taskGroups.map(
          (group) => _buildTaskGroupItem(
            name: group['name'] as String,
            totalTasks: group['totalTasks'] as int,
            completedTasks: group['completedTasks'] as int,
            color: group['color'] as Color,
            icon: group['icon'] as IconData,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskGroupItem({
    required String name,
    required int totalTasks,
    required int completedTasks,
    required Color color,
    required IconData icon,
  }) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final remaining = totalTasks - completedTasks;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.blackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalTasks tasks',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          CustomCircularProgress(
            progressPercent: progress * 100,
            size: 56,
            strokeWidth: 6,
            progressColor: color,
            backgroundColor: color.withOpacity(0.2),
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            showPercentage: true,
          ),
        ],
      ),
    );
  }
}
