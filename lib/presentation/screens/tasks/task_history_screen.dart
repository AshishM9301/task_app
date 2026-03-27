import 'package:flutter/material.dart';
import 'package:task_app/core/constants/app_constants.dart';
import 'package:task_app/data/models/task.dart';

class TaskHistoryScreen extends StatefulWidget {
  final bool hasNotification;
  const TaskHistoryScreen({super.key, this.hasNotification = false});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<Task> _sampleTasks = [
    Task(
      id: '1',
      title: 'Complete project documentation',
      description: 'Write comprehensive docs for the new API',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: TaskPriority.high,
      taskType: TaskType.work,
      status: TaskStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'Design landing page mockups',
      description: 'Create mockups for the new landing page',
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      priority: TaskPriority.medium,
      taskType: TaskType.personal,
      status: TaskStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      completedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Task(
      id: '3',
      title: 'Fix login bug',
      description: 'Users cannot login with Google OAuth',
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      priority: TaskPriority.high,
      taskType: TaskType.work,
      status: TaskStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      completedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Task(
      id: '4',
      title: 'Update dependencies',
      description: 'Update all npm packages to latest versions',
      dueDate: DateTime.now().subtract(const Duration(days: 8)),
      priority: TaskPriority.low,
      taskType: TaskType.personal,
      status: TaskStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      completedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Task(
      id: '5',
      title: 'Code review for PR #42',
      description: 'Review the new authentication flow',
      dueDate: DateTime.now().subtract(const Duration(days: 12)),
      priority: TaskPriority.medium,
      taskType: TaskType.work,
      status: TaskStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      completedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  List<Task> get _filteredTasks {
    List<Task> tasks = _sampleTasks
        .where((task) => task.status == TaskStatus.completed)
        .toList();

    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    switch (_selectedFilter) {
      case 'Last 7 Days':
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        tasks = tasks
            .where(
              (task) =>
                  task.completedAt != null &&
                  task.completedAt!.isAfter(sevenDaysAgo),
            )
            .toList();
        break;
      case 'Last Month':
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        tasks = tasks
            .where(
              (task) =>
                  task.completedAt != null &&
                  task.completedAt!.isAfter(thirtyDaysAgo),
            )
            .toList();
        break;
      default:
        break;
    }

    return tasks;
  }

  List<Task> get _recentlyCompleted {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    return _filteredTasks
        .where(
          (task) =>
              task.completedAt != null &&
              task.completedAt!.isAfter(threeDaysAgo),
        )
        .toList();
  }

  List<Task> get _lastWeek {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    return _filteredTasks.where((task) {
      if (task.completedAt == null) return false;
      return task.completedAt!.isAfter(fourteenDaysAgo) &&
          task.completedAt!.isBefore(sevenDaysAgo);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterPills(),
            _buildTaskSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 40, height: 40),
          const Center(
            child: Text(
              "Task History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.blackColor,
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              if (widget.hasNotification)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConstants.whiteColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: AppConstants.primaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Search tasks by title...',
                  hintStyle: TextStyle(
                    color: AppConstants.secondaryColor,
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Icon(
                  Icons.close,
                  color: AppConstants.secondaryColor,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = ['All', 'Last 7 Days', 'Last Month'];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: filter != filters.last ? 8 : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusLarge,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppConstants.primaryColor
                          : AppConstants.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppConstants.secondaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskSections() {
    final recentlyCompleted = _recentlyCompleted;
    final lastWeek = _lastWeek;

    if (_filteredTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppConstants.secondaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No completed tasks found',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recentlyCompleted.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(
              left: AppConstants.paddingMedium,
              bottom: 8,
            ),
            child: Text(
              'Recently Completed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.blackColor,
              ),
            ),
          ),
          ...recentlyCompleted.map((task) => _buildTaskCard(task)),
        ],
        if (lastWeek.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(
              left: AppConstants.paddingMedium,
              top: 16,
              bottom: 8,
            ),
            child: Text(
              'Last Week',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.blackColor,
              ),
            ),
          ),
          ...lastWeek.map((task) => _buildOldTaskCard(task)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return InkWell(
      onTap: () {
        print('Task tapped: ${task.title}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: 6,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppConstants.primaryColor,
                      size: 24,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTaskTypeColor(task.taskType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: Text(
                      _getTaskTypeLabel(task.taskType),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTaskTypeColor(task.taskType),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.blackColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(task.completedAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.secondaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOldTaskCard(Task task) {
    return InkWell(
      onTap: () {
        print('Task tapped: ${task.title}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: 6,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppConstants.whiteColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.blackColor,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Row(
                        children: [
                          Text(
                            _formatDate(task.completedAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTaskTypeLabel(task.taskType),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    width: 40,
                    height: 40,

                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppConstants.secondaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getTaskTypeColor(TaskType taskType) {
    switch (taskType) {
      case TaskType.work:
        return Colors.red;
      case TaskType.personal:
        return Colors.orange;
      case TaskType.low:
        return Colors.green;
    }
  }

  IconData _getTaskTypeIcon(TaskType taskType) {
    switch (taskType) {
      case TaskType.work:
        return Icons.work;
      case TaskType.personal:
        return Icons.person;
      case TaskType.low:
        return Icons.low_priority;
    }
  }

  String _getTaskTypeLabel(TaskType taskType) {
    switch (taskType) {
      case TaskType.work:
        return 'Work';
      case TaskType.personal:
        return 'Personal';
      case TaskType.low:
        return 'Low';
    }
  }
}
