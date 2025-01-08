import 'package:flutter/material.dart';
import 'package:flutter_application/utility/colors.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lBoardBackground,
      appBar: AppBar(
        backgroundColor: lBoardBackground,
        elevation: 0, // No shadow
        toolbarHeight: 0, // Minimal height
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 25, bottom: 0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Center(
                  child: Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tabs
                _buildTabs(),
                const SizedBox(height: 20),

                // Top 3 Players
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTopPlayer(
                          rank: 2,
                          avatar: 'assets/images/avatar.jpg',
                          username: 'user_2',
                          firstName: 'Alena',
                          points: 1469,
                        ),
                        _buildTopPlayer(
                          rank: 1,
                          avatar: 'assets/images/avatar.jpg',
                          username: 'user_1',
                          firstName: 'Davis',
                          points: 2569,
                          isHighlighted: true,
                        ),
                        _buildTopPlayer(
                          rank: 3,
                          avatar: 'assets/images/avatar.jpg',
                          username: 'user_3',
                          firstName: 'Craig',
                          points: 1053,
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 200,
                        child: Image.asset('assets/images/leaderboard.png'))
                  ],
                ),

                // Player List
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 5, top: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Rank
                              Text(
                                '${index + 4}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Avatar
                              const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/avatar.jpg'),
                                radius: 20,
                              ),
                              const SizedBox(width: 16),

                              // Player Info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Player ${index + 4}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '@username${index + 4}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              // Spacer for XP Alignment
                              const Spacer(),

                              // XP
                              Text(
                                '${1000 - (index * 50)} XP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build tabs
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: lBoardDarkAccent, // Dark purple background
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'All Time'),
          ],
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 14),
          unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
              fontSize: 14),
          labelColor: Colors.white, // Selected text color
          unselectedLabelColor:
              const Color.fromARGB(255, 181, 157, 242), // Background page color
          indicator: const ShapeDecoration(
            color: lBoardLightAccent, // Oval shape background color
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
        ),
      ),
    );
  }

  // Helper to build a pillar
  Widget _buildPillar({required double height}) {
    return Container(
      width: 80,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Helper to build top player
  Widget _buildTopPlayer({
    required int rank,
    required String avatar,
    required String username,
    required String firstName,
    required int points,
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(avatar),
          radius: 32,
        ),
        const SizedBox(height: 12),
        Text(
          firstName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHighlighted ? Colors.yellow : Colors.white,
          ),
        ),
        Text(
          '@$username',
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 149, 137, 209),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Text(
            '$points XP',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
