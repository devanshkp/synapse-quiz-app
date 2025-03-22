import 'package:flutter/material.dart';

// Regular colors
const Color appColor = Color.fromARGB(255, 76, 76, 146);
const Color warningRed = Color.fromARGB(255, 181, 56, 47);
const Color safeGreen = Color.fromARGB(255, 84, 183, 102);

// Grey Variants
const Color backgroundPageColor = Color(0xff121212);
const Color buttonColor = Color.fromARGB(255, 35, 35, 35);
const Color buttonStrokeColor = Color(0xff636363);
const Color navbarColor = Color(0xff090909);
const Color drawerColor = Color.fromARGB(255, 14, 14, 14);

// Purple Accents Variants
const Color fadedPurpleAccent = Color.fromARGB(255, 167, 120, 239);
const Color lightPurpleAccent = Color.fromARGB(255, 157, 84, 252);
const Color purpleAccent = Color.fromARGB(255, 132, 52, 236);
const Color darkPurpleAccent = Color.fromARGB(255, 116, 52, 236);
const Color pinkAccent = Color.fromARGB(255, 202, 84, 252);

// Main stats colors
const Color solvedQuestionsColor = Color.fromARGB(255, 105, 240, 130);
const Color currentStreakColor = Color.fromARGB(255, 255, 160, 64);
const Color globalRankColor = Color.fromARGB(255, 64, 207, 255);

// Topic Colors
const Color machineLearningColor = Color.fromARGB(255, 87, 119, 193);
const Color computerNeworkColor = Color.fromARGB(255, 205, 81, 201);
const Color dataScienceColor = Color.fromARGB(255, 164, 164, 164);
const Color probabilityStatisticsColor = Color.fromARGB(255, 187, 74, 74);
const Color dataStructuresColor = Color.fromARGB(255, 159, 124, 79);
const Color cloudComputingColor = Color.fromARGB(255, 64, 182, 119);
const Color databaseColor = Color.fromARGB(255, 42, 167, 198);
const Color algorithmsColor = Color.fromARGB(255, 130, 102, 214);
const Color sweFundamentalsColor = Color.fromARGB(255, 214, 116, 24);
const Color discreteMathColor = Color.fromARGB(255, 222, 96, 87);
const Color cyberSecurityColor = Color.fromARGB(255, 63, 67, 60);
const Color artificialIntelligenceColor = Color.fromARGB(255, 207, 65, 108);

// Random Colors
const Color goldColor = Color(0xffFFD700);
const Color silverColor = Color(0xFFC0C0C0);
const Color bronzeColor = Color(0xffe38d4c);
const Color githubColor = Color.fromARGB(255, 33, 40, 50);

// Gradients

// Widget Gradients
const LinearGradient buttonGradient = LinearGradient(
  colors: [Color.fromARGB(255, 40, 40, 40), Color.fromARGB(255, 28, 28, 28)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 32, 32, 32),
      Color.fromARGB(255, 22, 22, 22),
      Color.fromARGB(255, 9, 9, 9),
    ]);

const LinearGradient profileCardGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 34, 34, 34),
    Color.fromARGB(255, 26, 26, 26),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Miscellaneous

BoxShadow buttonDropShadow = BoxShadow(
  color: Colors.black.withValues(alpha: 0.3), // Shadow color
  blurRadius: 10, // Reduced spread for a cleaner look
  offset: const Offset(0, 4), // Positioning of the shadow
);

Route slideTransitionRoute(Widget page,
    {int transitionDuration = 300,
    int reverseTransitionDuration = 400,
    bool reverse = false}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin = (reverse)
            ? const Offset(-1.0, 0.0) // Slide from right to left
            : const Offset(1.0, 0.0); // Slide from right to left
        const end = Offset.zero; // End at the default position

        const curve = Curves.easeInOutQuart; // Smooth easing curve

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: transitionDuration),
      reverseTransitionDuration: Duration(
          milliseconds: reverseTransitionDuration) // Transition duration
      );
}

Route scaleUpTransitionRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Create a smoother animation controller with a custom curve
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic, // Smoother main curve
      );

      // Refined slide up animation (more subtle)
      var slideUpAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.2), // Less vertical movement (0.3 → 0.2)
        end: Offset.zero,
      ).animate(curvedAnimation);

      // Refined scale animation (more subtle)
      var scaleAnimation = Tween<double>(
        begin: 0.92, // Less dramatic scaling (0.85 → 0.92)
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8,
              curve: Curves.easeOutQuint), // Finishes earlier
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
    transitionDuration:
        const Duration(milliseconds: 300), // Slightly shorter duration
    reverseTransitionDuration: const Duration(milliseconds: 400),
    // Slightly shorter exit
  );
}

Route fadeTransitionRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}
