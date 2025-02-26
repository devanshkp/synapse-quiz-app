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

// Category Colors
const Color machineLearningColor = Color.fromARGB(255, 87, 119, 193);
const Color dataStructuresColor = Color.fromARGB(255, 159, 124, 79);
const Color proBasicsColor = Color.fromARGB(255, 73, 150, 101);
const Color dataBaseColor = Color.fromARGB(255, 207, 73, 89);
const Color popularAlgColor = Color.fromARGB(255, 155, 75, 184);
const Color sweFundColor = Color.fromARGB(255, 81, 161, 144);
const Color foundMathColor = Color.fromARGB(255, 222, 96, 87);
const Color sortingAlgColor = Color.fromARGB(255, 230, 142, 59);
const Color artificalIntelligenceColor = Color.fromARGB(255, 207, 65, 108);

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
