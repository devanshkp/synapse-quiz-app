import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';

class TopicSelectionPage extends StatefulWidget {
  const TopicSelectionPage({super.key});

  @override
  TopicSelectionPageState createState() => TopicSelectionPageState();
}

class TopicSelectionPageState extends State<TopicSelectionPage>
    with SingleTickerProviderStateMixin {
  late UserProvider userProvider;
  late TriviaProvider triviaProvider;
  late List<String> _tempSelectedTopics;
  late AnimationController _animationController;
  bool _hasLoadedTopics = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tempSelectedTopics = List.from(triviaProvider.selectedTopics);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
    _tempSelectedTopics = List.from(triviaProvider.selectedTopics);
  }

  bool _canSave() {
    final Set<String> currentTopics = Set.from(triviaProvider.selectedTopics);
    final Set<String> tempTopics = Set.from(_tempSelectedTopics);

    final bool hasChanges =
        !const SetEquality().equals(currentTopics, tempTopics);
    final bool hasMinimumTopics = _tempSelectedTopics.isNotEmpty;
    final bool isLoading = triviaProvider.isLoadingQuestions;
    return hasChanges && hasMinimumTopics && !isLoading;
  }

  void _toggleTopic(String topic) {
    final unformattedTopic =
        triviaProvider.allTopics[triviaProvider.displayedTopics.indexOf(topic)];

    setState(() {
      if (_tempSelectedTopics.contains(unformattedTopic)) {
        _tempSelectedTopics.remove(unformattedTopic);
      } else {
        _tempSelectedTopics.add(unformattedTopic);
      }
    });
  }

  Future<void> _saveSelection() async {
    await triviaProvider.syncTopics(_tempSelectedTopics);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: backgroundPageColor,
      appBar: _buildAppBar(),
      body: Consumer<TriviaProvider>(
        builder: (context, triviaProvider, child) {
          final isLoading = triviaProvider.isLoadingTopics;

          if (!isLoading && !_hasLoadedTopics) {
            _tempSelectedTopics = List.from(triviaProvider.selectedTopics);
            _hasLoadedTopics = true;
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: _buildSelectionButtons(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: _buildSelectionStats(),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: _buildTopicsGrid(isLoading, isSmallScreen),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      centerTitle: true,
      actions: [
        if (_canSave())
          TextButton(
            onPressed: _saveSelection,
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (triviaProvider.isFetchingQuestions)
          const CircularProgressIndicator(
            color: Colors.white,
          )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personalize Your Experience",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Select topics you're interested in to customize your trivia questions.",
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Select All',
            icon: Icons.check_circle_outline_rounded,
            color: Colors.green,
            onTap: () {
              setState(() {
                if (!Set.of(_tempSelectedTopics)
                    .containsAll(triviaProvider.allTopics)) {
                  _tempSelectedTopics = List.from(triviaProvider.allTopics);
                }
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Clear All',
            icon: Icons.cancel_outlined,
            color: Colors.redAccent,
            onTap: () {
              setState(() {
                _tempSelectedTopics.clear();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.white.withValues(alpha: 0.1),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.6),
                color.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionStats() {
    return Consumer<TriviaProvider>(
      builder: (context, provider, child) {
        final selectedCount = _tempSelectedTopics.length;
        final totalCount = provider.allTopics.length;
        final bool hasMinimumTopics = selectedCount > 0;

        // Calculate percentage for progress indicator
        final double percentage =
            totalCount > 0 ? selectedCount / totalCount : 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasMinimumTopics
                            ? Icons.check_circle
                            : Icons.info_outline,
                        size: 20,
                        color: hasMinimumTopics
                            ? Colors.green.withValues(alpha: 0.9)
                            : Colors.amber.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "$selectedCount of $totalCount topics selected",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Use the parent container's width for the progress bar
                        final double maxWidth = constraints.maxWidth;
                        return Stack(
                          children: [
                            Container(
                              height: 8,
                              width: maxWidth,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height: 8,
                              width: percentage == 1.0
                                  ? maxWidth
                                  : maxWidth * percentage,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: hasMinimumTopics
                                      ? [
                                          Colors.green.withValues(alpha: 0.7),
                                          Colors.greenAccent
                                              .withValues(alpha: 0.9),
                                        ]
                                      : [
                                          Colors.amber.withValues(alpha: 0.7),
                                          Colors.orange.withValues(alpha: 0.9),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: hasMinimumTopics
                                        ? Colors.green.withValues(alpha: 0.4)
                                        : Colors.amber.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverGrid _buildTopicsGrid(bool isLoading, bool isSmallScreen) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen
            ? 1
            : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
        childAspectRatio: 2.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (isLoading) {
            return _buildLoadingItem();
          } else {
            final unformattedTopic = triviaProvider.allTopics[index];
            final topic = triviaProvider.displayedTopics[index];
            final bool isSelected =
                _tempSelectedTopics.contains(unformattedTopic);
            return _buildTopicItem(topic, isSelected);
          }
        },
        childCount: isLoading ? 12 : triviaProvider.allTopics.length,
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: const Center(
        child: CustomCircularProgressIndicator(),
      ),
    );
  }

  Widget _buildTopicItem(String topic, bool isSelected) {
    return Hero(
      tag: 'topic-${topic.hashCode}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleTopic(topic),
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        lightPurpleAccent.withValues(alpha: 0.6),
                        lightPurpleAccent.withValues(alpha: 0.8),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.08),
                      ],
              ),
              border: Border.all(
                color: isSelected
                    ? lightPurpleAccent.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: lightPurpleAccent.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      topic.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isSelected ? 1.0 : 0.0,
                      curve: Curves.elasticOut,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: lightPurpleAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
