import 'package:flutter/material.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class StatsSection extends StatefulWidget {
  final UserProfile userProfile;

  const StatsSection({super.key, required this.userProfile});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  Map<String, int> _topicCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopicCounts();
  }

  Future<void> _loadTopicCounts() async {
    final triviaProvider = Provider.of<TriviaProvider>(context, listen: false);

    if (triviaProvider.topicCounts.isEmpty) {
      await triviaProvider.getTopicCounts();
    }
    final topicCounts = triviaProvider.topicCounts;

    debugPrint('BadgesSection - Topic Counts from Provider: $topicCounts');

    if (mounted) {
      setState(() {
        _topicCounts = topicCounts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27.5, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserStatsCards(),
          const SizedBox(height: 24),
          _buildSolveRate(),
          const SizedBox(height: 24),
          _buildTopicPerformance(),
        ],
      ),
    );
  }

  Widget _buildUserStatsCards() {
    // Calculate join date
    DateTime? joinDate;
    if (widget.userProfile.lastSolvedDate.isNotEmpty) {
      try {
        joinDate = DateTime.parse(widget.userProfile.lastSolvedDate);
      } catch (e) {
        // Use a fallback date if parsing fails
        joinDate = DateTime.now().subtract(const Duration(days: 30));
      }
    } else {
      joinDate = DateTime.now().subtract(const Duration(days: 30));
    }

    String formattedJoinDate = DateFormat('MMM, yyyy').format(joinDate);

    // Get the number of selected topics
    final topicsCount = widget.userProfile.selectedTopics.length;

    // Get today's solved count
    final todaySolvedCount = widget.userProfile.solvedTodayCount;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 41, 41, 41),
            Color.fromARGB(255, 34, 34, 34),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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

  Widget _buildSolveRate() {
    // Calculate solve rate percentage
    final totalEncountered = widget.userProfile.encounteredQuestions.length;
    final solveRate = totalEncountered > 0
        ? (widget.userProfile.questionsSolved / totalEncountered * 100)
            .clamp(0, 100)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 41, 41, 41),
            Color.fromARGB(255, 34, 34, 34),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
              'Solve Rate',
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
                        '${solveRate.toStringAsFixed(1)}% Success Rate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: solveRate / 100,
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
                          value: solveRate / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00B894), // Green color for solve rate
                          ),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        '${solveRate.round()}%',
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

  Widget _buildTopicPerformance() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get user's selected topics
    final selectedTopics = widget.userProfile.selectedTopics;

    // Debug prints
    debugPrint('Selected Topics: $selectedTopics');
    debugPrint('Topic Counts: $_topicCounts');

    // Filter topic counts to only include selected topics
    final filteredTopicCounts = Map.fromEntries(_topicCounts.entries
        .where((entry) => selectedTopics.contains(entry.key)));

    // Debug print filtered counts
    debugPrint('Filtered Topic Counts: $filteredTopicCounts');

    // Sort topics by question count (descending)
    final sortedTopics = filteredTopicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 topics
    final topTopics = sortedTopics.toList();

    // Debug print top topics
    debugPrint('Top Topics: $topTopics');

    // If no topics, show a message
    if (topTopics.isEmpty) {
      // Debug print why it's empty
      if (selectedTopics.isEmpty) {
        debugPrint('No topics selected');
      } else if (_topicCounts.isEmpty) {
        debugPrint('Topic counts is empty');
      } else if (filteredTopicCounts.isEmpty) {
        debugPrint(
            'Filtered topic counts is empty - no match between selected topics and available topics');
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundPageColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'No topics selected yet. Go to settings to select topics!',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 41, 41, 41),
            Color.fromARGB(255, 34, 34, 34),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Topics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: backgroundPageColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.bar_chart_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add Top Topic section (just one topic)
            if (widget.userProfile.topicQuestionsSolved.isNotEmpty) ...[
              _buildTopTopicSection(),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
            ],

            // All topics performance
            ...topTopics.map((topic) => _buildTopicItem(
                  topic.key,
                  topic.value,
                )),
          ],
        ),
      ),
    );
  }

  // New method to build just the top topic section
  Widget _buildTopTopicSection() {
    // Find the topic with the most questions solved
    if (widget.userProfile.topicQuestionsSolved.isEmpty) {
      return const SizedBox.shrink();
    }

    final entry = widget.userProfile.topicQuestionsSolved.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    final topic = entry.key;
    final count = entry.value;
    final color = _getTopicColor(topic);

    // Format topic name
    final formattedTopic = topic
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Topic',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedTopic,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count solved',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicItem(String topic, int questionCount) {
    // Format topic name
    final formattedTopic = topic
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');

    // Get the number of questions solved in this topic from the topicQuestionsSolved map
    final solvedInTopic = widget.userProfile.topicQuestionsSolved[topic] ?? 0;

    // Calculate percentage
    final percentage = questionCount > 0
        ? (solvedInTopic / questionCount * 100).clamp(0, 100)
        : 0.0;

    final color = _getTopicColor(topic);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedTopic,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '$solvedInTopic/$questionCount',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTopicColor(String topic) {
    switch (topic) {
      case 'machine_learning':
        return machineLearningColor;
      case 'computer_network':
        return computerNeworkColor;
      case 'data_science':
        return dataScienceColor;
      case 'probability_statistics':
        return probabilityStatisticsColor;
      case 'data_structures':
        return dataStructuresColor;
      case 'cloud_computing':
        return cloudComputingColor;
      case 'database':
        return databaseColor;
      case 'algorithms':
        return algorithmsColor;
      case 'swe_fundamentals':
        return sweFundamentalsColor;
      case 'discrete_math':
        return discreteMathColor;
      case 'cyber_security':
        return cyberSecurityColor;
      case 'artifical_intelligence':
        return artificialIntelligenceColor;
      default:
        return Colors.grey;
    }
  }
}
