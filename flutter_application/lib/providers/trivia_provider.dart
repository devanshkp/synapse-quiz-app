import 'dart:math';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/utils/text_formatter.dart';
import 'dart:async';

class TriviaProvider extends ChangeNotifier {
  final UserProvider userProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constants
  static const double totalTime = 30;
  static const int minQuestions = 25;
  static const int questionBatchSize = 40;
  static const Duration fetchQuestionsDebounceDuration =
      Duration(milliseconds: 500);
  static const int questionsToPreserve = 3;
  static const int cachedQuestionsRetrieveLimit = 5;
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String metadataCollection = 'metadata';

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
  bool _disposed = false;

  // Cancelable Operations
  CancelableOperation<void>? _fetchQuestionsOperation;
  CancelableOperation<void>? _fetchQuestionsFromFirebaseOperation;

  //Others
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

  // Add these new state variables
  List<Map<String, dynamic>> _encounteredQuestions = [];
  bool _isLoadingEncounteredQuestions = false;
  bool _hasMoreEncounteredQuestions = true;

  // Getters
  int get totalQuestions => _totalQuestions;
  List<Map<String, dynamic>> get questions => _questions;
  List<String> get allTopics => _allTopics;
  List<String> get selectedTopics => _selectedTopics;
  List<String> get displayedTopics => _displayedTopics;
  Map<String, int> get topicCounts => _topicCounts;

  bool get isTemporarySession => _isTemporarySession;
  bool get isLoadingQuestions => _isLoadingQuestions;
  bool get isLoadingTopics => _isLoadingTopics;
  bool get isFetchingQuestions =>
      _isLoadingQuestions ||
      (_fetchQuestionsOperation != null &&
          !_fetchQuestionsOperation!.isCompleted &&
          !_fetchQuestionsOperation!.isCanceled) ||
      (_fetchQuestionsFromFirebaseOperation != null &&
          !_fetchQuestionsFromFirebaseOperation!.isCompleted &&
          !_fetchQuestionsFromFirebaseOperation!.isCanceled);

  ValueNotifier<double> get timeNotifier => _timeNotifier;
  bool get answered => _answered;
  String get selectedAnswer => _selectedAnswer;
  String get correctAnswer => _correctAnswer;
  Map<String, dynamic>? get currentUserData => _currentUserData;
  Map<String, dynamic> get currentQuestion =>
      _questions.isNotEmpty ? _questions.first : {};

  List<Map<String, dynamic>> get encounteredQuestions => _encounteredQuestions;
  bool get isLoadingEncounteredQuestions => _isLoadingEncounteredQuestions;
  bool get hasMoreEncounteredQuestions => _hasMoreEncounteredQuestions;

  TriviaProvider(this.userProvider) {
    initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeNotifier.dispose();
    _fetchQuestionsDebounceTimer?.cancel();
    _disposed = true;
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
    await safeFetchQuestions(topics: _selectedTopics);
  }

  void cancelFetchOperations() {
    _fetchQuestionsOperation?.cancel();
    _fetchQuestionsFromFirebaseOperation?.cancel();

    _fetchQuestionsOperation = null;
    _fetchQuestionsFromFirebaseOperation = null;
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

    // Make sure any existing timer is canceled
    stopTimer();

    _isTemporarySession = true;
    _isLoadingQuestions = true;
    safeNotifyListeners();

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

    _answered = false;
    _selectedAnswer = '';
    _timeNotifier.value = totalTime;

    // Fetch questions for this topic if there are less than minQuestions
    if (_questions.length < minQuestions) {
      await safeFetchQuestions(temporarySession: true, topics: _selectedTopics);
    }

    if (_questions.isNotEmpty) {
      _questions.shuffle();
    }

    // Start the timer after everything is set up
    Future.microtask(() {
      _isLoadingQuestions = false;
      if (_questions.isNotEmpty) {
        startQuestionTimer(resume: false);
      }
      safeNotifyListeners();
    });
  }

