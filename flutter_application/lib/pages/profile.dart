import 'dart:ui';
import '../utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
  double avatarRadius = 55.0;
  final double expandedHeight = 135.0;

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
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        drawer: _buildLeftDrawer(),
        endDrawer: _buildRightDrawer(),
        body: CustomScrollView(
          slivers: [
            _buildUpperSection(),
            _buildLowerSection(),
          ],
        ),
      ),
    );
  }

  // Upper Section: App Bar and User Profile
  Widget _buildUpperSection() {
    return SliverStack(
      children: [
        SliverAppBar(
          automaticallyImplyLeading:
              false, // Hides hamburger button for left drawer
          actions: <Widget>[
            Container()
          ], // Hides hamburger button for right drawer
          expandedHeight: expandedHeight,
          pinned: false,
          elevation: 0.0,
          backgroundColor: backgroundPageColor,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: backgroundPageColor,
                    image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: AssetImage('assets/images/mesh_alt.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                _buildAppBarIcons(), // Icons for left and Right drawers
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: Transform.translate(
              offset: const Offset(0, 30),
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: backgroundPageColor,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: expandedHeight - avatarRadius - 20),
              _buildUserProfile(), // User Profile: Avatar, Full Name, Friend Count
              _buildHorizontalDivider(70),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarIcons() {
    return Positioned(
      top: 70.0,
      left: 33.0,
      right: 33.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: const Icon(
                Icons.people_outline_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: SvgPicture.asset(
                'assets/icons/profile/settings.svg',
                height: 23,
              ),
            ),
          ),
        ],
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
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundImage: const AssetImage('assets/images/avatar.jpg'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'pathnem',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Devansh Kapoor • 54 Friends',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Lower Section: Tabs and Content
  Widget _buildLowerSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _buildMainStatCards(), // Main Stats : Current Streak, Global Rank, and Total questions solved
          _buildHorizontalDivider(50),
          _buildTabs(), // Tabs : Stats, Badges
          const SizedBox(height: 10),
          _buildTabContent(),
          const SizedBox(height: 20),
          _buildExtraContent(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Main Stats : Current Streak, Global Rank, and Total questions solved
  Widget _buildMainStatCards() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 27.5),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff353535), Color(0xff242424)],
          stops: [0.1, 0.9],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainStatCard('STREAK', '15 Days', Icons.whatshot),
          _buildVerticalDivider(Colors.white),
          _buildMainStatCard('RANK', '#264', Icons.language),
          _buildVerticalDivider(Colors.white),
          _buildMainStatCard(
              'SOLVED', '56/800', Icons.check_circle_outline_outlined),
        ],
      ),
    );
  }

  // Column builder for each main stat
  Widget _buildMainStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 21),
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
      labelColor: Colors.purpleAccent[700],
      unselectedLabelColor: Colors.white54,
      dividerColor: Colors.transparent,
      indicatorColor: Colors.purpleAccent[700], // Optional: Indicator color
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

  // Placeholder
  Widget _buildExtraContent() {
    return Container(
      width: 350,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: buttonColor,
      ),
    );
  }

  // Drawers
  Widget _buildLeftDrawer() {
    return Drawer(
      backgroundColor: backgroundPageColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Heading
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Text(
              'Friends',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Friends List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                // Online Section
                const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ..._buildFriendList(['Alice', 'Bob', 'Charlie'], online: true),
                const SizedBox(height: 16.0),
                // Offline Section
                const Text(
                  'Offline',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ..._buildFriendList(['Dave', 'Eve'], online: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightDrawer() {
    return const Drawer(
      backgroundColor: backgroundPageColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Heading
          Padding(
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
          // Empty Content
          Expanded(
            child: Center(
              child: Text(
                'No settings available',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper: Build Friend List Items
  List<Widget> _buildFriendList(List<String> friends, {required bool online}) {
    return friends
        .map(
          (friend) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: online ? Colors.green : Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12.0),
                Text(
                  friend,
                  style: TextStyle(
                    color: online ? Colors.white : Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
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
          color: buttonColor, // Adjust based on your theme
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
                            colors: [
                              Colors.purpleAccent,
                              Colors.deepPurpleAccent
                            ],
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
                      color: buttonColor,
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
