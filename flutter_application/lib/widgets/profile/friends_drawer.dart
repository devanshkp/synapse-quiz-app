import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/services/friend_services.dart';
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

  @override
  void initState() {
    super.initState();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      _friendsFuture =
          _friendService.getFriendIds(currentUserId).then((friendIds) {
        return _friendService.getFriends(friendIds);
      });
    }
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

        return _buildLeftDrawer(friends);
      },
    );
  }

  Future<void> _loadFriendRequests() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        final friendService = FriendService();
        final requests =
            await friendService.getPendingFriendRequests(currentUserId);

        setState(() {
          friendRequests = requests;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friend requests: $e')),
      );
    }
  }

  Widget _buildLeftDrawer(List<Friend> friends) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Friends',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search or add friend...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (query) async {
                if (query.isNotEmpty) {
                  await _searchUsers(query, friends);
                }
              },
            ),
          ),
          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: searchResults
                    .map((friend) => _buildSearchResultItem(friend, friends))
                    .toList(),
              ),
            ),
          if (searchResults.isEmpty)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Row(
                      children: [
                        const Text(
                          'All Friends',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            friends.length.toString(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (friends.isNotEmpty)
                    ...friends.map((friend) => _buildFriendItem(friend)),
                  if (friends.isEmpty)
                    _buildEmptyState('Start adding friends!'),
                  if (friendRequests.isNotEmpty)
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Friend Requests',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ...friendRequests
                      .map((request) => _buildFriendRequestItem(request)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendRequestItem(Friend request) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: AvatarImage(avatarUrl: request.avatarUrl, avatarRadius: 20),
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
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _acceptFriendRequest(request.userId),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _declineFriendRequest(request.userId),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(Friend friend, List<Friend> friends) {
    final isFriend = friends.any((f) => f.userId == friend.userId);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', isEqualTo: currentUserId)
          .where('receiverId', isEqualTo: friend.userId)
          .where('status', isEqualTo: 'pending')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text(
              'Loading...',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final isRequested =
            snapshot.data != null && snapshot.data!.docs.isNotEmpty;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: AvatarImage(avatarUrl: friend.avatarUrl, avatarRadius: 20),
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
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          trailing: isFriend
              ? PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Remove Friend'),
                      onTap: () => _removeFriend(friend.userId),
                    ),
                  ],
                )
              : isRequested
                  ? const Text(
                      'Requested',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    )
                  : IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.white54),
                      onPressed: () => _sendFriendRequest(friend.userId),
                    ),
        );
      },
    );
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('friend_requests').add({
        'senderId': currentUserId,
        'receiverId': receiverId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending friend request: $e')),
      );
    }
  }

  Future<void> _acceptFriendRequest(String senderId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated')),
        );
        return;
      }

      // Add each other as friends in the separate `friends` collection
      await FirebaseFirestore.instance.collection('friends').add({
        'userId1': currentUserId,
        'userId2': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove the friend request
      final requestSnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: currentUserId)
          .get();

      for (var doc in requestSnapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request accepted!')),
      );

      // Refresh the list of friends
      setState(() {
        friendRequests.removeWhere((request) => request.userId == senderId);
        _friendsFuture =
            _friendService.getFriendIds(currentUserId).then((friendIds) {
          return _friendService.getFriends(friendIds);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting friend request: $e')),
      );
    }
  }

  Future<void> _declineFriendRequest(String senderId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated')),
        );
        return;
      }

      // Remove the friend request
      final requestSnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: currentUserId)
          .get();

      for (var doc in requestSnapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request declined!')),
      );

      setState(() {
        friendRequests.removeWhere((request) => request.userId == senderId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining friend request: $e')),
      );
    }
  }

  Future<void> _removeFriend(String friendId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated')),
        );
        return;
      }

      // Remove the friend relationship from the `friends` collection
      final friendshipSnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId1', isEqualTo: currentUserId)
          .where('userId2', isEqualTo: friendId)
          .get();

      for (var doc in friendshipSnapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend removed successfully!')),
      );

      // Refresh the list of friends
      setState(() {
        _friendsFuture =
            _friendService.getFriendIds(currentUserId).then((friendIds) {
          return _friendService.getFriends(friendIds);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing friend: $e')),
      );
    }
  }

  Widget _buildFriendItem(Friend friend) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: AvatarImage(avatarUrl: friend.avatarUrl, avatarRadius: 20),
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
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      trailing: PopupMenuButton(
        icon: const Icon(Icons.more_vert, color: Colors.white54),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Text('Remove Friend'),
            onTap: () => _removeFriend(friend.userId),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
      ),
    );
  }

  Future<void> _searchUsers(String query, List<Friend> friends) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: query)
          .get();

      if (result.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User $query not found')),
        );
        return;
      }

      setState(() {
        searchResults =
            result.docs.map((doc) => Friend.fromDocument(doc)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching for user: $e')),
      );
    }
  }
}
