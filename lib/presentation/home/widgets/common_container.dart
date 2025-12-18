import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class CommonContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final String backgroundImageUrl;

  const CommonContainer({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    required this.backgroundImageUrl
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(backgroundImageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
