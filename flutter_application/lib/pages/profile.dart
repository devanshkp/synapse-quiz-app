import 'package:flutter/material.dart';
import 'package:flutter_application/utility/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double avatarTopOffset = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              // Adjust avatar's position based on scroll offset
              avatarTopOffset = (100 - scrollNotification.metrics.pixels)
                  .clamp(-100.0, 100.0);
            });
          }
          return true;
        },
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Gradient Background
                SliverAppBar(
                  expandedHeight: 125.0,
                  pinned: true,
                  backgroundColor: backgroundPageColor,
                  surfaceTintColor: Colors.transparent, 
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        color: backgroundPageColor,
                        image: DecorationImage(
                          image: AssetImage('assets/images/mesh.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                // Scrollable Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 110),
                      _buildHorizontalDivider(
                          70), // Placeholder for the avatar overlap
                      Container(
                        height: MediaQuery.of(context).size.height * 0.135,
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff353535), Color(0xff242424)],
                            stops: [0.1, 0.9],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard('STREAK', '15 Days', Icons.whatshot),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),

            // Avatar and User Details
            Positioned(
              top: avatarTopOffset,
              left: 0,
              right: 0,
              child: const Opacity(
                opacity: 1.0, // Fade out when off-screen
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/avatar.jpg'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'pathnem',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Devansh Kapoor • 54 Friends',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 7.5),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
