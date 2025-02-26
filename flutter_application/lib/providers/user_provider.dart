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
  int _totalQuestions = 0;
  List<Friend> _friends = [];
  List<Friend> _friendRequests = [];

  UserProfile? get userProfile => _userProfile;
  String get currentUserId => _currentUserId;
  int get totalQuestions => _totalQuestions;
  List<Friend> get friends => _friends;
  List<Friend> get friendRequests => _friendRequests;

  UserProvider() {
    fetchUserProfile();
    fetchTotalQuestions();
    notifyListeners();
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

  // Real-time listener for friends list
  void listenToFriendsList() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('friends')
          .doc(user.uid)
          .collection('userFriends')
          .snapshots()
          .listen((snapshot) {
        _friends =
            snapshot.docs.map((doc) => Friend.fromMap(doc.data())).toList();
        notifyListeners(); // Notify UI of changes
      });
    }
  }

  // Real-time listener for friend requests
  void listenToFriendRequests() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(user.uid)
          .collection('pendingRequests')
          .snapshots()
          .listen((snapshot) {
        _friendRequests =
            snapshot.docs.map((doc) => Friend.fromMap(doc.data())).toList();
        notifyListeners(); // Notify UI of changes
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

  Future<void> fetchTotalQuestions() async {
    try {
      final countQuery = await FirebaseFirestore.instance
          .collection('questions')
          .count()
          .get(); // Only fetches the count

      _totalQuestions = countQuery.count ?? 0; // Store the count
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
    );
    notifyListeners();
  }

  // Function to clear user data when logging out
  void clearUserData() {
    debugPrint('User logged out');
    _userProfile = null;
    notifyListeners();
  }
}
