// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/services/friend_service.dart';
import 'package:flutter_application/widgets/shared.dart';

class FriendsDrawer extends StatefulWidget {
  const FriendsDrawer({super.key});

  @override
  State<FriendsDrawer> createState() => _FriendsDrawerState();
}

class _FriendsDrawerState extends State<FriendsDrawer> {
  late Future<List<Friend>> _friendsFuture;
  final FriendService _friendService = FriendService();
  List<Friend> searchResults = [];
  List<Friend> friendRequests = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _friendsFuture = _friendService.getFriends(currentUserId!);
    _loadFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Friend>>(
      future: _friendsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final friends = snapshot.data ?? [];
        return Container(
          decoration: const BoxDecoration(color: drawerColor),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(
                  child: _buildContent(friends),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Friends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
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
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search or add friend...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: (query) async {
              if (query.isNotEmpty) {
                await _searchUsers(query);
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
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildUserCard(searchResults[index], friends),
        );
      },
    );
  }

  Widget _buildFriendsList(List<Friend> friends) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (friendRequests.isNotEmpty) ...[
          _buildSectionHeader('Friend Requests', friendRequests.length),
          const SizedBox(height: 12),
          ...friendRequests.map((request) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRequestCard(request),
              )),
          const SizedBox(height: 20),
        ],
        _buildSectionHeader('All Friends', friends.length),
        const SizedBox(height: 12),
        if (friends.isNotEmpty)
          ...friends.map((friend) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildFriendCard(friend),
              ))
        else
          _buildEmptyState('Start adding friends!'),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Friend friend, List<Friend> friends) {
    final isFriend = friends.any((f) => f.userId == friend.userId);

    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
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
              leading: AvatarImage(
                avatarUrl: friend.avatarUrl,
                avatarRadius: 20,
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
              trailing:
                  _buildUserCardTrailing(friend.userId, isFriend, isRequested),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCardTrailing(
      String userId, bool isFriend, bool isRequested) {
    if (isFriend) {
      return PopupMenuButton(
        icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
        color: Colors.grey[900],
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Text('Remove Friend',
                style: TextStyle(color: Colors.white)),
            onTap: () => _removeFriend(userId),
          ),
        ],
      );
    } else if (isRequested) {
      return Text(
        'Requested',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      );
    } else {
      return IconButton(
        icon: Icon(Icons.person_add, color: Colors.white.withOpacity(0.5)),
        onPressed: () => _sendFriendRequest(userId),
      );
    }
  }

  Widget _buildRequestCard(Friend request) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.085),
              Colors.white.withOpacity(0.05),
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
        child: ListTile(
          leading: AvatarImage(
            avatarUrl: request.avatarUrl,
            avatarRadius: 20,
          ),
          title: Text(
            request.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            request.userName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green, size: 20),
                onPressed: () => _acceptFriendRequest(request.userId),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () => _declineFriendRequest(request.userId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendCard(Friend friend) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
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
        child: ListTile(
          leading: AvatarImage(
            avatarUrl: friend.avatarUrl,
            avatarRadius: 20,
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
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
            color: Colors.grey[900],
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Remove Friend',
                    style: TextStyle(color: Colors.white)),
                onTap: () => _removeFriend(friend.userId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _searchUsers(String query) async {
    final result = await _friendService.searchUsers(query);

    if (result['error'] != null) {
      floatingSnackBar(
        message: result['error'],
        context: context,
      );
    } else if (mounted) {
      setState(() {
        searchResults = result['friends'];
      });
    }
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
    final result = await _friendService.acceptFriendRequest(senderId);

    if (!result['success']) {
      floatingSnackBar(
        message: result['error'],
        context: context,
      );
      return;
    }
    if (!mounted) return;
    floatingSnackBar(
      message: 'Friend request accepted!',
      context: context,
    );

    // Refresh the friends list
    setState(() {
      friendRequests.removeWhere((request) => request.userId == senderId);
      _friendsFuture = _friendService.getFriends(currentUserId!);
    });
  }

  Future<void> _declineFriendRequest(String senderId) async {
    final result = await _friendService.declineFriendRequest(senderId);

    if (!result['success']) {
      floatingSnackBar(
        message: result['error'],
        context: context,
      );
    } else if (mounted) {
      // Remove from the local list
      setState(() {
        friendRequests.removeWhere((request) => request.userId == senderId);
      });
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
    // Refresh the friends list
    setState(() {
      _friendsFuture = _friendService.getFriends(currentUserId!);
    });
  }

  Future<void> _loadFriendRequests() async {
    try {
      if (currentUserId != null) {
        final friendService = FriendService();
        final requests =
            await friendService.getPendingFriendRequests(currentUserId!);

        if (!mounted) return;

        setState(() {
          friendRequests = requests;
        });
      }
    } catch (e) {
      debugPrint('Error loading friend requests');
    }
  }
}
