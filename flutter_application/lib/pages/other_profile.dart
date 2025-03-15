import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/services/friend_service.dart';
import 'package:flutter_application/widgets/profile/tabs/topics_section.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/widgets/profile/main_stats.dart';
import 'package:flutter_application/widgets/profile/tabs/stats_section.dart';
import 'package:flutter_application/widgets/profile/tabs/badges_section.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
        centerTitle: true,
        title: Text(
          widget.friend.userName,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(
            color: Colors.white12,
            height: 1,
          ),
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
                        tabs: const ['Stats', 'Badges', 'Topics'],
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
                              ? BadgesSection(userProfile: _userProfile!)
                              : const Center(
                                  child: Text('No badges available',
                                      style: TextStyle(color: Colors.white))),
                          _userProfile != null
                              ? TopicsSection(userProfile: _userProfile!)
                              : const Center(
                                  child: Text('No topics available',
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

  Future<void> _showRemoveFriendConfirmation(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Remove Friend',
        content: 'Are you sure you want to remove this friend?',
        confirmationButtonText: 'Remove',
        cancelButtonText: 'Cancel',
        onPressed: () => _removeFriend(),
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
            child: UserAvatar(
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
      return FriendshipButton(
        text: 'Remove',
        icon: Icons.person_remove,
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 198, 74, 65),
            warningRed,
            Color.fromARGB(255, 160, 37, 28),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => _showRemoveFriendConfirmation(context),
      );
    } else if (_isPendingRequest) {
      return FriendshipButton(
        text: 'Cancel',
        icon: Icons.cancel,
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 227, 146, 24),
            Color.fromARGB(255, 206, 127, 8),
            Color.fromARGB(255, 184, 110, 0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: _cancelFriendRequest,
      );
    } else if (_isIncomingRequest) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FriendshipButton(
            text: 'Accept',
            icon: Icons.check_circle,
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 98, 207, 102),
                Colors.green,
                Color.fromARGB(255, 56, 143, 59),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: _acceptFriendRequest,
            width: 130,
          ),
          const SizedBox(width: 10),
          FriendshipButton(
            text: 'Decline',
            icon: Icons.cancel,
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 198, 74, 65),
                warningRed,
                Color.fromARGB(255, 148, 30, 22),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: _declineFriendRequest,
            width: 130,
          ),
        ],
      );
    } else {
      return FriendshipButton(
        text: 'Request',
        icon: Icons.person_add,
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 28, 154, 212),
            Color.fromARGB(255, 11, 145, 207),
            Color.fromARGB(255, 6, 127, 183),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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

class FriendshipButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final double width;

  const FriendshipButton({
    super.key,
    required this.text,
    required this.icon,
    required this.gradient,
    this.onTap,
    this.width = 170,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: text,
      icon: icon,
      gradient: gradient,
      textColor: Colors.white,
      borderColor: Colors.white.withOpacity(0.3),
      onPressed: onTap ?? () {},
      width: width,
      height: 40,
      borderRadius: 10.0,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      fontSize: 13,
      fontWeight: FontWeight.w500,
      fullWidth: false,
    );
  }
}
