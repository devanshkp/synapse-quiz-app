import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/profile/drawers/friends_drawer.dart';
import 'package:flutter_application/widgets/profile/main_stats.dart';
import 'package:flutter_application/widgets/profile/custom_app_bar.dart';
import 'package:flutter_application/widgets/profile/drawers/settings_drawer.dart';
import 'package:flutter_application/widgets/profile/tabs/topics_section.dart';
import 'package:flutter_application/widgets/profile/user_profile_header.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:flutter_application/widgets/profile/tabs/stats_section.dart';
import 'package:flutter_application/widgets/profile/tabs/badges_section.dart';
import 'package:contentsize_tabbarview/contentsize_tabbarview.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProvider userProvider;
  UserProfile? userProfile;
  final double expandedHeight = 110.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final double extraPadding;
    if (screenWidth < 700) {
      extraPadding = screenWidth * 0.1;
    } else if (screenWidth < 850) {
      extraPadding = screenWidth * 0.15;
    } else if (screenWidth < 1000) {
      extraPadding = screenWidth * .2;
    } else {
      extraPadding = screenWidth * .25;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ProfileAppBar(),
      ),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.1,
      drawer: const FriendsDrawer(),
      endDrawer: const SettingsDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (mounted) {
            setState(() {});
          }
        },
        color: Colors.white,
        backgroundColor: const Color(0xFF2C2C2C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: isTablet ? extraPadding : 0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return UserProfileHeader(scaffoldKey: _scaffoldKey);
                  },
                ),
                const SizedBox(height: 25),

                // Main stats section
                MainStats(
                  userProfile: userProvider.userProfile!,
                  totalQuestions:
                      Provider.of<TriviaProvider>(context, listen: false)
                          .totalQuestions,
                ),

                const SizedBox(height: 25),

                // Tab bar
                CustomTabBar(
                  controller: _tabController,
                  tabs: const ['Stats', 'Badges', 'Topics'],
                  horizontalPadding: 28,
                  tabHeight: 40,
                  indicatorPadding: const EdgeInsets.all(2),
                ),
                const SizedBox(height: 15),

                // Tab content
                ContentSizeTabBarView(
                  controller: _tabController,
                  children: [
                    StatsSection(userProfile: userProvider.userProfile!),
                    BadgesSection(userProfile: userProvider.userProfile!),
                    TopicsSection(userProfile: userProvider.userProfile!),
                  ],
                ),

                // Bottom padding
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
