import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        color: backgroundPageColor,
        image: DecorationImage(
          image: AssetImage('assets/images/shapes.png'),
          opacity: 0.2,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: const Center(
          child: Text(
        "Coming soon!",
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white),
      )),
    ));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundPageColor,
        scrolledUnderElevation: 0.0,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(15),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 18),
              child: const Column(
                children: [
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 21,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  CustomTabBar(
                    tabs: const ['Weekly', 'Monthly', 'All time'],
                    controller: _tabController,
                    horizontalPadding: 10,
                  ),
                  const SizedBox(height: 35),
                  _buildTopPlayersPodium(),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Next in Line',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  )
                ],
              ),
            );
          } else {
            return _buildPlayerTile(index - 1);
          }
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 44, 44, 44)),
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'All Time'),
          ],
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14),
          unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
              fontSize: 14),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          labelColor: Colors.black, // Selected text color
          unselectedLabelColor: Colors.white70, // Background page color
          indicator: BoxDecoration(
              boxShadow: [buttonDropShadow],
              color: Colors.white, // Oval shape background color
              borderRadius: const BorderRadius.all(Radius.circular(18))),
        ),
      ),
    );
  }

  Widget _buildPlayerTile(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank number
          SizedBox(
            width: 15, // Fixed width to prevent shifting
            child: Text(
              '${index + 4}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Main container
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                boxShadow: [buttonDropShadow],
                gradient: buttonGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  // Avatar
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.jpg'),
                    radius: 24,
                  ),
                  const SizedBox(width: 16),

                  // Player Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Player ${index + 4}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'username${index + 4}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // XP
                  Text(
                    '${1000 - (index * 50)} XP',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 167, 120, 239),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayersPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTopPlayer(
          rank: 2,
          avatar: 'assets/images/avatar.jpg',
          username: 'user_2',
          firstName: 'Davis Brown',
          points: 1469,
        ),
        const SizedBox(width: 15),
        Column(
          children: [
            _buildTopPlayer(
              rank: 1,
              avatar: 'assets/images/avatar.jpg',
              username: 'user_1',
              firstName: 'Alena Johnson',
              points: 2569,
              isHighlighted: true,
            ),
          ],
        ),
        const SizedBox(width: 15),
        _buildTopPlayer(
          rank: 3,
          avatar: 'assets/images/avatar.jpg',
          username: 'user_3',
          firstName: 'Craig David',
          points: 1053,
        ),
      ],
    );
  }

  Widget _buildTopPlayer({
    required int rank,
    required String avatar,
    required String username,
    required String firstName,
    required int points,
    bool isHighlighted = false,
  }) {
    List<Color> rankColors = [
      goldColor,
      silverColor,
      bronzeColor,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          firstName,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 7.5),
        Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                width: (rank == 1) ? 2.75 : 2,
                color: rankColors[rank - 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: rankColors[rank - 1]
                      .withOpacity((rank == 1) ? 0.3 : 0.2), // Glow color
                  spreadRadius: 3,
                  blurRadius: (rank == 1) ? 15 : 10,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage(avatar),
              radius: (rank == 1) ? 65 : 45,
            ),
          ),
          Positioned(
            bottom: -20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rankColors[rank - 1],
              ),
              child: Text('$rank'),
            ),
          ),
        ]),
        const SizedBox(height: 15),
        Text(
          '$points',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          username,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
