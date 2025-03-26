import 'package:contentsize_tabbarview/contentsize_tabbarview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/utils/profile_navigator.dart';

import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

enum SortOption {
  questionsSolved,
  accuracy,
}

class LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SortOption _sortOption = SortOption.questionsSolved;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize friends list if empty
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Future.microtask(() {
      if (userProvider.friends.isEmpty) {
        userProvider.fetchFriendsList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeSort(SortOption option) {
    if (mounted) {
      setState(() {
        _sortOption = option;
      });
    }
  }

  double getSafeAccuracy(double accuracy) {
    return accuracy.isNaN ? 0.0 : accuracy;
  }

  String formattedAccuracy0(double accuracy) {
    final String formattedAccuracy = accuracy.toStringAsFixed(2);
    // Remove trailing zeros after decimal point
    return formattedAccuracy.endsWith('.00')
        ? formattedAccuracy.substring(0, formattedAccuracy.length - 3)
        : formattedAccuracy
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
  }

  String getSortText() {
    switch (_sortOption) {
      case SortOption.questionsSolved:
        return 'Questions solved';
      case SortOption.accuracy:
        return 'Accuracy';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    double extraPadding = 0;
    if (screenWidth < 800) {
      extraPadding = screenWidth * 0.05;
    } else if (screenWidth < 850) {
      extraPadding = screenWidth * 0.1;
    } else if (screenWidth < 1000) {
      extraPadding = screenWidth * .125;
    } else {
      extraPadding = screenWidth * .15;
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 15),
            // Tab bar with gradient background
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isTablet ? extraPadding : 0),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: CustomTabBar(
                  controller: _tabController,
                  tabs: const ['Friends', 'Global'],
                  horizontalPadding: 4,
                  tabHeight: 40,
                  indicatorPadding: const EdgeInsets.all(2),
                ),
              ),
            ),
            // Content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: (_tabController.index == 0)
                    ? () => userProvider.fetchFriendsList()
                    : () => Future.value(),
                backgroundColor: const Color.fromARGB(255, 58, 58, 58),
                color: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ContentSizeTabBarView(
                    controller: _tabController,
                    children: [
                      buildFriendsLeaderboard(isTablet, extraPadding),
                      buildGlobalLeaderboard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundPageColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main header content with icon and text
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFE6C770),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'See who\'s on top!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom divider line
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGlobalLeaderboard() {
    return const SizedBox(
      height: 300,
      width: double.infinity,
      child: Center(
        child: Text(
          "Coming Soon",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildFriendsLeaderboard(bool isTablet, extraPadding) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final friends = List<Friend>.from(userProvider.friends);
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        // Create combined list with friends and current user
        final List<LeaderboardEntry> leaderboardEntries = [];

        // Add friends to the leaderboard
        for (final friend in friends) {
          leaderboardEntries.add(
            LeaderboardEntry(
              friend: friend,
              isCurrentUser: friend.userId == currentUserId,
            ),
          );
        }

        // Add current user if they're not already in the list
        if (userProvider.userProfile != null &&
            !leaderboardEntries.any((entry) => entry.isCurrentUser)) {
          final userProfile = userProvider.userProfile!;
          leaderboardEntries.add(
            LeaderboardEntry(
              friend: Friend(
                userId: currentUserId!,
                userName: userProfile.userName,
                fullName: userProfile.fullName,
                avatarUrl: userProfile.avatarUrl,
                questionsSolved: userProfile.questionsSolved,
                accuracy: userProfile.accuracy,
              ),
              isCurrentUser: true,
            ),
          );
        }

        // Sort based on selected sort option
        if (_sortOption == SortOption.questionsSolved) {
          leaderboardEntries.sort((a, b) =>
              b.friend.questionsSolved.compareTo(a.friend.questionsSolved));
        } else {
          leaderboardEntries.sort((a, b) {
            final accuracyA = getSafeAccuracy(a.friend.accuracy);
            final accuracyB = getSafeAccuracy(b.friend.accuracy);
            return accuracyB.compareTo(accuracyA);
          });
        }

        if (leaderboardEntries.isEmpty) {
          return buildEmptyState();
        }

        // Assign ranks
        for (int i = 0; i < leaderboardEntries.length; i++) {
          leaderboardEntries[i].rank = i + 1;
        }

        // Split entries into top 3 and others
        final topEntries = leaderboardEntries.length >= 3
            ? leaderboardEntries.sublist(0, 3)
            : leaderboardEntries;

        final remainingEntries = leaderboardEntries.length > 3
            ? leaderboardEntries.sublist(3)
            : <LeaderboardEntry>[];

        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: isTablet ? extraPadding : 0),
          child: Column(
            children: [
              buildTopRankings(topEntries),
              buildOtherPlayers(remainingEntries),
            ],
          ),
        );
      },
    );
  }

  Widget buildTopRankings(List<LeaderboardEntry> topEntries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Simple title with icon
              const Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: Color(0xFFE6C770),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Top Rankings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Right: Sort dropdown button
              PopupMenuButton<SortOption>(
                onSelected: _changeSort,
                offset: const Offset(0, 40),
                color: const Color.fromARGB(255, 31, 31, 31),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<SortOption>(
                    value: SortOption.questionsSolved,
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: _sortOption == SortOption.questionsSolved
                              ? Theme.of(context).primaryColor
                              : Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Questions solved',
                          style: TextStyle(
                            color: _sortOption == SortOption.questionsSolved
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            fontWeight:
                                _sortOption == SortOption.questionsSolved
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<SortOption>(
                    value: SortOption.accuracy,
                    child: Row(
                      children: [
                        Icon(
                          Icons.percent,
                          color: _sortOption == SortOption.accuracy
                              ? Theme.of(context).primaryColor
                              : Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Accuracy',
                          style: TextStyle(
                            color: _sortOption == SortOption.accuracy
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            fontWeight: _sortOption == SortOption.accuracy
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 23, 23, 23)
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Text(
                        getSortText(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Cards section with padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (topEntries.isNotEmpty)
                Column(
                  children: [
                    for (int i = 0; i < topEntries.length && i < 3; i++)
                      buildRankCard(topEntries[i], i + 1, _sortOption),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildOtherPlayers(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title section
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Text(
            'Other Players',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // List section
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: entries.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final rank = entry.rank;
            return buildRankCard(entry, rank, _sortOption);
          },
        ),
      ],
    );
  }

  Widget buildRankCard(
      LeaderboardEntry entry, int rank, SortOption sortOption) {
    final friend = entry.friend;
    final isCurrentUser = entry.isCurrentUser;

    // Metallic colors and lustrous effects
    LinearGradient cardGradient;
    Color baseColor;
    Color highlightColor;
    Color accentColor;
    Color borderColor;

    switch (rank) {
      case 1:
        // Gold - warm, rich gold with subtle lustre
        baseColor = const Color(0xFFAD8A56); // Muted gold base
        highlightColor = const Color(0xFFD4AF37); // Brighter gold highlight
        accentColor = const Color(0xFFFFD700); // Pure gold accent
        borderColor = const Color(0xFFE6C770);
        cardGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.6, 0.9],
          colors: [
            baseColor.withValues(alpha: 0.8),
            highlightColor.withValues(alpha: 0.5),
            baseColor.withValues(alpha: 0.7),
            baseColor.withValues(alpha: 0.9),
          ],
        );
        break;
      case 2:
        // Silver - cool, polished silver with subtle lustre
        baseColor = const Color(0xFFADB3B8); // Muted silver base
        highlightColor = const Color(0xFFD8D8D8); // Brighter silver highlight
        accentColor = const Color(0xFFE8E8E8); // Pure silver accent
        borderColor = const Color(0xFFC0C0C0);
        cardGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.6, 0.9],
          colors: [
            baseColor.withValues(alpha: 0.8),
            highlightColor.withValues(alpha: 0.5),
            baseColor.withValues(alpha: 0.7),
            baseColor.withValues(alpha: 0.9),
          ],
        );
        break;
      case 3:
        // Bronze - warm, polished bronze with subtle lustre
        baseColor = const Color(0xFF9C7A50); // Muted bronze base
        highlightColor = const Color(0xFFCD7F32); // Brighter bronze highlight
        accentColor =
            const Color.fromARGB(255, 201, 158, 93); // Pure bronze accent
        borderColor = const Color(0xFFB08D57);
        cardGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.6, 0.9],
          colors: [
            baseColor.withValues(alpha: 0.8),
            highlightColor.withValues(alpha: 0.5),
            baseColor.withValues(alpha: 0.7),
            baseColor.withValues(alpha: 0.9),
          ],
        );
        break;
      default:
        accentColor = const Color.fromARGB(255, 90, 90, 90);
        baseColor = isCurrentUser
            ? const Color.fromARGB(255, 48, 50, 54)
            : const Color(0xFF2D2D2D);
        borderColor = isCurrentUser
            ? const Color.fromARGB(255, 126, 126, 126)
            : accentColor.withValues(alpha: 0.15);
        highlightColor = baseColor;
        cardGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: 0.8),
            highlightColor,
            baseColor.withValues(alpha: 0.9),
          ],
        );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (rank <= 3)
            BoxShadow(
              color: baseColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
        border: Border.all(
          color: borderColor.withValues(alpha: isCurrentUser ? 1.0 : 0.7),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isCurrentUser
              ? null
              : () => ProfileNavigator.navigateToProfile(
                    context: context,
                    friend: friend,
                  ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Rank number with metallic effect
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.3),
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Avatar
                UserAvatar(
                  avatarUrl: friend.avatarUrl,
                  avatarRadius: 18,
                ),

                const SizedBox(width: 14),

                // User info - Name and Username
                Expanded(
                  child: isCurrentUser
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCurrentUser ? 'You' : friend.fullName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isCurrentUser
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${friend.userName}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),

                // Stats container
                if (_sortOption == SortOption.questionsSolved) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.2),
                          blurRadius: 2,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: accentColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${friend.questionsSolved}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Accuracy with metallic effect
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.2),
                          blurRadius: 2,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.precision_manufacturing_outlined,
                          color: accentColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${formattedAccuracy0(getSafeAccuracy(friend.accuracy))}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_outlined,
                size: 48,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Friends Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This leaderboard shows only your friends',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to friends page or open friends drawer
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Add Friends'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to track entries in the leaderboard
class LeaderboardEntry {
  final Friend friend;
  final bool isCurrentUser;
  int rank = 0;

  LeaderboardEntry({
    required this.friend,
    required this.isCurrentUser,
  });
}
