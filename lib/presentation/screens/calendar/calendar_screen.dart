import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_utils.dart';
import '../tasks/task_detail_screen.dart';

class CalendarScreenController {
  VoidCallback? _refresh;

  void _bind(VoidCallback refresh) => _refresh = refresh;
  void _unbind() => _refresh = null;

  void refresh() => _refresh?.call();
}

class CalendarScreen extends StatefulWidget {
  final IconData? backButtonIcon;
  final bool hasNotification;
  final VoidCallback? onBackPressed;
  final CalendarScreenController? controller;

  const CalendarScreen({
    super.key,
    this.backButtonIcon,
    this.hasNotification = true,
    this.onBackPressed,
    this.controller,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedCategoryIndex = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = ['All', 'Todo', 'In Progress', 'Completed'];

  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(() {
      if (!mounted) return;
      _fetchTasksForDate(_selectedDate);
    });
    _fetchTasksForDate(_selectedDate);
  }

  @override
  void dispose() {
    widget.controller?._unbind();
    super.dispose();
  }

  String _formatDateParam(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatIsoToTime(BuildContext context, String? iso) {
    if (iso == null) return '--:--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final tod = TimeOfDay.fromDateTime(dt);
      return MaterialLocalizations.of(context).formatTimeOfDay(tod);
    } catch (_) {
      return '--:--';
    }
  }

  String _mapStatusToCategory(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      case 'pending':
      default:
        return 'Todo';
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Completed':
        return const Color(0xFF10B981);
      case 'In Progress':
        return const Color(0xFFF59E0B);
      case 'Todo':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _projectIconFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('study') || t.contains('school')) return Icons.school;
    if (t.contains('personal') || t.contains('home')) return Icons.person;
    return Icons.work;
  }

  Future<void> _fetchTasksForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await getTasksByDate(date: _formatDateParam(date));

      final mapped = res.data.tasks.map((t) {
        final category = _mapStatusToCategory(t.status);
        final catColor = _categoryColor(category);
        final projectTitle = t.projectTitle;
        return <String, dynamic>{
          'title': t.title,
          'time': _formatIsoToTime(context, t.startedAt),
          'taskGroup': null,
          'dueDate': null,
          'category': category,
          'color': catColor,
          'categoryColor': catColor,
          'projectName': projectTitle,
          'projectIcon': _projectIconFromTitle(projectTitle),
          'taskStarted': (t.startedAt != null) && category != 'Todo',
          'isSharedWithTeam': null,
          'sharedWithUsers': null,
          'description': t.description,
          'startTime': t.startedAt,
          'endTime': t.endedAt,
        };
      }).toList();

      setState(() {
        _tasks = mapped;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _tasks = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredTasks() {
    if (_selectedCategoryIndex == 0) {
      return _tasks;
    }
    return _tasks
        .where(
          (task) => task['category'] == _categories[_selectedCategoryIndex],
        )
        .toList();
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
              child: SingleChildScrollView(
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final List<Map<String, dynamic>> days = [];
    for (int i = -3; i <= 3; i++) {
      final date = now.add(Duration(days: i));
      days.add({
        'date': date,
        'day': date.day,
        'weekName': dayNames[date.weekday - 1],
        'month': monthNames[date.month - 1],
        'isToday':
            date.day == now.day &&
            date.month == now.month &&
            date.year == now.year,
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
          final date = dayData['date'] as DateTime;
          final isToday = dayData['isToday'] as bool;
          final isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          final active = isSelected || isToday;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _fetchTasksForDate(date);
            },
            child: Container(
              width: 70,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == days.length - 1 ? 0 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: active ? AppConstants.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: active
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
                      color: active
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
                      color: active
                          ? AppConstants.whiteColor
                          : AppConstants.blackColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayData['month'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: active
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
    final filteredTasks = _getFilteredTasks();

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Failed to load tasks',
              style: const TextStyle(
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
                onPressed: () => _fetchTasksForDate(_selectedDate),
                child: const Text('Retry'),
              ),
            ),
          ],
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
        ...filteredTasks.map(
          (task) => _buildTaskItem(
            title: task['title'] as String,
            time: task['time'] as String,
            category: task['category'] as String,
            color: task['color'] as Color,
            categoryColor: task['categoryColor'] as Color,
            projectName: task['projectName'] as String,
            projectIcon: task['projectIcon'] as IconData,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(
                    title: task['title'] as String,
                    time: task['time'] as String,
                    taskGroup: task['taskGroup'] as String?,
                    description: task['description'] as String?,
                    startTime: task['startTime'] as String?,
                    endTime: task['endTime'] as String?,
                    dueDate: task['dueDate'] as String?,
                    category: task['category'] as String,
                    categoryColor: task['categoryColor'] as Color,
                    projectName: task['projectName'] as String,
                    projectIcon: task['projectIcon'] as IconData,
                    projectColor: task['color'] as Color,
                    taskStarted: task['taskStarted'] as bool?,
                    isSharedWithTeam: task['isSharedWithTeam'] as bool?,
                    sharedWithUsers: task['sharedWithUsers'] != null
                        ? List<String>.from(task['sharedWithUsers'] as List)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String time,
    required String category,
    required Color color,
    required Color categoryColor,
    String projectName = 'Work',
    IconData projectIcon = Icons.work,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                  projectName,
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(projectIcon, color: color, size: 18),
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
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.blackColor,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
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

}
