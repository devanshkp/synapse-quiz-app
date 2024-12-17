import 'package:flutter/material.dart';
import 'package:flutter_application/pages/Leaderboard.dart';
import 'package:flutter_application/pages/Trivia.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bottom Navbar Example',
      theme: ThemeData(
        fontFamily: 'Poppins',
        splashFactory: NoSplash.splashFactory, // Removes click effect
        highlightColor: Colors.transparent, // Removes highlight color
      ),
      home: const BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0; // Track the current tab index

  // List of pages (widgets) to display
  final List<Widget> _screens = [
    const HomePage(),
    const SearchPage(),
    TriviaPage(),
    const LeaderboardPage(),
    const ProfilePage(),
  ];

  // List of icon paths (for filled and outlined versions)
  final List<Map<String, String>> _icons = [
    {'filled': 'assets/icons/navbar/Home_Filled.svg', 'outline': 'assets/icons/navbar/Home.svg'},
    {'filled': 'assets/icons/navbar/Discover_Filled.svg', 'outline': 'assets/icons/navbar/Discover.svg'},
    {'filled': 'assets/icons/navbar/Scroll_Filled.svg', 'outline': 'assets/icons/navbar/Scroll.svg'},
    {'filled': 'assets/icons/navbar/Leaderboard_Filled.svg', 'outline': 'assets/icons/navbar/Leaderboard.svg'},
    {'filled': 'assets/icons/navbar/Profile_Filled.svg', 'outline': 'assets/icons/navbar/Profile.svg'},
  ];

  // Function to update the selected index
  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the current page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D0D0F),
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: List.generate(5, (index) {
          return BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _currentIndex == index
                  ? _icons[index]['filled']! // Filled version of the icon
                  : _icons[index]['outline']!, // Outline version
              width: 24, // Set icon size
              height: 24,
            ),
            label: ['Home', 'Search', 'Trivia', 'Leaderboard', 'Profile'][index], // Labels
          );
        }),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed, // Ensures all 5 items are visible
      ),
    );
  }
}
