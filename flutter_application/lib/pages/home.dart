import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/home/session_history.dart';
import 'package:flutter_application/widgets/home/topic_selection.dart';
import 'package:flutter_application/widgets/home/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // List of widgets to be displayed
    final List<Widget> sections = [
      const TopPortion(),
      MiddlePortion(
        userProvider: userProvider,
      ),
      BottomPortion(
        userProvider: userProvider,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: backgroundPageColor,
          image: DecorationImage(
            image: AssetImage('assets/images/shapes.png'),
            opacity: 0.2,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 18, right: 18),
          child: ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              return sections[index];
            },
          ),
        ),
      ),
    );
  }
}

class TopPortion extends StatelessWidget {
  const TopPortion({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final String firstName =
            userProvider.userProfile?.fullName.split(' ')[0] ?? 'Guest';
        final int questionCount =
            Provider.of<TriviaProvider>(context, listen: false)
                .questions
                .length;
        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                // Ensure the Column takes the available space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Text
                    Text(
                      'Hi, $firstName',
                      style: const TextStyle(
                        color: Colors.white70, // Subdued color for greeting
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Text(
                      'Let’s play!',
                      style: TextStyle(
                        color: Colors.white, // Bright color for emphasis
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 20), // Space between greeting and content
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: GestureDetector(
                  onTap: () => debugPrint("$questionCount"),
                  child: SvgPicture.asset('assets/icons/home/Bolt.svg'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MiddlePortion extends StatelessWidget {
  final UserProvider userProvider;

  const MiddlePortion({super.key, required this.userProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: DailyTaskCard(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: TopicButton(userProvider: userProvider),
            ),
            const SizedBox(width: 15), // Space between the two columns
            const Expanded(
              flex: 4,
              child: HistoryButton(),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 15),
          child: QuickPlayButton(),
        )
      ],
    );
  }
}

class BottomPortion extends StatelessWidget {
  final UserProvider userProvider;

  const BottomPortion({super.key, required this.userProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Topics >',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: 1,
            children: [
              topicButton(
                title: 'Foundational Math',
                iconName: 'math.png',
                iconSize: 65,
                color: foundMathColor,
                onTap: () => debugPrint('Foundational math pressed.'),
                rightOffset: -6,
                radius: 18,
                titleFontSize: 11,
              ),
              topicButton(
                title: 'Sorting Algorithms',
                iconName: 'sort.png',
                iconSize: 65,
                color: sortingAlgColor,
                onTap: () => debugPrint('Sorting Algorithms pressed.'),
                radius: 18,
                titleFontSize: 11,
              ),
              topicButton(
                title: 'Artificial Intelligence',
                iconName: 'artificial_intelligence.png',
                iconSize: 73,
                color: artificalIntelligenceColor,
                onTap: () => debugPrint('Artificial Intelligence pressed.'),
                bottomOffset: -15,
                rightOffset: -12,
                radius: 18,
                titleFontSize: 11,
              ),
              topicButton(
                title: 'Machine Learning',
                iconName: 'machine_learning.png',
                iconSize: 65,
                color: machineLearningColor,
                onTap: () => debugPrint('Machine learning pressed.'),
                rightOffset: -8,
                radius: 18,
                titleFontSize: 11,
              ),
              topicButton(
                title: 'Data Structures',
                iconName: 'brace.png',
                iconSize: 65,
                color: dataStructuresColor,
                rightOffset: -8,
                onTap: () => debugPrint('Data structures pressed.'),
                radius: 18,
                titleFontSize: 11,
              ),
              topicButton(
                title: 'Programming Basics',
                iconName: 'programming.png',
                iconSize: 65,
                color: proBasicsColor,
                onTap: () => debugPrint('Programming basics pressed.'),
                radius: 18,
                titleFontSize: 11,
              ),
              topicButton(
                title: 'Popular Algorithms',
                iconName: 'algorithm.png',
                iconSize: 65,
                color: popularAlgColor,
                onTap: () => debugPrint('Popular algorithms pressed.'),
                rightOffset: -8,
                radius: 18,
                titleFontSize: 11,
              ),
              topicButton(
                title: 'Database Systems',
                iconName: 'database.png',
                iconSize: 65,
                color: dataBaseColor,
                onTap: () => debugPrint('Database pressed.'),
                radius: 18,
                titleFontSize: 11,
              ),
              topicButton(
                title: 'SWE Fundamentals',
                iconName: 'swe.png',
                iconSize: 65,
                color: sweFundColor,
                onTap: () => debugPrint('SWE fundamentals pressed.'),
                radius: 18,
                rightOffset: -7,
                titleFontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

class DailyTaskCard extends StatelessWidget {
  const DailyTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: backgroundPageColor),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [purpleAccent, darkPurpleAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        color: purpleAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.34),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(
                  'assets/images/task.png',
                  height: 70,
                  width: 70,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Task',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '15 Questions',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Wrap the progress bar and count with Consumer
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    int solvedTodayCount =
                        userProvider.userProfile?.solvedTodayCount ?? 0;
                    double progress = (solvedTodayCount / 15).clamp(0.0, 1.0);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 9,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double progressWidth =
                                    progress * constraints.maxWidth;
                                return Container(
                                  height: 9,
                                  width: progressWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                'Progress',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '$solvedTodayCount/15',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
  }
}

class QuickPlayButton extends StatelessWidget {
  const QuickPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: customHomeButton(
        title: 'QUICK PLAY',
        titleFontSize: 28,
        titleFontWeight: FontWeight.bold,
        subtitle: 'Play questions from your selected topics!',
        subtitleFontSize: 11,
        iconPath: 'assets/icons/home/Play.svg',
        iconSize: 22,
        onTap: () => Navigator.pushNamed(context, '/trivia'),
        textPadding: const EdgeInsets.only(left: 17, right: 12, bottom: 5),
        iconPadding: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}

class HistoryButton extends StatelessWidget {
  const HistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: customHomeButton(
        title: 'Session History',
        titleFontSize: 16,
        subtitle: 'Explore your most recent gameplay sessions.',
        subtitleFontSize: 9,
        iconPath: 'assets/icons/home/History.svg',
        iconSize: 25,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const SessionHistoryPopup(),
        ),
        textPadding: const EdgeInsets.only(left: 15, right: 7, bottom: 3),
        iconPadding: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}

class TopicButton extends StatelessWidget {
  final UserProvider userProvider;

  const TopicButton({super.key, required this.userProvider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: customHomeButton(
        title: 'Topic Selection',
        titleFontSize: 16,
        iconPath: 'assets/icons/home/Edit.svg',
        iconSize: 15,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const TopicSelectionPopup(),
        ),
        textPadding: const EdgeInsets.only(left: 15, right: 11),
        iconPadding: const EdgeInsets.only(bottom: 25),
      ),
    );
  }
}
