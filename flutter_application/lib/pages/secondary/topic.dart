import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/pages/main/trivia.dart';
import 'package:flutter_application/utils/text_formatter.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
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

  // Breakpoints
  static const double tabletBreakpoint = 600.0;

  // Screen size factors
  late double _iconSizeFactor;
  late double _spacingFactor;
  late double _fontSizeFactor;

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
    if (mounted) {
      setState(() {
        _isTopicSelected =
            triviaProvider.selectedTopics.contains(widget.topicName);
      });
    }
  }

  void _getTopicQuestionCount() {
    final triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
    if (triviaProvider.topicCounts.isEmpty) {
      triviaProvider.getTopicCounts().then((_) {
        if (mounted) {
          setState(() {
            _topicQuestionCount =
                triviaProvider.topicCounts[widget.topicName] ?? 0;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _topicQuestionCount =
              triviaProvider.topicCounts[widget.topicName] ?? 0;
        });
      }
    }
  }

  void _toggleTopicSelection() async {
    final triviaProvider = Provider.of<TriviaProvider>(context, listen: false);

    // Update the UI immediately
    if (mounted) {
      setState(() {
        _isTopicSelected = !_isTopicSelected;
      });
    }

    // Create a new list to avoid direct modification
    List<String> updatedTopics = List.from(triviaProvider.selectedTopics);

    if (_isTopicSelected && !updatedTopics.contains(widget.topicName)) {
      updatedTopics.add(widget.topicName);
    } else {
      updatedTopics.remove(widget.topicName);
    }

    triviaProvider.syncTopics(updatedTopics, isTopicAdded: _isTopicSelected);
  }

  // Calculate adaptive sizes based on screen dimensions
  void _calculateAdaptiveSizes(Size screenSize) {
    final height = screenSize.height;
    // Adjust icon size factor based on screen height
    _iconSizeFactor = height < 600 ? 0.7 : (height < 800 ? 0.85 : 1.0);

    // Adjust spacing factor based on screen height
    _spacingFactor = height < 600 ? 0.5 : (height < 800 ? 0.75 : 1.0);

    // Adjust font size factor based on screen height
    _fontSizeFactor = height < 600 ? 0.8 : (height < 800 ? 0.9 : 1.0);
  }

  // Get adaptive spacing
  double _getSpacing(double baseSpacing) {
    return baseSpacing * _spacingFactor;
  }

  // Get adaptive icon size
  double _getIconSize(double baseSize) {
    return baseSize * _iconSizeFactor;
  }

  // Get adaptive font size
  double _getFontSize(double baseSize) {
    return baseSize * _fontSizeFactor;
  }

  @override
  Widget build(BuildContext context) {
    final formattedTopicName =
        TextFormatter.formatTitlePreservingCase(widget.topicName);
    final size = MediaQuery.of(context).size;

    // Calculate adaptive sizes
    _calculateAdaptiveSizes(size);

    // Determine if we should use tablet layout
    final bool isTablet = size.width >= tabletBreakpoint;

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
                  widget.topicColor.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.8),
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
                color: Colors.black.withValues(alpha: 0.35),
                image: DecorationImage(
                  image: const AssetImage('assets/images/shapes.png'),
                  opacity: 0.15,
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(
                    widget.topicColor.withValues(alpha: 0.5),
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
                    padding: const EdgeInsets.fromLTRB(12, 6, 18, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.question_answer_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_topicQuestionCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white24,
                    height: 1,
                  ),

                  // Main Content - Conditionally Scrollable
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // If screen is very small, keep it scrollable
                        final bool isLandscape = constraints.maxHeight < 500;

                        return SingleChildScrollView(
                          physics: isLandscape
                              ? const BouncingScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 16.0 : 24.0,
                                  vertical: isTablet ? 8.0 : 0.0,
                                ),
                                child: isLandscape
                                    ? _buildLandscapeLayout(
                                        formattedTopicName, size)
                                    : (size.width >= tabletBreakpoint
                                        ? _buildTabletLayout(
                                            formattedTopicName, size)
                                        : _buildMobileLayout(
                                            formattedTopicName, size)),
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildLandscapeLayout(String formattedTopicName, Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column (icon and buttons)
        Flexible(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTopicIcon(size),
              SizedBox(height: _getSpacing(24)),
              _buildActionButtons(),
            ],
          ),
        ),

        SizedBox(width: _getSpacing(24)),

        // Right column (content)
        Flexible(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopicName(formattedTopicName),
              SizedBox(height: _getSpacing(16)),
              _buildDescriptionCard(formattedTopicName),
              SizedBox(height: _getSpacing(24)),
              _buildProgressCard(size),
            ],
          ),
        ),
      ],
    );
  }

  // Mobile layout with vertical flow
  Widget _buildMobileLayout(String formattedTopicName, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: _getSpacing(16)),

        // Topic Icon with Animation
        _buildTopicIcon(size),

        SizedBox(height: _getSpacing(24)),

        // Topic Name
        _buildTopicName(formattedTopicName),

        SizedBox(height: _getSpacing(24)),

        // Topic Description Card
        _buildDescriptionCard(formattedTopicName),

        SizedBox(height: _getSpacing(20)),

        // User Progress Card
        _buildProgressCard(size),

        SizedBox(height: _getSpacing(24)),

        // Action Buttons
        _buildActionButtons(),

        SizedBox(height: _getSpacing(20)),
      ],
    );
  }

  // Tablet layout with horizontal header
  Widget _buildTabletLayout(String formattedTopicName, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: _getSpacing(20)),

        // Horizontal header section (icon + title)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Topic Icon
            _buildTopicIcon(size),

            const SizedBox(width: 32),

            // Topic name and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Topic Name
                  _buildTopicName(formattedTopicName),

                  SizedBox(height: _getSpacing(20)),

                  // Topic Description
                  _buildDescriptionCard(formattedTopicName),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: _getSpacing(32)),

        // User Progress Card
        _buildProgressCard(size),

        const Spacer(),

        // Action Buttons
        _buildActionButtons(),

        SizedBox(height: _getSpacing(20)),
      ],
    );
  }

  // Topic Icon Widget
  Widget _buildTopicIcon(Size size) {
    final iconSize = _getIconSize(160);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: iconSize,
            height: iconSize,
            padding: EdgeInsets.all(26 * _iconSizeFactor),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(iconSize / 2),
              boxShadow: [
                BoxShadow(
                  color: widget.topicColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
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
    );
  }

  // Topic Name Widget
  Widget _buildTopicName(String formattedTopicName) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.white,
          Colors.white.withValues(alpha: 0.8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Text(
        formattedTopicName,
        style: TextStyle(
          fontSize: _getFontSize(28),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.1,
          letterSpacing: -0.5,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        textAlign: MediaQuery.of(context).size.width >= tabletBreakpoint
            ? TextAlign.left
            : TextAlign.center,
      ),
    );
  }

  // Description Card Widget
  Widget _buildDescriptionCard(String formattedTopicName) {
    final bool isTablet = MediaQuery.of(context).size.width >= tabletBreakpoint;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!isTablet) ...[
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 24,
            ),
            SizedBox(height: _getSpacing(8)),
          ],
          Text(
            topicDescriptions[widget.topicName] ??
                'Explore exciting questions about $formattedTopicName and test your knowledge!',
            style: TextStyle(
              fontSize: _getFontSize(14),
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
              letterSpacing: 0.2,
            ),
            textAlign: isTablet ? TextAlign.left : TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Progress Card Widget
  Widget _buildProgressCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
                  color: widget.topicColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getFontSize(16),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final userProfile = userProvider.userProfile;
              if (userProfile == null) {
                return const Center(child: CustomCircularProgressIndicator());
              }

              final solvedInTopic =
                  userProfile.topicQuestionsSolved[widget.topicName] ?? 0;
              final percentage = _topicQuestionCount > 0
                  ? (solvedInTopic / _topicQuestionCount * 100).clamp(0, 100)
                  : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: _getSpacing(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions Solved',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: _getFontSize(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$solvedInTopic/$_topicQuestionCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getFontSize(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _getSpacing(10)),
                  Stack(
                    children: [
                      // Background track
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Progress
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutQuart,
                        height: 10,
                        width: (size.width -
                                (MediaQuery.of(context).size.width >=
                                        tabletBreakpoint
                                    ? 64
                                    : 48)) *
                            (percentage / 100),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              widget.topicColor.withValues(alpha: 0.7),
                              widget.topicColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: widget.topicColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _getSpacing(8)),
                  Text(
                    '${percentage.toStringAsFixed(1)}% Complete',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: _getFontSize(13),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Action Buttons Widget
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Play Now and Add/Remove Buttons
        Consumer<TriviaProvider>(
          builder: (context, triviaProvider, child) {
            final bool isLoading = triviaProvider.isFetchingQuestions ||
                triviaProvider.isTemporarySession;
            final bool isTablet =
                MediaQuery.of(context).size.width >= tabletBreakpoint;

            final bool isLandscape =
                isTablet && MediaQuery.of(context).size.height <= 500;

            return isTablet && !isLandscape
                ? Row(
                    children: [
                      Flexible(
                        child: GradientButton(
                            icon: isLoading
                                ? Icons.hourglass_top
                                : Icons.play_circle_filled_rounded,
                            text: 'Start Session',
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
                                      widget.topicColor.withValues(alpha: 0.7),
                                      widget.topicColor,
                                      widget.topicColor.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderColor: Colors.white
                                .withValues(alpha: isLoading ? 0.05 : 0.2),
                            textColor: Colors.white,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            fontSize: _getFontSize(16),
                            borderRadius: 16,
                            elevation: 10,
                            onPressed: isLoading
                                ? () {}
                                : () async {
                                    try {
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          slideTransitionRoute(
                                            TriviaPage(
                                              topic: widget.topicName,
                                              isTemporarySession: true,
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint("Error starting session: $e");
                                      if (mounted) {
                                        floatingSnackBar(
                                            message:
                                                'Error starting session, please try again later.',
                                            context: context);
                                      }
                                    }
                                  }),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: GradientButton(
                          icon: _isTopicSelected
                              ? Icons.playlist_remove_rounded
                              : Icons.playlist_add_rounded,
                          text: _isTopicSelected ? 'Remove Topic' : 'Add Topic',
                          gradient: isLoading
                              ? LinearGradient(
                                  colors: [
                                    Colors.grey.shade800,
                                    Colors.grey.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : _isTopicSelected
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
                          borderColor: Colors.white.withValues(alpha: 0.2),
                          textColor: Colors.white,
                          fullWidth: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          fontSize: _getFontSize(16),
                          borderRadius: 16,
                          elevation: 8,
                          onPressed: isLoading ? () {} : _toggleTopicSelection,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Flexible(
                        child: GradientButton(
                            icon: isLoading
                                ? Icons.hourglass_top
                                : Icons.play_circle_filled_rounded,
                            text: 'Start',
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
                                      widget.topicColor.withValues(alpha: 0.7),
                                      widget.topicColor,
                                      widget.topicColor.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderColor: Colors.white
                                .withValues(alpha: isLoading ? 0.05 : 0.2),
                            textColor: Colors.white,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            fontSize: _getFontSize(16),
                            borderRadius: 16,
                            elevation: 10,
                            onPressed: isLoading
                                ? () {}
                                : () async {
                                    try {
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          slideTransitionRoute(
                                            TriviaPage(
                                              topic: widget.topicName,
                                              isTemporarySession: true,
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint("Error starting session: $e");
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Failed to start session: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }),
                      ),
                      SizedBox(width: _getSpacing(20)),
                      Flexible(
                        child: GradientButton(
                          icon: _isTopicSelected
                              ? Icons.playlist_remove_rounded
                              : Icons.playlist_add_rounded,
                          text: _isTopicSelected ? 'Remove' : 'Add',
                          gradient: isLoading
                              ? LinearGradient(
                                  colors: [
                                    Colors.grey.shade800,
                                    Colors.grey.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : _isTopicSelected
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
                          borderColor: Colors.white.withValues(alpha: 0.2),
                          textColor: Colors.white,
                          fullWidth: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          fontSize: 16,
                          borderRadius: 16,
                          elevation: 8,
                          onPressed: isLoading ? () {} : _toggleTopicSelection,
                        ),
                      ),
                    ],
                  );
          },
        ),
      ],
    );
  }
}
