import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:provider/provider.dart';

class TopicSelectionPopup extends StatefulWidget {
  const TopicSelectionPopup({super.key});

  @override
  TopicSelectionPopupState createState() => TopicSelectionPopupState();
}

class TopicSelectionPopupState extends State<TopicSelectionPopup> {
  late UserProvider userProvider;
  late TriviaProvider triviaProvider;
  late List<String> _tempSelectedTopics;
  static const surfaceColor = backgroundPageColor;
  static const headerColor = Color.fromARGB(255, 28, 28, 28);
  static const primaryAccentColor =
      Color.fromARGB(255, 123, 70, 229); // Indigo accent
  static const selectedItemColor =
      Color(0xFF2D2B55); // Dark purple for selected items
  static const unprimaryAccentColor = Color(0xFF3A3A3A);
  static const textColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tempSelectedTopics = List.from(triviaProvider.selectedTopics);
    });
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
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
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
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildCategoriesGrid(isLoading),
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
            "Select Categories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: isLoading ? 12 : triviaProvider.allTopics.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          if (isLoading) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: headerColor,
              ),
            );
          } else {
            final unformattedTopic = triviaProvider.allTopics[index];
            final topic = triviaProvider.displayedTopics[index];
            final bool isSelected =
                _tempSelectedTopics.contains(unformattedTopic);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleTopic(topic),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? primaryAccentColor
                            : unprimaryAccentColor,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected ? selectedItemColor : headerColor,
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Text(
                              topic,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected ? Colors.white : textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.check_circle_outline_outlined,
                              size: 16,
                              color: primaryAccentColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
      child: ElevatedButton(
        onPressed: _saveSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 123, 70, 229),
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Save Selection",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
