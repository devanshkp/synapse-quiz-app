import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/pages/auth/email_verification.dart';
import 'package:flutter_application/pages/auth/login.dart';
import 'package:flutter_application/pages/auth/registration.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isPhone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOrientations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _setOrientations();
  }

  void _setOrientations() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final width = view.physicalSize.width / view.devicePixelRatio;
    final newIsPhone = width < 600;

    if (newIsPhone != _isPhone) {
      _isPhone = newIsPhone;
      SystemChrome.setPreferredOrientations(
        _isPhone
            ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
            : DeviceOrientation.values,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

          title: 'Synapse',
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
              builders:
                  Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
                      TargetPlatform.values,
                      value: (dynamic _) => const ZoomPageTransitionsBuilder(
                          backgroundColor: backgroundPageColor)),
            ),
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: backgroundPageColor,
            primaryColor: appColor,
            secondaryHeaderColor: appColor,
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
          },
        ),
      ),
    );
  }
}

class ResponsiveNavBar extends StatefulWidget {
  const ResponsiveNavBar({super.key});

  @override
  ResponsiveNavBarState createState() => ResponsiveNavBarState();
}

class ResponsiveNavBarState extends State<ResponsiveNavBar> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomePage(),
    SearchPage(),
    TriviaPage(),
    LeaderboardPage(),
    ProfilePage(),
  ];

  static const List<Map<String, Icon>> _icons = [
    {'filled': Icon(Icons.home_rounded), 'outline': Icon(Icons.home_outlined)},
    {
      'filled': Icon(Icons.search_rounded),
      'outline': Icon(Icons.search_outlined)
    },
    {
      'filled': Icon(Icons.keyboard_double_arrow_down_sharp),
      'outline': Icon(Icons.keyboard_double_arrow_down_outlined)
    },
    {
      'filled': Icon(Icons.leaderboard),
      'outline': Icon(Icons.leaderboard_outlined)
    },
    {'filled': Icon(Icons.person), 'outline': Icon(Icons.person_outline)},
  ];

  void _onTap(int index) {
    if (_currentIndex == index) return;

    final triviaProvider = Provider.of<TriviaProvider>(context, listen: false);

    if (_currentIndex == 2 && index != 2) {
      debugPrint("navigated away");
      triviaProvider.setTriviaActive(false);
    }

    if (_currentIndex != 2 && index == 2) {
      debugPrint("navigated to");
      triviaProvider.setTriviaActive(true);
    }

    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        bool isWideScreen = constraints.maxWidth >= 900;

        if (isTablet) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  groupAlignment: 0,
                  backgroundColor: navbarColor,
                  selectedIndex: _currentIndex,
                  minWidth: isWideScreen ? 100 : 75,
                  selectedIconTheme:
                      const IconThemeData(color: Colors.white, size: 30),
                  unselectedIconTheme:
                      const IconThemeData(color: Colors.white70, size: 26),
                  labelType: NavigationRailLabelType.none,
                  indicatorColor: Colors.transparent,
                  onDestinationSelected: _onTap,
                  destinations: List.generate(5, (index) {
                    return NavigationRailDestination(
                        icon: Icon(_icons[index]['outline']!.icon,
                            color: Colors.white70),
                        selectedIcon: Icon(_icons[index]['filled']!.icon,
                            color: Colors.white),
                        label: Text(_getNavItemLabel(index),
                            style: const TextStyle(color: Colors.white)));
                  }),
                ),

                // Main Content Area
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: backgroundPageColor,
                      image: DecorationImage(
                        image: AssetImage('assets/images/shapes.png'),
                        opacity: 0.2,
                        repeat: ImageRepeat.repeat,
                      ),
                    ),
                    child: _screens[_currentIndex],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile Layout with Bottom Navigation Bar (original implementation)
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
              child: _screens[_currentIndex],
            ),
            bottomNavigationBar: BottomNavigationBar(
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
          );
        }
      },
    );
  }

  // Helper method to get labels for NavigationRail
  String _getNavItemLabel(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Trivia';
      case 3:
        return 'Leaderboard';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }
}
