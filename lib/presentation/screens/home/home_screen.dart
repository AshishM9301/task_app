import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_utils.dart';
import '../../../data/models/dashboard.dart';
import '../../../data/models/user.dart';
import '../../widgets/custom_circular_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _error;
  final User _user = User(
    id: '1',
    name: 'John',
    email: 'john@example.com',
    avatarUrl: null,
  );

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await getDashboardData();

      setState(() {
        _dashboardData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.whiteColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorState()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(_user),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppConstants.secondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(fontSize: 14, color: AppConstants.secondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: AppConstants.whiteColor,
            ),
            child: const Text('Retry'),
          ),
        ],
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
    final overview = _dashboardData!.overview;
    final progressPercent = overview.completedPercentage.toDouble();

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
                progressPercent: progressPercent,
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
    final tasks = _dashboardData!.inProgressTasks;

    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

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
                child: Text(
                  '${tasks.length}',
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
              children: tasks.asMap().entries.map((entry) {
                final task = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                    left: entry.key == 0 ? 0 : 0,
                  ),
                  child: _buildInProgressCard(
                    title: task.title,
                    category: task.taskGroupTitle,
                    color: _getCategoryColor(task.taskGroupSlug),
                    progress: 0.5,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String slug) {
    final colors = {
      'design': const Color(0xFF10B981),
      'development': const Color(0xFF3B82F6),
      'meeting': const Color(0xFFF59E0B),
    };
    return colors[slug.toLowerCase()] ?? AppConstants.primaryColor;
  }

  Widget _buildInProgressCard({
    required String title,
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
          const Spacer(),
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
    switch (category.toLowerCase()) {
      case 'design':
        return Icons.brush_outlined;
      case 'meeting':
        return Icons.people_outline;
      case 'development':
        return Icons.code_outlined;
      default:
        return Icons.task_alt;
    }
  }

  Widget _buildTaskTitle() {
    final overview = _dashboardData!.overview;
    final progress = overview.totalTasks > 0
        ? overview.completedTasks / overview.totalTasks
        : 0.0;

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
    final taskGroups = _dashboardData!.taskGroups;

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
            name: group.title,
            totalTasks: group.totalTasks,
            completedTasks: group.completedTasks,
            color: _getGroupColor(group.slug),
            icon: _getGroupIcon(group.slug),
          ),
        ),
      ],
    );
  }

  Color _getGroupColor(String slug) {
    final colors = {
      'work': const Color(0xFF3B82F6),
      'personal': const Color(0xFF10B981),
      'shopping': const Color(0xFFF59E0B),
      'health': const Color(0xFFEF4444),
    };
    return colors[slug.toLowerCase()] ?? AppConstants.primaryColor;
  }

  IconData _getGroupIcon(String slug) {
    final icons = {
      'work': Icons.work,
      'personal': Icons.person,
      'shopping': Icons.shopping_bag,
      'health': Icons.health_and_safety,
    };
    return icons[slug.toLowerCase()] ?? Icons.folder;
  }

  Widget _buildTaskGroupItem({
    required String name,
    required int totalTasks,
    required int completedTasks,
    required Color color,
    required IconData icon,
  }) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

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
