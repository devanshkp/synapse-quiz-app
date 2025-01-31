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
      'fullName': fullName ?? user.displayName ?? 'No Name',
      'avatarUrl': avatarUrl ?? '',
      'selectedCategories': [
        "neural_networks",
        "foundational_math",
        "sorting_algorithms",
        "machine_learning",
        "data_structures",
        "programming_basics",
        "popular_algorithms",
        "database_systems",
        "swe_fundamentals"
      ],
      'encounteredQuestions': [],
      'questionsSolved': 0,
    });
  }
}
