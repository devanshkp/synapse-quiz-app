import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String userId;
  final String userName;
  final String fullName;
  final String? avatarUrl; // Optional

  Friend({
    required this.userId,
    required this.userName,
    required this.fullName,
    this.avatarUrl,
  });

  // Factory constructor to create a Friend object from a Firestore document
  factory Friend.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      userId: doc.id,
      fullName: data['fullName'] ?? 'Unknown',
      userName: data['userName'] ?? 'Unknown',
      avatarUrl: data['avatarUrl'],
    );
  }
}
