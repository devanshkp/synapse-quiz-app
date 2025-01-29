import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:rxdart/rxdart.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch friend IDs for a user
  Future<List<String>> getFriendIds(String userId) async {
    try {
      // Query for userId1 and userId2
      final friendsSnapshot1 = await _firestore
          .collection('friends')
          .where('userId1', isEqualTo: userId)
          .get();

      final friendsSnapshot2 = await _firestore
          .collection('friends')
          .where('userId2', isEqualTo: userId)
          .get();

      // Extract the friend IDs from both queries
      final friendIds = [
        ...friendsSnapshot1.docs.map((doc) => doc['userId2'] as String),
        ...friendsSnapshot2.docs.map((doc) => doc['userId1'] as String),
      ];

      return friendIds;
    } catch (e) {
      throw Exception('Failed to fetch friend IDs: $e');
    }
  }

  // Fetch friend details for a list of user IDs
  Future<List<Friend>> getFriends(List<String> friendIds) async {
    try {
      if (friendIds.isEmpty) return [];

      final usersSnapshot = await _firestore
          .collection('users')
          .where('userId', whereIn: friendIds)
          .get();

      final friends =
          usersSnapshot.docs.map((doc) => Friend.fromDocument(doc)).toList();

      return friends;
    } catch (e) {
      throw Exception('Failed to fetch friend details: $e');
    }
  }

  Stream<int> getFriendCountStream(String userId) {
    final userId1Query = _firestore
        .collection('friends')
        .where('userId1', isEqualTo: userId)
        .snapshots();

    final userId2Query = _firestore
        .collection('friends')
        .where('userId2', isEqualTo: userId)
        .snapshots();

    return Rx.combineLatest2(
      userId1Query,
      userId2Query,
      (QuerySnapshot query1, QuerySnapshot query2) {
        return query1.docs.length + query2.docs.length;
      },
    );
  }

  // Fetch pending friend requests
  Future<List<Friend>> getPendingFriendRequests(String userId) async {
    try {
      final requestsSnapshot = await _firestore
          .collection('friend_requests')
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      final senderIds = requestsSnapshot.docs
          .map((doc) => doc['senderId'] as String)
          .toList();

      if (senderIds.isEmpty) return [];

      return getFriends(senderIds); // Fetch user details of senders
    } catch (e) {
      throw Exception('Failed to fetch friend requests: $e');
    }
  }

  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: query)
          .get();

      if (result.docs.isEmpty) {
        return {'friends': [], 'error': 'User $query not found'};
      }

      return {
        'friends': result.docs.map((doc) => Friend.fromDocument(doc)).toList(),
        'error': null,
      };
    } catch (e) {
      return {'friends': [], 'error': 'Error: ${e.toString()}'};
    }
  }

  Future<bool> isFriendRequestPending(
      String senderId, String receiverId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false; // or handle as needed
    }
  }

  Future<Map<String, dynamic>> sendFriendRequest(String receiverId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        return {'success': false, 'error': 'User is not authenticated'};
      }

      // Check if a friend request already exists
      final existingRequest = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', isEqualTo: currentUserId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        return {'success': false, 'error': 'Friend request already sent!'};
      }

      // Send the friend request
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'senderId': currentUserId,
        'receiverId': receiverId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      return {'success': true, 'error': null};
    } catch (e) {
      return {
        'success': false,
        'error': 'Error sending friend request: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> acceptFriendRequest(String senderId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        return {'success': false, 'error': 'User is not authenticated'};
      }

      final firestore = FirebaseFirestore.instance;

      // Add each other as friends in the `friends` collection
      await firestore.collection('friends').add({
        'userId1': currentUserId,
        'userId2': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove the friend request
      final requestSnapshot = await firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: currentUserId)
          .get();

      for (var doc in requestSnapshot.docs) {
        await doc.reference.delete();
      }

      return {'success': true, 'error': null};
    } catch (e) {
      return {
        'success': false,
        'error': 'Error accepting friend request: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> declineFriendRequest(String senderId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        return {'success': false, 'error': 'User is not authenticated'};
      }

      final firestore = FirebaseFirestore.instance;

      // Remove the friend request
      final requestSnapshot = await firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: currentUserId)
          .get();

      for (var doc in requestSnapshot.docs) {
        await doc.reference.delete();
      }

      return {'success': true, 'error': null};
    } catch (e) {
      return {
        'success': false,
        'error': 'Error declining friend request: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> removeFriend(String friendId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        return {'success': false, 'error': 'User is not authenticated'};
      }

      final friendshipSnapshot1 = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId1', isEqualTo: currentUserId)
          .where('userId2', isEqualTo: friendId)
          .get();

      final friendshipSnapshot2 = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId1', isEqualTo: friendId)
          .where('userId2', isEqualTo: currentUserId)
          .get();

      final allFriendshipDocs = [
        ...friendshipSnapshot1.docs,
        ...friendshipSnapshot2.docs,
      ];

      // Remove friend relationship from Firestore
      for (var doc in allFriendshipDocs) {
        await doc.reference.delete();
      }

      return {'success': true, 'error': null};
    } catch (e) {
      return {
        'success': false,
        'error': 'Error removing friend: ${e.toString()}'
      };
    }
  }
}
