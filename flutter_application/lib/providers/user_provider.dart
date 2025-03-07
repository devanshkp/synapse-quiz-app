import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/services/friend_service.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  // Listeners
  late StreamSubscription<QuerySnapshot> _friendsListener1;
  late StreamSubscription<QuerySnapshot> _friendsListener2;
  late StreamSubscription<QuerySnapshot> _friendRequestsListener;
  late StreamSubscription<DocumentSnapshot> _userProfileListener;

  // User profile and user id
  UserProfile? _userProfile;
  late String _currentUserId;

  // Friend service
  final FriendService _friendService = FriendService();

  // Friends and friend requests
  List<Friend> _friends = [];
  List<Friend> _friendRequests = [];

  // Is developer
  bool _isDeveloper = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  String get currentUserId => _currentUserId;
  List<Friend> get friends => List.unmodifiable(_friends);
  List<Friend> get friendRequests => List.unmodifiable(_friendRequests);
  bool get isDeveloper => _isDeveloper;

  // Setters
  set isDeveloper(bool value) {
    _isDeveloper = value;
    notifyListeners();
  }

  UserProvider() {
    initialize();
  }

  void initialize() {
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // Fetches
    fetchUserProfile();
    fetchUserPermissions();
    fetchFriendsList();
    fetchFriendRequests();
    // Listeners
    listenToUserProfile();
    listenToFriends();
    listenToFriendRequests();
  }

  void reset() {
    _userProfile = null;
    _currentUserId = '';
    _friends = [];
    _friendRequests = [];
    _isDeveloper = false;
  }

  void disposeListeners() {
    _friendsListener1.cancel();
    _friendsListener2.cancel();
    _friendRequestsListener.cancel();
    _userProfileListener.cancel();
  }

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
        notifyListeners();
      } else {
        _userProfile = null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  Future<void> fetchUserPermissions() async {
    try {
      debugPrint("Fetching user permissions");
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _isDeveloper = false;
        debugPrint("User is null");
        return;
      }

      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();

      // Simply check if the document exists
      _isDeveloper = adminDoc.exists;
      debugPrint("User is developer: $_isDeveloper");

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching admin status: $e");
      _isDeveloper = false;
    }
  }

  // Fetch friends list from Firestore
  Future<void> fetchFriendsList() async {
    try {
      _friends = await _friendService.getFriends(_currentUserId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching friends: $e");
    }
  }

  // Fetch friend request data (pending requests)
  Future<void> fetchFriendRequests() async {
    try {
      _friendRequests =
          await _friendService.getPendingFriendRequests(_currentUserId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching friend requests: $e");
    }
  }

  void listenToFriends() {
    // Listen to friends collection for changes
    _friendsListener1 = FirebaseFirestore.instance
        .collection('friends')
        .where('userId1', isEqualTo: _currentUserId)
        .snapshots()
        .listen((_) => fetchFriendsList());

    _friendsListener2 = FirebaseFirestore.instance
        .collection('friends')
        .where('userId2', isEqualTo: _currentUserId)
        .snapshots()
        .listen((_) => fetchFriendsList());
  }

  void listenToFriendRequests() {
    // Listen to friend requests collection for changes
    _friendRequestsListener = FirebaseFirestore.instance
        .collection('friend_requests')
        .where('receiverId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((_) => fetchFriendRequests());
  }

  void listenToUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userProfileListener = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((docSnapshot) {
        if (docSnapshot.exists) {
          _userProfile = UserProfile.fromMap(docSnapshot.data()!);
          notifyListeners();
        }
      });
    }
  }

  Future<void> refreshUserProfile() async {
    await fetchUserProfile();
  }

  void updateUserProfile({
    String? userName,
    String? fullName,
    String? avatarUrl,
    List<String>? selectedTopics,
    List<String>? encounteredQuestions,
    int? questionsSolved,
    int? solvedTodayCount,
    String? lastSolvedDate,
    int? currentStreak,
    int? maxStreak,
    Map<String, int>? topicQuestionsSolved,
  }) {
    _userProfile = _userProfile?.copyWith(
      userName: userName,
      fullName: fullName,
      avatarUrl: avatarUrl,
      selectedTopics: selectedTopics,
      encounteredQuestions: encounteredQuestions,
      questionsSolved: questionsSolved,
      solvedTodayCount: solvedTodayCount,
      lastSolvedDate: lastSolvedDate,
      currentStreak: currentStreak,
      maxStreak: maxStreak,
      topicQuestionsSolved: topicQuestionsSolved,
    );
    notifyListeners();
  }

  Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile by ID: $e");
      return null;
    }
  }
}
