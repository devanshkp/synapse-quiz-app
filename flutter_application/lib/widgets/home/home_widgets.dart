import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/pages/topic.dart';
import 'package:flutter_application/pages/trivia.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/home/topic_selection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

import 'package:string_extensions/string_extensions.dart';

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
  String? heroTag,
}) {
  Widget buttonContent = Container(
    padding: textPadding,
    height: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 5,
          offset: const Offset(0, 4),
        ),
      ],
      gradient: buttonGradient,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
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
  );

  if (heroTag != null) {
    buttonContent = Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: buttonContent,
      ),
    );
  }

  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 1,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    child: buttonContent,
  );
}

class TopicButton extends StatelessWidget {
  final String title;
  final String iconName;
  final double iconSize;
  final Color color;
  final double titleFontSize;
  final String buttonType;
  final double? radius;
  final double? buttonWidth;
  final double? buttonHeight;
  final double? bottomOffset;
  final double? rightOffset;
  final String? section;

  const TopicButton({
    super.key,
    required this.title,
    required this.iconName,
    required this.iconSize,
    required this.color,
    required this.titleFontSize,
    required this.buttonType,
    this.radius,
    this.buttonWidth,
    this.buttonHeight,
    this.bottomOffset,
    this.rightOffset,
    this.section,
  });

  @override
  Widget build(BuildContext context) {
    final String heroBaseTag = section != null
        ? '${title}_${buttonType}_$section'
        : '${title}_$buttonType';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TopicDetailsPage(
                topicName: title,
                iconName: iconName,
                topicColor: color,
                buttonType: buttonType,
                heroBaseTag: heroBaseTag,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: Container(
          width: buttonWidth ?? double.infinity,
          height: buttonHeight ?? double.infinity,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ], gradient: createGradientFromColor(color)),
          child: Stack(
            children: [
              // Positioned image for bottom-right corner
              Positioned(
                bottom: bottomOffset ?? -10,
                right: rightOffset ?? -10,
                child: Hero(
                  tag: 'topic_icon_$heroBaseTag',
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Image.asset(
                      'assets/images/topics/$iconName',
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Positioned text for top-left corner
              Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Hero(
                    tag: 'topic_title_$heroBaseTag',
                    child: Material(
                      color: Colors.transparent,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Text(
                          title.replaceAll('_', ' ').toTitleCase,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: radius != null
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

class QuickPlayButton extends StatelessWidget {
  const QuickPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: customHomeButton(
        title: 'QUICK PLAY',
        titleFontSize: 28,
        titleFontWeight: FontWeight.bold,
        subtitle: 'Play questions from your selected topics!',
        subtitleFontSize: 11,
        iconPath: 'assets/icons/home/Play.svg',
        iconSize: 22,
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TriviaPage(quickPlay: true),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Main slide up animation
                var slideUpAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutExpo,
                  ),
                );

                // Scale animation
                var scaleAnimation = Tween<double>(
                  begin: 0.85,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                );

                return SlideTransition(
                  position: slideUpAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 600),
              reverseTransitionDuration: const Duration(milliseconds: 500),
            ),
          );
        },
        textPadding: const EdgeInsets.only(left: 17, right: 12, bottom: 5),
        iconPadding: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}

class TopicSelectionButton extends StatelessWidget {
  final UserProvider userProvider;

  const TopicSelectionButton({super.key, required this.userProvider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: customHomeButton(
        title: 'Topic Selection',
        titleFontSize: 16,
        iconPath: 'assets/icons/home/Edit.svg',
        iconSize: 15,
        heroTag: 'topic_selection_popup',
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (context) => const TopicSelectionPopup(),
          );
        },
        textPadding: const EdgeInsets.only(left: 15, right: 11),
        iconPadding: const EdgeInsets.only(bottom: 25),
      ),
    );
  }
}
