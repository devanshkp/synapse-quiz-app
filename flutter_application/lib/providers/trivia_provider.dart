import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'dart:async';

import 'package:string_extensions/string_extensions.dart';

class TriviaProvider extends ChangeNotifier {
  final UserProvider userProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const double totalTime = 30;
  static const int minQuestions = 15;

  static const int questionBatchSize = 50;

  // Questions and Topics
  List<Map<String, dynamic>> _questions = [];
  List<String> _allTopics = [];
  List<String> _selectedTopics = [];
  List<String> _displayedTopics = [];

  // Loading state
  bool _isLoadingQuestions = true;
  bool _isLoadingTopics = true;
  bool _isFetching = false;

  //Others
  int _currentIndex = 0;
  final ValueNotifier<double> _timeNotifier = ValueNotifier<double>(totalTime);
  Timer? _timer;
  late double _lastSavedTime;
  bool _answered = false;
  String _selectedAnswer = '';
  String _correctAnswer = '';
  Map<String, dynamic>? _currentUserData;
  bool _isTriviaActive = false;

  // Getters
  List<Map<String, dynamic>> get questions => _questions;
  List<String> get allTopics => _allTopics;
  List<String> get selectedTopics => _selectedTopics;
  List<String> get displayedTopics => _displayedTopics;
  bool get isLoadingQuestions => _isLoadingQuestions;
  bool get isLoadingTopics => _isLoadingTopics;
  int get currentIndex => _currentIndex;
  ValueNotifier<double> get timeNotifier => _timeNotifier;
  bool get answered => _answered;
  String get selectedAnswer => _selectedAnswer;
  String get correctAnswer => _correctAnswer;
  Map<String, dynamic>? get currentUserData => _currentUserData;
  Map<String, dynamic> get currentQuestion => _questions[_currentIndex];

  TriviaProvider(this.userProvider) {
    _lastSavedTime = totalTime;
    init();
  }

