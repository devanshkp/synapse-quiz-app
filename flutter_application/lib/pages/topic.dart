import 'package:flutter/material.dart';
import 'package:flutter_application/pages/trivia.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:flutter_application/colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';

class TopicDetailsPage extends StatefulWidget {
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
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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

    setState(() {
      _isTopicSelected = !_isTopicSelected;
    });

    if (_isTopicSelected) {
      triviaProvider.selectedTopics.remove(widget.topicName);
    } else {
      triviaProvider.selectedTopics.add(widget.topicName);
    }

    // Update the user's selected topics in Firestore
    await triviaProvider.updateUserSelectedTopics(topicAdded: _isTopicSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: widget.topicColor,
          ),

          Container(
            decoration: const BoxDecoration(
              color: Colors.black26,
              image: DecorationImage(
                image: AssetImage('assets/images/shapes.png'),
                opacity: 0.2,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Stack(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: buttonGradient,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      // Question Count
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: buttonGradient,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.quiz_rounded,
                              color: widget.topicColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_topicQuestionCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Topic Icon
                            Center(
                              child: Hero(
                                tag: 'topic_icon_${widget.heroBaseTag}',
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(80),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            widget.topicColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/topics/${widget.iconName}',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Topic Name
                            Hero(
                              tag: 'topic_title_${widget.heroBaseTag}',
                              child: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    widget.topicName
                                        .replaceAll('_', ' ')
                                        .toTitleCase,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Topic Description
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Explore exciting questions about ${widget.topicName.replaceAll('_', ' ').toTitleCase} and test your knowledge!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Play Button
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.play_arrow,
                                    text: 'Play Now',
                                    color: buttonColor,
                                    borderColor: Colors.white.withOpacity(0.15),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // Launch a temporary topic session
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TriviaPage(
                                            topic: widget.topicName,
                                            isTemporarySession: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Add/Remove Topic Button
                                Expanded(
                                  child: _buildActionButton(
                                    icon: _isTopicSelected
                                        ? Icons.remove_circle
                                        : Icons.add_circle,
                                    text: _isTopicSelected
                                        ? 'Remove'
                                        : 'Add Topic',
                                    color: _isTopicSelected
                                        ? warningRed
                                        : safeGreen,
                                    borderColor: Colors.white.withOpacity(0.2),
                                    textColor: Colors.white,
                                    onPressed: _toggleTopicSelection,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: cardGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Questions Solved',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '$solvedInTopic/$_topicQuestionCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: LinearProgressIndicator(
                                              value: percentage / 100,
                                              backgroundColor: Colors.grey[800],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      widget.topicColor),
                                              minHeight: 8,
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
                          ],
                        ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onPressed,
  }) {
    // width of the button is 100% of the screen
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        elevation: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
