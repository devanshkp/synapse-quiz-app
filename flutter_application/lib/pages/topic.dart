import 'package:flutter/material.dart';
import 'package:flutter_application/pages/main/trivia.dart';
import 'package:flutter_application/utils/text_formatter.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';

final Map<String, String> topicDescriptions = {
  "SWE_fundamentals":
      "Learn core software engineering principles and best practices.",
  "algorithms":
      "Understand problem-solving techniques and efficiency optimization.",
  "discrete_math":
      "Explore logic, set theory, and combinatorics for computing.",
  "computer_network":
      "Dive into protocols, communication, and network security.",
  "data_science": "Analyze data to extract insights and drive decisions.",
  "cloud_computing":
      "Learn about scalable computing, storage, and services in the cloud.",
  "artificial_intelligence":
      "Discover how machines can learn, reason, and solve problems.",
  "cyber_security": "Protect systems, networks, and data from cyber threats.",
  "data_structures": "Master ways to store and organize data efficiently.",
  "machine_learning":
      "Train models to recognize patterns and make predictions.",
  "database": "Manage structured data using relational and NoSQL databases.",
  "probability_&_statistics":
      "Use math to analyze uncertainty and make data-driven decisions.",
};

class TopicDetailsPage extends StatefulWidget {
  final String topicName;
  final String iconName;
  final Color topicColor;
  final String buttonType;

  const TopicDetailsPage({
    super.key,
    required this.topicName,
    required this.iconName,
    required this.topicColor,
    required this.buttonType,
  });

  @override
  State<TopicDetailsPage> createState() => _TopicDetailsPageState();
}

class _TopicDetailsPageState extends State<TopicDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isTopicSelected = false;
  int _topicQuestionCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.125), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();

    // Check if this topic is in the user's selected topics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfTopicSelected();
      _getTopicQuestionCount();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkIfTopicSelected() {
    final triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
    setState(() {
      _isTopicSelected =
          triviaProvider.selectedTopics.contains(widget.topicName);
    });
  }

  void _getTopicQuestionCount() {
    final triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
    if (triviaProvider.topicCounts.isEmpty) {
      triviaProvider.getTopicCounts().then((_) {
        setState(() {
          _topicQuestionCount =
              triviaProvider.topicCounts[widget.topicName] ?? 0;
        });
      });
    } else {
      setState(() {
        _topicQuestionCount = triviaProvider.topicCounts[widget.topicName] ?? 0;
      });
    }
  }

  void _toggleTopicSelection() async {
    final triviaProvider = Provider.of<TriviaProvider>(context, listen: false);

    // Update the UI immediately
    setState(() {
      _isTopicSelected = !_isTopicSelected;
    });

    // Create a new list to avoid direct modification
    List<String> updatedTopics = List.from(triviaProvider.selectedTopics);

    if (_isTopicSelected && !updatedTopics.contains(widget.topicName)) {
      updatedTopics.add(widget.topicName);
    } else {
      updatedTopics.remove(widget.topicName);
    }

    triviaProvider.syncTopics(updatedTopics, isTopicAdded: _isTopicSelected);
  }

  @override
  Widget build(BuildContext context) {
    final formattedTopicName =
        TextFormatter.formatTitlePreservingCase(widget.topicName);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.topicColor,
                  widget.topicColor.withOpacity(0.7),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Animated pattern overlay
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                image: DecorationImage(
                  image: const AssetImage('assets/images/shapes.png'),
                  opacity: 0.15,
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(
                    widget.topicColor.withOpacity(0.5),
                    BlendMode.overlay,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.question_answer_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$_topicQuestionCount Questions',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content - Scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // Topic Icon with Animation
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    padding: const EdgeInsets.all(26),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(90),
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.topicColor
                                              .withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Image.asset(
                                      'assets/images/topics/${widget.iconName}',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Topic Name
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Text(
                                formattedTopicName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Topic Description Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    topicDescriptions[widget.topicName] ??
                                        'Explore exciting questions about $formattedTopicName and test your knowledge!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.5,
                                      letterSpacing: 0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // User Progress Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.black.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: widget.topicColor
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.timeline_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Your Progress',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Consumer<UserProvider>(
                                    builder: (context, userProvider, child) {
                                      final userProfile =
                                          userProvider.userProfile;
                                      if (userProfile == null) {
                                        return const Center(
                                            child:
                                                CustomCircularProgressIndicator());
                                      }

                                      final solvedInTopic =
                                          userProfile.topicQuestionsSolved[
                                                  widget.topicName] ??
                                              0;
                                      final percentage = _topicQuestionCount > 0
                                          ? (solvedInTopic /
                                                  _topicQuestionCount *
                                                  100)
                                              .clamp(0, 100)
                                          : 0.0;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Questions Solved',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 11,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '$solvedInTopic/$_topicQuestionCount',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Stack(
                                            children: [
                                              // Background track
                                              Container(
                                                height: 10,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              // Progress
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 800),
                                                curve: Curves.easeOutQuart,
                                                height: 10,
                                                width: (size.width - 48) *
                                                    (percentage / 100),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                    colors: [
                                                      widget.topicColor
                                                          .withOpacity(0.7),
                                                      widget.topicColor,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: widget.topicColor
                                                          .withOpacity(0.4),
                                                      blurRadius: 6,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${percentage.toStringAsFixed(1)}% Complete',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Action Buttons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Play Now Button
                                Consumer<TriviaProvider>(
                                  builder: (context, triviaProvider, child) {
                                    final bool isLoading =
                                        triviaProvider.isLoadingQuestions;

                                    return GradientButton(
                                      icon: isLoading
                                          ? Icons.hourglass_top
                                          : Icons.play_circle_filled_rounded,
                                      text: isLoading
                                          ? 'Please wait...'
                                          : 'Start Session',
                                      gradient: isLoading
                                          ? LinearGradient(
                                              colors: [
                                                Colors.grey.shade800,
                                                Colors.grey.shade700,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : LinearGradient(
                                              colors: [
                                                widget.topicColor
                                                    .withOpacity(0.7),
                                                widget.topicColor,
                                                widget.topicColor
                                                    .withOpacity(0.8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      borderColor: Colors.white
                                          .withOpacity(isLoading ? 0.05 : 0.2),
                                      textColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16),
                                      fontSize: 16,
                                      borderRadius: 16,
                                      elevation: 10,
                                      fullWidth: true,
                                      onPressed: isLoading
                                          ? () {}
                                          : () {
                                              // Launch a temporary topic session
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TriviaPage(
                                                    topic: widget.topicName,
                                                    isTemporarySession: true,
                                                  ),
                                                ),
                                              );
                                            },
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Add/Remove Topic Button
                                GradientButton(
                                  icon: _isTopicSelected
                                      ? Icons.playlist_remove_rounded
                                      : Icons.playlist_add_rounded,
                                  text: _isTopicSelected
                                      ? 'Remove from My Topics'
                                      : 'Add to My Topics',
                                  gradient: _isTopicSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 180, 70, 70),
                                            warningRed,
                                            Color.fromARGB(255, 150, 40, 40),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 70, 180, 90),
                                            Colors.green,
                                            Color.fromARGB(255, 40, 130, 50),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderColor: Colors.white.withOpacity(0.2),
                                  textColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  fontSize: 16,
                                  borderRadius: 16,
                                  elevation: 8,
                                  fullWidth: true,
                                  onPressed: _toggleTopicSelection,
                                ),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
