import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String userId;
  final String userName;
  final String fullName;
  final String? avatarUrl; // Optional
  final int questionsSolved; // Track number of solved questions
  final int totalEncounteredQuestions;
  final double accuracy;

  Friend({
    required this.userId,
    required this.userName,
    required this.fullName,
    this.avatarUrl,
    this.questionsSolved = 0, // Default to 0
    this.totalEncounteredQuestions = 0,
    this.accuracy = 0.0,
  });

  // Factory constructor to create a Friend object from a Firestore document
  factory Friend.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      userId: doc.id,
      fullName: data['fullName'] ?? 'Unknown',
      userName: data['userName'] ?? 'Unknown',
      avatarUrl: data['avatarUrl'],
      questionsSolved: data['questionsSolved'] ?? 0,
      totalEncounteredQuestions: data['encounteredQuestions'].length ?? 0,
      accuracy: (data['questionsSolved'] / data['encounteredQuestions'].length)
          .toDouble() * 100,
    );
  }

  // Factory constructor to create a Friend object from a Map
  factory Friend.fromMap(Map<String, dynamic> data) {
    return Friend(
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? 'Unknown',
      userName: data['userName'] ?? 'Unknown',
      avatarUrl: data['avatarUrl'],
      questionsSolved: data['questionsSolved'] ?? 0,
      totalEncounteredQuestions: data['encounteredQuestions'].length ?? 0,
      accuracy: (data['questionsSolved'] / data['encounteredQuestions'].length)
          .toDouble() * 100,
    );
  }

  // Method to convert a Friend object to a Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'questionsSolved': questionsSolved,
      'totalEncounteredQuestions': totalEncounteredQuestions,
      'accuracy': accuracy,
    };
  }
}
