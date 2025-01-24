import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../utility/colors.dart';
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
  double avatarRadius = 55.0;
  final double expandedHeight = 110.0;

  bool _isDeveloperMode = false; // Tracks if developer mode is enabled
  final TextEditingController _devModeController = TextEditingController();
  final GlobalKey<FormState> _questionFormKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();
  String? _selectedCategory;

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
    userProvider = Provider.of<UserProvider>(context); // Listen for updates
    userProfile = userProvider.userProfile;
    if (userProfile == null) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator()), // Show a loading indicator
      );
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4), // Shadow color
                blurRadius: 10, // Spread of the shadow
                offset: const Offset(0, 8), // Positioning of the shadow
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF131313),
                      Color(0xFF1D1D1D),
                      Color(0xFF272727),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              leading: Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              actions: [
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: const Padding(
                        padding: EdgeInsets.only(right: 30.0),
                        child: Icon(Icons.settings, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildLeftDrawer(),
      endDrawer: _buildRightDrawer(),
      body: ListView.builder(
        itemCount: 6, // Adjust based on your number of sections/items
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                const SizedBox(height: 20),
                _buildUserProfile(),
              ],
            );
          } else if (index == 1) {
            return _buildHorizontalDivider(70);
          } else if (index == 2) {
            return _buildMainStatCards();
          } else if (index == 3) {
            return _buildHorizontalDivider(50);
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

  Widget _buildUserProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border:
                Border.all(width: 1.5, color: Colors.white.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: userProfile!.profilePicture.isNotEmpty
                      ? NetworkImage(userProfile!.profilePicture)
                      : const AssetImage('assets/images/avatar.jpg')
                          as ImageProvider,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userProfile!.username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            text: '${userProfile!.fullName} • ',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
            children: [
              TextSpan(
                text: '${userProfile!.friends.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: ' Friends',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Main Stats : Current Streak, Global Rank, and Total questions solved
  Widget _buildMainStatCards() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 27.5),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainStatCard(
              'STREAK', '15 Days', Icons.whatshot, Colors.orangeAccent),
          _buildVerticalDivider(Colors.white),
          _buildMainStatCard('RANK', '#264', Icons.language,
              const Color.fromARGB(255, 64, 207, 255)),
          _buildVerticalDivider(Colors.white),
          _buildMainStatCard('SOLVED', '56/800', Icons.check_circle,
              const Color.fromARGB(255, 105, 240, 130)),
        ],
      ),
    );
  }

  // Column builder for each main stat
  Widget _buildMainStatCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        // Glow Effect
        Stack(
          alignment: Alignment.center,
          children: [
            // Glowing Effect
            Container(
              width: 21, // Adjust the size to fit the glow
              height: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2), // Glow color
                    blurRadius: 10, // How much the glow spreads
                    spreadRadius: 1, // Intensity of the glow
                  ),
                ],
              ),
            ),
            // Actual Icon
            Icon(icon, color: color, size: 21),
          ],
        ),
        const SizedBox(height: 7.5),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2.5),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
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
          fontWeight: FontWeight.normal, fontFamily: 'Poppins', fontSize: 15),
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
  Widget _buildLeftDrawer() {
    final friends = userProfile!.friends;

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
        return AlertDialog(
          title: const Text('Add New Question'),
          content: Form(
            key: _questionFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      "neural_networks",
                      "foundational_math",
                      "sorting_algorithms",
                      "machine_learning",
                      "data_structures",
                      "programming_basics",
                      "popular_algorithms",
                      "database_systems",
                      "swe_fundamentals"
                    ]
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _hintController,
                    decoration: const InputDecoration(labelText: 'Hint'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a hint';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _answerController,
                    decoration: const InputDecoration(labelText: 'Answer'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the answer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _optionsController,
                    decoration: const InputDecoration(
                        labelText: 'Options (comma-separated)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the options';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addQuestionToFirestore,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addQuestionToFirestore() async {
    if (_questionFormKey.currentState?.validate() ?? false) {
      final question = {
        'title': _titleController.text,
        'category': _selectedCategory,
        'hint': _hintController.text,
        'answer': _answerController.text,
        'options':
            _optionsController.text.split(',').map((e) => e.trim()).toList(),
      };

      try {
        await FirebaseFirestore.instance.collection('questions').add(question);
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully')),
        );

        // Clear the form fields
        _titleController.clear();
        _hintController.clear();
        _answerController.clear();
        _optionsController.clear();
        setState(() {
          _selectedCategory = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding question: $e')),
        );
      }
    }
  }

  // Reusable Widgets (Dividers)
  Widget _buildHorizontalDivider(double horizontalPadding) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      child: const Divider(color: Colors.white38, thickness: 1.25),
    );
  }

  Widget _buildVerticalDivider(Color color) {
    return Container(height: double.infinity, width: 1, color: color);
  }

  // Renders stats section as an image
  Widget _statsSectionWrapper() {
    return _statsImage != null
        ? Image.memory(_statsImage!, fit: BoxFit.contain)
        : RepaintBoundary(key: _statsKey, child: _buildStatsSection());
  }

  // Placeholder for badges section
  Widget _buildBadgesSection() {
    return const Padding(padding: EdgeInsets.all(12.0));
  }

  // Builds the stats section: Joining date, Longest Streak, and other performance metrics
  Widget _buildStatsSection() {
    double statsSpacing = 12.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(statsSpacing),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 41, 41, 41),
              Color.fromARGB(255, 34, 34, 34),
              Color(0xff242424)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Member Since and Longest Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Member Since', 'Jan, 2022'),
                SizedBox(width: statsSpacing),
                _buildStatCard('Longest Streak', '124 Days',
                    isHighlighted: true),
              ],
            ),
            SizedBox(height: statsSpacing),

            // Performance Chart
            _buildPerformanceChart([
              {
                'label': 'Data Structures',
                'answered': 42,
                'total': 80,
                'color': const Color(0xffFFD6DD),
              },
              {
                'label': 'Time Complexity',
                'answered': 7,
                'total': 10,
                'color': const Color(0xffC4D0FB),
              },
              {
                'label': 'Search Algorithms',
                'answered': 3,
                'total': 15,
                'color': const Color(0xffA9ADF3),
              },
            ]),
          ],
        ),
      ),
    );
  }

  // Helper function for Stat Cards
  Widget _buildStatCard(String title, String value,
      {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: backgroundPageColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 5.0),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Poppins'),
                children: [
                  if (isHighlighted)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [accentPink, darkAccentPurple],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            value.split(' ').first,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Fallback color
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    TextSpan(
                      text: '${value.split(' ').first} ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  TextSpan(
                    text: value.split(' ').sublist(1).join(' '),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build the performance chart
  Widget _buildPerformanceChart(List<Map<String, dynamic>> topics) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundPageColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Flexible(
                child: Text(
                  'Top performance by category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                      color: const Color(0xff232323),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.0)),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.bar_chart_outlined,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
              alignment: WrapAlignment.start,
              spacing: 15.0,
              runSpacing: 10.0,
              children: topics.map((topic) {
                return _buildStatTopic(topic['color'], topic['label']);
              }).toList()),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end, // Align all bars to the bottom
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: topics.map((topic) {
              double percentage = (topic['answered'] / topic['total']) * 100;
              return _buildBar(
                topic['label'],
                topic['answered'],
                topic['total'],
                percentage,
                topic['color'],
              );
            }).toList(),
          ),
          _buildHorizontalDivider(50),
          const Text(
            'Questions Answered',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build individual bars
  Widget _buildBar(
      String label, int answered, int total, double percentage, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end, // Align bar at the bottom
      children: [
        const SizedBox(height: 50),
        Container(
          height:
              150.0 * (percentage / 100), // Height proportional to completion
          width: 40.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          '$answered/$total',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
      ],
    );
  }

  // Helper function to display the different stat topics in a list view
  Widget _buildStatTopic(Color colour, String topic) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
            color: colour, borderRadius: BorderRadius.circular(100)),
      ),
      const SizedBox(width: 10),
      Text(
        topic,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      )
    ]);
  }
}
