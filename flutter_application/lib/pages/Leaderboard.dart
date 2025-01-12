import 'package:flutter/material.dart';
import 'package:flutter_application/utility/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

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
      body: Stack(children: [
        // Container(
        //     decoration: const BoxDecoration(
        //         image: DecorationImage(
        //             image: AssetImage('assets/images/mesh.png'),
        //             fit: BoxFit.cover))),
        // Positioned.fill(
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(
        //         sigmaX: 10.0, sigmaY: 10.0), // Adjust blur intensity
        //     child: Container(
        //       color:
        //           Colors.black.withOpacity(0.3), // Optional: Add overlay color
        //     ),
        //   ),
        // ),
        Padding(
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
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tabs
                  _buildTabs(),
                  const SizedBox(height: 10),

                  // Top 3 Players
                  _buildTopPlayersPodium(),

                  // Player List
                  _buildPlayerList(),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Expanded _buildPlayerList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8, top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              decoration: BoxDecoration(
                boxShadow: [buttonDropShadow],
                color: const Color.fromARGB(255, 68, 40, 117),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Rank
                  Text(
                    '${index + 4}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Avatar
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.jpg'),
                    radius: 28,
                  ),
                  const SizedBox(width: 16),

                  // Player Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Player ${index + 4}',
                        style: const TextStyle(
                          fontSize: 16,
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
    );
  }

  Stack _buildTopPlayersPodium() {
    return Stack(alignment: Alignment.bottomCenter, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTopPlayer(
            rank: 2,
            avatar: 'assets/images/avatar.jpg',
            username: 'user_2',
            firstName: 'Alena',
            points: 1469,
          ),
          const SizedBox(width: 95),
          _buildTopPlayer(
            rank: 3,
            avatar: 'assets/images/avatar.jpg',
            username: 'user_3',
            firstName: 'Craig',
            points: 1053,
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: _buildTopPlayer(
          rank: 1,
          avatar: 'assets/images/avatar.jpg',
          username: 'user_1',
          firstName: 'Davis',
          points: 2569,
          isHighlighted: true,
        ),
      ),
    ]);
  }

  // Helper to build tabs
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
            fontWeight: FontWeight.normal, fontFamily: 'Poppins', fontSize: 14),
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
        Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        (rank == 1)
            ? Column(
                children: [
                  const SizedBox(height: 5),
                  SvgPicture.asset('assets/icons/crown.svg', height: 40),
                ],
              )
            : const SizedBox(),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                width: (rank == 1) ? 4 : 3, color: lBoardLightAccent),
            boxShadow: (rank == 1)
                ? [
                    BoxShadow(
                      color: lBoardLightAccent.withOpacity(0.8), // Glow color
                      spreadRadius: 5, // Spread of the glow
                      blurRadius: 20, // Blur effect of the glow
                    ),
                  ]
                : null,
          ),
          child: CircleAvatar(
            backgroundImage: AssetImage(avatar),
            radius: (rank == 1) ? 65 : 50,
          ),
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
        Text(
          '$points XP',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: lBoardLightAccent,
          ),
        ),
      ],
    );
  }
}
