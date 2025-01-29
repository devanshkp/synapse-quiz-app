import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createUserProfile({
  required User user,
  required String userName,
  String? fullName,
  String? avatarUrl,
}) async {
  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'userId': user.uid,
    'userName': userName,
    'fullName': fullName ??
        user.displayName ??
        'No Name', // Default to Firebase display name if not provided
    'avatarUrl': avatarUrl ?? '', // Default to empty if not provided
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
