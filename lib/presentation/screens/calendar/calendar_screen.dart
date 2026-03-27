import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
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
  int _selectedCategoryIndex = 0;

  final List<String> _categories = ['All', 'Todo', 'In Progress'];

  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Design UI Mockups',
      'time': '10:00 AM',
      'taskGroup': 'Work',
      'dueDate': '2026-03-22',
      'category': 'Todo',
      'color': const Color(0xFF10B981),
      'categoryColor': const Color(0xFF3B82F6),
      'projectName': 'Work',
      'projectIcon': Icons.work,
      'taskStarted': true,
      'isSharedWithTeam': true,
      'sharedWithUsers': ['John Doe', 'Jane Smith'],
      'description': 'Design UI Mockups for the new project',
    },
    {
      'title': 'Team Meeting',
      'time': '2:00 PM',
      'taskGroup': 'Personal',
      'category': 'In Progress',
      'color': const Color(0xFFF59E0B),
      'categoryColor': const Color(0xFFF59E0B),
      'projectName': 'Personal',
      'projectIcon': Icons.person,
      'startTime': '2026-03-22',
      'endTime': '2026-03-25',
      'taskStarted': false,
      'sharedWithUsers': ['Alice Johnson'],
      'description': 'Team Meeting with the team',
    },
    {
      'title': 'Code Review',
      'time': '4:30 PM',
      'category': 'Todo',
      'color': const Color(0xFF3B82F6),
      'categoryColor': const Color(0xFF3B82F6),
      'projectName': 'Study',
      'projectIcon': Icons.school,
      'taskStarted': false,
      'description': 'Code Review for the new project',
    },
    {
      'title': 'API Integration',
      'time': '5:00 PM',
      'category': 'In Progress',
      'color': const Color(0xFF8B5CF6),
      'categoryColor': const Color(0xFFF59E0B),
      'projectName': 'Work',
      'projectIcon': Icons.work,
      'taskStarted': false,
      'sharedWithUsers': ['Bob Wilson', 'Carol White', 'David Brown'],
      'description': 'API Integration for the new project',
    },
    {
      'title': 'Write Documentation',
      'time': '6:00 PM',
      'category': 'Todo',
      'color': const Color(0xFFEF4444),
      'categoryColor': const Color(0xFF3B82F6),
      'projectName': 'Personal',
      'projectIcon': Icons.person,
      'taskStarted': false,
      'description': 'Write Documentation for the new project',
    },
  ];

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
          final isToday = dayData['isToday'] as bool;

          return Container(
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Todo':
        return Icons.radio_button_unchecked;
      case 'In Progress':
        return Icons.timelapse;
      default:
        return Icons.task_alt;
    }
  }
}
