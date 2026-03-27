import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  final String iconPath;
  final double? width;
  final double? height;
  final Color? color;

  const AppIcon({
    super.key,
    required this.iconPath,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        width: width ?? 24,
        height: height ?? 24,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
      );
    }
    print(iconPath);
    return Image.asset(
      iconPath,
      width: width ?? 24,
      height: height ?? 24,
    );
  }
}
