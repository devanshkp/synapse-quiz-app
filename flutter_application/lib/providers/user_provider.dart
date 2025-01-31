import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/services/friend_service.dart';
import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final FriendService _friendService = FriendService();
  int _totalQuestions = 0;
  List<Friend> _friends = [];
  List<Friend> _friendRequests = [];

  UserProfile? get userProfile => _userProfile;
  int get totalQuestions => _totalQuestions;
  List<Friend> get friends => _friends;
  List<Friend> get friendRequests => _friendRequests;

  Future<void> fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _userProfile = null;
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
        notifyListeners(); // Notify UI of changes
      } else {
        _userProfile = null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  Future<void> fetchTotalQuestions() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .get(); // Get all documents
      _totalQuestions = querySnapshot.size; // Get the count of documents
      notifyListeners(); // Notify UI of changes
    } catch (e) {
      debugPrint("Error fetching total questions: $e");
    }
  }

  // Fetch friends list from Firestore
  Future<void> fetchFriendsList() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _friends = await _friendService.getFriends(currentUserId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching friends: $e");
    }
  }

  // Fetch friend request data (pending requests)
  Future<void> fetchFriendRequests() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _friendRequests =
            await _friendService.getPendingFriendRequests(currentUserId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching friend requests: $e");
    }
  }

  Future<void> refreshUserProfile() async {
    await fetchUserProfile();
    await fetchTotalQuestions();
  }

  void updateUserProfile(UserProfile userProfile) {
    _userProfile = userProfile;
    notifyListeners();
  }

  // Function to clear user data when logging out
  void clearUserData() {
    debugPrint('User logged out');
    _userProfile = null;
    notifyListeners();
  }
}
