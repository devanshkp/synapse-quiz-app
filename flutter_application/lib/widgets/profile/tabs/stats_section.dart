import 'package:flutter/material.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/constants.dart';
import 'package:intl/intl.dart';

class StatsSection extends StatefulWidget {
  final UserProfile userProfile;

  const StatsSection({super.key, required this.userProfile});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27.5, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserStatsCards(),
          const SizedBox(height: 24),
          _buildAccuracy(),
        ],
      ),
    );
  }

  Widget _buildUserStatsCards() {
    // Use the actual join date from the user profile
    final joinDate = widget.userProfile.joinDate;
    String formattedJoinDate = DateFormat('MMM yyyy').format(joinDate);

    // Get the number of selected topics
    final topicsCount = widget.userProfile.selectedTopics.length;

    // Get today's solved count
    final todaySolvedCount = widget.userProfile.solvedTodayCount;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        gradient: profileCardGradient,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatCard(
                  'Active Topics',
                  '$topicsCount',
                  Icons.category_outlined,
                  const Color(0xFF6C5CE7),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Solved Today',
                  '$todaySolvedCount',
                  Icons.today_outlined,
                  const Color(0xFFFF7675),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  'Max Streak',
                  '${widget.userProfile.maxStreak} ${widget.userProfile.maxStreak == 1 ? 'Day' : 'Days'}',
                  Icons.emoji_events,
                  const Color(0xFFFFD700),
                  isHighlighted: true,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Member Since',
                  formattedJoinDate,
                  Icons.calendar_today,
                  const Color(0xFF00B894),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: backgroundPageColor,
          borderRadius: BorderRadius.circular(16.0),
          border: isHighlighted
              ? Border.all(color: color.withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            isHighlighted
                ? ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracy() {
    // Calculate solve rate percentage
    final totalEncountered = widget.userProfile.encounteredQuestions.length;
    final accuracy = totalEncountered > 0
        ? (widget.userProfile.questionsSolved / totalEncountered * 100)
            .clamp(0, 100)
        : 0.0;
    // Format accuracy to show up to 2 decimal places
    final String formattedAccuracy = accuracy.toStringAsFixed(2);
    // Remove trailing zeros after decimal point
    final String displayAccuracy = formattedAccuracy.endsWith('.00')
        ? formattedAccuracy.substring(0, formattedAccuracy.length - 3)
        : formattedAccuracy
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        gradient: profileCardGradient,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accuracy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$displayAccuracy% Solve Rate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .75,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: accuracy / 100,
                          backgroundColor: backgroundPageColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white, // Green color for solve rate
                          ),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.userProfile.questionsSolved} solved out of $totalEncountered encountered',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: backgroundPageColor,
                    boxShadow: [],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: CircularProgressIndicator(
                          value: accuracy / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00B894), // Green color for solve rate
                          ),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        '${accuracy.round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
