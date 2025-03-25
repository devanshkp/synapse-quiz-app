import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/pages/main/trivia.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/pages/secondary/question_history.dart';
import 'package:flutter_application/pages/secondary/topic_selection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

class CustomHomeButton extends StatelessWidget {
  final String title;
  final double titleFontSize;
  final String? subtitle;
  final double subtitleFontSize;
  final FontWeight titleFontWeight;
  final String iconPath;
  final double iconSize;
  final VoidCallback onTap;
  final EdgeInsetsGeometry textPadding;
  final EdgeInsetsGeometry iconPadding;
  final Color splashColor;
  final Color highlightColor;

  const CustomHomeButton({
    super.key,
    required this.title,
    required this.titleFontSize,
    this.subtitle,
    this.subtitleFontSize = 9.0,
    this.titleFontWeight = FontWeight.w600,
    required this.iconPath,
    required this.iconSize,
    required this.onTap,
    required this.textPadding,
    required this.iconPadding,
    this.splashColor = Colors.white,
    this.highlightColor = Colors.white,
  });

  final borderRadius = 18.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.zero,
      child: Ink(
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.03),
              blurRadius: 0.5,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: splashColor.withValues(alpha: 0.1),
          highlightColor: highlightColor.withValues(alpha: 0.05),
          child: Container(
            padding: textPadding,
            height: double.infinity,
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
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0.1,
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
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.white70],
                      ).createShader(bounds);
                    },
                    child: SvgPicture.asset(
                      iconPath,
                      width: iconSize,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      height: iconSize,
                    ),
                  ),
                ),
              ],
            ),
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
            color: Colors.black
                .withValues(alpha: 0.3), // Optional: Add overlay color
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
      child: CustomHomeButton(
          title: 'QUICK PLAY',
          titleFontSize: 28,
          titleFontWeight: FontWeight.bold,
          subtitle: 'Play questions from your selected topics!',
          subtitleFontSize: 11,
          iconPath: 'assets/icons/home/Play.svg',
          iconSize: 22,
          textPadding: const EdgeInsets.only(left: 17, right: 12, bottom: 5),
          iconPadding: const EdgeInsets.only(bottom: 20),
          onTap: () {
            Navigator.push(
                context,
                scaleUpTransitionRoute(const TriviaPage(
                  quickPlay: true,
                )));
          }),
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
      child: CustomHomeButton(
        title: 'Edit Topics',
        titleFontSize: 16,
        subtitle: "Select the topics you're interested in",
        iconPath: 'assets/icons/home/Edit.svg',
        iconSize: 15,
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TopicSelectionPage(),
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
        textPadding: const EdgeInsets.only(left: 15, right: 11),
        iconPadding: const EdgeInsets.only(bottom: 25),
      ),
    );
  }
}

class QuestionHistoryButton extends StatelessWidget {
  const QuestionHistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: CustomHomeButton(
        title: 'Question History',
        titleFontSize: 16,
        subtitle: 'Explore your most recently encountered questions.',
        subtitleFontSize: 9,
        iconPath: 'assets/icons/home/History.svg',
        iconSize: 25,
        textPadding: const EdgeInsets.only(left: 15, right: 7, bottom: 3),
        iconPadding: const EdgeInsets.only(bottom: 20),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const QuestionHistoryPage(),
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
      ),
    );
  }
}
