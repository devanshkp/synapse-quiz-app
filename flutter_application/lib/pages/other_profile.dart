import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/services/friend_service.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/user_provider.dart';

class OtherProfilePage extends StatefulWidget {
  final Friend friend;

  const OtherProfilePage({super.key, required this.friend});

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> {
  final FriendService _friendService = FriendService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isFriend = false;
  bool _isPendingRequest = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadUserProfile();
    _checkFriendshipStatus();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use UserProvider to fetch the profile
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profile =
          await userProvider.getUserProfileById(widget.friend.userId);

      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        floatingSnackBar(
            context: context, message: 'Error loading user profile: $e');
      }
    }
  }

  Future<void> _checkFriendshipStatus() async {
    if (_currentUserId == null) return;

    try {
      // Check if they are already friends
      final friendsSnapshot1 = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId1', isEqualTo: _currentUserId)
          .where('userId2', isEqualTo: widget.friend.userId)
          .get();

      final friendsSnapshot2 = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId1', isEqualTo: widget.friend.userId)
          .where('userId2', isEqualTo: _currentUserId)
          .get();

      final isPending = await _friendService.isFriendRequestPending(
          _currentUserId!, widget.friend.userId);

      setState(() {
        _isFriend = friendsSnapshot1.docs.isNotEmpty ||
            friendsSnapshot2.docs.isNotEmpty;
        _isPendingRequest = isPending;
      });
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            context: context, message: 'Error checking friendship status: $e');
      }
    }
  }

  Future<void> _sendFriendRequest() async {
    if (_currentUserId == null) return;

    try {
      final result =
          await _friendService.sendFriendRequest(widget.friend.userId);

      if (result['success']) {
        setState(() {
          _isPendingRequest = true;
        });
        if (mounted) {
          floatingSnackBar(context: context, message: 'Friend request sent!');
        }
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context,
              message: result['error'] ?? 'Failed to send friend request');
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            context: context, message: 'Error sending friend request: $e');
      }
    }
  }

  Future<void> _removeFriend() async {
    if (_currentUserId == null) return;

    try {
      final result = await _friendService.removeFriend(widget.friend.userId);

      if (result['success']) {
        setState(() {
          _isFriend = false;
        });
        if (mounted) {
          floatingSnackBar(context: context, message: 'Friend removed');
        }
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context,
              message: result['error'] ?? 'Failed to remove friend');
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            context: context, message: 'Error removing friend: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPageColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.friend.userName,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(
                  child: Text('User profile not found',
                      style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildUserHeader(),
                      const SizedBox(height: 20),
                      _buildFriendshipButton(),
                      const SizedBox(height: 25),
                      _buildMainStats(),
                      const SizedBox(height: 20),
                      _buildStatsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserHeader() {
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
            child: AvatarImage(
              avatarUrl: widget.friend.avatarUrl,
              avatarRadius: 55,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.friend.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        StreamBuilder<int>(
          stream: _friendService.getFriendCountStream(widget.friend.userId),
          builder: (context, snapshot) {
            final friendCount = snapshot.data ?? 0;

            return RichText(
              text: TextSpan(
                text: '${widget.friend.fullName} • ',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
                children: [
                  TextSpan(
                    text: '$friendCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(
                    text: ' Friends',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFriendshipButton() {
    if (_currentUserId == null) {
      return const SizedBox.shrink();
    }

    if (_isFriend) {
      return _FriendshipButton(
        text: 'Remove Friend',
        icon: Icons.person_remove,
        gradientColors: const [
          Color(0xFFE53935),
          Color.fromARGB(255, 114, 19, 19)
        ],
        onTap: _removeFriend,
      );
    } else if (_isPendingRequest) {
      return const _FriendshipButton(
        text: 'Request Pending',
        icon: Icons.pending,
        gradientColors: [Color(0xFFFF9800), Color(0xFFE65100)],
        isDisabled: true,
      );
    } else {
      return _FriendshipButton(
        text: 'Add Friend',
        icon: Icons.person_add,
        gradientColors: const [Color(0xFF42A5F5), Color(0xFF1565C0)],
        onTap: _sendFriendRequest,
      );
    }
  }

  Widget _buildMainStats() {
    if (_userProfile == null) return const SizedBox.shrink();

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
            'STREAK',
            '${_userProfile!.currentStreak} ${_userProfile!.currentStreak == 1 ? 'day' : 'days'}',
            Icons.whatshot,
            currentStreakColor,
          ),
          const CustomVerticalDivider(),
          _buildMainStatCard('RANK', '#264', Icons.language, globalRankColor),
          const CustomVerticalDivider(),
          _buildMainStatCard(
            'SOLVED',
            '${_userProfile!.questionsSolved}/100',
            Icons.check_circle,
            solvedQuestionsColor,
          ),
        ],
      ),
    );
  }

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
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
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

  Widget _buildStatsSection() {
    if (_userProfile == null) return const SizedBox.shrink();

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
                _buildStatCard(
                  'Longest Streak',
                  '${_userProfile!.maxStreak} ${_userProfile!.maxStreak == 1 ? 'Day' : 'Days'}',
                  isHighlighted: true,
                ),
              ],
            ),
            SizedBox(height: statsSpacing),

            // Performance Chart (simplified for other users)
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
                            colors: [lightPurpleAccent, darkPurpleAccent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            value.split(' ').first,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    TextSpan(
                      text: '${value.split(' ').first} ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  TextSpan(
                    text: value.split(' ').sublist(1).join(' '),
                    style: const TextStyle(
                      fontSize: 20,
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
                  'Top performance by topic',
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
            crossAxisAlignment: CrossAxisAlignment.end,
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
          const CustomHorizontalDivider(padding: 50),
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

  Widget _buildStatTopic(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBar(
      String label, int answered, int total, double percentage, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 50),
        Container(
          height: 150.0 * (percentage / 100),
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
}

class _FriendshipButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _FriendshipButton({
    required this.text,
    required this.icon,
    required this.gradientColors,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: isDisabled
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildButtonContent(),
              )
            : InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildButtonContent(),
                ),
              ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 13,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
