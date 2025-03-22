import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/services/friend_service.dart';
import '../models/user_profile.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProvider extends ChangeNotifier {
  // Listeners
  late StreamSubscription<QuerySnapshot> _friendsListener1;
  late StreamSubscription<QuerySnapshot> _friendsListener2;
  late StreamSubscription<QuerySnapshot> _incomingRequestsListener;
  late StreamSubscription<QuerySnapshot> _outgoingRequestsListener;
  late StreamSubscription<DocumentSnapshot> _userProfileListener;

  // User profile and user id
  UserProfile? _userProfile;
  late String _currentUserId;

  // Friend service
  final FriendService _friendService = FriendService();

  // Friends and friend requests
  List<Friend> _friends = [];
  List<Friend> _incomingFriendRequests = [];
  List<Friend> _outgoingFriendRequests = [];

  // Booleans
  bool _isDeveloper = false;
  bool _isDisposed = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  String get currentUserId => _currentUserId;
  List<Friend> get friends => List.unmodifiable(_friends);
  List<Friend> get incomingFriendRequests =>
      List.unmodifiable(_incomingFriendRequests);
  List<Friend> get outgoingFriendRequests =>
      List.unmodifiable(_outgoingFriendRequests);
  bool get isDeveloper => _isDeveloper;

  // Setters
  set isDeveloper(bool value) {
    _isDeveloper = value;
    safeNotifyListeners();
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
    fetchFriendRequests(isIncoming: true);
    fetchFriendRequests(isIncoming: false);
    // Listeners
    listenToUserProfile();
    listenToFriends();
    listenToFriendRequests();
  }

  void reset() {
    _userProfile = null;
    _currentUserId = '';
    _friends = [];
    _incomingFriendRequests = [];
    _outgoingFriendRequests = [];
    _isDeveloper = false;
  }

  @override
  void dispose() {
    disposeListeners();
    _isDisposed = true;
    super.dispose();
  }

  void disposeListeners() {
    _friendsListener1.cancel();
    _friendsListener2.cancel();
    _incomingRequestsListener.cancel();
    _outgoingRequestsListener.cancel();
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
        safeNotifyListeners();
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

      safeNotifyListeners();
    } catch (e) {
      debugPrint("Error fetching admin status: $e");
      _isDeveloper = false;
    }
  }

  // Fetch friends list from Firestore
  Future<void> fetchFriendsList() async {
    try {
      _friends = await _friendService.getFriends(_currentUserId);
      safeNotifyListeners();
    } catch (e) {
      debugPrint("Error fetching friends: $e");
    }
  }

  // Fetch friend request data (pending requests)
  Future<void> fetchFriendRequests({bool isIncoming = false}) async {
    try {
      final result =
          await _friendService.getFriendRequests(_currentUserId, isIncoming);
      if (isIncoming) {
        _incomingFriendRequests = result;
      } else {
        _outgoingFriendRequests = result;
      }
      safeNotifyListeners();
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
    // Listen to incoming friend requests
    _incomingRequestsListener = FirebaseFirestore.instance
        .collection('friend_requests')
        .where('receiverId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((_) => fetchFriendRequests(isIncoming: true));

    // Listen to outgoing friend requests
    _outgoingRequestsListener = FirebaseFirestore.instance
        .collection('friend_requests')
        .where('senderId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((_) => fetchFriendRequests(isIncoming: false));
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
          safeNotifyListeners();
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
    safeNotifyListeners();
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

  /// Updates the user's profile in Firestore
  Future<void> updateUserProfileInFirestore({
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final Map<String, dynamic> updateData = {
        'fullName': fullName,
      };

      // Only update avatarUrl if it's provided
      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      // The user profile will be updated via the listener
    } catch (e) {
      debugPrint("Error updating user profile in Firestore: $e");
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Uploads a profile image to Firebase Storage and returns the download URL
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if user already has a profile image
      final String? existingImageUrl = _userProfile?.avatarUrl;
      String destination;

      if (existingImageUrl != null &&
          existingImageUrl.contains('firebasestorage.googleapis.com')) {
        // Extract the existing path from the URL to reuse it
        try {
          final ref = FirebaseStorage.instance.refFromURL(existingImageUrl);
          destination = ref.fullPath;
          debugPrint('Updating existing image at path: $destination');
        } catch (e) {
          // If we can't get the path from the URL, create a new one
          debugPrint('Could not extract path from existing URL: $e');
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
          destination = 'profile_images/${user.uid}/$fileName';
        }
      } else {
        // Create a new path if no existing image
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
        destination = 'profile_images/${user.uid}/$fileName';
      }

      final ref = FirebaseStorage.instance.ref().child(destination);
      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Image uploaded successfully at: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint("Error uploading profile image: $e");
      return null;
    }
  }

  void safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }
}
