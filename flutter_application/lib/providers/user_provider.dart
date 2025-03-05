import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/services/friend_service.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final FriendService _friendService = FriendService();
  List<Friend> _friends = [];
  List<Friend> _friendRequests = [];
  bool _isDeveloper = false;
  UserProfile? get userProfile => _userProfile;
  String get currentUserId => _currentUserId;
  List<Friend> get friends => List.unmodifiable(_friends);
  List<Friend> get friendRequests => List.unmodifiable(_friendRequests);
  bool get isDeveloper => _isDeveloper;
  set isDeveloper(bool value) {
    _isDeveloper = value;
    notifyListeners();
  }

  UserProvider() {
    // Fetches
    fetchUserProfile();
    fetchFriendsList();
    fetchFriendRequests();
    // Listeners
    listenToUserProfile();
    listenToFriends();
    listenToFriendRequests();
    notifyListeners();
  }

  void listenToFriends() {
    // Listen to friends collection for changes
    FirebaseFirestore.instance
        .collection('friends')
        .where('userId1', isEqualTo: _currentUserId)
        .snapshots()
        .listen((_) => fetchFriendsList());

    FirebaseFirestore.instance
        .collection('friends')
        .where('userId2', isEqualTo: _currentUserId)
        .snapshots()
        .listen((_) => fetchFriendsList());
  }

  void listenToFriendRequests() {
    // Listen to friend requests collection for changes
    FirebaseFirestore.instance
        .collection('friend_requests')
        .where('receiverId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((_) => fetchFriendRequests());
  }

  void listenToUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((docSnapshot) {
        if (docSnapshot.exists) {
          _userProfile = UserProfile.fromMap(docSnapshot.data()!);
          notifyListeners(); // Notify UI of changes
        }
      });
    }
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
        notifyListeners(); // Notify UI of changes
      } else {
        _userProfile = null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
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

  // Function to clear user data when logging out
  void clearUserData() {
    _userProfile = null;
    _friends = [];
    _friendRequests = [];
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
