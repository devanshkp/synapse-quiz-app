import 'package:flutter/material.dart';

const Color backgroundPageColor = Color(0xff161616);
const Color buttonColor = Color(0xff232323);
const Color buttonStrokeColor = Color(0xff636363);
const Color navbarColor = Color(0xff090909);

const Color lBoardBackground = Color.fromARGB(255, 37, 26, 67);
const Color lBoardLightAccent = Color.fromARGB(255, 128, 17, 255);
const Color lBoardDarkAccent = Color.fromARGB(255, 89, 59, 159);

// Accents
const Color lightAccentPurple = Color.fromARGB(255, 157, 84, 252);
const Color accentPurple = Color.fromARGB(255, 132, 52, 236);
const Color darkAccentPurple = Color.fromARGB(255, 116, 52, 236);

const Color accentPink = Color.fromARGB(255, 202, 84, 252);

const LinearGradient buttonGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 48, 48, 48),
    Color.fromARGB(255, 30, 30, 30),
  ],
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

BoxShadow buttonDropShadow = BoxShadow(
  color: Colors.black.withOpacity(0.3), // Shadow color
  blurRadius: 10, // Reduced spread for a cleaner look
  offset: const Offset(0, 4), // Positioning of the shadow
);
