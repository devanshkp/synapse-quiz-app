import 'package:flutter/material.dart';
import 'package:flutter_application/pages/topic.dart';
import 'package:flutter_application/utils/text_formatter.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import '../../constants.dart';

class SearchPage extends StatefulWidget {
  final bool fromHome;
  const SearchPage({super.key, this.fromHome = false});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<Map<String, dynamic>> _allTopics = [
    {
      'title': 'algorithms',
      'iconName': 'algorithms.png',
      'iconSize': 65.0,
      'color': algorithmsColor,
      'bottomOffset': -10.0,
      'section': 'all'
    },
    {
      'title': 'SWE_fundamentals',
      'iconName': 'SWE_fundamentals.png',
      'iconSize': 65.0,
      'color': sweFundamentalsColor,
      'bottomOffset': -10.0,
      'section': 'all'
    },
    {
      'title': 'discrete_math',
      'iconName': 'discrete_math.png',
      'iconSize': 65.0,
      'color': discreteMathColor,
      'section': 'all'
    },
    {
      'title': 'computer_network',
      'iconName': 'computer_network.png',
      'iconSize': 65.0,
      'color': computerNeworkColor,
      'section': 'all'
    },
    {
      'title': 'data_science',
      'iconName': 'data_science.png',
      'iconSize': 68.0,
      'color': dataScienceColor,
      'bottomOffset': -10.0,
      'section': 'all'
    },
    {
      'title': 'cloud_computing',
      'iconName': 'cloud_computing.png',
      'iconSize': 65.0,
      'bottomOffset': -5.0,
      'color': cloudComputingColor,
      'section': 'all'
    },
    {
      'title': 'artificial_intelligence',
      'iconName': 'artificial_intelligence.png',
      'iconSize': 73.0,
      'color': artificialIntelligenceColor,
      'bottomOffset': -15.0,
      'section': 'all'
    },
    {
      'title': 'cyber_security',
      'iconName': 'cyber_security.png',
      'iconSize': 72.0,
      'bottomOffset': -10.0,
      'color': cyberSecurityColor,
      'section': 'all'
    },
    {
      'title': 'data_structures',
      'iconName': 'data_structures.png',
      'iconSize': 68.0,
      'color': dataStructuresColor,
      'bottomOffset': -5.0,
      'section': 'all'
    },
    {
      'title': 'machine_learning',
      'iconName': 'machine_learning.png',
      'iconSize': 70.0,
      'bottomOffset': -10.0,
      'color': machineLearningColor,
      'section': 'all'
    },
    {
      'title': 'database',
      'iconName': 'database.png',
      'iconSize': 70.0,
      'bottomOffset': -10.0,
      'color': databaseColor,
      'section': 'all'
    },
    {
      'title': 'probability_&_statistics',
      'iconName': 'probability_&_statistics.png',
      'iconSize': 65.0,
      'color': probabilityStatisticsColor,
      'section': 'all'
    },
  ];

  final List<Map<String, dynamic>> _recommendedTopics = [
    {
      'title': 'machine_learning',
      'iconName': 'machine_learning.png',
      'iconSize': 70.0,
      'bottomOffset': -10.0,
      'color': machineLearningColor,
      'section': 'recommended'
    },
    {
      'title': 'data_structures',
      'iconName': 'data_structures.png',
      'iconSize': 68.0,
      'color': dataStructuresColor,
      'bottomOffset': -5.0,
      'section': 'recommended'
    },
    {
      'title': 'cyber_security',
      'iconName': 'cyber_security.png',
      'iconSize': 72.0,
      'color': cyberSecurityColor,
      'bottomOffset': -10.0,
      'section': 'recommended'
    },
    {
      'title': 'database',
      'iconName': 'database.png',
      'iconSize': 70.0,
      'bottomOffset': -10.0,
      'color': databaseColor,
      'section': 'recommended'
    },
  ];

  List<Map<String, dynamic>> _filteredTopics = [];

