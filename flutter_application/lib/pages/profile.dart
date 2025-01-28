import 'package:flutter_application/colors.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/profile/add_question_form.dart';
import 'package:flutter_application/widgets/profile/main_stats.dart';
import 'package:flutter_application/widgets/profile/custom_app_bar.dart';
import 'package:flutter_application/widgets/profile/user_profile_header.dart';
import 'package:flutter_application/widgets/profile/shared.dart';
import 'package:flutter_application/widgets/profile/stats_section.dart';

import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _statsKey = GlobalKey();
  static Uint8List? _statsImage;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureStatsSection();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _captureStatsSection() async {
    try {
      final boundary = _statsKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        setState(() {
          _statsImage = byteData?.buffer.asUint8List();
        });
      }
    } catch (e) {
      debugPrint("Error capturing stats section: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ProfileAppBar(),
      ),
      drawer: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userProfile = userProvider.userProfile;
          if (userProfile == null) {
            return const Drawer(
              backgroundColor: backgroundPageColor,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildLeftDrawer(userProfile);
        },
      ),
      endDrawer: _buildRightDrawer(),
      body: ListView.builder(
        itemCount: 6, // Adjust based on your number of sections/items
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
            return const CustomHorizontalDivider(padding: 70);
          } else if (index == 2) {
            return Consumer<UserProvider>(
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
            );
          } else if (index == 3) {
            return const CustomHorizontalDivider(padding: 50);
          } else if (index == 4) {
            return _buildTabs();
          } else if (index == 5) {
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

  // Build the different tabs for each label (under main stats)
  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Stats', height: 30.0),
        Tab(text: 'Badges', height: 30.0),
      ],
      unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal, fontFamily: 'Poppins', fontSize: 13),
      labelStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
      labelColor: lightAccentPurple,
      unselectedLabelColor: Colors.white54,
      dividerColor: Colors.transparent,
      indicatorColor: lightAccentPurple, // Optional: Indicator color
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 515,
      child: TabBarView(
        controller: _tabController,
        children: [
          _statsSectionWrapper(),
          _buildBadgesSection(),
        ],
      ),
    );
  }

  // Drawers
  Widget _buildLeftDrawer(UserProfile userProfile) {
    final friends = userProfile.friends;

    return Drawer(
      backgroundColor: backgroundPageColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            child: Text(
              'Friends',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add Friend',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.person_add_alt_1_rounded,
                    color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (friendId) async {
                if (friendId.isNotEmpty) {
                  await _addFriend(friendId);
                }
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const Text(
                  'Your Friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ..._buildFriendList(friends),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addFriend(String friendId) async {
    // Add friend logic here
  }

  List<Widget> _buildFriendList(List<String> friends) {
    if (friends.isEmpty) {
      return [
        const Text(
          'No friends added yet.',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      ];
    }

    return friends.map((friendId) {
      return ListTile(
        title: Text(
          friendId, // You can fetch and display more details if needed
          style: const TextStyle(color: Colors.white),
        ),
      );
    }).toList();
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

  // Renders stats section as an image
  Widget _statsSectionWrapper() {
    return _statsImage != null
        ? Image.memory(_statsImage!, fit: BoxFit.contain)
        : Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final userProfile = userProvider.userProfile;

              if (userProfile == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return RepaintBoundary(
                key: _statsKey,
                child: StatsSection(userProfile: userProfile),
              );
            },
          );
  }

  // Placeholder for badges section
  Widget _buildBadgesSection() {
    return const Padding(padding: EdgeInsets.all(12.0));
  }
}
