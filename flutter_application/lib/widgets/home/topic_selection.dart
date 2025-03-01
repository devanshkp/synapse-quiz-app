import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class TopicSelectionPopup extends StatefulWidget {
  const TopicSelectionPopup({super.key});

  @override
  TopicSelectionPopupState createState() => TopicSelectionPopupState();
}

class TopicSelectionPopupState extends State<TopicSelectionPopup>
    with SingleTickerProviderStateMixin {
  late UserProvider userProvider;
  late TriviaProvider triviaProvider;
  late List<String> _tempSelectedTopics;
  late AnimationController _animationController;
  bool _hasLoadedTopics = false;

  static const surfaceColor = backgroundPageColor;
  static const headerColor = Color.fromARGB(255, 28, 28, 28);
  static const primaryAccentColor = Color.fromARGB(255, 123, 70, 229);
  static const selectedItemColor = Color(0xFF2D2B55);
  static const unprimaryAccentColor = Color(0xFF3A3A3A);
  static const textColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Essentially instant
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tempSelectedTopics = List.from(triviaProvider.selectedTopics);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    triviaProvider.syncTopics(_tempSelectedTopics);
    Navigator.pop(context);
  }

  void _handleClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Consumer<TriviaProvider>(
          builder: (context, triviaProvider, child) {
            final isLoading = triviaProvider.isLoadingTopics;

            if (!isLoading && !_hasLoadedTopics) {
              _tempSelectedTopics = List.from(triviaProvider.selectedTopics);
              _hasLoadedTopics = true;
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildTopicsGrid(isLoading),
                  _buildSaveButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(
            color: unprimaryAccentColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            "Select Topics",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: textColor),
            onPressed: _handleClose,
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsGrid(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: isLoading ? 12 : triviaProvider.allTopics.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
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
    );
  }

  Widget _buildLoadingItem() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: headerColor,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryAccentColor),
        ),
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
              color: isSelected ? primaryAccentColor : unprimaryAccentColor,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? selectedItemColor : headerColor,
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: primaryAccentColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    topic.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : textColor,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 1000),
                    scale: isSelected ? 1.0 : 0.0,
                    curve: Curves.elasticOut,
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: primaryAccentColor,
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

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: ElevatedButton(
        onPressed: _saveSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccentColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Save Selection",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
