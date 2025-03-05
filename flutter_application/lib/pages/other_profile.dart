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
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/widgets/profile/main_stats.dart';
import 'package:flutter_application/widgets/profile/stats_section.dart';
import 'package:flutter_application/widgets/profile/badges_section.dart';
import 'package:contentsize_tabbarview/contentsize_tabbarview.dart';

class OtherProfilePage extends StatefulWidget {
  final Friend friend;

  const OtherProfilePage({super.key, required this.friend});

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage>
    with SingleTickerProviderStateMixin {
  final FriendService _friendService = FriendService();
  UserProfile? _userProfile;
  bool _isLoadingFriendshipStatus = true;
  bool _isLoading = true;
  bool _isFriend = false;
  bool _isPendingRequest = false;
  bool _isIncomingRequest = false;
  String? _currentUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadUserProfile();
    _checkFriendshipStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      setState(() {
        _isLoadingFriendshipStatus = true;
      });
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

      // Check if there's a pending outgoing request
      final outgoingRequest = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', isEqualTo: _currentUserId)
          .where('receiverId', isEqualTo: widget.friend.userId)
          .where('status', isEqualTo: 'pending')
          .get();

      // Check if there's a pending incoming request
      final incomingRequest = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', isEqualTo: widget.friend.userId)
          .where('receiverId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        _isFriend = friendsSnapshot1.docs.isNotEmpty ||
            friendsSnapshot2.docs.isNotEmpty;
        _isPendingRequest = outgoingRequest.docs.isNotEmpty;
        _isIncomingRequest = incomingRequest.docs.isNotEmpty;
        _isLoadingFriendshipStatus = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFriendshipStatus = false;
        });
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

  Future<void> _acceptFriendRequest() async {
    if (_currentUserId == null) return;

    try {
      final result =
          await _friendService.acceptFriendRequest(widget.friend.userId);

      if (result['success']) {
        setState(() {
          _isIncomingRequest = false;
          _isFriend = true;
        });
        if (mounted) {
          floatingSnackBar(
              context: context, message: 'Friend request accepted!');
        }
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context,
              message: result['error'] ?? 'Failed to accept friend request');
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            context: context, message: 'Error accepting friend request: $e');
      }
    }
  }

  Future<void> _cancelFriendRequest() async {
    if (_currentUserId == null) return;

    try {
      // For outgoing requests, we need to find and delete the request
      final result = await _friendService.withdrawFriendRequest(
          _currentUserId!, widget.friend.userId);

      if (result['success']) {
        setState(() {
          _isPendingRequest = false;
        });

        if (mounted) {
          floatingSnackBar(
              context: context, message: 'Friend request canceled');
        }
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context, message: 'No pending request found');
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            context: context, message: 'Error canceling friend request: $e');
      }
    }
  }

  Future<void> _declineFriendRequest() async {
    if (_currentUserId == null) return;

    try {
      final result =
          await _friendService.declineFriendRequest(widget.friend.userId);

      if (result['success']) {
        setState(() {
          _isIncomingRequest = false;
        });
        if (mounted) {
          floatingSnackBar(
              context: context, message: 'Friend request declined');
        }
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context,
              message: result['error'] ?? 'Failed to decline friend request');
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            context: context, message: 'Error declining friend request: $e');
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
      body: _isLoading || _isLoadingFriendshipStatus
          ? const Center(
              child: CustomCircularProgressIndicator(),
            )
          : _userProfile == null
              ? const Center(
                  child: Text('User profile not found',
                      style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Profile header section
                      const SizedBox(height: 20),
                      _buildUserHeader(),
                      const SizedBox(height: 15),

                      // Friendship button
                      _buildFriendshipButton(),
                      const SizedBox(height: 25),

                      // Main stats section
                      _buildMainStats(),
                      const SizedBox(height: 25),

                      // Tab bar
                      CustomTabBar(
                        controller: _tabController,
                        tabs: const ['Stats', 'Badges'],
                        horizontalPadding: 28,
                        tabHeight: 40,
                        indicatorPadding: const EdgeInsets.all(2),
                      ),
                      const SizedBox(height: 15),

                      // Tab content with responsive height
                      ContentSizeTabBarView(
                        controller: _tabController,
                        children: [
                          _userProfile != null
                              ? StatsSection(userProfile: _userProfile!)
                              : const Center(
                                  child: Text('No stats available',
                                      style: TextStyle(color: Colors.white))),
                          _userProfile != null
                              ? const BadgesSection()
                              : const Center(
                                  child: Text('No badges available',
                                      style: TextStyle(color: Colors.white))),
                        ],
                      ),

                      // Bottom padding
                      const SizedBox(height: 15),
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
        Text(
          widget.friend.fullName,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
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
        color: warningRed,
        onTap: _removeFriend,
      );
    } else if (_isPendingRequest) {
      return _FriendshipButton(
        text: 'Cancel Request',
        icon: Icons.cancel,
        color: const Color.fromARGB(255, 206, 127, 8),
        onTap: _cancelFriendRequest,
      );
    } else if (_isIncomingRequest) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FriendshipButton(
            text: 'Accept',
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: _acceptFriendRequest,
            width: 130,
          ),
          const SizedBox(width: 10),
          _FriendshipButton(
            text: 'Decline',
            icon: Icons.cancel,
            color: warningRed,
            onTap: _declineFriendRequest,
            width: 130,
          ),
        ],
      );
    } else {
      return _FriendshipButton(
        text: 'Add Friend',
        icon: Icons.person_add,
        color: const Color.fromARGB(255, 11, 145, 207),
        onTap: _sendFriendRequest,
      );
    }
  }

  Widget _buildMainStats() {
    if (_userProfile == null) return const SizedBox.shrink();

    return MainStats(
      userProfile: _userProfile!,
      totalQuestions:
          Provider.of<TriviaProvider>(context, listen: false).totalQuestions,
    );
  }
}

class _FriendshipButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double width;

  const _FriendshipButton({
    required this.text,
    required this.icon,
    required this.color,
    this.onTap,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: color,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
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
        // Glow Effect for Icon
        Icon(
          icon,
          color: Colors.white.withOpacity(0.95),
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
