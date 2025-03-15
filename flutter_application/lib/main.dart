import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/pages/auth/email_verification.dart';
import 'package:flutter_application/pages/auth/login.dart';
import 'package:flutter_application/pages/auth/register.dart';
import 'package:flutter_application/pages/auth/username.dart';
import 'package:flutter_application/providers/auth_provider.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/services/observer_service.dart';
import 'package:flutter_application/services/restart_service.dart';
import 'package:provider/provider.dart';
import 'pages/main/home.dart';
import 'pages/main/search.dart';
import 'pages/main/profile.dart';
import 'pages/main/leaderboard.dart';
import 'pages/main/trivia.dart';
import 'pages/landing.dart';
import 'constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_application/pages/edit_profile.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return RestartService(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (context) {
            return TriviaProvider(
                Provider.of<UserProvider>(context, listen: false));
          }),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quiz App',
          theme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: backgroundPageColor,
            primaryColor: lightPurpleAccent,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          navigatorObservers: [ObserverService.routeObserver],
          initialRoute: '/', // Start with AuthProvider logic
          routes: {
            '/': (context) => const AuthProvider(),
            '/landing': (context) => const LandingPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegistrationPage(),
            '/email-verification': (context) => const EmailVerificationPage(),
            '/username-dialog': (context) => const UsernamePage(),
            '/trivia': (context) => const TriviaPage(quickPlay: true),
            '/search': (context) => const SearchPage(fromHome: true),
            '/edit_profile': (context) => const EditProfilePage(),
          },
        ),
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const SearchPage(),
    const TriviaPage(),
    const LeaderboardPage(),
    const ProfilePage(),
  ];

  final List<Map<String, Icon>> _icons = [
    {
      'filled': const Icon(Icons.home_rounded),
      'outline': const Icon(Icons.home_outlined)
    },
    {
      'filled': const Icon(Icons.search_rounded),
      'outline': const Icon(Icons.search_outlined)
    },
    {
      'filled': const Icon(Icons.keyboard_double_arrow_down_sharp),
      'outline': const Icon(Icons.keyboard_double_arrow_down_outlined)
    },
    {
      'filled': const Icon(Icons.leaderboard),
      'outline': const Icon(Icons.leaderboard_outlined)
    },
    {
      'filled': const Icon(Icons.person),
      'outline': const Icon(Icons.person_outline)
    },
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: navbarColor,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: _onTap,
          items: List.generate(5, (index) {
            return BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Icon(_icons[index]['outline']!.icon,
                    size: 26, color: Colors.white70),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Icon(
                  _icons[index]['filled']!.icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              label: '',
            );
          }),
          showUnselectedLabels: false,
          showSelectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
