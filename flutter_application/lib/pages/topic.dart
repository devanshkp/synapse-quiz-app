import 'package:flutter/material.dart';
import 'package:flutter_application/pages/trivia.dart';

class TopicDetailsPage extends StatelessWidget {
  final String topicName;
  final String iconName;
  final Color topicColor;
  final String buttonType;
  final String heroBaseTag;

  const TopicDetailsPage({
    super.key,
    required this.topicName,
    required this.iconName,
    required this.topicColor,
    required this.buttonType,
    required this.heroBaseTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  topicColor.withOpacity(0.8),
                  topicColor.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Topic Icon
                          Center(
                            child: Hero(
                              tag: 'topic_icon_$heroBaseTag',
                              child: Container(
                                width: 160,
                                height: 160,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(80),
                                ),
                                child: Image.asset(
                                  'assets/images/topics/$iconName',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Topic Name
                          Hero(
                            tag: 'topic_title_$heroBaseTag',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                topicName,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Topic Description
                          Text(
                            'Explore exciting questions about $topicName and test your knowledge!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Play Button
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TriviaPage(topic: topicName),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: topicColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 48, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow, size: 28),
                                  SizedBox(width: 8),
                                  Text(
                                    'Play Now',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
