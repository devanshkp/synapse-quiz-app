import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/profile/friends_drawer.dart';
import 'package:flutter_application/widgets/profile/main_stats.dart';
import 'package:flutter_application/widgets/profile/custom_app_bar.dart';
import 'package:flutter_application/widgets/profile/settings_drawer.dart';
import 'package:flutter_application/widgets/profile/user_profile_header.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/widgets/profile/stats_section.dart';

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
      body: ListView.builder(
        itemCount: 4, // Adjust based on your number of sections/items
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                const SizedBox(height: 20),
                UserProfileHeader(),
              ],
            );
          } else if (index == 1) {
            return Column(
              children: [
                const SizedBox(height: 20),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final userProfile = userProvider.userProfile;
                    if (userProfile == null) {
                      return const SizedBox.shrink();
                    }
                    return MainStats(
                      userProfile: userProfile,
                      totalQuestions: userProvider.totalQuestions,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          } else if (index == 2) {
            return CustomTabBar(
              controller: _tabController,
              tabs: const ['Stats', 'Badges'],
            );
          } else if (index == 3) {
            return Column(
              children: [
                const SizedBox(height: 10),
                _buildTabContent(),
              ],
            );
          }
          return const SizedBox.shrink(); // Fallback for any undefined indices
        },
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 515,
      child: TabBarView(
        controller: _tabController,
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final userProfile = userProvider.userProfile;

              if (userProfile == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return StatsSection(userProfile: userProfile);
            },
          ),
          _buildBadgesSection(),
        ],
      ),
    );
  }

  // Placeholder for badges section
  Widget _buildBadgesSection() {
    return const Padding(padding: EdgeInsets.all(12.0));
  }
}
