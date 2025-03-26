import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/utils/topic_color.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/utils/text_formatter.dart';

class QuestionHistoryPage extends StatefulWidget {
  const QuestionHistoryPage({
    super.key,
  });

  @override
  QuestionHistoryPageState createState() => QuestionHistoryPageState();
}

class QuestionHistoryPageState extends State<QuestionHistoryPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    double extraPadding = 0;
    if (screenWidth < 800) {
      extraPadding = screenWidth * 0.05;
    } else if (screenWidth < 850) {
      extraPadding = screenWidth * 0.1;
    } else if (screenWidth < 1000) {
      extraPadding = screenWidth * .15;
    } else {
      extraPadding = screenWidth * .2;
    }
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: backgroundPageColor,
      body: Container(
        decoration: const BoxDecoration(
          color: backgroundPageColor,
          image: DecorationImage(
            image: AssetImage('assets/images/shapes.png'),
            opacity: 0.2,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Consumer<TriviaProvider>(
          builder: (context, triviaProvider, child) {
            if (triviaProvider.isLoadingEncounteredQuestions &&
                triviaProvider.encounteredQuestions.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: purpleAccent,
                ),
              );
            }

            if (triviaProvider.encounteredQuestions.isEmpty) {
              return const Center(
                child: Text(
                  "No questions encountered yet!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            // Calculate total item count: header (1) + questions + possibly "load more" (1)
            final itemCount = 1 +
                triviaProvider.encounteredQuestions.length +
                (triviaProvider.hasMoreEncounteredQuestions ? 1 : 0);

            return ListView.builder(
              padding: isTablet
                  ? EdgeInsets.symmetric(horizontal: extraPadding, vertical: 16)
                  : const EdgeInsets.all(16),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                // First item is the header
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sorted by most recently encountered',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Last item might be the "Load more" button
                if (index == itemCount - 1 &&
                    triviaProvider.hasMoreEncounteredQuestions) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: GestureDetector(
                      onTap: () => triviaProvider.fetchEncounteredQuestions(
                          loadMore: true),
                      child: const SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Text(
                          'Load more',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            decorationColor: Colors.white70,
                            decorationThickness: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                // Regular question cards (offset by 1 because of the header)
                return QuestionHistoryCard(
                  question: triviaProvider.encounteredQuestions[index - 1],
                );
              },
            );
          },
        ),
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
        "Recent Questions",
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
}

class QuestionHistoryCard extends StatefulWidget {
  final Map<String, dynamic> question;

  const QuestionHistoryCard({
    super.key,
    required this.question,
  });

  @override
  State<QuestionHistoryCard> createState() => _QuestionHistoryCardState();
}

class _QuestionHistoryCardState extends State<QuestionHistoryCard> {
  bool _isExpanded = false;

  int _getCorrectIndex() {
    final answerKey = widget.question['answer'] as String;
    return answerKey.toLowerCase().codeUnitAt(0) - 97;
  }

  @override
  Widget build(BuildContext context) {
    final unformattedTopic = widget.question['topic'];
    final topic =
        TextFormatter.formatTitlePreservingCase(widget.question['topic']);
    final correctAnswerIndex = _getCorrectIndex();
    final options = widget.question['options'] as List<dynamic>;
    final hasExplanation = widget.question['explanation'] != null &&
        widget.question['explanation'].toString().isNotEmpty &&
        widget.question['explanation'] != 'None.';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color.fromARGB(255, 26, 26, 26),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1.5,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          if (mounted) {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic and expand icon
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: TopicColorUtil.getTopicColor((unformattedTopic))
                          .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question text (limited to 3 lines when not expanded)
              TextFormatter.formatText(
                widget.question['question'],
                minFontSize: 14,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: _isExpanded ? 20 : 3,
                textAlign: TextAlign.left,
              ),

              // Only show options and explanation when expanded
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                // Options
                ...List.generate(options.length, (index) {
                  final isCorrect = index == correctAnswerIndex;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                color: isCorrect
                                    ? Colors.green
                                    : Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormatter.formatText(
                            options[index].toString(),
                            style: TextStyle(
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight:
                                  isCorrect ? FontWeight.w600 : FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 20,
                          ),
                        ),
                        if (isCorrect)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                      ],
                    ),
                  );
                }),

                // Explanation (if available) 
                if (hasExplanation) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.yellow.withValues(alpha: 0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Explanation',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormatter.formatText(widget.question['explanation'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 20),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
