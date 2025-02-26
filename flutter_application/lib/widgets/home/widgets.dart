import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

Widget customHomeButton({
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
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 1,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    child: Container(
      padding: textPadding,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            blurRadius: 5, // Reduced spread for a cleaner look
            offset: const Offset(0, 4), // Positioning of the shadow
          ),
        ],
        gradient: buttonGradient,
      ),
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

Widget topicButton({
  required String title,
  required String iconName,
  required double iconSize,
  required VoidCallback onTap,
  required Color color,
  required double titleFontSize,
  double? radius,
  double? buttonWidth, // Added width option
  double? buttonHeight, // Added height option
  double? bottomOffset,
  double? rightOffset,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius ?? 10),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonWidth ?? double.infinity, // Default width if not provided
        height:
            buttonHeight ?? double.infinity, // Default height if not provided
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            blurRadius: 8, // Reduced spread for a cleaner look
            offset: const Offset(0, 6), // Positioning of the shadow
          ),
        ], gradient: createGradientFromColor(color)),
        child: Stack(
          children: [
            // Positioned image for bottom-right corner
            Positioned(
              bottom: bottomOffset ?? -10, // Adjust for better positioning
              right: rightOffset ?? -10, // Adjust for better positioning
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
    ),
  );
}

LinearGradient createGradientFromColor(Color baseColor) {
  // Convert the base color to HSL to manipulate lightness
  HSLColor hslColor = HSLColor.fromColor(baseColor);
  Color darkerVariant = hslColor
      .withLightness((hslColor.lightness - 0.025).clamp(0.0, 1.0))
      .toColor();

  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      baseColor,
      darkerVariant,
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
