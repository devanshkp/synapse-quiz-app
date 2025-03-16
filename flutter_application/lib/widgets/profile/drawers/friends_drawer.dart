// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/services/friend_service.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/pages/other_profile.dart';

class FriendsDrawer extends StatefulWidget {
  const FriendsDrawer({super.key});

  @override
  State<FriendsDrawer> createState() => _FriendsDrawerState();
}

class _FriendsDrawerState extends State<FriendsDrawer> {
  final FriendService _friendService = FriendService();
  List<Friend> searchResults = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _initializeFriends();
  }

  void _initializeFriends() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.friends.isEmpty) {
      userProvider.fetchFriendsList();
    }
    if (userProvider.friendRequests.isEmpty) {
      userProvider.fetchFriendRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: const BoxDecoration(color: backgroundPageColor),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(
                  child: _buildContent(userProvider.friends),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
          if (userProvider.friendRequests.isNotEmpty) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue[200],
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${userProvider.friendRequests.length} new',
                    style: TextStyle(
                      color: Colors.blue[200],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black45,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search or add friend...',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              suffixIcon: Icon(Icons.search,
                  color: Colors.black.withOpacity(0.5), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (query) {
              if (query.isEmpty) {
                setState(() {
                  searchResults = [];
                });
              } else if (query.length >= 2) {
                _searchUsers(query);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Friend> friends) {
    if (searchResults.isNotEmpty) {
      return _buildSearchResults(friends);
    }
    return _buildFriendsList(friends);
  }

  Widget _buildSearchResults(List<Friend> friends) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: searchResults.length,
      itemExtent: 80, // Fixed height for better performance
      itemBuilder: (context, index) {
        final friend = searchResults[index];
        return _buildSearchResultCard(friend, friends);
      },
    );
  }

  Widget _buildFriendsList(List<Friend> friends) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final friendRequests = userProvider.friendRequests;
    // Calculate total items: section headers + friend requests + divider (if requests exist) + all friends
    final int totalItems = 1 + // "All Friends" header
        (friendRequests.isNotEmpty
            ? 1 + friendRequests.length + 1
            : 0) + // "Friend Requests" header + requests + divider
        (friends.isEmpty ? 1 : friends.length); // Empty state or friends list

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        int currentIndex = 0;

        // Friend Requests Section
        if (friendRequests.isNotEmpty) {
          // Friend Requests Header
          if (index == currentIndex) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Friend Requests', friendRequests.length,
                    isRequest: true),
                const SizedBox(height: 12),
              ],
            );
          }
          currentIndex++;

          // Friend Request Items
          if (index < currentIndex + friendRequests.length) {
            final requestIndex = index - currentIndex;
            final request = friendRequests[requestIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: _buildFriendRequestCard(request),
            );
          }
          currentIndex += friendRequests.length;

          // Divider
          if (index == currentIndex) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.white24, height: 16),
            );
          }
          currentIndex++;
        }

        // All Friends Header
        if (index == currentIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('All Friends', friends.length),
              const SizedBox(height: 12),
            ],
          );
        }
        currentIndex++;

        // All Friends List or Empty State
        if (friends.isEmpty) {
          return _buildEmptyState('Start adding friends!');
        } else {
          final friendIndex = index - currentIndex;
          if (friendIndex < friends.length) {
            final friend = friends[friendIndex];
            return Padding(
              key: ValueKey('friend_${friend.userId}'),
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildUserCard(friend),
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUserCard(Friend friend) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.085),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: GestureDetector(
                onTap: () => _navigateToUserProfile(friend),
                child: UserAvatar(
                  avatarUrl: friend.avatarUrl,
                  avatarRadius: 20,
                ),
              ),
              title: GestureDetector(
                onTap: () => _navigateToUserProfile(friend),
                child: Text(
                  friend.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              subtitle: Text(
                friend.userName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              trailing: IconButton(
                icon:
                    Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
                onPressed: () => _showFriendOptions(friend.userId),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(Friend friend, List<Friend> friends) {
    final isFriend = friends.any((f) => f.userId == friend.userId);

    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.085),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: FutureBuilder<bool>(
          future: _friendService.isFriendRequestPending(
              currentUserId!, friend.userId),
          builder: (context, snapshot) {
            final isRequested = snapshot.data ?? false;

            return ListTile(
              leading: GestureDetector(
                onTap: () => _navigateToUserProfile(friend),
                child: AvatarImage(
                  avatarUrl: friend.avatarUrl,
                  avatarRadius: 20,
                ),
              ),
              title: Text(
                friend.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                friend.userName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              trailing: _buildSearchResultCardTrailing(
                  friend.userId, isFriend, isRequested),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResultCardTrailing(
      String userId, bool isFriend, bool isRequested) {
    if (isFriend) {
      return IconButton(
        icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
        onPressed: () => _showFriendOptions(userId),
      );
    } else if (isRequested) {
      return GestureDetector(
        onTap: () async {
          try {
            final result = await _friendService.withdrawFriendRequest(
                currentUserId!, userId);

            if (!result['success']) {
              if (mounted) {
                floatingSnackBar(
                  message:
                      result['error'] ?? 'Failed to withdraw friend request',
                  context: context,
                );
              }
              return;
            }

            if (mounted) {
              // Show success message
              floatingSnackBar(
                message: 'Friend request withdrawn',
                context: context,
              );

              // Force rebuild of the widget to refresh the UI
              setState(() {
                // This will trigger a rebuild of the FutureBuilder
                searchResults = List.from(searchResults);
              });
            }
          } catch (e) {
            if (mounted) {
              floatingSnackBar(
                message: 'Error withdrawing friend request: $e',
                context: context,
              );
            }
          }
        },
        child: Text(
          'Requested',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      );
    } else {
      return IconButton(
        icon: Icon(Icons.person_add, color: Colors.white.withOpacity(0.5)),
        onPressed: () => _sendFriendRequest(userId),
      );
    }
  }

  Widget _buildSectionHeader(String title, int count,
      {bool isRequest = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isRequest ? Colors.blue[200] : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isRequest
                ? Colors.blue.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: isRequest ? Colors.blue[100] : Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        if (isRequest && count > 0)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFriendRequestCard(Friend request) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _navigateToUserProfile(request),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Stack(
                  children: [
                    AvatarImage(
                      avatarUrl: request.avatarUrl,
                      avatarRadius: 20,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: drawerColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  request.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wants to be your friend',
                      style: TextStyle(
                        color: Colors.blue[200],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Accept',
                        icon: Icons.check,
                        color: Colors.green,
                        onTap: () => _acceptFriendRequest(request.userId),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Decline',
                        icon: Icons.close,
                        color: warningRed,
                        onTap: () => _declineFriendRequest(request.userId),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Modern bottom sheet for friend options
  void _showFriendOptions(String friendId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 21, 21, 21),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // View Profile Option
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToUserProfileById(friendId);
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Centered text
                              const Center(
                                child: Text(
                                  'View Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Right-aligned arrow
                              Positioned(
                                right: 0,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withOpacity(0.3),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),

                    // Remove Friend Option
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showRemoveFriendConfirmation(friendId);
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Center(
                            child: Text(
                              'Remove Friend',
                              style: TextStyle(
                                color: warningRed,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Cancel button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Extra padding for bottom safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  // Confirmation dialog for removing friends
  void _showRemoveFriendConfirmation(String friendId) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Remove Friend',
        content: 'Are you sure you want to remove this friend?',
        confirmationButtonText: 'Remove',
        cancelButtonText: 'Cancel',
        onPressed: () => _removeFriend(friendId),
      ),
    );
  }

  void _navigateToUserProfile(Friend friend) {
    // animate the page route and make it fast
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            OtherProfilePage(friend: friend),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToUserProfileById(String userId) {
    // Find the friend in either friends list or search results
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final friend = userProvider.friends.firstWhere(
      (f) => f.userId == userId,
      orElse: () => searchResults.firstWhere(
        (f) => f.userId == userId,
        orElse: () => Friend(
          userId: userId,
          fullName: '',
          userName: '',
          avatarUrl: '',
        ),
      ),
    );

    _navigateToUserProfile(friend);
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _searchUsers(String query) async {
    // Debounce the search to avoid too many requests
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;

      final result = await _friendService.searchUsers(query);

      if (mounted) {
        setState(() {
          searchResults = List<Friend>.from(result['friends'] ?? []);

          if (result['error'] != null &&
              result['error'] != 'User $query not found') {
            floatingSnackBar(
              message: result['error'],
              context: context,
            );
          }
        });
      }
    });
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    final result = await _friendService.sendFriendRequest(receiverId);

    if (!result['success']) {
      floatingSnackBar(
        message: result['error'],
        context: context,
      );
      return;
    }

    if (!mounted) return;
    // Update the UI state here to reflect the "Requested" state
    setState(
        () {}); // This will re-trigger the build method and update the trailing widget.
  }

  Future<void> _acceptFriendRequest(String senderId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await _friendService.acceptFriendRequest(senderId);

      if (!result['success']) {
        if (mounted) {
          floatingSnackBar(
            message: result['error'],
            context: context,
          );
        }
        return;
      }

      if (!mounted) return;

      // Show success message
      floatingSnackBar(
        message: 'Friend request accepted!',
        context: context,
      );

      // Refresh data from server
      userProvider.fetchFriendsList();
      userProvider.fetchFriendRequests();
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
          message: 'Error accepting friend request: $e',
          context: context,
        );
      }
    }
  }

  Future<void> _declineFriendRequest(String senderId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await _friendService.declineFriendRequest(senderId);

      if (!result['success']) {
        if (mounted) {
          floatingSnackBar(
            message: result['error'],
            context: context,
          );
        }
        return;
      }

      if (!mounted) return;

      // Refresh data from server
      userProvider.fetchFriendRequests();
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
          message: 'Error declining friend request: $e',
          context: context,
        );
      }
    }
  }

  Future<void> _removeFriend(String friendId) async {
    final result = await _friendService.removeFriend(friendId);

    if (!result['success']) {
      floatingSnackBar(
        message: result['error'],
        context: context,
      );
      return;
    }

    if (!mounted) return;

    // Show success message
    floatingSnackBar(
      message: 'Friend removed successfully',
      context: context,
    );

    // Refresh the friends list
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchFriendsList();
  }
}
