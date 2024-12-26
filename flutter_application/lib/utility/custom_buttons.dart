import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './constants.dart';

Container customHomeButton({
  required String title,
  required double titleFontSize,
  String? subtitle,
  double subtitleFontSize = 9.0,
  FontWeight titleFontWeight = FontWeight.w600,
  required String iconPath,
  required double iconSize,
  required VoidCallback onTap,
  required EdgeInsetsGeometry textPadding,
  required EdgeInsetsGeometry iconPadding,
}) {
  return Container(
    height: double.infinity,
    padding: textPadding,
    decoration: BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: buttonStrokeColor),
    ),
    child: InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Text Column
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: titleFontWeight,
                    ),
                  ),
                  // Conditionally show subtitle if it's provided
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          // Icon on the right
          Padding(
            padding: iconPadding,
            child: SvgPicture.asset(
              iconPath,
              color: Colors.white,
              width: iconSize,
              height: iconSize,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget customCategoryButton({
  required String title,
  required double titleFontSize,
  required String iconName,
  required double iconSize,
  required VoidCallback onTap,
  required double spacing,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: buttonStrokeColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/shadow_categories/$iconName',
                width: iconSize, height: iconSize),
            SizedBox(height: spacing),
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          ],
        )),
  );
}
