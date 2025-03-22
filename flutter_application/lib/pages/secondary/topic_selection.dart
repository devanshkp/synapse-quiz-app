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

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSelectionInfo(),
              _buildSelectionButtons(),
              // take up just enough space to fit the grid view
              Flexible(
                fit: FlexFit.loose,
                child: _buildTopicsGrid(isLoading),
              ),
              const SizedBox(height: 2),
              _buildSelectionCount(),
              const SizedBox(height: 2),
              _buildSaveButton(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        "Topic Selection",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Divider(
          color: Colors.white12,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(
        "Select topics you're interested in",
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildSelectionButtons() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Select All',
              icon: Icons.add_circle_outline_rounded,
              color: Colors.white,
              onTap: () {
                setState(() {
                  if (!Set.of(_tempSelectedTopics)
                      .containsAll(triviaProvider.allTopics)) {
                    _tempSelectedTopics.addAll(triviaProvider.allTopics);
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              label: 'Remove All',
              icon: Icons.remove_circle_outline_rounded,
              color: warningRed,
              onTap: () {
                setState(() {
                  _tempSelectedTopics.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsGrid(bool isLoading) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: GridView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            itemCount: isLoading ? 12 : triviaProvider.allTopics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
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
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: const Center(
        child: CustomCircularProgressIndicator(),
      ),
    );
  }

  Widget _buildTopicItem(String topic, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleTopic(topic),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1,
            ),
            color: isSelected
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.05),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    topic.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: isSelected ? 1.0 : 0.0,
                    curve: Curves.elasticOut,
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCount() {
    return Consumer<TriviaProvider>(
      builder: (context, provider, child) {
        final selectedCount = _tempSelectedTopics.length;
        final totalCount = provider.allTopics.length;
        final bool hasMinimumTopics = selectedCount > 0;

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: hasMinimumTopics
                          ? Colors.green.withValues(alpha: 0.8)
                          : Colors.amber.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$selectedCount of $totalCount topics selected",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildSaveButton() {
    final Set<String> currentTopics = Set.from(triviaProvider.selectedTopics);
    final Set<String> tempTopics = Set.from(_tempSelectedTopics);

    final bool hasChanges =
        !const SetEquality().equals(currentTopics, tempTopics);
    final bool hasMinimumTopics = _tempSelectedTopics.isNotEmpty;
    final bool isLoading = triviaProvider.isLoadingQuestions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: LoadingStateButton(
        backgroundColor: Colors.white,
        textColor: Colors.black,
        label: isLoading ? "Please wait..." : "Save selection",
        isEnabled: hasChanges && hasMinimumTopics && !isLoading,
        onPressed: _saveSelection,
      ),
    );
  }
}
