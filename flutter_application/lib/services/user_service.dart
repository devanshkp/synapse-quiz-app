import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required User user,
    required String userName,
    String? fullName,
    String? avatarUrl,
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'userName': userName,
      'fullName': fullName ?? user.displayName ?? 'User',
      'avatarUrl': avatarUrl ?? '',
      'selectedTopics': [
        "computer_network",
        "discrete_math",
        "data_structures",
        "algorithms",
        "probability_&_statistics",
      ],
      'encounteredQuestions': [],
      'questionsSolved': 0,
      'solvedTodayCount': 0,
      'lastSolvedDate': '',
      'currentStreak': 0,
      'maxStreak': 0,
    });
  }
}
