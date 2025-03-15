import 'package:flutter/material.dart';
import 'package:flutter_application/pages/main/trivia.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/home/session_history.dart';
import 'package:flutter_application/widgets/home/topic_selection.dart';
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
  String? heroTag,
}) {
  Widget buttonContent = Container(
    padding: textPadding,
    height: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 8,
          offset: const Offset(0, 3),
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.03),
          blurRadius: 0.5,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ],
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 40, 40, 40),
          Color.fromARGB(255, 28, 28, 28),
        ],
        stops: [0.1, 1.0],
      ),
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
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
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
              color: Colors.white,
              width: iconSize,
              height: iconSize,
            ),
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
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          return Colors.white.withOpacity(0.05);
        },
      ),
    ),
    child: buttonContent,
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

class SessionHistoryButton extends StatelessWidget {
  const SessionHistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: customHomeButton(
        title: 'Session History',
        titleFontSize: 16,
        subtitle: 'Explore your most recent gameplay sessions.',
        subtitleFontSize: 9,
        iconPath: 'assets/icons/home/History.svg',
        iconSize: 25,
        textPadding: const EdgeInsets.only(left: 15, right: 7, bottom: 3),
        iconPadding: const EdgeInsets.only(bottom: 20),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SessionHistoryPage(),
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
