class UserProfile {
  final String userId;
  final String userName;
  final String fullName;
  final String avatarUrl;
  final List<String> selectedCategories;
  final List<String> encounteredQuestions;
  final int questionsSolved;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.fullName,
    required this.avatarUrl,
    required this.selectedCategories,
    required this.encounteredQuestions,
    required this.questionsSolved,
  });

  // Factory method to create a UserProfile from a Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'No Username',
      fullName: data['fullName'] ?? 'No Name',
      avatarUrl: data['avatarUrl'] ?? '',
      selectedCategories: List<String>.from(data['selectedCategories'] ?? []),
      encounteredQuestions:
          List<String>.from(data['encounteredQuestions'] ?? []),
      questionsSolved: data['questionsSolved'] ?? 0,
    );
  }

  // Method to convert UserProfile to a Map (useful for Firestore updates)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'selectedCategories': selectedCategories,
      'encounteredQuestions': encounteredQuestions,
      'questionsSolved': questionsSolved,
    };
  }

  // Method to create a copy of the UserProfile with updated fields
  UserProfile copyWith({
    String? userId,
    String? userName,
    String? fullName,
    String? avatarUrl,
    List<String>? selectedCategories,
    List<String>? encounteredQuestions,
    int? questionsSolved,
    List<String>? friends,
    List<String>? friendRequests,
  }) {
    return UserProfile(
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        selectedCategories: selectedCategories ?? this.selectedCategories,
        encounteredQuestions: encounteredQuestions ?? this.encounteredQuestions,
        questionsSolved: questionsSolved ?? this.questionsSolved);
  }
}
