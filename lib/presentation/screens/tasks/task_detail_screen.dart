import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';

class TaskDetailScreen extends StatefulWidget {
  final IconData? backButtonIcon;
  final bool hasNotification;
  final VoidCallback? onBackPressed;

  // Task details
  final String? title;
  final String? time;
  final String? category;
  final Color? categoryColor;
  final String? projectName;
  final IconData? projectIcon;
  final Color? projectColor;

  // New parameters
  final String? taskGroup; // "Work" or "Personal"
  final String? description; // Task description
  final String? startTime;
  final String? endTime;
  final String? dueDate;
  final bool? taskStarted; // false = show start/end date, true = show due date
  final bool? isSharedWithTeam;
  final String? createdBy;
  final List<String>? sharedWithUsers;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkComplete;

  const TaskDetailScreen({
    super.key,
    this.backButtonIcon,
    this.hasNotification = true,
    this.onBackPressed,
    this.title,
    this.time,
    this.category,
    this.categoryColor,
    this.projectName,
    this.projectIcon,
    this.projectColor,
    this.taskGroup,
    this.description,
    this.startTime,
    this.endTime,
    this.dueDate,
    this.taskStarted,
    this.isSharedWithTeam,
    this.createdBy,
    this.sharedWithUsers,
    this.onEdit,
    this.onMarkComplete,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  IconData _getTaskGroupIcon() {
    if (widget.taskGroup?.toLowerCase() == 'personal') {
      return Icons.person;
    }
    return Icons.work;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.whiteColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (widget.title != null) _buildTaskDetails(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFABButton(
            icon: Icons.edit,
            label: 'Edit',
            onTap: widget.onEdit,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          _buildFABButton(
            icon: Icons.check_circle,
            label: 'Mark Complete',
            onTap: widget.onMarkComplete,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFABButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Category Pill
          if (widget.category != null) _buildCategoryPill(),
          const SizedBox(height: 16),

          // Row 2: Project Title (small)
          if (widget.projectName != null) _buildProjectTitle(),
          const SizedBox(height: 8),

          // Row 3: Task Title (large)
          if (widget.title != null) _buildTaskTitle(),
          const SizedBox(height: 16),

          // Row 4: Task Group, Time, Due Date, Shared, Created By
          _buildTaskMetaInfo(),
          if (widget.description != null && widget.description!.isNotEmpty)
            const SizedBox(height: 16),

          // Row 5: Description
          if (widget.description != null && widget.description!.isNotEmpty)
            _buildDescription(),
          if (widget.sharedWithUsers != null &&
              widget.sharedWithUsers!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSharedWithSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSharedWithSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.people,
              size: 18,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Shared with',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.blackColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.sharedWithUsers!.map((userName) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppConstants.primaryColor,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppConstants.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (widget.categoryColor ?? AppConstants.primaryColor).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (widget.categoryColor ?? AppConstants.primaryColor)
              .withOpacity(0.3),
        ),
      ),
      child: Text(
        widget.category!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: widget.categoryColor ?? AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildProjectTitle() {
    return Text(
      widget.projectName ?? '',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppConstants.secondaryColor,
      ),
    );
  }

  Widget _buildTaskTitle() {
    return Text(
      widget.title ?? '',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppConstants.blackColor,
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.whiteColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: AppConstants.secondaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.description ?? 'Here is the description of the task',
        style: const TextStyle(
          fontSize: 14,
          color: AppConstants.secondaryColor,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTaskMetaInfo() {
    final bool isStarted = widget.taskStarted ?? false;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMetaItem(
            icon: widget.projectIcon ?? Icons.group,
            label: widget.taskGroup,
            iconColor: AppConstants.primaryColor,
          ),
          if (!isStarted) ...[
            // Task not started - show start and end date
            if (widget.startTime != null) ...[
              const SizedBox(width: 20),
              _buildMetaItem(
                icon: Icons.play_arrow,
                label: DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(widget.startTime!)),
                iconColor: AppConstants.primaryColor,
              ),
            ],
            if (widget.endTime != null) ...[
              const SizedBox(width: 20),
              _buildMetaItem(
                icon: Icons.stop,
                label: DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(widget.endTime!)),
                iconColor: AppConstants.primaryColor,
              ),
            ],
          ] else ...[
            // Task started - show due date
            if (widget.dueDate != null) ...[
              const SizedBox(width: 20),
              _buildMetaItem(
                icon: Icons.calendar_today,
                label: widget.dueDate,
                iconColor: AppConstants.primaryColor,
              ),
            ],
          ],
          const SizedBox(width: 20),
          _buildMetaItem(
            icon: Icons.people,
            label: widget.isSharedWithTeam ?? false ? 'Shared' : 'Private',
            iconColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({required List<Widget> children}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: children.map((child) {
          final index = children.indexOf(child);
          return Row(
            children: [
              child,
              if (index < children.length - 1) const SizedBox(width: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    String? label,
    required Color iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        if (label != null) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppConstants.secondaryColor,
            ),
          ),
        ],
      ],
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
            "Task Management",
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
}
