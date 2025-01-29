import 'package:flutter_application/colors.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/profile/add_question_form.dart';
import 'package:flutter_application/widgets/profile/friends_drawer.dart';
import 'package:flutter_application/widgets/profile/main_stats.dart';
import 'package:flutter_application/widgets/profile/custom_app_bar.dart';
import 'package:flutter_application/widgets/profile/user_profile_header.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/widgets/profile/stats_section.dart';

import 'package:firebase_auth/firebase_auth.dart';
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

  bool _isDeveloperMode = false; // Tracks if developer mode is enabled
  final TextEditingController _devModeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();

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
      endDrawer: _buildRightDrawer(),
      body: ListView.builder(
        itemCount: 4, // Adjust based on your number of sections/items
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                const SizedBox(height: 20),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final userProfile = userProvider.userProfile;
                    if (userProfile == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return UserProfileHeader(userProfile: userProfile);
                  },
                ),
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

  Widget _buildRightDrawer() {
    return Drawer(
      backgroundColor: backgroundPageColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white38),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
            onTap: _signOut, // Call the sign-out function
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode, color: Colors.green),
            title: const Text('Developer Mode',
                style: TextStyle(color: Colors.white)),
            onTap: _promptDeveloperMode, // Prompt user for developer password
          ),
          if (_isDeveloperMode) ...[
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('Add Question',
                  style: TextStyle(color: Colors.white)),
              onTap: _showAddQuestionCard, // Show the add question card
            ),
          ],
        ],
      ),
    );
  }

  void _signOut() {
    // Sign out logic
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
        context, '/'); // Navigate back to the login page
  }

  void _promptDeveloperMode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Developer Password'),
          content: TextField(
            controller: _devModeController,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_devModeController.text == "devmode") {
                  setState(() {
                    _isDeveloperMode = true;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect password')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showAddQuestionCard() {
    showDialog(
      context: context,
      builder: (context) {
        return AddQuestionForm(
          onQuestionAdded: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Question added successfully!')),
            );
            // Clear form fields
            _titleController.clear();
            _hintController.clear();
            _answerController.clear();
            _optionsController.clear();
          },
        );
      },
    );
  }

  // Placeholder for badges section
  Widget _buildBadgesSection() {
    return const Padding(padding: EdgeInsets.all(12.0));
  }
}
