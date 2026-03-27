import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final double? size;

  const ProfileIcon({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: Stack(
        children: [
          // Background/secondary parts
          CustomPaint(
            size: Size(size ?? 24, size ?? 24),
            painter: _ProfilePainter(
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _ProfilePainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Left person head
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.35),
      size.width * 0.12,
      secondaryPaint,
    );

    // Left person body
    final leftBodyPath = Path();
    leftBodyPath.moveTo(size.width * 0.07, size.height * 0.85);
    leftBodyPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.55,
      size.width * 0.43,
      size.height * 0.85,
    );
    canvas.drawPath(leftBodyPath, secondaryPaint);

    // Right person head (front)
    canvas.drawCircle(
      Offset(size.width * 0.60, size.height * 0.30),
      size.width * 0.14,
      primaryPaint,
    );

    // Right person body (front)
    final rightBodyPath = Path();
    rightBodyPath.moveTo(size.width * 0.40, size.height * 0.85);
    rightBodyPath.quadraticBezierTo(
      size.width * 0.60,
      size.height * 0.50,
      size.width * 0.80,
      size.height * 0.85,
    );
    canvas.drawPath(rightBodyPath, primaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
