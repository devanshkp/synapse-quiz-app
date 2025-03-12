import 'package:flutter/material.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:provider/provider.dart';

class TopicsSection extends StatefulWidget {
  final UserProfile userProfile;

  const TopicsSection({super.key, required this.userProfile});

  @override
  State<TopicsSection> createState() => _TopicsSectionState();
}

class _TopicsSectionState extends State<TopicsSection> {
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
      child: _buildTopicPerformance(),
    );
  }

  Widget _buildTopicPerformance() {
    if (_isLoading) {
      return const Center(child: CustomCircularProgressIndicator());
    }

    // Sort topics by question count (descending)
    final sortedTopics = _topicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 topics
    final topTopics = sortedTopics.toList();

    // If no topics, show a message
    if (topTopics.isEmpty) {
      if (_topicCounts.isEmpty) {
        debugPrint('Topic counts is empty');
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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
        child: const Center(
          child: Text(
            'Topic Counts Empty.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: profileCardGradient,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Topic Performance',
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

            // Add Top Topic section
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
          Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Solved',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
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
      case 'SWE_fundamentals':
        return sweFundamentalsColor;
      case 'discrete_math':
        return discreteMathColor;
      case 'cyber_security':
        return cyberSecurityColor;
      case 'artificial_intelligence':
        return artificialIntelligenceColor;
      default:
        return Colors.grey;
    }
  }
}
