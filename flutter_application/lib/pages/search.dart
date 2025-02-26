import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/home/widgets.dart';
import '../colors.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundPageColor, // Match background
        toolbarHeight:
            90, // Set height for the app bar to accommodate the search bar
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Search Topics...",
                      hintStyle: TextStyle(color: Colors.black54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(
                  Icons.search,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18),
        child: ListView.builder(
          itemCount: 1, // Only one section of content
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Recommended section
                const Text(
                  "Recommended for you",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  shrinkWrap:
                      true, // Allows the GridView to take only the required space
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  children: [
                    topicButton(
                      title: 'Machine Learning',
                      iconName: 'machine_learning.png',
                      iconSize: 70,
                      color: machineLearningColor,
                      onTap: () => (debugPrint('Machine learning pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Data Structures',
                      iconName: 'brace.png',
                      iconSize: 70,
                      color: dataStructuresColor,
                      onTap: () => (debugPrint('Data structures pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Programming Basics',
                      iconName: 'programming.png',
                      iconSize: 65,
                      color: proBasicsColor,
                      onTap: () => (debugPrint('Programming basics pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Database Systems',
                      iconName: 'database.png',
                      iconSize: 70,
                      color: dataBaseColor,
                      onTap: () => (debugPrint('Database pressed.')),
                      titleFontSize: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // All topics section
                const Text(
                  "All Topics",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  shrinkWrap:
                      true, // Allows the GridView to take only the required space
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  children: [
                    topicButton(
                      title: 'Popular Algorithms',
                      iconName: 'algorithm.png',
                      iconSize: 70,
                      color: popularAlgColor,
                      onTap: () => (debugPrint('Popular algorithms pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'SWE Fundamentals',
                      iconName: 'swe.png',
                      iconSize: 70,
                      color: sweFundColor,
                      onTap: () => (debugPrint('SWE fundamentals pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Foundational Math',
                      iconName: 'math.png',
                      iconSize: 70,
                      color: foundMathColor,
                      onTap: () => (debugPrint('Foundational math pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Sorting Algorithms',
                      iconName: 'sort.png',
                      iconSize: 72,
                      color: sortingAlgColor,
                      onTap: () => (debugPrint('Sorting Algorithms pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Artifical Intelligence',
                      iconName: 'artificial_intelligence.png',
                      iconSize: 80,
                      color: artificalIntelligenceColor,
                      onTap: () =>
                          (debugPrint('Artifical Intelligence pressed.')),
                      bottomOffset: -15,
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Programming Basics',
                      iconName: 'programming.png',
                      iconSize: 65,
                      color: proBasicsColor,
                      onTap: () => (debugPrint('Programming basics pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Data Structures',
                      iconName: 'brace.png',
                      iconSize: 70,
                      color: dataStructuresColor,
                      onTap: () => (debugPrint('Data structures pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Machine Learning',
                      iconName: 'machine_learning.png',
                      iconSize: 70,
                      color: machineLearningColor,
                      onTap: () => (debugPrint('Machine learning pressed.')),
                      titleFontSize: 13,
                    ),
                    topicButton(
                      title: 'Database Systems',
                      iconName: 'database.png',
                      iconSize: 70,
                      color: dataBaseColor,
                      onTap: () => (debugPrint('Database pressed.')),
                      titleFontSize: 13,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
