  import 'package:flutter/material.dart';
  import 'package:flutter_application/providers/trivia_provider.dart';
  import 'package:flutter_application/providers/user_provider.dart';
  import 'package:flutter_application/widgets/home/home_widgets.dart';
  import 'package:flutter_application/widgets/shared_widgets.dart';
  import 'package:provider/provider.dart';
  import '../../constants.dart';
  import 'package:flutter_application/pages/main/search.dart';

  const List<Map<String, dynamic>> allTopics = [
    // Your existing topics
    {
      'title': 'probability_&_statistics',
      'iconName': 'probability_&_statistics.png',
      'iconRatio': 1,
      'color': probStatColor,
      'rightOffset': -4,
    },
    {
      'title': 'cloud_computing',
      'iconName': 'cloud_computing.png',
      'iconRatio': 1,
      'color': cloudCompColor,
    },
    {
      'title': 'artificial_intelligence',
      'iconName': 'artificial_intelligence.png',
      'iconRatio': 1.125,
      'color': artificialIntelColor,
      'rightOffset': -12,
      'bottomOffset': -15,
    },
    {
      'title': 'machine_learning',
      'iconName': 'machine_learning.png',
      'iconRatio': 1,
      'color': macLearningColor,
      'rightOffset': -8,
    },
    {
      'title': 'data_structures',
      'iconName': 'data_structures.png',
      'iconRatio': 1,
      'color': dataStructColor,
      'rightOffset': -8,
    },
    {
      'title': 'cyber_security',
      'iconName': 'cyber_security.png',
      'iconRatio': 1.075,
      'color': cyberSecColor,
    },
    {
      'title': 'algorithms',
      'iconName': 'algorithms.png',
      'iconRatio': 1,
      'color': algorithmsColor,
      'rightOffset': -2,
    },
    {
      'title': 'database',
      'iconName': 'database.png',
      'iconRatio': 1.05,
      'color': databaseColor,
    },
    {
      'title': 'SWE_fundamentals',
      'iconName': 'SWE_fundamentals.png',
      'iconRatio': 1,
      'color': sweFundColor,
      'rightOffset': -7,
    },
    {
      'title': 'data_science',
      'iconName': 'data_science.png',
      'iconRatio': 1.05,
      'color': dataSciColor,
      'bottomOffset': -10.0,
    },
    {
      'title': 'discrete_math',
      'iconName': 'discrete_math.png',
      'iconRatio': 1,
      'color': discMathColor,
    },
    {
      'title': 'computer_network',
      'iconName': 'computer_network.png',
      'iconRatio': 1,
      'color': compNetworkColor,
    },
  ];

  class HomePage extends StatelessWidget {
    const HomePage({super.key});

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
        extraPadding = screenWidth * .125;
      } else {
        extraPadding = screenWidth * .175;
      }
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // List of widgets to be displayed
      final List<Widget> sections = [
        const TopPortion(),
        MiddlePortion(
          userProvider: userProvider,
          isTablet: isTablet,
        ),
        BottomPortion(
          userProvider: userProvider,
        ),
      ];

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView.builder(
            padding: EdgeInsets.only(
                top: 20,
                left: isTablet ? extraPadding : 18,
                right: isTablet ? extraPadding : 18),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              return sections[index];
            },
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
              userProvider.userProfile?.fullName.split(' ')[0] ?? 'Player';
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
                        "Let's play!",
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
                    child: Image.asset(
                      'assets/icons/logos/app_foreground.png',
                      height: 15,
                      width: 15,
                    ),
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
    final bool isTablet;

    const MiddlePortion(
        {super.key, required this.userProvider, required this.isTablet});

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
                child: TopicSelectionButton(
                  userProvider: userProvider,
                  titleFontSize: isTablet ? 17.5 : 16,
                  subtitleFontSize: isTablet ? 10.5 : 9,
                ),
              ),
              const SizedBox(width: 15), // Space between the two columns
              Expanded(
                flex: 4,
                child: QuestionHistoryButton(
                  titleFontSize: isTablet ? 17.5 : 16,
                  subtitleFontSize: isTablet ? 10.5 : 9,
                ),
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
            GestureDetector(
              // animate to page
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(fromHome: true),
                  ),
                ),
              },
              child: const Text(
                'Topics >',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 15),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = MediaQuery.sizeOf(context).width >= 600;
                final crossAxisCount = isTablet ? 4 : 3;
                final topics = isTablet ? allTopics : allTopics.sublist(0, 9);

                // Calculate responsive sizes based on container width
                final baseIconSize = constraints.maxWidth / (crossAxisCount * 2);
                final iconSize = baseIconSize.clamp(40.0, 80.0); // Min 50, max 75

                final baseFontSize = constraints.maxWidth / (crossAxisCount * 11);
                final titleFontSize = baseFontSize.clamp(10.0, 14.0);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topics.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 11,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return TopicButton(
                      title: topic['title'],
                      iconName: topic['iconName'],
                      iconSize: topic['iconRatio'] * iconSize,
                      color: topic['color'],
                      borderRadius: 14,
                      titleFontSize: titleFontSize,
                      buttonType: 'home',
                      section: 'grid',
                    );
                  },
                );
              },
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
                    color: Colors.black.withValues(alpha: 0.34),
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
                                color: Colors.white.withValues(alpha: .85),
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
                                  color: Colors.white.withValues(alpha: 0.3),
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
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '$solvedTodayCount/15',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
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
