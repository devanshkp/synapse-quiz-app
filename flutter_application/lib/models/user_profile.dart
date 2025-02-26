class UserProfile {
  final String userId;
  final String userName;
  final String fullName;
  final String avatarUrl;
  final List<String> selectedTopics;
  final List<String> encounteredQuestions;
  final int questionsSolved;
  final int solvedTodayCount;
  final String lastSolvedDate;
  final int currentStreak;
  final int maxStreak;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.fullName,
    required this.avatarUrl,
    required this.selectedTopics,
    required this.encounteredQuestions,
    required this.questionsSolved,
    required this.solvedTodayCount,
    required this.lastSolvedDate,
    required this.currentStreak,
    required this.maxStreak,
  });

  // Factory method to create a UserProfile from a Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'No Username',
      fullName: data['fullName'] ?? 'No Name',
      avatarUrl: data['avatarUrl'] ?? '',
      selectedTopics: List<String>.from(data['selectedTopics'] ?? []),
      encounteredQuestions:
          List<String>.from(data['encounteredQuestions'] ?? []),
      questionsSolved: data['questionsSolved'] ?? 0,
      solvedTodayCount: data['solvedTodayCount'] ?? 0,
      lastSolvedDate: data['lastSolvedDate'] ?? '',
      currentStreak: data['currentStreak'] ?? 0,
      maxStreak: data['maxStreak'] ?? 0,
    );
  }

  // Method to convert UserProfile to a Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'selectedTopics': selectedTopics,
      'encounteredQuestions': encounteredQuestions,
      'questionsSolved': questionsSolved,
      'solvedTodayCount': solvedTodayCount,
      'lastSolvedDate': lastSolvedDate,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
    };
  }

  // Method to create a copy of the UserProfile with updated fields
  UserProfile copyWith({
    String? userId,
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
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      encounteredQuestions: encounteredQuestions ?? this.encounteredQuestions,
      questionsSolved: questionsSolved ?? this.questionsSolved,
      solvedTodayCount: solvedTodayCount ?? this.solvedTodayCount,
      lastSolvedDate: lastSolvedDate ?? this.lastSolvedDate,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
    );
  }
}
