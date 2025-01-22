import 'package:flutter/material.dart';
import '../utility/colors.dart';
import '../utility/utility.dart';

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
                      hintText: "Search Categories...",
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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap:
                      true, // Allows the GridView to take only the required space
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  children: [
                    categoryButton(
                      title: 'Machine Learning',
                      iconName: 'machine_learning.png',
                      iconSize: 70,
                      color: machineLearningColor,
                      onTap: () => (print('Machine learning pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                    categoryButton(
                      title: 'Data Structures',
                      iconName: 'brace.png',
                      iconSize: 70,
                      color: dataStructuresColor,
                      onTap: () => (print('Data structures pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                    categoryButton(
                      title: 'Programming Basics',
                      iconName: 'programming.png',
                      iconSize: 65,
                      color: proBasicsColor,
                      onTap: () => (print('Programming basics pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                    categoryButton(
                      title: 'Database',
                      iconName: 'database.png',
                      iconSize: 70,
                      color: dataBaseColor,
                      onTap: () => (print('Database pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // All categories section
                const Text(
                  "All Categories",
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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap:
                      true, // Allows the GridView to take only the required space
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  children: [
                    categoryButton(
                      title: 'Popular Algorithms',
                      iconName: 'algorithm.png',
                      iconSize: 70,
                      color: popularAlgColor,
                      onTap: () => (print('Popular algorithms pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                    categoryButton(
                      title: 'SWE Fundamentals',
                      iconName: 'swe.png',
                      iconSize: 70,
                      color: sweFundColor,
                      onTap: () => (print('SWE fundamentals pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                    categoryButton(
                      title: 'Foundational Math',
                      iconName: 'math.png',
                      iconSize: 70,
                      color: foundMathColor,
                      onTap: () => (print('Foundational math pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                    categoryButton(
                      title: 'Sorting Algorithms',
                      iconName: 'sort.png',
                      iconSize: 72,
                      color: sortingAlgColor,
                      onTap: () => (print('Sorting Algorithms pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                    categoryButton(
                      title: 'Neural Networks',
                      iconName: 'neural_network.png',
                      iconSize: 75,
                      color: neuralNetworksColor,
                      onTap: () => (print('Neural networks pressed.')),
                      spacing: 5,
                      titleFontSize: 13,
                    ),
                    categoryButton(
                      title: 'Foundational Math',
                      iconName: 'math.png',
                      iconSize: 70,
                      color: Colors.red,
                      onTap: () => (print('Foundational math pressed.')),
                      spacing: 5,
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
