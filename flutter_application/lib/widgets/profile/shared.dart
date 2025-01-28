import 'package:flutter/material.dart';

class CustomHorizontalDivider extends StatelessWidget {
  final double padding;
  final Color color;
  final double thickness;

  const CustomHorizontalDivider({
    super.key,
    required this.padding,
    this.color = Colors.white24,
    this.thickness = 1.25,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
      child: Divider(color: color, thickness: thickness),
    );
  }
}

class CustomVerticalDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double width;

  const CustomVerticalDivider({
    super.key,
    this.color = Colors.white30,
    this.height = double.infinity,
    this.width = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color,
    );
  }
}
