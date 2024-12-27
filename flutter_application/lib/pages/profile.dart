import 'package:flutter/material.dart';
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
  double avatarTopOffset = 65.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: backgroundPageColor));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStack(children: [
            SliverAppBar(
                expandedHeight: 105.0,
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
                      top:
                          75.0, // Adjust this value to position the Row lower
                      left: 30.0,
                      right: 30.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                              height: 25,
                              'assets/icons/profile/add_friend.svg'),
                          SvgPicture.asset(
                              height: 25,
                              'assets/icons/profile/settings.svg'),
                        ],
                      ),
                    ),
                  ]),
                ),
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0.0),
                    child: Transform.translate(
                      offset: const Offset(0, 40),
                      child: Container(
                          height: 50,
                          decoration: const BoxDecoration(
                              color: backgroundPageColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)))),
                    ))),
            
            // Scrollable Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 75),
                  userProfile(),
                  _buildHorizontalDivider(
                      70), // Placeholder for the avatar overlap
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
                        _buildStatCard(
                            'STREAK', '15 Days', Icons.whatshot),
                        _buildVerticalDivider(),
                        _buildStatCard('RANK', '#264', Icons.language),
                        _buildVerticalDivider(),
                        _buildStatCard(
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
                      _buildTab('Rankings', false),
                      _buildTab('Stats', true),
                      _buildTab('Friends', false),
                    ],
                  ),
                  const SizedBox(height: 20),
            
                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Member Since',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Jan, 2022',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Longest Streak',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '124 Days',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
            
                        // Placeholder for a chart or additional information
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Top Performance by Category (Chart Placeholder)',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Top Performance by Category (Chart Placeholder)',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Top Performance by Category (Chart Placeholder)',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ])
          // Gradient Background
        ],
      ),
    );
  }

  Positioned userProfile() {
    return Positioned(
      top: avatarTopOffset,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: 1.0, // Fade out when off-screen
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
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
                text: 'Devansh Kapoor • ', // First part of the text
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                children: [
                  TextSpan(
                    text: '54', // The number of friends
                    style: TextStyle(
                      color: Colors.white, // Different color for the number
                      fontWeight: FontWeight.bold, // Bold font for emphasis
                    ),
                  ),
                  TextSpan(
                    text: ' Friends', // Remaining part of the text
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
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
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
}
