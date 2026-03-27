import 'dart:math';

import 'package:flutter/material.dart';

class CustomCircularProgress extends StatefulWidget {
  final double progressPercent;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final bool showPercentage;

  const CustomCircularProgress({
    super.key,
    required this.progressPercent,
    this.size = 100,
    this.strokeWidth = 10,
    this.progressColor = Colors.green,
    this.backgroundColor = const Color(0xFF16262D),
    this.textStyle,
    this.showPercentage = true,
  });

  @override
  State<CustomCircularProgress> createState() => _CustomCircularProgressState();
}

class _CustomCircularProgressState extends State<CustomCircularProgress> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _buildProgress(),
    );
  }

  Widget _buildProgress() {
    final reducedValue = widget.progressPercent / 100;

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CircularProgressPainter(
            strokeWidth: widget.strokeWidth,
            progressPercent: reducedValue,
            color: widget.progressColor,
            backColor: widget.backgroundColor,
          ),
        ),
        if (widget.showPercentage)
          Text(
            '${widget.progressPercent.round()}%',
            style: widget.textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double strokeWidth;
  final double progressPercent;
  final Color color;
  final Color backColor;

  _CircularProgressPainter({
    required this.strokeWidth,
    required this.progressPercent,
    required this.color,
    required this.backColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backPaint = Paint()
      ..color = backColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progressPercent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      -sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent ||
        oldDelegate.color != color ||
        oldDelegate.backColor != backColor;
  }
}
