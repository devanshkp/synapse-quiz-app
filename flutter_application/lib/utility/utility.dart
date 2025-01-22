import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'colors.dart';
import 'dart:ui';

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
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3), // Shadow color
          blurRadius: 10, // Reduced spread for a cleaner look
          offset: const Offset(0, 4), // Positioning of the shadow
        ),
      ],
      gradient: buttonGradient,
      borderRadius: BorderRadius.circular(20),
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

Widget categoryButton({
  required String title,
  required String iconName,
  required double iconSize,
  required VoidCallback onTap,
  required double spacing,
  required Color color,
  required double titleFontSize,
  double? radius,
  double? buttonWidth, // Added width option
  double? buttonHeight, // Added height option
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: buttonWidth ?? double.infinity, // Default width if not provided
      height: buttonHeight ?? double.infinity, // Default height if not provided
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            blurRadius: 8, // Reduced spread for a cleaner look
            offset: const Offset(0, 6), // Positioning of the shadow
          ),
        ],
        color: color,
        borderRadius: BorderRadius.circular(radius ?? 10),
      ),
      child: Stack(
        children: [
          // Positioned image for bottom-right corner
          Positioned(
            bottom: -10, // Adjust for better positioning
            right: -10, // Adjust for better positioning
            child: Transform.rotate(
              angle: 0.3, // 45 degrees in radians
              child: Image.asset(
                'assets/images/shadow_categories/$iconName',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Positioned text for top-left corner
          Padding(
            padding: const EdgeInsets.all(12), // Padding for the text
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: radius != null
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: Colors.white,
                          shadows: <Shadow>[
                            Shadow(
                              offset: const Offset(2.0, 2.0),
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2, // Optional: Limit to 2 lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget altCategoryButton({
  required String title,
  required String iconName,
  required double iconSize,
  required VoidCallback onTap,
  required double spacing,
  required Color color,
  required double titleFontSize,
  double? radius,
  double? buttonWidth, // Added width option
  double? buttonHeight, // Added height option
}) {
  return Column(
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          width:
              buttonWidth ?? double.infinity, // Default width if not provided
          height:
              buttonHeight ?? double.infinity, // Default height if not provided
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Shadow color
                blurRadius: 8, // Reduced spread for a cleaner look
                offset: const Offset(0, 6), // Positioning of the shadow
              ),
            ],
            color: color,
            borderRadius: BorderRadius.circular(radius ?? 10),
          ),
          child: Image.asset(
            'assets/images/shadow_categories/$iconName',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.cover,
          ),
        ),
      ),
      Text(
        title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: radius != null ? FontWeight.w700 : FontWeight.w600,
          color: Colors.white,
          shadows: <Shadow>[
            Shadow(
              offset: const Offset(2.0, 2.0),
              blurRadius: 10.0,
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        textAlign: TextAlign.left,
        maxLines: 2, // Optional: Limit to 2 lines
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget backgroundImage() {
  return Stack(
    children: [
      Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/mesh.png'),
                  fit: BoxFit.cover))),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 10.0, sigmaY: 10.0), // Adjust blur intensity
          child: Container(
            color: Colors.black.withOpacity(0.3), // Optional: Add overlay color
          ),
        ),
      ),
    ],
  );
}
