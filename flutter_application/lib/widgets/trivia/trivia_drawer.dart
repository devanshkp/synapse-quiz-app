import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/trivia/bottom_buttons.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:flutter_application/utils/text_formatter.dart';

class TriviaDrawer extends StatefulWidget {
  final Map<String, dynamic> question;
  final bool isAnswered;
  final VoidCallback onNextQuestion;

  const TriviaDrawer({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onNextQuestion,
  });

  @override
  TriviaDrawerState createState() => TriviaDrawerState();
}

class TriviaDrawerState extends State<TriviaDrawer> {
  void updateContent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: drawerColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: _buildContentCard(),
              ),
              const SizedBox(height: 20),
              if (widget.isAnswered)
                NextButton(
                  onPressed: widget.onNextQuestion,
                  drawerButton: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isAnswered ? 'Explanation' : 'Hint',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.085),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.question.containsKey('topic'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    widget.question['topic']
                        .toString()
                        .replaceAll('_', ' ')
                        .toTitleCase,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              TextFormatter.formatText(
                widget.isAnswered
                    ? (widget.question['explanation'] ??
                        'No explanation available.')
                    : (widget.question['hint'] ?? 'No hint available.'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
