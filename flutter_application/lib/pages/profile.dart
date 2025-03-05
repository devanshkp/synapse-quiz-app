import 'package:flutter_application/colors.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/profile/friends_drawer.dart';
import 'package:flutter_application/widgets/profile/main_stats.dart';
import 'package:flutter_application/widgets/profile/custom_app_bar.dart';
import 'package:flutter_application/widgets/profile/settings_drawer.dart';
import 'package:flutter_application/widgets/profile/user_profile_header.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/widgets/profile/stats_section.dart';
import 'package:flutter_application/widgets/profile/badges_section.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set up listeners for user profile and total questions changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.listenToUserProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ProfileAppBar(),
      ),
      drawer: const FriendsDrawer(),
      endDrawer: const SettingsDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh user data
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          await userProvider.refreshUserProfile();
        },
        color: Colors.white,
        backgroundColor: const Color(0xFF2C2C2C),
        child: Container(
          decoration: const BoxDecoration(
            color: backgroundPageColor,
            image: DecorationImage(
              image: AssetImage('assets/images/shapes.png'),
              opacity: 0.15,
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Profile header section
                const SizedBox(height: 20),
                const UserProfileHeader(),
                const SizedBox(height: 25),

                // Main stats section
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final userProfile = userProvider.userProfile;
                    if (userProfile == null) {
                      return const SizedBox.shrink();
                    }
                    return MainStats(
                      userProfile: userProfile,
                      totalQuestions:
                          Provider.of<TriviaProvider>(context, listen: false)
                              .totalQuestions,
                    );
                  },
                ),

                const SizedBox(height: 25),

                // Tab bar
                CustomTabBar(
                  controller: _tabController,
                  tabs: const ['Stats', 'Badges'],
                  horizontalPadding: 28,
                  tabHeight: 40,
                  indicatorPadding: const EdgeInsets.all(2),
                ),
                const SizedBox(height: 15),

                // Tab content
                ContentSizeTabBarView(
                  controller: _tabController,
                  children: [
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final userProfile = userProvider.userProfile;
                        if (userProfile == null) {
                          return const Center(
                              child: CustomCircularProgressIndicator());
                        }
                        return StatsSection(userProfile: userProfile);
                      },
                    ),
                    const BadgesSection(),
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
