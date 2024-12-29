import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/utility/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey _statsKey =
      GlobalKey(); // Key for capturing the stats section
  Uint8List? _statsImage; // Stores the captured stats section as an image

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureStatsSection(); // Capture stats section after the page is built
    });
  }

  Future<void> _captureStatsSection() async {
    try {
      final boundary = _statsKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(
            pixelRatio: 5.0); // Higher pixel ratio for better quality
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
        const SystemUiOverlayStyle(statusBarColor: backgroundPageColor));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStack(children: [
            SliverAppBar(
                expandedHeight: 110.0,
                pinned: false,
                elevation: 0.0,
                backgroundColor: backgroundPageColor,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(children: [
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
                    Positioned(
                      top: 70.0,
                      left: 33.0,
                      right: 33.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                              height: 23,
                              'assets/icons/profile/add_friend.svg'),
                          SvgPicture.asset(
                              height: 23, 'assets/icons/profile/settings.svg'),
                        ],
                      ),
                    ),
                  ]),
                ),
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0.0),
                    child: Transform.translate(
                      offset: const Offset(0, 30),
                      child: Container(
                          height: 50,
                          decoration: const BoxDecoration(
                              color: backgroundPageColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)))),
                    ))),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 65),
                  userProfile(),
                  _buildHorizontalDivider(70),
                  Container(
                    height: 105,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildMainStatCard('STREAK', '15 Days', Icons.whatshot),
                        _buildVerticalDivider(),
                        _buildMainStatCard('RANK', '#264', Icons.language),
                        _buildVerticalDivider(),
                        _buildMainStatCard(
                            'SOLVED', '56/800', Icons.check_circle),
                      ],
                    ),
                  ),
                  _buildHorizontalDivider(50),
                  const SizedBox(height: 10),

                  // Tabs Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTab('Stats', true),
                      _buildTab('Badges', false),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats Section as Image
                  _statsSectionWrapper(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget userProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border:
                  Border.all(width: 3, color: Colors.white.withOpacity(0.5))),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
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
        RichText(
          text: const TextSpan(
            text: 'Devansh Kapoor • ',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
            children: [
              TextSpan(
                text: '54',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
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

  Widget _statsSectionWrapper() {
    return _statsImage != null
        ? Image.memory(
            _statsImage!,
            fit: BoxFit.contain,
          )
        : RepaintBoundary(
            key: _statsKey,
            child: _buildStatsSection(),
          );
  }

  Widget _buildMainStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 23),
        const SizedBox(height: 7.5),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2.5),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.purpleAccent : Colors.white70,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        if (isActive)
          Container(
            height: 2,
            width: 20,
            color: Colors.purpleAccent,
          ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: double.infinity,
      width: 1,
      color: Colors.white54,
    );
  }

  Widget _buildHorizontalDivider(double horizontalPadding) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      child: const Divider(
        color: Colors.white38,
        thickness: 1.25,
      ),
    );
  }

  Widget _buildBadgesSection() {
    return const Padding(
      padding: EdgeInsets.all(12.0),
    );
  }

  Widget _buildStatsSection() {
    double statsSpacing = 12.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                _buildStatCardItem('Member Since', 'Jan, 2022'),
                SizedBox(width: statsSpacing),
                _buildStatCardItem('Longest Streak', '124 Days',
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
                'color': Colors.pinkAccent,
              },
              {
                'label': 'Time Complexity',
                'answered': 7,
                'total': 10,
                'color': Colors.lightBlueAccent,
              },
              {
                'label': 'Search Algorithms',
                'answered': 3,
                'total': 15,
                'color': Colors.purpleAccent,
              },
            ]),
          ],
        ),
      ),
    );
  }

  // Helper function for Stat Cards
  Widget _buildStatCardItem(String title, String value,
      {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
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
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: TextStyle(
                color: isHighlighted ? Colors.purpleAccent : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundPageColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  'Top performance by category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),
              Icon(Icons.bar_chart, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 15),
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
          const SizedBox(height: 10),
          const Text(
            'Questions Answered',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
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

  Widget _buildStatTopic(Color colour, String topic) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: colour, borderRadius: BorderRadius.circular(100)),
      ),
      const SizedBox(width: 10),
      Text(
        topic,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      )
    ]);
  }
}