  @override
  void initState() {
    super.initState();
    _filteredTopics = List.from(_allTopics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterTopics(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTopics = List.from(_allTopics);
      } else {
        // Normalize the query: lowercase and handle both spaces and underscores
        final normalizedQuery = query.toLowerCase().trim();

        _filteredTopics = _allTopics.where((topic) {
          // Get the topic title and normalize it
          final topicTitle = topic['title'].toString().toLowerCase();

          // Replace underscores with spaces for matching with user input containing spaces
          final titleWithSpaces = topicTitle.replaceAll('_', ' ');

          // Split into words for word-start matching
          final words = titleWithSpaces.split(' ');

          // Check if any word starts with the query
          final wordStartMatch =
              words.any((word) => word.startsWith(normalizedQuery));

          // Check if the whole title starts with the query (for multi-word queries)
          final titleStartMatch = titleWithSpaces.startsWith(normalizedQuery);

          // Also check if the query with underscores matches
          final queryWithUnderscores = normalizedQuery.replaceAll(' ', '_');
          final underscoreMatch = topicTitle.startsWith(queryWithUnderscores);

          return wordStartMatch || titleStartMatch || underscoreMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      child: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside the text field
          _searchFocusNode.unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: backgroundPageColor,
            toolbarHeight: 90,
            leading: widget.fromHome
                ? Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 20.0),
                    child: IconButton(
                      onPressed: () {
                        // Ensure we're popping back to the correct screen
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  )
                : null,
            title: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "Search Topics...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                        onChanged: _filterTopics,
                      ),
                    ),
                    // Show clear icon when there's text, otherwise show search icon
                    GestureDetector(
                      onTap: _searchQuery.isNotEmpty
                          ? () {
                              // Clear the search field and reset results
                              setState(() {
                                _searchQuery = '';
                                _filteredTopics = List.from(_allTopics);
                                _searchController.clear();
                                _searchFocusNode
                                    .unfocus(); // Also unfocus when clearing
                              });
                            }
                          : null,
                      child: Icon(
                        _searchQuery.isNotEmpty ? Icons.close : Icons.search,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ListView(
              children: [
                const SizedBox(height: 30),

                // Show recommended section only if not searching
                if (_searchQuery.isEmpty) ...[
                  const Text(
                    "Recommended for you",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _recommendedTopics
                        .map((topic) => TopicButton(
                              title: topic['title'],
                              iconName: topic['iconName'],
                              iconSize: topic['iconSize'],
                              color: topic['color'],
                              titleFontSize: 13,
                              buttonType: "search",
                              section: topic['section'],
                              bottomOffset: topic['bottomOffset'] ?? 0,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 30),
                ],

                // All topics or search results
                Text(
                  _searchQuery.isEmpty ? "All Topics" : "Search Results",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _filteredTopics.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "No topics found",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    : _searchQuery.isEmpty
                        // Grid view for all topics (when not searching)
                        ? GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 1.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: _filteredTopics
                                .map((topic) => TopicButton(
                                      title: topic['title'],
                                      iconName: topic['iconName'],
                                      iconSize: topic['iconSize'],
                                      color: topic['color'],
                                      titleFontSize: 13,
                                      buttonType: "search",
                                      section: topic['section'],
                                      bottomOffset: topic['bottomOffset'] ?? 0,
                                    ))
                                .toList(),
                          )
                        // List view for search results (one topic per line)
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredTopics.length,
                            itemBuilder: (context, index) {
                              final topic = _filteredTopics[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        topic['color'].withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: topic['color']
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Image.asset(
                                        'assets/images/topics/${topic['iconName']}',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    title: Text(
                                      TextFormatter.formatTitlePreservingCase(
                                          topic['title'].toString()),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white54,
                                      size: 16,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              TopicDetailsPage(
                                            topicName: topic['title'],
                                            iconName: topic['iconName'],
                                            topicColor: topic['color'],
                                            buttonType: "search",
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOutCubic;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
                                            var offsetAnimation =
                                                animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                          transitionDuration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
