import 'package:flutter/material.dart';

// Regular colors
const Color appColor = Color.fromARGB(255, 76, 76, 146);

// Grey Variants
const Color backgroundPageColor = Color(0xff161616);
const Color buttonColor = Color(0xff232323);
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
const Color cyberSecurityColor = Color.fromARGB(255, 60, 60, 60);
const Color artificialIntelligenceColor = Color.fromARGB(255, 207, 65, 108);

// Leaderboard Colors
const Color goldColor = Color(0xffFFD700);
const Color silverColor = Color(0xFFC0C0C0);
const Color bronzeColor = Color(0xffe38d4c);

// Gradients

// Widget Gradients
const LinearGradient buttonGradient = LinearGradient(
  colors: [Color.fromARGB(255, 58, 58, 58), Color.fromARGB(255, 34, 34, 34)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 46, 46, 46),
      Color.fromARGB(255, 26, 26, 26),
      Color.fromARGB(255, 20, 20, 20),
    ]);

// Miscellaneous

BoxShadow buttonDropShadow = BoxShadow(
  color: Colors.black.withOpacity(0.3), // Shadow color
  blurRadius: 10, // Reduced spread for a cleaner look
  offset: const Offset(0, 4), // Positioning of the shadow
);