  /// Ends the temporary topic session and restores the original state
  void endTemporarySession(String topic) {
    if (!_isTemporarySession) return;

    stopTimer();

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

      if (_questions.length < minQuestions) {
        safeFetchQuestions(topics: _selectedTopics);
      } else {
        preserveAndShuffleQuestions();
      }

      // Reset session state
      _cachedQuestions = [];
      _cachedSelectedTopics = [];
      _answered = false;
      _selectedAnswer = '';

      _isTemporarySession = false;

      safeNotifyListeners();
    });
  }

  // ============================== TRIVIA STATISTICS FUNCTIONS ==============================

  Future<void> updateProfileStats() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef =
          _firestore.collection(usersCollection).doc(user.uid);
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
        if (currentStreak > maxStreak) maxStreak = currentStreak;
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
      if (_questions.isEmpty) {
        safeFetchQuestions(topics: _selectedTopics);
      } else {
        resumeTimer();
      }
    } else {
      pauseTimer();
    }
  }

  void pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      _lastSavedTime = _timeNotifier.value;
      debugPrint("Timer paused at ${_timeNotifier.value}");
    }
  }

  void resumeTimer() {
    if (_answered) return;
    startQuestionTimer(resume: true);
    debugPrint("Timer resumed.");
  }

  // Explicitly stop the timer and reset its state
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      debugPrint("Timer explicitly stopped at ${_timeNotifier.value}");
    }
  }

  void startQuestionTimer({bool resume = false}) {
    if (_questions.isEmpty || _isLoadingQuestions) return;

    // Always cancel any existing timer first
    stopTimer();

    debugPrint("TIMER STARTED (resume: $resume)");

    _timeNotifier.value = (resume) ? _lastSavedTime : totalTime;

    Future.microtask(() {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_timeNotifier.value > 0) {
          _timeNotifier.value -= 0.1;
        } else {
          timer.cancel();
          _timer = null;
          handleTimeout();
        }
      });
    });
  }

  void handleTimeout() {
    if (!_answered) {
      debugPrint("TIMEOUT");
      _answered = true;
      _selectedAnswer = '';
      getAnswer();
      updateQuestionData(false);
      safeNotifyListeners();
    }
  }

  // Force loading to complete (safety method)
  void forceLoadingComplete() {
    if (_isLoadingQuestions) {
      _isLoadingQuestions = false;
      debugPrint(
          "Forced loading state to complete. Questions count: ${_questions.length}");
      safeNotifyListeners();
    }
  }

  // ============================== TOPIC FUNCTIONS ==============================

  Future<void> loadTopics() async {
    final userTopics =
        await fetchUserselectedTopics(userProvider.currentUserId);
    final topics = await fetchAllTopics();
    _allTopics = topics;
    _selectedTopics = userTopics;
    _displayedTopics = allTopics
        .map((topic) => TextFormatter.formatTitlePreservingCase(topic))
        .toList();
    _isLoadingTopics = false;
    safeNotifyListeners();
  }

  Future<void> syncTopics(List<String> newTopics,
      {bool isTopicAdded = true}) async {
    _fetchQuestionsOperation?.cancel();
    _fetchQuestionsFromFirebaseOperation?.cancel();
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

  Future<void> updateUserSelectedTopics({
    bool topicAdded = true,
    List<String>? addedTopics,
  }) async {
    // Update Firestore immediately
    try {
      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(userProvider.currentUserId)
          .update({
        'selectedTopics': _selectedTopics,
      });
    } catch (e) {
      debugPrint("Error updating user selected topics: $e");
    }

    // Filter out questions from unselected topics immediately
    await filterQuestionsBySelectedTopics();

    // Only schedule fetchQuestions if we're adding topics and have topics to add
    if (topicAdded && addedTopics != null && addedTopics.isNotEmpty) {
      debugPrint(
          "Fetching questions for newly added topics: ${addedTopics.join(', ')}");
      safeFetchQuestions(topics: addedTopics);
    }

    _lastSavedTime = totalTime;
    safeNotifyListeners();
  }

  Future<List<String>> fetchUserselectedTopics(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(userId)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data();
      return List<String>.from(data?['selectedTopics'] ?? []);
    }
    return [];
  }

  Future<List<String>> fetchAllTopics() async {
    try {
      final topicsDoc =
          await _firestore.collection(metadataCollection).doc('topics').get();

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

  // Fetch topic counts from metadata
  Future<void> fetchTopicCounts() async {
    try {
      final topicsDoc =
          await _firestore.collection(metadataCollection).doc('topics').get();

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
      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error updating topic counts: $e');
    }
  }

  // ============================== QUESTION RELATED FUNCTIONS ==============================

  Future<void> fetchTotalQuestions() async {
    try {
      final countQuery = await FirebaseFirestore.instance
          .collection(questionsCollection)
          .count()
          .get(); // Only fetches the count

      _totalQuestions = countQuery.count ?? 0; // Store the count
      safeNotifyListeners(); // Notify UI of changes
    } catch (e) {
      debugPrint("Error fetching total questions: $e");
    }
  }

  void printQuestionDetails(Map<String, dynamic> question) {
    // Extract question details
    String questionText = question['question'] ?? 'No question text available';
    String topic = TextFormatter.formatTitlePreservingCase(question['topic']);
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

  /// Preserves the first few questions and shuffles the rest of the questions
  void preserveAndShuffleQuestions() {
    if (_questions.isEmpty) return;

    // Determine how many questions to preserve (up to questionsToPreserve)
    int preserveCount = min(questionsToPreserve, _questions.length);

    // If we have fewer than 'questionsToPreserve' questions, don't shuffle at all
    if (_questions.length <= questionsToPreserve) {
      debugPrint(
          "Not shuffling as we have fewer than $questionsToPreserve questions");
      return;
    }

    // Extract the questions to preserve
    List<Map<String, dynamic>> preservedQuestions =
        _questions.sublist(0, preserveCount).toList();

    // Get the remaining questions to shuffle
    List<Map<String, dynamic>> remainingQuestions =
        _questions.sublist(preserveCount).toList();

    // Shuffle only the remaining questions
    remainingQuestions.shuffle();

    // Combine the preserved questions with the shuffled remaining questions
    _questions = [...preservedQuestions, ...remainingQuestions];

    debugPrint(
        "Preserved first $preserveCount questions and shuffled the rest");
  }

  Future<void> safeFetchQuestions(
      {bool temporarySession = false, List<String>? topics}) async {
    if (_fetchQuestionsDebounceTimer != null) {
      _fetchQuestionsDebounceTimer!.cancel();
      _fetchQuestionsOperation?.cancel();
      _fetchQuestionsFromFirebaseOperation?.cancel();
    }

    _fetchQuestionsDebounceTimer =
        Timer(fetchQuestionsDebounceDuration, () async {
      try {
        await fetchQuestions(
            temporarySession: temporarySession, topics: topics);
      } catch (e) {
        if (e == 'Cancelled') {
          debugPrint("Fetching questions cancelled");
        } else {
          debugPrint("Error fetching questions: $e");
        }
      }
    });
  }

  Future<void> fetchQuestions(
      {bool temporarySession = false, List<String>? topics}) async {
    _fetchQuestionsOperation?.cancel();

    // Create a new cancelable operation
    _fetchQuestionsOperation = CancelableOperation.fromFuture(() async {
      try {
        User? user = _auth.currentUser;
        if (user == null) return;
        safeNotifyListeners();

        topics ??= _selectedTopics;

        // Only set loading state if we have no questions or it's a temporary session
        if (_questions.isEmpty || temporarySession) {
          debugPrint("Setting loading state to true");
          _isLoadingQuestions = true;
          safeNotifyListeners();
        }

        // Try to get cached questions first
        for (String topic in topics ?? _selectedTopics) {
          retrieveCachedQuestionsForTopic(topic,
              limit: cachedQuestionsRetrieveLimit);
        }

        // Fetch the user's data and encountered questions
        DocumentSnapshot userDoc =
            await _firestore.collection(usersCollection).doc(user.uid).get();
        _currentUserData = userDoc.data() as Map<String, dynamic>?;

        if (_currentUserData != null) {
          // Get encountered questions from the user document
          List<dynamic> encounteredQuestions =
              _currentUserData!['encounteredQuestions'] ?? [];

          if (topics!.isEmpty) {
            debugPrint("No topics selected");
            _questions = [];
            _isLoadingQuestions = false;
            safeNotifyListeners();
            return;
          }

          // Only fetch from Firebase if we need more questions
          if (_questions.where((q) => topics!.contains(q['topic'])).isEmpty ||
              _questions.length < minQuestions) {
            await fetchQuestionsFromFirebase(encounteredQuestions, topics!);
          }

          // Only shuffle if it's not a temporary session
          if (!temporarySession) {
            preserveAndShuffleQuestions();
          }
        }
      } catch (e) {
        debugPrint("Error fetching questions: $e");
      } finally {
        if (_isTriviaActive && _questions.isNotEmpty && _isLoadingQuestions) {
          _isLoadingQuestions = false;
          resumeTimer();
        }
        _isLoadingQuestions = false;
        safeNotifyListeners();
      }
    }());

    await _fetchQuestionsOperation?.valueOrCancellation();
  }

  Future<void> fetchQuestionsFromFirebase(
      List<dynamic> encounteredQuestions, List<String> selectedTopics) async {
    // Cancel any existing operation
    _fetchQuestionsFromFirebaseOperation?.cancel();

    // Create a new cancelable operation
    _fetchQuestionsFromFirebaseOperation =
        CancelableOperation.fromFuture(() async {
      try {
        User? user = _auth.currentUser;
        if (user == null) return null;
        DocumentSnapshot userDoc =
            await _firestore.collection(usersCollection).doc(user.uid).get();
        _currentUserData = userDoc.data() as Map<String, dynamic>?;

        if (_currentUserData == null) return null;

        // Track how many questions we've added
        List<Map<String, dynamic>> fetchedQuestions = [];

        // Keep track of IDs we've seen to avoid duplicates
        Set<String> processedIds = Set.from(encounteredQuestions);
        processedIds
            .addAll(_questions.map((q) => q['questionId'].toString()).toList());

        // Approach: Use a random field to get random documents efficiently

        // For each topic, fetch some random questions
        for (String topic in selectedTopics) {
          int questionsToGet =
              (questionBatchSize / selectedTopics.length).ceil();

          // Use a random value between 0 and 1 as the starting point
          double randomStart = Random().nextDouble();

          // First try getting questions with random value >= our random start
          QuerySnapshot querySnapshot = await _firestore
              .collection(questionsCollection)
              .where('topic', isEqualTo: topic)
              .where('random', isGreaterThanOrEqualTo: randomStart)
              .limit(questionsToGet)
              .get();

          // If we didn't get enough, wrap around and get more from the beginning
          if (querySnapshot.docs.length < questionsToGet) {
            QuerySnapshot additionalSnapshot = await _firestore
                .collection(questionsCollection)
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

        // Shuffle the fetched questions before adding them to the main list
        fetchedQuestions.shuffle();

        _questions.addAll(fetchedQuestions);
      } catch (e) {
        debugPrint('Error fetching random questions: $e');
      }
    }());

    await _fetchQuestionsFromFirebaseOperation?.valueOrCancellation();
  }

  void resetEncounteredQuestions() {
    User? user = _auth.currentUser;
    if (user == null) return;
    DocumentReference userRef =
        _firestore.collection(usersCollection).doc(user.uid);
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
    if (_questions.isEmpty) {
      debugPrint("ERROR: getAnswer() called when _questions is empty!");
      _correctAnswer = '';
      return;
    }

    Map<String, dynamic> question = _questions.first;

    if (!question.containsKey('answer') || question['answer'] == null) {
      debugPrint(
          "ERROR: Question is missing 'answer' field: ${question['questionId']}");
      _correctAnswer = '';
      return;
    }

    String correctAnswerKey = question['answer'];
    if (correctAnswerKey.isEmpty) {
      debugPrint(
          "ERROR: Question has empty 'answer' field: ${question['questionId']}");
      _correctAnswer = '';
      return;
    }

    if (!question.containsKey('options') || question['options'] == null) {
      debugPrint(
          "ERROR: Question is missing 'options' field: ${question['questionId']}");
      _correctAnswer = '';
      return;
    }

    List<dynamic> options = question['options'];
    if (options.isEmpty) {
      debugPrint(
          "ERROR: Question has empty 'options' field: ${question['questionId']}");
      _correctAnswer = '';
      return;
    }

    try {
      int index = correctAnswerKey.toLowerCase().trim().codeUnitAt(0) - 97;
      if (index < 0 || index >= options.length) {
        debugPrint(
            "ERROR: Invalid answer index $index for question: ${question['questionId']}");
        _correctAnswer = '';
        return;
      }

      _correctAnswer = options[index];
    } catch (e) {
      debugPrint(
          "ERROR getting answer: $e for question: ${question['questionId']}");
      _correctAnswer = '';
    }
  }

  void handleAnswer(String selectedOption) {
    if (_answered) return;

    debugPrint("Answer selected: $selectedOption - Stopping timer");

    // Stop the timer immediately
    stopTimer();

    _answered = true;
    _selectedAnswer = selectedOption;

    // Freeze the timer display at current value
    _lastSavedTime = _timeNotifier.value;

    getAnswer();
    bool isCorrect = selectedOption == _correctAnswer;

    if (isCorrect) {
      updateProfileStats();
    }
    updateQuestionData(isCorrect);
    safeNotifyListeners();
  }

  Future<void> updateQuestionData(bool isCorrect) async {
    User? user = _auth.currentUser;
    if (user == null) return;
    DocumentReference userRef =
        _firestore.collection(usersCollection).doc(user.uid);
    WriteBatch batch = _firestore.batch();

    // Add to Firestore
    batch.update(userRef, {
      'encounteredQuestions':
          FieldValue.arrayUnion([currentQuestion['questionId']])
    });

    await batch.commit();

    // Add to local list
    addToEncounteredQuestions(currentQuestion);
  }

  Future<void> nextQuestion() async {
    // Make sure the timer is canceled before moving to next question
    stopTimer();

    _answered = false;
    _selectedAnswer = '';

    // Remove the current question (first in the list)
    if (_questions.isNotEmpty) {
      _questions.removeAt(0);
    }

    // If questions list is getting low, fetch more questions
    // but don't disrupt the current flow by setting a higher threshold
    if (_questions.length < minQuestions) {
      debugPrint(
          "Fetching more questions because count is low: ${_questions.length}");

      // Use a microtask to avoid blocking the UI
      Future.microtask(() async {
        await safeFetchQuestions(topics: _selectedTopics);
      });
    }

    // Only start the timer if we have questions
    if (_questions.isNotEmpty) {
      startQuestionTimer(resume: false);
    } else {
      debugPrint("ERROR: No questions available in nextQuestion()!");
      // Try to fetch questions immediately if we have none
      await safeFetchQuestions(topics: _selectedTopics);
    }

    safeNotifyListeners();
  }

  // ============================== ADMIN UTILITY FUNCTIONS ==============================

  // Admin utility function to add a "random" value field to all questions
  Future<void> addRandomFieldToQuestions() async {
    WriteBatch batch = _firestore.batch();
    final docs = await _firestore.collection(questionsCollection).get();

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
      final querySnapshot =
          await _firestore.collection(questionsCollection).get();

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
        await _firestore.collection(metadataCollection).doc('topics').set({
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
          .map((topic) => TextFormatter.formatTitlePreservingCase(topic))
          .toList();

      safeNotifyListeners();
      return topics;
    } catch (e, stackTrace) {
      debugPrint('Error refreshing topics metadata: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to refresh topics metadata: $e');
    }
  }

  void safeNotifyListeners() {
    if (_disposed) return;

    try {
      // Check if we're in a build phase
      if (WidgetsBinding.instance.buildOwner?.debugBuilding ?? false) {
        // Schedule the notification for the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_disposed) notifyListeners();
        });
        return;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error in safeNotifyListeners: $e');
    }
  }

  // Modify the loadEncounteredQuestions method
  Future<void> loadEncounteredQuestions({bool refresh = false}) async {
    if (_isLoadingEncounteredQuestions) return;

    User? user = _auth.currentUser;

    if (user == null) return;

    _isLoadingEncounteredQuestions = true;
    if (refresh) {
      _encounteredQuestions = [];
      _hasMoreEncounteredQuestions = true;
    }
    safeNotifyListeners();

    try {
      // Get the user's encountered question IDs
      DocumentSnapshot userDoc =
          await _firestore.collection(usersCollection).doc(user.uid).get();
      List<dynamic> encounteredIds =
          (userDoc.data() as Map<String, dynamic>)['encounteredQuestions'] ??
              [];

      // For initial load, get first 15 questions
      int endIndex = 15;
      if (endIndex >= encounteredIds.length) {
        endIndex = encounteredIds.length;
        _hasMoreEncounteredQuestions = false;
      }

      List<String> idsToFetch =
          encounteredIds.take(endIndex).map((id) => id.toString()).toList();

      if (idsToFetch.isEmpty) {
        _isLoadingEncounteredQuestions = false;
        safeNotifyListeners();
        return;
      }

      await _fetchAndAddQuestions(idsToFetch, encounteredIds);
    } catch (e) {
      debugPrint('Error loading encountered questions: $e');
    } finally {
      _isLoadingEncounteredQuestions = false;
      safeNotifyListeners();
    }
  }

  // Add new method for loading more questions
  Future<void> loadMoreEncounteredQuestions() async {
    if (_isLoadingEncounteredQuestions || !_hasMoreEncounteredQuestions) return;

    User? user = _auth.currentUser;

    if (user == null) return;

    _isLoadingEncounteredQuestions = true;
    safeNotifyListeners();

    try {
      // Get the user's encountered question IDs
      DocumentSnapshot userDoc =
          await _firestore.collection(usersCollection).doc(user.uid).get();
      List<dynamic> encounteredIds =
          (userDoc.data() as Map<String, dynamic>)['encounteredQuestions'] ??
              [];

      // Get the IDs of questions we already have
      Set<String> existingIds =
          _encounteredQuestions.map((q) => q['questionId'].toString()).toSet();

      // Filter out IDs we already have
      List<String> remainingIds = encounteredIds
          .where((id) => !existingIds.contains(id.toString()))
          .map((id) => id.toString())
          .toList();

      if (remainingIds.isEmpty) {
        _hasMoreEncounteredQuestions = false;
        _isLoadingEncounteredQuestions = false;
        safeNotifyListeners();
        return;
      }

      // Take next 15 questions from remaining IDs
      List<String> idsToFetch = remainingIds.take(15).toList();

      if (idsToFetch.length < 15) {
        _hasMoreEncounteredQuestions = false;
      }

      await _fetchAndAddQuestions(idsToFetch, encounteredIds);
    } catch (e) {
      debugPrint('Error loading more encountered questions: $e');
    } finally {
      _isLoadingEncounteredQuestions = false;
      safeNotifyListeners();
    }
  }

  // Helper method to fetch and add questions
  Future<void> _fetchAndAddQuestions(
      List<String> idsToFetch, List<dynamic> encounteredIds) async {
    List<Map<String, dynamic>> newQuestions = [];

    // Fetch questions in batches of 10
    for (int i = 0; i < idsToFetch.length; i += 10) {
      int end = (i + 10 < idsToFetch.length) ? i + 10 : idsToFetch.length;
      List<String> batch = idsToFetch.sublist(i, end);

      QuerySnapshot querySnapshot = await _firestore
          .collection(questionsCollection)
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (var doc in querySnapshot.docs) {
        newQuestions.add({
          'questionId': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
    }

    // Sort questions to match the order in encounteredIds
    newQuestions.sort((a, b) {
      int indexA = encounteredIds.indexOf(a['questionId']);
      int indexB = encounteredIds.indexOf(b['questionId']);
      return indexB.compareTo(indexA); // Reverse order (newest first)
    });

    _encounteredQuestions.addAll(newQuestions);
  }

  // Add this method to add newly encountered questions to the history
  void addToEncounteredQuestions(Map<String, dynamic> question) {
    // Only add if it's not already at the top of the list
    if (_encounteredQuestions.isEmpty ||
        _encounteredQuestions.first['questionId'] != question['questionId']) {
      _encounteredQuestions.insert(0, question);
      safeNotifyListeners();
    }
  }
}
