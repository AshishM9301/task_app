import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/task.dart';
import '../../../data/utils/api_service.dart';
import '../../../providers/guest_provider.dart';

class TaskHistoryScreen extends StatefulWidget {
  final bool hasNotification;
  const TaskHistoryScreen({super.key, this.hasNotification = false});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isLoading = true;
  List<Task> _tasks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory({String dateRange = 'all'}) async {
    final guestProvider = context.read<GuestProvider>();
    if (!guestProvider.hasGuestKey) {
      await guestProvider.initializeGuestKey();
    }
    _apiService.setGuestKey(guestProvider.guestKey ?? '');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getTaskHistory(
        page: 1,
        limit: 50,
        dateRange: dateRange == 'All' ? 'all' : dateRange.toLowerCase(),
      );

      if (response.success && response.data != null) {
        final tasksData = response.data!['tasks'] as List<dynamic>? ?? [];
        setState(() {
          _tasks = tasksData
              .map((json) => Task.fromApiJson(json as Map<String, dynamic>))
              .toList();
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

  List<Task> get _filteredTasks {
    List<Task> tasks = _tasks
        .where((task) => task.status == 'completed')
        .toList();

    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    switch (_selectedFilter) {
      case 'Last 7 Days':
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        tasks = tasks
            .where((task) =>
                task.completedAt != null &&
                task.completedAt!.isAfter(sevenDaysAgo))
            .toList();
        break;
      case 'Last Month':
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        tasks = tasks
            .where((task) =>
                task.completedAt != null &&
                task.completedAt!.isAfter(thirtyDaysAgo))
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
        .where((task) =>
            task.completedAt != null &&
            task.completedAt!.isAfter(threeDaysAgo))
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
      body: RefreshIndicator(
        onRefresh: () => _fetchHistory(
          dateRange: _selectedFilter == 'All' ? 'all' : _selectedFilter.toLowerCase(),
        ),
        color: AppConstants.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterPills(),
              _isLoading ? _buildLoading() : _buildTaskSections(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
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
                  _fetchHistory(
                    dateRange: filter == 'All' ? 'all' : filter.toLowerCase(),
                  );
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
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

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
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: Text(
                      task.projectTitle ?? 'Task',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
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
          child: Row(
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
              Expanded(
                child: Column(
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
                    Row(
                      children: [
                        Text(
                          _formatDate(task.completedAt),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '•',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppConstants.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.projectTitle ?? 'Task',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppConstants.secondaryColor,
                size: 16,
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
}
