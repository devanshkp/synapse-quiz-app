import 'package:flutter/material.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/widgets/shared.dart';

class MainStats extends StatelessWidget {
  final UserProfile userProfile;
  final int totalQuestions;

  const MainStats(
      {super.key, required this.userProfile, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 27.5),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainStatCard(
              'STREAK', '15 Days', Icons.whatshot, currentStreakColor),
          const CustomVerticalDivider(),
          _buildMainStatCard('RANK', '#264', Icons.language, globalRankColor),
          const CustomVerticalDivider(),
          _buildMainStatCard(
            'SOLVED',
            '${userProfile.questionsSolved}/$totalQuestions',
            Icons.check_circle,
            solvedQuestionsColor,
          ),
        ],
      ),
    );
  }

  // Column builder for each main stat
  Widget _buildMainStatCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        // Glow Effect
        Stack(
          alignment: Alignment.center,
          children: [
            // Glowing Effect
            Container(
              width: 21, // Adjust the size to fit the glow
              height: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2), // Glow color
                    blurRadius: 10, // How much the glow spreads
                    spreadRadius: 1, // Intensity of the glow
                  ),
                ],
              ),
            ),
            // Actual Icon
            Icon(icon, color: color, size: 21),
          ],
        ),
        const SizedBox(height: 7.5),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2.5),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