  Future<void> init() async {
    await loadTopics(); // Wait for topics to load
    await fetchQuestions(); // Fetch questions after topics are loaded
    await refreshProfileStats();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  // ============================== TRIVIA STATISTICS FUNCTIONS ==============================

  Future<void> refreshProfileStats() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot userDoc = await userRef.get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      String currentDate = DateTime.now().toIso8601String().split('T').first;
      String lastSolvedDate = userData?['lastSolvedDate'] ?? '';
      int currentStreak = userData?['currentStreak'] ?? 0;
      int maxStreak = userData?['maxStreak'] ?? 0;
      int solvedTodayCount = userData?['solvedTodayCount'] ?? 0;
      List<dynamic> encounteredQuestions =
          userData?['encounteredQuestions'] ?? [];

      DateTime? lastSolved;
      if (lastSolvedDate.isNotEmpty) {
        lastSolved = DateTime.tryParse(lastSolvedDate);
      }

      if (lastSolved == null ||
          lastSolved
              .isBefore(DateTime.now().subtract(const Duration(days: 2)))) {
        // If it's been 2 or more days since the last solved date, reset the streak to 0
        currentStreak = 0;
      }

      // Always reset solved today count if it's a new day
      if (lastSolvedDate != currentDate) {
        solvedTodayCount = 0; // Reset solved today count
      }

      await userRef.set({
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'solvedTodayCount': solvedTodayCount,
        'lastSolvedDate': currentDate,
        'encounteredQuestions': encounteredQuestions,
      }, SetOptions(merge: true));

      userProvider.updateUserProfile(
        currentStreak: currentStreak,
        maxStreak: maxStreak,
        solvedTodayCount: solvedTodayCount,
        lastSolvedDate: currentDate,
      );
      debugPrint(
          "Updated streak to $currentStreak, solved today count to $solvedTodayCount.");
    }
  }

  Future<void> updateProfileStats() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot userDoc = await userRef.get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      String currentDate = DateTime.now().toIso8601String().split('T').first;

      int questionsSolved = (userData?['questionsSolved'] ?? 0) + 1;
      int solvedTodayCount = userData?['solvedTodayCount'] + 1;
      int currentStreak = userData?['currentStreak'];
      int maxStreak = userData?['maxStreak'];
      if (solvedTodayCount == 1) {
        currentStreak++;
        if (maxStreak < currentStreak) maxStreak = currentStreak;
      }

      await userRef.set({
        'questionsSolved': questionsSolved,
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'solvedTodayCount': solvedTodayCount,
        'lastSolvedDate': currentDate,
      }, SetOptions(merge: true));

      userProvider.updateUserProfile(
        questionsSolved: questionsSolved,
        currentStreak: currentStreak,
        maxStreak: maxStreak,
        solvedTodayCount: solvedTodayCount,
        lastSolvedDate: currentDate,
      );

      debugPrint("Solved questions today: $solvedTodayCount");
    }
  }

  // ============================== TIMER FUNCTIONS ==============================

  void setTriviaActive(bool active) {
    _isTriviaActive = active;
    if (active) {
      resumeTimer();
    } else {
      pauseTimer();
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    _lastSavedTime = _timeNotifier.value;
    debugPrint("Timer paused at $_timeNotifier.value");
  }

  void resumeTimer() {
    if (_answered) return;
    startQuestionTimer(resume: true);
    debugPrint("Timer resumed.");
  }

  void startQuestionTimer({bool resume = false, bool initialStart = false}) {
    if (_questions.isEmpty || _isLoadingQuestions) return;
    debugPrint("TIMER STARTED");
    _timer?.cancel();

    _timeNotifier.value = (resume) ? _lastSavedTime : totalTime;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_timeNotifier.value > 0) {
        _timeNotifier.value -= 0.1;
      } else {
        _timer?.cancel();
        handleTimeout();
      }
    });
  }

  void handleTimeout() {
    if (!_answered) {
      debugPrint("TIMEOUT");
      _answered = true;
      _selectedAnswer = '';
      getAnswer();
      updateQuestionData(false);
      notifyListeners();
    }
  }

  // ============================== TOPIC FUNCTIONS ==============================

  String formatTopic(String topic) {
    return topic.replaceAll('_', ' ').toTitleCase;
  }

  Future<void> loadTopics() async {
    final userTopics =
        await fetchUserselectedTopics(userProvider.currentUserId);
    final topics = await fetchAllTopics();
    _allTopics = topics;
    _selectedTopics = userTopics;
    _displayedTopics = allTopics
        .map((topic) => topic.replaceAll('_', ' ').toTitleCase)
        .toList();
    _isLoadingTopics = false;
    notifyListeners();
  }

  void syncTopics(List<String> cachedTopics) async {
    _selectedTopics = cachedTopics;
    await updateUserSelectedTopics();
  }

  void addTopic(String topic) {
    if (!selectedTopics.contains(topic)) {
      selectedTopics.add(topic);
      notifyListeners();
    }
  }

  void removeTopic(String topic) {
    if (selectedTopics.contains(topic)) {
      selectedTopics.remove(topic);
      notifyListeners();
    }
  }

  Future<List<String>> fetchUserselectedTopics(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      return List<String>.from(data?['selectedTopics'] ?? []);
    }
    return [];
  }

  Future<List<String>> fetchAllTopics() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('questions').get();
    final topics = querySnapshot.docs
        .map((doc) => doc['topic'] as String)
        .toSet()
        .toList();
    return topics;
  }

  Future<void> updateUserSelectedTopics({bool inTriviaPage = false}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserId)
        .update({
      'selectedTopics': _selectedTopics,
    });
    // Filter out questions from unselected topics and fetch more questions
    filterQuestionsBySelectedTopics();
    fetchQuestions();
    // Reset timer when questions are fetched
    _lastSavedTime = totalTime;
  }

  Future<void> excludeTopic() async {
    if (_currentUserData != null &&
        _currentUserData!.containsKey('selectedTopics')) {
      List<dynamic> updatedTopics =
          List.from(_currentUserData!['selectedTopics'] as List);
      String currentTopic = _questions[_currentIndex]['topic'];
      updatedTopics.remove(currentTopic);

      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'selectedTopics': updatedTopics,
      });

      // Remove questions from the excluded topic
      _questions.removeWhere((q) => q['topic'] == currentTopic);

      if (_questions.length - _currentIndex <= minQuestions) {
        fetchQuestions(); // Refetch questions if below threshold
      }

      notifyListeners();
    }
  }

  // ============================== QUESTION RELATED FUNCTIONS ==============================

  void printQuestionDetails(Map<String, dynamic> question) {
    // Extract question details
    String questionText = question['question'] ?? 'No question text available';
    String topic = formatTopic(question['topic']);
    String subtopic = question['subtopic'] ?? 'No subtopic available';
    List<dynamic> options = question['options'] ?? [];
    String answerKey = question['answer'] ?? '';
    String explanation = question['explanation'] ?? 'No explanation available';
    String hint = question['hint'] ?? 'No hint available';

    // Calculate the correct answer based on the answer key
    String correctAnswer = '';
    if (answerKey.isNotEmpty && options.isNotEmpty) {
      try {
        int correctIndex = answerKey.toLowerCase().codeUnitAt(0) - 97;
        if (correctIndex >= 0 && correctIndex < options.length) {
          correctAnswer = options[correctIndex];
        } else {
          correctAnswer = 'Invalid answer key';
        }
      } catch (e) {
        correctAnswer = 'Error determining correct answer';
      }
    } else {
      correctAnswer = 'No options or answer key available';
    }

    // Print the formatted question details
    debugPrint("Question Details:");
    debugPrint("  - Question: $questionText");
    debugPrint("  - Topic: $topic");
    debugPrint("  - Subtopic: $subtopic");
    debugPrint("  - Options:");
    for (int i = 0; i < options.length; i++) {
      debugPrint(
          "    ${String.fromCharCode(97 + i).toUpperCase()}: ${options[i]}");
    }
    debugPrint("  - Answer Key: $answerKey");
    debugPrint("  - Correct Answer: $correctAnswer");
    debugPrint("  - Explanation: $explanation");
    debugPrint("  - Hint: $hint");
    debugPrint("----------------------------------------");
  }

  bool isValidAnswerKey(String key) {
    final validKeys = ['a', 'b', 'c', 'd'];
    return validKeys.contains(key.toLowerCase().trim());
  }

  bool isValidQuestion(Map<String, dynamic> question) {
    // Check if required fields exist
    if (question['question'] == null ||
        question['options'] == null ||
        question['answer'] == null) {
      debugPrint("Invalid question: Missing required fields.");
      return false;
    }

    final options = question['options'];
    if (options is! List || options.length < 2) {
      debugPrint(
          "Invalid question: 'options' must be a list with at least 2 elements.");
      printQuestionDetails(question);
      return false;
    }

    // Validate the 'answer' key
    final answerKey = question['answer'];
    if (!isValidAnswerKey(answerKey)) {
      debugPrint("Invalid question: 'answer' key is not valid.");
      printQuestionDetails(question);
      return false;
    }

    // Ensure the answer key corresponds to a valid option index
    try {
      final correctAnswerIndex =
          answerKey.toLowerCase().trim().codeUnitAt(0) - 97;
      if (correctAnswerIndex < 0 || correctAnswerIndex >= options.length) {
        debugPrint(
            "Invalid question: 'answer' key does not correspond to a valid option.");
        printQuestionDetails(question);
        return false;
      }
    } catch (e) {
      debugPrint("Error validating 'answer' key: $e");
      printQuestionDetails(question);
      return false;
    }

    return true;
  }

  Future<void> filterQuestionsBySelectedTopics() async {
    debugPrint("filtering");
    _questions.removeWhere(
        (question) => !_selectedTopics.contains(question['topic']));
  }

  Future<void> fetchQuestionsFromFirebase(
      List<dynamic> encounteredQuestions) async {
    User? user = _auth.currentUser;

    if (user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    _currentUserData = userDoc.data() as Map<String, dynamic>?;

    if (_currentUserData == null) return;

    // Track how many questions we've added
    List<Map<String, dynamic>> fetchedQuestions = [];

    // Keep track of IDs we've seen to avoid duplicates
    Set<String> processedIds = Set.from(encounteredQuestions);
    processedIds
        .addAll(_questions.map((q) => q['questionId'].toString()).toList());

    // Approach: Use a random field to get random documents efficiently
    try {
      // For each topic, fetch some random questions
      for (String topic in _selectedTopics) {
        int questionsToGet =
            (questionBatchSize / _selectedTopics.length).ceil();

        // Use a random value between 0 and 1 as the starting point
        double randomStart = Random().nextDouble();

        // First try getting questions with random value >= our random start
        QuerySnapshot querySnapshot = await _firestore
            .collection('questions')
            .where('topic', isEqualTo: topic)
            .where('random', isGreaterThanOrEqualTo: randomStart)
            .limit(questionsToGet)
            .get();

        // If we didn't get enough, wrap around and get more from the beginning
        if (querySnapshot.docs.length < questionsToGet) {
          QuerySnapshot additionalSnapshot = await _firestore
              .collection('questions')
              .where('topic', isEqualTo: topic)
              .where('random', isLessThan: randomStart)
              .limit(questionsToGet - querySnapshot.docs.length)
              .get();

          // Add the additional questions
          querySnapshot.docs.addAll(additionalSnapshot.docs);
        }

        // Process the results
        for (var doc in querySnapshot.docs) {
          String questionId = doc.id;

          // Skip if we've already seen this question
          if (processedIds.contains(questionId)) continue;

          // Add to processed IDs to avoid duplicates
          processedIds.add(questionId);

          // Create question map and add if valid
          Map<String, dynamic> question = {
            'questionId': questionId,
            ...doc.data() as Map<String, dynamic>,
          };

          if (isValidQuestion(question)) {
            fetchedQuestions.add(question);
          }
        }
      }

      _questions.addAll(fetchedQuestions);
      _questions = _questions.toList();

      debugPrint('Questions fetched: ${_questions.length}');
    } catch (e) {
      debugPrint('Error fetching random questions: $e');
    }
  }

  Future<void> fetchQuestions() async {
    User? user = _auth.currentUser;
    _isFetching = true;
    if (_questions.isEmpty) {
      _isLoadingQuestions = true;
      notifyListeners();
    }

    if (user != null) {
      // Fetch the user's data and encountered questions
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      _currentUserData = userDoc.data() as Map<String, dynamic>?;
      if (_currentUserData != null) {
        // Get encountered questions from the user document
        List<dynamic> encounteredQuestions =
            _currentUserData!['encounteredQuestions'] ?? [];

        if (_selectedTopics.isEmpty) {
          debugPrint("No topics selected");
          _questions = [];
          _isLoadingQuestions = false;
          notifyListeners();
          return;
        }

        await fetchQuestionsFromFirebase(encounteredQuestions);
      }
    }

    if (_isTriviaActive && _questions.isNotEmpty && _isLoadingQuestions) {
      _isLoadingQuestions = false;
      resumeTimer();
    }
    _isFetching = false;
    _isLoadingQuestions = false;
    notifyListeners();
  }

  // Admin utility function to add a "random" value field to all questions
  Future<void> addRandomFieldToQuestions() async {
    WriteBatch batch = _firestore.batch();
    final docs = await _firestore.collection('questions').get();

    int count = 0;
    for (var doc in docs.docs) {
      // Add a random value between 0 and 1
      batch.update(doc.reference, {'random': Random().nextDouble()});

      count++;
      // Firestore batches are limited to 500 operations
      if (count >= 400) {
        await batch.commit();
        // Create new batch after committing
        batch = _firestore.batch();
        count = 0;
      }
    }

    if (count > 0) {
      await batch.commit();
    }
  }

  // ============================== ANSWER HANDLING FUNCTIONS ==============================

  void getAnswer() {
    String correctAnswerKey = currentQuestion['answer'];
    _correctAnswer = currentQuestion['options']
        [correctAnswerKey.toLowerCase().trim().codeUnitAt(0) - 97];
  }

  void handleAnswer(String selectedOption) {
    if (_answered) return;

    _answered = true;
    _selectedAnswer = selectedOption;
    _timer?.cancel();

    getAnswer();
    bool isCorrect = selectedOption == _correctAnswer;

    if (isCorrect) {
      updateProfileStats();
    }
    updateQuestionData(isCorrect);
    notifyListeners();
  }

  Future<void> updateQuestionData(bool isCorrect) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      WriteBatch batch = _firestore.batch();

      batch.update(userRef, {
        'encounteredQuestions':
            FieldValue.arrayUnion([currentQuestion['questionId']])
      });

      await batch.commit();
    }
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void nextQuestion() {
    // debugPrint('Current Index Before: $_currentIndex');
    _timer?.cancel();
    _answered = false;
    _selectedAnswer = '';

    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      startQuestionTimer(resume: false);
    }
    if (_questions.length - _currentIndex <= minQuestions && !_isFetching) {
      fetchQuestions();
    }
    // debugPrint('Current Index After: $_currentIndex');
    notifyListeners();
  }
}
