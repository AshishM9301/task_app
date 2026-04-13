import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user.dart';
import '../../../data/utils/api_service.dart';
import '../../../providers/guest_provider.dart';
import '../../widgets/custom_circular_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;
  String? _error;

  // Dashboard data
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _inProgressTasks = 0;
  int _pendingTasks = 0;
  int _completedPercentage = 0;
  int _inProgressPercentage = 0;
  int _pendingPercentage = 0;
  List<dynamic> _inProgressTasksList = [];
  List<dynamic> _taskGroups = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndFetch();
    });
  }

  Future<void> _initializeAndFetch() async {
    final guestProvider = context.read<GuestProvider>();
    
    try {
      await guestProvider.initializeGuestKey();
    } catch (e) {
      // Continue even if guest key fails - guest key is optional for viewing
      debugPrint('Guest key initialization failed: $e');
    }
    
    if (guestProvider.hasGuestKey) {
      _apiService.setGuestKey(guestProvider.guestKey!);
    }
    
    // Always try to fetch dashboard - guest key is optional
    await _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getDashboard();
      if (response.success && response.data != null) {
        final data = response.data!;
        final overview = data['overview'] ?? {};

        setState(() {
          _totalTasks = overview['totalTasks'] ?? 0;
          _completedTasks = overview['completedTasks'] ?? 0;
          _inProgressTasks = overview['inProgressTasks'] ?? 0;
          _pendingTasks = overview['pendingTasks'] ?? 0;
          _completedPercentage = overview['completedPercentage'] ?? 0;
          _inProgressPercentage = overview['inProgressPercentage'] ?? 0;
          _pendingPercentage = overview['pendingPercentage'] ?? 0;
          _inProgressTasksList = data['inProgressTasks'] ?? [];
          _taskGroups = data['taskGroups'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestProvider = context.watch<GuestProvider>();

    if (guestProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppConstants.whiteColor,
        body: Center(
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.whiteColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDashboard,
          color: AppConstants.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(guestProvider.guestKey ?? ''),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  )
                else if (_error != null)
                  _buildErrorWidget()
                else ...[
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                  _buildInProgressTasks(),
                  const SizedBox(height: 24),
                  _buildTaskGroups(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String guestKey) {
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
                const Text(
                  'Hello,',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.secondaryColor,
                  ),
                ),
                Text(
                  guestKey.isNotEmpty ? 'Guest' : 'User',
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
          onPressed: _fetchDashboard,
          icon: const Icon(Icons.notifications),
          color: AppConstants.blackColor,
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progressPercent = _completedPercentage.toDouble();

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
    if (_inProgressTasksList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'In Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.blackColor,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: AppConstants.secondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No tasks in progress',
                    style: TextStyle(color: AppConstants.secondaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
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
                  '${_inProgressTasksList.length}',
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 12,
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
              children: _inProgressTasksList.take(10).map((task) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildInProgressCard(
                    title: task['title'] ?? 'Untitled',
                    time: task['ended_at'] != null
                        ? _formatDateTime(task['ended_at'])
                        : 'No deadline',
                    category: task['project_title'] ?? 'General',
                    color: AppConstants.primaryColor,
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return dateStr;
    }
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                    const Icon(
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
    final total = _totalTasks;
    final progress = total > 0 ? _completedTasks / total : 0.0;

    String message;
    if (total == 0) {
      message = "Let's get started! Create your first task.";
    } else if (progress == 0) {
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
    if (_taskGroups.isEmpty) {
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 48,
                    color: AppConstants.secondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No task groups yet',
                    style: TextStyle(color: AppConstants.secondaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

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
        ..._taskGroups.map((group) {
          final color = _getGroupColor(_taskGroups.indexOf(group));
          return _buildTaskGroupItem(
            name: group['title'] ?? 'Untitled',
            totalTasks: group['totalTasks'] ?? 0,
            completedTasks: group['completedTasks'] ?? 0,
            color: color,
            icon: _getCategoryIcon(group['title'] ?? ''),
          );
        }),
      ],
    );
  }

  Color _getGroupColor(int index) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];
    return colors[index % colors.length];
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