import 'dart:math';

import 'package:floating_snackbar/floating_snackbar.dart';
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

  // Constants
  static const double totalTime = 30;
  static const int minQuestions = 5;
  static const int questionBatchSize = 15;

  // Questions and Topics
  int _totalQuestions = 0;
  List<Map<String, dynamic>> _questions = [];
  List<String> _allTopics = [];
  List<String> _selectedTopics = [];
  List<String> _displayedTopics = [];
  final Map<String, int> _topicCounts = {};

  // Temporary topic session variables
  bool _isTemporarySession = false;
  List<String> _cachedSelectedTopics = [];
  List<Map<String, dynamic>> _cachedQuestions = [];

  // Cached questions per topic
  final Map<String, List<Map<String, dynamic>>> _cachedQuestionsPerTopic = {};

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

  // Add this timer at the class level
  Timer? _fetchQuestionsDebounceTimer;

  // Getters
  int get totalQuestions => _totalQuestions;
  List<Map<String, dynamic>> get questions => _questions;
  List<String> get allTopics => _allTopics;
  List<String> get selectedTopics => _selectedTopics;
  List<String> get displayedTopics => _displayedTopics;
  Map<String, int> get topicCounts => _topicCounts;
  bool get isLoadingQuestions => _isLoadingQuestions;
  bool get isLoadingTopics => _isLoadingTopics;
  int get currentIndex => _currentIndex;
  ValueNotifier<double> get timeNotifier => _timeNotifier;
  bool get answered => _answered;
  String get selectedAnswer => _selectedAnswer;
  String get correctAnswer => _correctAnswer;
  Map<String, dynamic>? get currentUserData => _currentUserData;
  Map<String, dynamic> get currentQuestion => _questions[_currentIndex];
  bool get isTemporarySession => _isTemporarySession;

  TriviaProvider(this.userProvider) {
    initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    _lastSavedTime = totalTime;
    await fetchTotalQuestions();
    await loadTopics(); // Load topics first

    // Initialize cached questions per topic after topics are loaded
    for (String topic in _allTopics) {
      _cachedQuestionsPerTopic[topic] = [];
    }
    await fetchQuestions(topics: _selectedTopics);
    await refreshProfileStats();
  }

  void reset() {
    _totalQuestions = 0;
    _questions = [];
    _selectedTopics = [];

    _isTemporarySession = false;
    _cachedQuestions = [];
    _cachedSelectedTopics = [];

    _isLoadingQuestions = true;
    _isLoadingTopics = true;
    _isFetching = false;

    _currentIndex = 0;
    _timeNotifier.value = totalTime;
    _timer?.cancel();
    _answered = false;
    _selectedAnswer = '';
    _correctAnswer = '';
    _currentUserData = null;
    _isTriviaActive = false;

    for (String topic in _allTopics) {
      _cachedQuestionsPerTopic[topic] = [];
    }
  }

  // ============================== TEMPORARY TOPIC SESSION FUNCTIONS ==============================

  /// Starts a temporary trivia session with a specific topic
  Future<void> startTemporarySession(String topic) async {
    if (_isTemporarySession) return;

    debugPrint("Starting temporary session for topic: $topic");

    _isTemporarySession = true;
    _isLoadingQuestions = true;
    notifyListeners();

    // Cache current state
    _cachedQuestions = List.from(_questions);
    _cachedSelectedTopics = List.from(_selectedTopics);

    _questions = _questions.where((q) => q['topic'] == topic).toList();
    _selectedTopics = [topic];

    debugPrint("Selected topics set to: $_selectedTopics");

    // Add cached questions for this topic
    retrieveCachedQuestionsForTopic(topic);

    debugPrint(
        "After retrieving cached questions: ${_questions.length} questions, all for topic $topic");

    for (var q in _questions) {
      if (q['topic'] != topic) {
        debugPrint("WARNING: Found question with wrong topic: ${q['topic']}");
      }
    }

    _currentIndex = 0;
    _answered = false;
    _selectedAnswer = '';

    // Fetch questions for this topic if there are less than minQuestions
    if (_questions.length < minQuestions) {
      await fetchQuestions(temporarySession: true, topics: [topic]);
    }

    _isLoadingQuestions = false;
    _questions.shuffle();
    // Start the timer
    startQuestionTimer();
    notifyListeners();
  }

  /// Ends the temporary topic session and restores the original state
  void endTemporarySession(String topic) {
    if (!_isTemporarySession) return;

    Future.microtask(() {
      // Restore original state
      _selectedTopics = List.from(_cachedSelectedTopics);

      if (_selectedTopics.contains(topic)) {
        List<Map<String, dynamic>> currentQuestions = List.from(_questions);
        _questions = List.from(_cachedQuestions);

        for (var question in currentQuestions) {
          if (!_questions
              .any((q) => q['questionId'] == question['questionId'])) {
            _questions.add(question);
          }
        }
      } else {
        cacheQuestionsForTopic(topic);
        _questions = List.from(_cachedQuestions);
      }

      // Don't call fetchQuestions() immediately, defer it if there are less than minQuestions
      if (_questions.length < minQuestions) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_isTemporarySession == false) {
            fetchQuestions(topics: [topic]);
          }
        });
      }

      // Shuffle the questions
      _questions.shuffle();

      // Reset session state
      _cachedQuestions = [];
      _cachedSelectedTopics = [];
      _currentIndex = 0;
      _answered = false;
      _selectedAnswer = '';

      _isTemporarySession = false;

      notifyListeners();

      // Reset the timer
      _timer?.cancel();
      _timeNotifier.value = totalTime;
    });
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

      // Check if the user has missed a day
      if (lastSolved == null) {
        // First time user, no streak yet
        currentStreak = 0;
      } else {
        // Get yesterday's date
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayDate =
            DateTime(yesterday.year, yesterday.month, yesterday.day);

        // Get the last solved date without time
        final lastSolvedWithoutTime =
            DateTime(lastSolved.year, lastSolved.month, lastSolved.day);

        // If last solved date is before yesterday, they've missed at least one day
        if (lastSolvedWithoutTime.isBefore(yesterdayDate)) {
          currentStreak = 0;
        }
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
    }
  }

  Future<void> updateProfileStats() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot userDoc = await userRef.get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      String currentDate = DateTime.now().toIso8601String().split('T').first;

      // Get the current question's topic
      String currentTopic = currentQuestion['topic'] ?? '';

      // Update total questions solved
      int questionsSolved = (userData?['questionsSolved'] ?? 0) + 1;
      int solvedTodayCount = userData?['solvedTodayCount'] + 1;
      int currentStreak = userData?['currentStreak'];
      int maxStreak = userData?['maxStreak'];
      if (solvedTodayCount == 1) {
        currentStreak++;
        if (maxStreak < currentStreak) maxStreak = currentStreak;
      }

      // Update topic-specific questions solved
      Map<String, dynamic> topicQuestionsSolved =
          Map<String, dynamic>.from(userData?['topicQuestionsSolved'] ?? {});

      // Increment the count for this topic
      topicQuestionsSolved[currentTopic] =
          (topicQuestionsSolved[currentTopic] ?? 0) + 1;

      await userRef.set({
        'questionsSolved': questionsSolved,
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'solvedTodayCount': solvedTodayCount,
        'lastSolvedDate': currentDate,
        'topicQuestionsSolved': topicQuestionsSolved,
      }, SetOptions(merge: true));

      userProvider.updateUserProfile(
        questionsSolved: questionsSolved,
        currentStreak: currentStreak,
        maxStreak: maxStreak,
        solvedTodayCount: solvedTodayCount,
        lastSolvedDate: currentDate,
        topicQuestionsSolved: Map<String, int>.from(topicQuestionsSolved),
      );
    }
  }

  // ============================== TIMER FUNCTIONS ==============================

  void setTriviaActive(bool active, {bool temporarySession = false}) {
    _isTriviaActive = active;
    if (temporarySession) return;
    if (active) {
      resumeTimer();
      if (_questions.isEmpty) {
        fetchQuestions(topics: _selectedTopics);
      }
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

  // Force loading to complete (safety method)
  void forceLoadingComplete() {
    if (_isLoadingQuestions) {
      _isLoadingQuestions = false;
      debugPrint(
          "Forced loading state to complete. Questions count: ${_questions.length}");
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

  void syncTopics(List<String> newTopics, {bool isTopicAdded = true}) async {
    // Find removed topics
    final removedTopics =
        _selectedTopics.where((topic) => !newTopics.contains(topic)).toList();

    // Find added topics
    final addedTopics =
        newTopics.where((topic) => !_selectedTopics.contains(topic)).toList();

    // Cache questions for removed topics
    for (String topic in removedTopics) {
      cacheQuestionsForTopic(topic);
    }

    // Update selected topics
    _selectedTopics = newTopics;

    // Pass both isTopicAdded flag and the list of added topics
    await updateUserSelectedTopics(
        topicAdded: isTopicAdded, addedTopics: isTopicAdded ? addedTopics : []);
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
    try {
      final topicsDoc =
          await _firestore.collection('metadata').doc('topics').get();

      if (!topicsDoc.exists) {
        return refreshTopicsMetadata();
      }

      final data = topicsDoc.data();
      if (data == null || !data.containsKey('list')) {
        return refreshTopicsMetadata();
      }

      final List<String> topics = List<String>.from(data['list']);
      if (topics.isEmpty) {
        return refreshTopicsMetadata();
      }

      debugPrint('Successfully fetched ${topics.length} topics from metadata.');
      return topics;
    } catch (e) {
      debugPrint('Error fetching topics from metadata: $e');
      return refreshTopicsMetadata();
    }
  }

  Future<void> updateUserSelectedTopics({
    bool topicAdded = true,
    List<String>? addedTopics,
  }) async {
    // Update Firestore immediately
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserId)
        .update({
      'selectedTopics': _selectedTopics,
    });

    // Filter out questions from unselected topics immediately
    filterQuestionsBySelectedTopics();

    // Cancel any pending timer
    _fetchQuestionsDebounceTimer?.cancel();

    // Only schedule fetchQuestions if we're adding topics and have topics to add
    if (topicAdded && addedTopics != null && addedTopics.isNotEmpty) {
      // Set a new timer to fetch questions after a delay
      _fetchQuestionsDebounceTimer = Timer(const Duration(seconds: 2), () {
        if (!_isTemporarySession) {
          debugPrint(
              "Fetching questions for newly added topics: ${addedTopics.join(', ')}");
          fetchQuestions(topics: addedTopics);
          _lastSavedTime = totalTime;
        }
      });
    } else {
      _lastSavedTime = totalTime;
    }

    notifyListeners();
  }

  Future<void> excludeTopic(BuildContext context) async {
    if (_currentUserData == null ||
        _currentUserData!.containsKey('selectedTopics') == false) {
      return;
    }

    if (_selectedTopics.length == 1) {
      if (context.mounted) {
        floatingSnackBar(
          context: context,
          message: 'Cannot exclude last topic',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    List<dynamic> updatedTopics =
        List.from(_currentUserData!['selectedTopics'] as List);
    String currentTopic = _questions[_currentIndex]['topic'];
    updatedTopics.remove(currentTopic);

    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'selectedTopics': updatedTopics,
    });

    cacheQuestionsForTopic(currentTopic);

    // Remove questions from the excluded topic
    _questions.removeWhere((q) => q['topic'] == currentTopic);

    if (_questions.length - _currentIndex <= minQuestions) {
      fetchQuestions(topics: _selectedTopics);
    }

    nextQuestion();

    notifyListeners();
  }

  // Fetch topic counts from metadata
  Future<void> fetchTopicCounts() async {
    try {
      final topicsDoc =
          await _firestore.collection('metadata').doc('topics').get();

      if (!topicsDoc.exists) {
        await refreshTopicsMetadata();
        return fetchTopicCounts();
      }

      final data = topicsDoc.data();
      if (data == null || !data.containsKey('counts')) {
        await refreshTopicsMetadata();
        return fetchTopicCounts();
      }

      final Map<String, dynamic> rawCounts = data['counts'];

      // Convert from dynamic to int
      rawCounts.forEach((key, value) {
        topicCounts[key] = value is int ? value : 0;
      });

      debugPrint(
          'Successfully fetched counts for ${topicCounts.length} topics.');
      topicCounts;
    } catch (e) {
      debugPrint('Error fetching topic counts from metadata: $e');
    }
  }

  // Update topic counts
  Future<void> getTopicCounts() async {
    try {
      await fetchTopicCounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating topic counts: $e');
    }
  }

  // ============================== QUESTION RELATED FUNCTIONS ==============================

  Future<void> fetchTotalQuestions() async {
    try {
      final countQuery = await FirebaseFirestore.instance
          .collection('questions')
          .count()
          .get(); // Only fetches the count

      _totalQuestions = countQuery.count ?? 0; // Store the count
      notifyListeners(); // Notify UI of changes
    } catch (e) {
      debugPrint("Error fetching total questions: $e");
    }
  }

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

  Future<void> retrieveCachedQuestionsForTopic(String topic,
      {int limit = 20}) async {
    // Initialize empty list if needed
    _cachedQuestionsPerTopic.putIfAbsent(topic, () => []);

    final cachedTopicQuestions = _cachedQuestionsPerTopic[topic]!;

    if (cachedTopicQuestions.isEmpty) {
      return;
    }

    debugPrint(
        "Adding ${cachedTopicQuestions.length} cached questions for topic: $topic");
    _questions.addAll(cachedTopicQuestions);

    // Remove used questions from cache
    if (cachedTopicQuestions.isNotEmpty) {
      cachedTopicQuestions.removeRange(
          0, min(cachedTopicQuestions.length, cachedTopicQuestions.length));
    }
  }

  Future<void> cacheQuestionsForTopic(String topic) async {
    // Filter questions to only include those with the matching topic
    final topicQuestions =
        _questions.where((q) => q['topic'] == topic).toList();

    // Add the filtered questions to the cache
    _cachedQuestionsPerTopic[topic]!.addAll(topicQuestions);

    // Remove duplicates by questionId
    final ids = <dynamic>{};
    _cachedQuestionsPerTopic[topic]!
        .retainWhere((x) => ids.add(x['questionId']));
    debugPrint(
        "Cached ${_cachedQuestionsPerTopic[topic]!.length} questions for topic: $topic");
  }

  Future<void> removeDuplicateQuestions() async {
    final ids = <dynamic>{};
    _questions.retainWhere((x) => ids.add(x['questionId']));
  }

  Future<void> filterQuestionsBySelectedTopics() async {
    debugPrint("filtering questions by selected topics");
    _questions.removeWhere(
        (question) => !_selectedTopics.contains(question['topic']));
  }

  Future<void> fetchQuestions(
      {int retryCount = 0,
      bool temporarySession = false,
      List<String>? topics}) async {
    // Guard against multiple simultaneous calls
    if (_isFetching && retryCount == 0) {
      debugPrint("Fetch already in progress, skipping this call");
      return;
    }

    User? user = _auth.currentUser;
    _isFetching = true;
    _currentIndex = 0;

    if (_questions.isEmpty || temporarySession) {
      debugPrint("is loading set to true");
      _isLoadingQuestions = true;
    }

    for (String topic in topics ?? _selectedTopics) {
      retrieveCachedQuestionsForTopic(topic, limit: 5);
      if (_questions.isNotEmpty) {
        _questions.shuffle();
      }
    }

    try {
      if (user != null) {
        // Fetch the user's data and encountered questions
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        _currentUserData = userDoc.data() as Map<String, dynamic>?;
        if (_currentUserData != null) {
          // Get encountered questions from the user document
          List<dynamic> encounteredQuestions =
              _currentUserData!['encounteredQuestions'] ?? [];

          if (topics?.isEmpty ?? _selectedTopics.isEmpty) {
            debugPrint("No topics selected");
            _questions = [];
            _isLoadingQuestions = false;
            if (_isTriviaActive) {
              notifyListeners();
            }
            return;
          }

          if (_questions.length < minQuestions) {
            await fetchQuestionsFromFirebase(
                encounteredQuestions, topics ?? _selectedTopics);
          }

          // If no questions were fetched and we haven't exceeded retry limit, try again
          if (_questions.isEmpty && retryCount < 3) {
            debugPrint(
                "No questions fetched, retrying (attempt ${retryCount + 1})...");
            _isFetching = false;
            _isLoadingQuestions = false;
            return fetchQuestions(
                retryCount: retryCount + 1,
                temporarySession: temporarySession,
                topics: topics ?? _selectedTopics);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching questions: $e");
    } finally {
      if (_isTriviaActive && _questions.isNotEmpty && _isLoadingQuestions) {
        resumeTimer();
        notifyListeners();
      }
      _isLoadingQuestions = false;
      _isFetching = false;

      notifyListeners();
    }
  }

  Future<void> fetchQuestionsFromFirebase(
      List<dynamic> encounteredQuestions, List<String> selectedTopics) async {
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
      for (String topic in selectedTopics) {
        int questionsToGet = (questionBatchSize / selectedTopics.length).ceil();

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

      fetchedQuestions.shuffle();
      _questions.addAll(fetchedQuestions);
      _questions.shuffle();

      debugPrint('Questions fetched: ${_questions.length}');
    } catch (e) {
      debugPrint('Error fetching random questions: $e');
    }
  }

  void resetEncounteredQuestions() {
    User? user = _auth.currentUser;
    if (user == null) return;
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    userRef.update({'encounteredQuestions': []});
    userRef.update({'questionsSolved': 0});
    userRef.update({'solvedTodayCount': 0});
    userRef.update({'topicQuestionsSolved': {}});

    userProvider.updateUserProfile(
      encounteredQuestions: [],
      questionsSolved: 0,
      solvedTodayCount: 0,
      topicQuestionsSolved: {},
    );
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
    if (user == null) return;
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    WriteBatch batch = _firestore.batch();

    batch.update(userRef, {
      'encounteredQuestions':
          FieldValue.arrayUnion([currentQuestion['questionId']])
    });

    await batch.commit();
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void nextQuestion() {
    _timer?.cancel();
    _answered = false;
    _selectedAnswer = '';

    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      startQuestionTimer(resume: false);
    }
    if (_questions.length - _currentIndex <= minQuestions) {
      fetchQuestions(topics: _selectedTopics);
    }
    notifyListeners();
  }

  // ============================== ADMIN UTILITY FUNCTIONS ==============================

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

  // Refreshes the topics metadata from the firestore's questions collection
  Future<List<String>> refreshTopicsMetadata() async {
    try {
      // Fetch all questions to get unique topics
      final querySnapshot = await _firestore.collection('questions').get();

      // Create a map to count questions per topic
      Map<String, int> topicCounts = {};

      // Count questions for each topic
      for (var doc in querySnapshot.docs) {
        String topic = doc['topic'] as String;
        topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
      }

      // Get the unique topics
      final topics = topicCounts.keys.toList();

      // Sort topics alphabetically
      topics.sort();

      // Try to update the metadata document, but don't fail if we can't
      try {
        await _firestore.collection('metadata').doc('topics').set({
          'list': topics,
          'counts': topicCounts,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        debugPrint('Metadata document updated successfully');
      } catch (e) {
        // Log the error but continue with the local topics list
        debugPrint('Warning: Could not update metadata document: $e');
      }

      // Refresh the topics in the provider
      _allTopics = topics;
      _displayedTopics = topics
          .map((topic) => topic.replaceAll('_', ' ').toTitleCase)
          .toList();

      notifyListeners();
      return topics;
    } catch (e, stackTrace) {
      debugPrint('Error refreshing topics metadata: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to refresh topics metadata: $e');
    }
  }
}
