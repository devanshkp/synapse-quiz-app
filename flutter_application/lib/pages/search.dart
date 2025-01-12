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
                  childAspectRatio: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap:
                      true, // Allows the GridView to take only the required space
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  children: [
                    searchCategoryButton(
                        title: 'Machine Learning',
                        titleFontSize: 11,
                        iconName: 'machine_learning.png',
                        iconSize: 60,
                        onTap: () => (print('Machine learning pressed.')),
                        spacing: 5),
                    searchCategoryButton(
                        title: 'Data Structures',
                        titleFontSize: 11,
                        iconName: 'brace.png',
                        iconSize: 60,
                        onTap: () => (print('Data structures pressed.')),
                        spacing: 5),
                    searchCategoryButton(
                        title: 'Programming Basics',
                        titleFontSize: 11,
                        iconName: 'programming.png',
                        iconSize: 60,
                        onTap: () => (print('Programming basics pressed.')),
                        spacing: 5),
                    searchCategoryButton(
                        title: 'Database',
                        titleFontSize: 11,
                        iconName: 'database.png',
                        iconSize: 60,
                        onTap: () => (print('Database pressed.')),
                        spacing: 5),
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
                  childAspectRatio: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap:
                      true, // Allows the GridView to take only the required space
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  children: [
                    searchCategoryButton(
                        title: 'Popular Algorithms',
                        titleFontSize: 11,
                        iconName: 'algorithm.png',
                        iconSize: 60,
                        onTap: () => (print('Popular algorithms pressed.')),
                        spacing: 5),
                    searchCategoryButton(
                        title: 'SWE Fundamentals',
                        titleFontSize: 11,
                        iconName: 'swe.png',
                        iconSize: 55,
                        onTap: () => (print('SWE fundamentals pressed.')),
                        spacing: 5),
                    searchCategoryButton(
                        title: 'Foundational Math',
                        titleFontSize: 11,
                        iconName: 'math.png',
                        iconSize: 60,
                        onTap: () => (print('Foundational math pressed.')),
                        spacing: 5),
                    searchCategoryButton(
                        title: 'Sorting Algorithms',
                        titleFontSize: 11,
                        iconName: 'sort.png',
                        iconSize: 60,
                        onTap: () => (print('Sorting Algorithms pressed.')),
                        spacing: 5),
                    searchCategoryButton(
                        title: 'Neural Networks',
                        titleFontSize: 11,
                        iconName: 'neural_network.png',
                        iconSize: 60,
                        onTap: () => (print('Neural networks pressed.')),
                        spacing: 5),
                    searchCategoryButton(
                        title: 'Foundational Math',
                        titleFontSize: 11,
                        iconName: 'math.png',
                        iconSize: 60,
                        onTap: () => (print('Foundational math pressed.')),
                        spacing: 5),
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
