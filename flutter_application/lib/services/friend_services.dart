import 'package:cloud_firestore/cloud_firestore.dart';
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
}
