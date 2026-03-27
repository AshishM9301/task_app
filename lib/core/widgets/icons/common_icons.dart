import 'package:flutter/material.dart';

class HomeIcon extends StatelessWidget {
  final Color color;
  final double? size;

  const HomeIcon({
    super.key,
    required this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.home,
      color: color,
      size: size ?? 24,
    );
  }
}

class TasksIcon extends StatelessWidget {
  final Color color;
  final double? size;

  const TasksIcon({
    super.key,
    required this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.checklist,
      color: color,
      size: size ?? 24,
    );
  }
}

class CalendarIcon extends StatelessWidget {
  final Color color;
  final double? size;

  const CalendarIcon({
    super.key,
    required this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.calendar_month,
      color: color,
      size: size ?? 24,
    );
  }
}
