import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart'; // Import UserProfile model

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

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

  void updateUserProfile(UserProfile userProfile) {
    _userProfile = userProfile;
    notifyListeners();
  }
}
