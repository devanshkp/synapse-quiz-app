import 'package:flutter/material.dart';
import 'package:flutter_application/pages/email_verification.dart';
import 'package:flutter_application/pages/login.dart';
import 'package:flutter_application/pages/register.dart';
import 'package:flutter_application/providers/auth_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/profile.dart';
import 'pages/leaderboard.dart';
import 'pages/trivia.dart';
import 'colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quiz App',
        theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: backgroundPageColor,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        initialRoute: '/', // Start with AuthProvider logic
        routes: {
          '/': (context) => const AuthProvider(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegistrationPage(),
          '/email-verification': (context) => const EmailVerificationPage(),
        },
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 2; // Track the current tab index

  // List of pages (widgets) to display
  final List<Widget> _screens = [
    const HomePage(),
    const SearchPage(),
    const TriviaPage(),
    const LeaderboardPage(),
    const ProfilePage(),
  ];

  // List of icon paths (for filled and outlined versions)
  final List<Map<String, String>> _icons = [
    {
      'filled': 'assets/icons/navbar/Home_Filled.svg',
      'outline': 'assets/icons/navbar/Home.svg'
    },
    {
      'filled': 'assets/icons/navbar/Discover_Filled.svg',
      'outline': 'assets/icons/navbar/Discover.svg'
    },
    {
      'filled': 'assets/icons/navbar/Scroll_Filled.svg',
      'outline': 'assets/icons/navbar/Scroll.svg'
    },
    {
      'filled': 'assets/icons/navbar/Leaderboard_Filled.svg',
      'outline': 'assets/icons/navbar/Leaderboard.svg'
    },
    {
      'filled': 'assets/icons/navbar/Profile_Filled.svg',
      'outline': 'assets/icons/navbar/Profile.svg'
    },
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
        backgroundColor: navbarColor,
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: List.generate(5, (index) {
          return BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SvgPicture.asset(
                _currentIndex == index
                    ? _icons[index]['filled']! // Filled version of the icon
                    : _icons[index]['outline']!, // Outline version
                width: 24, // Set icon size
                height: 24,
              ),
            ),
            label: [
              'Home',
              'Search',
              'Trivia',
              'Leaderboard',
              'Profile'
            ][index], // Labels
          );
        }),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        iconSize: 0.0,
        type: BottomNavigationBarType.fixed, // Ensures all 5 items are visible
      ),
    );
  }
}
