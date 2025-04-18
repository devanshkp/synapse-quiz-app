import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/services/friend_service.dart';
import 'package:flutter_application/widgets/profile/tabs/topics_section.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:flutter_application/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/widgets/profile/main_stats.dart';
import 'package:flutter_application/widgets/profile/tabs/stats_section.dart';
import 'package:flutter_application/widgets/profile/tabs/badges_section.dart';
import 'package:contentsize_tabbarview/contentsize_tabbarview.dart';

class OtherProfilePage extends StatefulWidget {
  final Friend friend;
  final UserProfile? preloadedProfile;

  const OtherProfilePage(
      {super.key, required this.friend, this.preloadedProfile});

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage>
    with SingleTickerProviderStateMixin {
  final FriendService _friendService = FriendService();
  UserProfile? _userProfile;
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
    if (widget.preloadedProfile != null) {
      _userProfile = widget.preloadedProfile;
      _isLoading = false;
    } else {
      _loadUserProfile();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Use UserProvider to fetch the profile
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profile =
          await userProvider.getUserProfileById(widget.friend.userId);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          debugPrint("Error loading profile: $e");
          floatingSnackBar(
              context: context, message: 'Couldn\'t load user\'s profile.');
        }
      }
    }
  }

  Future<void> _sendFriendRequest() async {
    if (_currentUserId == null) return;

    try {
      final result =
          await _friendService.sendFriendRequest(widget.friend.userId);

      if (result['success'] && mounted) {
        setState(() {
          _isPendingRequest = true;
        });
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context,
              message: result['error'] ??
                  'Couldn\'t send request. Please try again later');
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error sending friend request: $e");
        floatingSnackBar(
            context: context,
            message: 'Couldn\'t send request. Please try again later');
      }
    }
  }

  Future<void> _removeFriend() async {
    if (_currentUserId == null) return;

    try {
      final result = await _friendService.removeFriend(widget.friend.userId);

      if (result['success'] && mounted) {
        setState(() {
          _isFriend = false;
        });
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context,
              message: result['error'] ??
                  'Couldn\'t remove. Please try again later.');
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error removing friend: $e");
        floatingSnackBar(
            context: context,
            message: 'Couldn\'t remove. Please try again later.');
      }
    }
  }

  Future<void> _acceptFriendRequest() async {
    if (_currentUserId == null) return;

    try {
      final result =
          await _friendService.acceptFriendRequest(widget.friend.userId);

      if (result['success'] && mounted) {
        setState(() {
          _isIncomingRequest = false;
          _isFriend = true;
        });
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context,
              message: result['error'] ??
                  'Couldn\'t accept request. Please try again later.');
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            context: context,
            message: 'Couldn\'t accept request. Please try again later.');
      }
    }
  }

  Future<void> _cancelFriendRequest() async {
    if (_currentUserId == null) return;

    try {
      // For outgoing requests, we need to find and delete the request
      final result =
          await _friendService.withdrawFriendRequest(widget.friend.userId);

      if (result['success'] && mounted) {
        setState(() {
          _isPendingRequest = false;
        });
      } else {
        if (mounted) {
          debugPrint('No pending request found');
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            context: context,
            message: 'Couldn\'t withdraw  request. Please try again later.');
      }
    }
  }

  Future<void> _declineFriendRequest() async {
    if (_currentUserId == null) return;

    try {
      final result =
          await _friendService.declineFriendRequest(widget.friend.userId);

      if (result['success'] && mounted) {
        setState(() {
          _isIncomingRequest = false;
        });
      } else {
        if (mounted) {
          floatingSnackBar(
              context: context,
              message: result['error'] ??
                  'Couldn\'t decline. Please try again later.');
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error declining friend request: $e");
        floatingSnackBar(
            context: context,
            message: 'Couldn\'t decline. Please try again later.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final double extraPadding;
    if (screenWidth < 700) {
      extraPadding = screenWidth * 0.1;
    } else if (screenWidth < 850) {
      extraPadding = screenWidth * 0.15;
    } else if (screenWidth < 1000) {
      extraPadding = screenWidth * .2;
    } else {
      extraPadding = screenWidth * .25;
    }
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
      body: _isLoading
          ? const SizedBox.shrink()
          : _userProfile == null
              ? const Center(
                  child: Text('User profile not found',
                      style: TextStyle(color: Colors.white)))
              : Consumer<UserProvider>(builder: (context, userProvider, child) {
                  return Selector<
                      UserProvider,
                      ({
                        List<Friend> friends,
                        List<Friend> incomingRequests,
                        List<Friend> outgoingRequests,
                      })>(
                    selector: (_, provider) => (
                      friends: provider.friends,
                      incomingRequests: provider.incomingFriendRequests,
                      outgoingRequests: provider.outgoingFriendRequests,
                    ),
                    builder: (context, data, child) {
                      final isFriend = data.friends.any(
                          (friend) => friend.userId == widget.friend.userId);
                      final isIncomingRequest = data.incomingRequests.any(
                          (request) => request.userId == widget.friend.userId);
                      final isPendingRequest = data.outgoingRequests.any(
                          (request) => request.userId == widget.friend.userId);

                      _isFriend = isFriend;
                      _isPendingRequest = isPendingRequest;
                      _isIncomingRequest = isIncomingRequest;

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? extraPadding : 0),
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
                                              style: TextStyle(
                                                  color: Colors.white))),
                                  _userProfile != null
                                      ? BadgesSection(
                                          userProfile: _userProfile!)
                                      : const Center(
                                          child: Text('No badges available',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                  _userProfile != null
                                      ? TopicsSection(
                                          userProfile: _userProfile!)
                                      : const Center(
                                          child: Text('No topics available',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                ],
                              ),

                              // Bottom padding
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
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
        onPressed: () {
          _removeFriend();
          Navigator.pop(context);
        },
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
            border: Border.all(
                width: 1.5, color: Colors.white.withValues(alpha: 0.2)),
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

  Widget _buildFriendshipButton({bool empty = false}) {
    if (_currentUserId == null || empty) {
      return const SizedBox(
        height: 35,
      );
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
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: text,
      icon: icon,
      gradient: gradient,
      textColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.2),
      showBorder: true,
      onPressed: onTap ?? () {},
      width: width,
      height: 35,
      borderRadius: 10.0,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fullWidth: false,
    );
  }
}
