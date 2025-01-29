import 'package:flutter/material.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/widgets/shared.dart';

class StatsSection extends StatelessWidget {
  final UserProfile userProfile;

  const StatsSection({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    double statsSpacing = 12.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(statsSpacing),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 41, 41, 41),
              Color.fromARGB(255, 34, 34, 34),
              Color(0xff242424)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Member Since and Longest Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Member Since', 'Jan, 2022'),
                SizedBox(width: statsSpacing),
                _buildStatCard('Longest Streak', '124 Days',
                    isHighlighted: true),
              ],
            ),
            SizedBox(height: statsSpacing),

            // Performance Chart
            _buildPerformanceChart([
              {
                'label': 'Data Structures',
                'answered': 42,
                'total': 80,
                'color': const Color(0xffFFD6DD),
              },
              {
                'label': 'Time Complexity',
                'answered': 7,
                'total': 10,
                'color': const Color(0xffC4D0FB),
              },
              {
                'label': 'Search Algorithms',
                'answered': 3,
                'total': 15,
                'color': const Color(0xffA9ADF3),
              },
            ]),
          ],
        ),
      ),
    );
  }

  // Helper function for Stat Cards
  Widget _buildStatCard(String title, String value,
      {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: backgroundPageColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 5.0),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Poppins'),
                children: [
                  if (isHighlighted)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [accentPink, darkAccentPurple],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            value.split(' ').first,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Fallback color
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    TextSpan(
                      text: '${value.split(' ').first} ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  TextSpan(
                    text: value.split(' ').sublist(1).join(' '),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build the performance chart
  Widget _buildPerformanceChart(List<Map<String, dynamic>> topics) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundPageColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Flexible(
                child: Text(
                  'Top performance by category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                      color: const Color(0xff232323),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.0)),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.bar_chart_outlined,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
              alignment: WrapAlignment.start,
              spacing: 15.0,
              runSpacing: 10.0,
              children: topics.map((topic) {
                return _buildStatTopic(topic['color'], topic['label']);
              }).toList()),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end, // Align all bars to the bottom
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: topics.map((topic) {
              double percentage = (topic['answered'] / topic['total']) * 100;
              return _buildBar(
                topic['label'],
                topic['answered'],
                topic['total'],
                percentage,
                topic['color'],
              );
            }).toList(),
          ),
          const CustomHorizontalDivider(padding: 50),
          const Text(
            'Questions Answered',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build individual bars
  Widget _buildBar(
      String label, int answered, int total, double percentage, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end, // Align bar at the bottom
      children: [
        const SizedBox(height: 50),
        Container(
          height:
              150.0 * (percentage / 100), // Height proportional to completion
          width: 40.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          '$answered/$total',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
      ],
    );
  }

  // Helper function to display the different stat topics in a list view
  Widget _buildStatTopic(Color colour, String topic) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
            color: colour, borderRadius: BorderRadius.circular(100)),
      ),
      const SizedBox(width: 10),
      Text(
        topic,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      )
    ]);
  }
}
