import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart'; // Import UserProfile model

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  int _totalQuestions = 0;

  UserProfile? get userProfile => _userProfile;
  int get totalQuestions => _totalQuestions;

  Future<void> fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
        notifyListeners(); // Notify UI of changes
      }
    } catch (e) {
      print("Error fetching user profile: $e");
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
      print("Error fetching total questions: $e");
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
}
