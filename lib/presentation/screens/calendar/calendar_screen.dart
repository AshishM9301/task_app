import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/task.dart';
import '../../../data/utils/api_service.dart';
import '../../../providers/guest_provider.dart';
import '../tasks/task_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  final IconData? backButtonIcon;
  final bool hasNotification;
  final VoidCallback? onBackPressed;

  const CalendarScreen({
    super.key,
    this.backButtonIcon,
    this.hasNotification = true,
    this.onBackPressed,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  int _selectedCategoryIndex = 0;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['All', 'Todo', 'In Progress'];

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTasks();
    });
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final guestProvider = context.read<GuestProvider>();
      if (!guestProvider.hasGuestKey) {
        await guestProvider.initializeGuestKey();
        if (!guestProvider.hasGuestKey) {
          setState(() {
            _error = 'Failed to initialize guest key';
            _isLoading = false;
          });
          return;
        }
      }
      _apiService.setGuestKey(guestProvider.guestKey!);
      final response = await _apiService.getTasksByDate(
        date: _selectedDate.toIso8601String().split('T')[0],
      );


      if (response.success && response.data != null) {
        final tasksData = response.data! as List<dynamic>;
        setState(() {
          _tasks = tasksData
              .map((json) => Task.fromApiJson(json as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        print('error: ${response.message}');
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Task> _getFilteredTasks() {
    if (_selectedCategoryIndex == 0) {
      return _tasks;
    }

    final statusMap = {
      1: 'pending',
      2: 'in_progress',
    };

    final status = statusMap[_selectedCategoryIndex] ?? 'all';
    return _tasks.where((task) => task.status == status).toList();
  }

  void _selectDate(int daysFromToday) {
    final newDate = DateTime.now().add(Duration(days: daysFromToday));
    setState(() {
      _selectedDate = newDate;
    });
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchTasks,
                color: AppConstants.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDaysCard(),
                      const SizedBox(height: 24),
                      _buildCategoryChips(),
                      const SizedBox(height: 24),
                      _buildTasksList(),
                    ],
                  ),
                ),
              ),
            ),
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
          GestureDetector(
            onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                widget.backButtonIcon ?? Icons.arrow_back_ios_new,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
          ),
          const Text(
            "Today's Tasks",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.blackColor,
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

  Widget _buildDaysCard() {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final List<Map<String, dynamic>> days = [];
    for (int i = -3; i <= 3; i++) {
      final date = now.add(Duration(days: i));
      days.add({
        'day': date.day,
        'weekName': dayNames[date.weekday - 1],
        'month': monthNames[date.month - 1],
        'isToday':
            date.day == now.day &&
            date.month == now.month &&
            date.year == now.year,
        'offset': i,
      });
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final dayData = days[index];
          final isToday = dayData['isToday'] as bool;
          final offset = dayData['offset'] as int;

          return GestureDetector(
            onTap: () => _selectDate(offset),
            child: Container(
              width: 70,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == days.length - 1 ? 0 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isToday ? AppConstants.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: isToday
                        ? AppConstants.primaryColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayData['weekName'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isToday
                          ? AppConstants.whiteColor.withOpacity(0.8)
                          : AppConstants.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayData['day'].toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? AppConstants.whiteColor
                          : AppConstants.blackColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayData['month'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday
                          ? AppConstants.whiteColor.withOpacity(0.8)
                          : AppConstants.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppConstants.primaryColor
                      : AppConstants.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppConstants.whiteColor
                      : AppConstants.primaryColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            color: AppConstants.primaryColor,
          ),
        ),
      );
    }

    print('tasks: ${_error}');

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchTasks,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredTasks = _getFilteredTasks();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: AppConstants.secondaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No tasks for this day',
                style: TextStyle(
                  fontSize: 18,
                  color: AppConstants.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${filteredTasks.length} Tasks',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredTasks.map((task) => _buildTaskItem(task: task)),
      ],
    );
  }

  Widget _buildTaskItem({required Task task}) {
    final status = task.status;
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.projectTitle ?? 'No Project',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.secondaryColor,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: statusColor,
                    size: 18,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.blackColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppConstants.secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(task.endedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatStatus(status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'pending':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.timelapse;
      case 'pending':
      default:
        return Icons.radio_button_unchecked;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
      default:
        return 'Todo';
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'No deadline';
    try {
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return 'Invalid';
    }
  }
}