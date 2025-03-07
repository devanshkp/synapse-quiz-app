import 'package:flutter/material.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/shared.dart';

class MainStats extends StatelessWidget {
  final UserProfile userProfile;
  final int totalQuestions;

  const MainStats(
      {super.key, required this.userProfile, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    // Calculate accuracy - if no questions encountered yet, show 0%
    final int questionsEncountered = userProfile.encounteredQuestions.length;
    final int questionsSolved = userProfile.questionsSolved;
    final int accuracy = questionsEncountered > 0
        ? ((questionsSolved / questionsEncountered) * 100).round()
        : 0;

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 27.5),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: buttonGradient,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainStatCard(
            'ACCURACY',
            '$accuracy%',
            Icons.gps_fixed,
            globalRankColor,
          ),
          const CustomVerticalDivider(),
          _buildMainStatCard(
            'STREAK',
            '${userProfile.currentStreak} ${userProfile.currentStreak == 1 ? 'day' : 'days'}', // Display "day" or "days"
            Icons.whatshot,
            currentStreakColor,
          ),
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
    return SizedBox(
      width: 80, // Fixed width for each stat card
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glow Effect
          Stack(
            alignment: Alignment.center,
            children: [
              // Glowing Effect
              Container(
                width: 21,
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
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2.5),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
