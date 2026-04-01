import 'package:flutter/material.dart';
import 'package:task_app/core/constants/app_constants.dart';
import 'package:task_app/data/models/task.dart';
import 'package:task_app/core/utils/api_utils.dart';
import 'package:task_app/data/models/models.dart';

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

  final List<Task> _tasks = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _page = 1;
  int _limit = 10;
  bool _hasNextPage = false;

  List<Task> get _filteredTasks {
    List<Task> tasks =
        _tasks.where((task) => task.status == TaskStatus.completed).toList();

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

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  String _mapFilterToDateRange(String filter) {
    switch (filter) {
      case 'Last 7 Days':
        return '7days';
      case 'Last Month':
        return 'lastMonth';
      case 'All':
      default:
        // Backend may treat empty/unknown as "all"; safest is a wide range.
        return 'lastMonth';
    }
  }

  TaskStatus _mapApiStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'in_progress':
      case 'in progress':
        return TaskStatus.inProgress;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }

  TaskType _mapProjectTitleToType(String projectTitle) {
    final t = projectTitle.toLowerCase();
    if (t.contains('personal') || t.contains('home')) return TaskType.personal;
    return TaskType.work;
  }

  DateTime _safeParseDate(String? iso, {required DateTime fallback}) {
    if (iso == null) return fallback;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return fallback;
    }
  }

  Task _mapApiTaskToUi(TaskHistoryApiTask api) {
    final createdAt = _safeParseDate(api.createdAt, fallback: DateTime.now());
    final completedAt =
        api.endedAt != null ? _safeParseDate(api.endedAt, fallback: createdAt) : null;
    final status = _mapApiStatus(api.status);

    return Task(
      id: api.id.toString(),
      title: api.title,
      description: api.description,
      dueDate: completedAt ?? createdAt,
      priority: TaskPriority.medium,
      taskType: _mapProjectTitleToType(api.projectTitle),
      status: status,
      createdAt: createdAt,
      completedAt: status == TaskStatus.completed ? completedAt : null,
    );
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _page = 1;
      _limit = 10;
    });

    try {
      final res = await getTaskHistory(
        page: _page,
        limit: _limit,
        dateRange: _mapFilterToDateRange(_selectedFilter),
      );

      final mapped = res.data.tasks.map(_mapApiTaskToUi).toList();
      setState(() {
        _tasks
          ..clear()
          ..addAll(mapped);
        _hasNextPage = res.data.pagination.hasNextPage;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isLoading || !_hasNextPage) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _page + 1;
      final res = await getTaskHistory(
        page: nextPage,
        limit: _limit,
        dateRange: _mapFilterToDateRange(_selectedFilter),
      );

      final mapped = res.data.tasks.map(_mapApiTaskToUi).toList();
      setState(() {
        _page = nextPage;
        _tasks.addAll(mapped);
        _hasNextPage = res.data.pagination.hasNextPage;
      });
    } catch (e) {
      // Keep existing items; show a lightweight error.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading more: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= (metrics.maxScrollExtent - 200)) {
            _loadMore();
          }
          return false;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterPills(),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Failed to load history',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.blackColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loadFirstPage,
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _buildTaskSections(),
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!_hasNextPage)
                  const SizedBox(height: 20),
              ],
            ],
          ),
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
                  _loadFirstPage();
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
