class UserProfile {
  final String userId;
  final String username;
  final String fullName;
  final String profilePicture;
  final List<String> selectedCategories;
  final List<String> encounteredQuestions;
  final int questionsSolved;
  final List<String> friends;
  final List<String> friendRequests;

  UserProfile({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.profilePicture,
    required this.selectedCategories,
    required this.encounteredQuestions,
    required this.questionsSolved,
    required this.friends,
    required this.friendRequests,
  });

  // Factory method to create a UserProfile from a Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'No Username',
      fullName: data['fullName'] ?? 'No Name',
      profilePicture: data['profilePicture'] ?? '',
      selectedCategories: List<String>.from(data['selectedCategories'] ?? []),
      encounteredQuestions:
          List<String>.from(data['encounteredQuestions'] ?? []),
      questionsSolved: data['questionsSolved'] ?? 0,
      friends: List<String>.from(data['friends'] ?? []),
      friendRequests: List<String>.from(data['friend_requests'] ?? []),
    );
  }

  // Method to convert UserProfile to a Map (useful for Firestore updates)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'selectedCategories': selectedCategories,
      'encounteredQuestions': encounteredQuestions,
      'questionsSolved': questionsSolved,
      'friends': friends,
      'friend_requests': friendRequests,
    };
  }

  // Method to create a copy of the UserProfile with updated fields
  UserProfile copyWith({
    String? userId,
    String? username,
    String? fullName,
    String? profilePicture,
    List<String>? selectedCategories,
    List<String>? encounteredQuestions,
    int? questionsSolved,
    List<String>? friends,
    List<String>? friendRequests,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      encounteredQuestions: encounteredQuestions ?? this.encounteredQuestions,
      questionsSolved: questionsSolved ?? this.questionsSolved,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
    );
  }
}
