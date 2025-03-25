import 'package:flutter/material.dart';
import 'package:flutter_application/pages/secondary/topic.dart';
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
  static const List<Map<String, dynamic>> _allTopics = [
    {
      'title': 'algorithms',
      'iconName': 'algorithms.png',
      'iconRatio': 1,
      'color': algorithmsColor,
      'bottomOffset': -10.0,
      'section': 'all'
    },
    {
      'title': 'SWE_fundamentals',
      'iconName': 'SWE_fundamentals.png',
      'iconRatio': 1,
      'color': sweFundColor,
      'bottomOffset': -10.0,
      'section': 'all'
    },
    {
      'title': 'discrete_math',
      'iconName': 'discrete_math.png',
      'iconRatio': 1,
      'color': discMathColor,
      'section': 'all'
    },
    {
      'title': 'computer_network',
      'iconName': 'computer_network.png',
      'iconRatio': 1,
      'color': compNetworkColor,
      'section': 'all'
    },
    {
      'title': 'data_science',
      'iconName': 'data_science.png',
      'iconRatio': 1.05,
      'color': dataSciColor,
      'bottomOffset': -10.0,
      'section': 'all'
    },
    {
      'title': 'cloud_computing',
      'iconName': 'cloud_computing.png',
      'iconRatio': 1,
      'bottomOffset': -5.0,
      'color': cloudCompColor,
      'section': 'all'
    },
    {
      'title': 'artificial_intelligence',
      'iconName': 'artificial_intelligence.png',
      'iconRatio': 1.125,
      'color': artificialIntelColor,
      'bottomOffset': -15.0,
      'section': 'all'
    },
    {
      'title': 'cyber_security',
      'iconName': 'cyber_security.png',
      'iconRatio': 1.12,
      'bottomOffset': -10.0,
      'color': cyberSecColor,
      'section': 'all'
    },
    {
      'title': 'data_structures',
      'iconName': 'data_structures.png',
      'iconRatio': 1.05,
      'color': dataStructColor,
      'bottomOffset': -5.0,
      'section': 'all'
    },
    {
      'title': 'machine_learning',
      'iconName': 'machine_learning.png',
      'iconRatio': 1.075,
      'bottomOffset': -10.0,
      'color': macLearningColor,
      'section': 'all'
    },
    {
      'title': 'database',
      'iconName': 'database.png',
      'iconRatio': 1.075,
      'bottomOffset': -10.0,
      'color': databaseColor,
      'section': 'all'
    },
    {
      'title': 'probability_&_statistics',
      'iconName': 'probability_&_statistics.png',
      'iconRatio': 1,
      'color': probStatColor,
      'section': 'all'
    },
  ];

  static const List<Map<String, dynamic>> _recommendedTopics = [
    {
      'title': 'machine_learning',
      'iconName': 'machine_learning.png',
      'iconRatio': 1.075,
      'bottomOffset': -10.0,
      'color': macLearningColor,
      'section': 'recommended'
    },
    {
      'title': 'data_structures',
      'iconName': 'data_structures.png',
      'iconRatio': 1.05,
      'color': dataStructColor,
      'bottomOffset': -5.0,
      'section': 'recommended'
    },
    {
      'title': 'cyber_security',
      'iconName': 'cyber_security.png',
      'iconRatio': 1.12,
      'color': cyberSecColor,
      'bottomOffset': -10.0,
      'section': 'recommended'
    },
    {
      'title': 'database',
      'iconName': 'database.png',
      'iconRatio': 1.075,
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
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    double extraPadding = 0;
    if (screenWidth < 800) {
      extraPadding = screenWidth * 0.05;
    } else if (screenWidth < 850) {
      extraPadding = screenWidth * 0.1;
    } else if (screenWidth < 1000) {
      extraPadding = screenWidth * .125;
    } else {
      extraPadding = screenWidth * .15;
    }
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
                      onTap: _searchQuery.isNotEmpty && mounted
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isTablet ? 3 : 2;
              final recommendedtopics = isTablet
                  ? _recommendedTopics.sublist(0, 3)
                  : _recommendedTopics;

              // Calculate responsive sizes based on container width

              final baseIconSize =
                  constraints.maxWidth / (crossAxisCount * 3.5);
              final iconSize = baseIconSize.clamp(40.0, 80.0); // Min 50, max 75

              final baseFontSize = constraints.maxWidth / (crossAxisCount * 16);
              final titleFontSize = baseFontSize.clamp(10.0, 15.0);

              return ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? extraPadding : 18),
                children: [
                  const SizedBox(height: 30),

                  // Show recommended section only if not searching
                  if (_searchQuery.isEmpty) ...[
                    Text(
                      "Recommended",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize * 1.1, // Slightly larger
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: recommendedtopics.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.85,
                      ),
                      itemBuilder: (context, index) {
                        final topic = recommendedtopics[index];
                        return TopicButton(
                          title: topic['title'],
                          iconName: topic['iconName'],
                          iconSize: topic['iconRatio'] * iconSize,
                          color: topic['color'],
                          titleFontSize: titleFontSize,
                          buttonType: 'search',
                          section: 'recommended',
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],

                  // All topics or search results
                  Text(
                    _searchQuery.isEmpty ? "All Topics" : "Search Results",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize * 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _filteredTopics.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(titleFontSize),
                            child: Text(
                              "No topics found",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: titleFontSize,
                              ),
                            ),
                          ),
                        )
                      : _searchQuery.isEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              itemCount: _allTopics.length,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.85,
                              ),
                              itemBuilder: (context, index) {
                                final topic = _allTopics[index];
                                return TopicButton(
                                  title: topic['title'],
                                  iconName: topic['iconName'],
                                  iconSize: topic['iconRatio'] * iconSize,
                                  color: topic['color'],
                                  titleFontSize: titleFontSize,
                                  buttonType: 'search',
                                  section: 'all',
                                );
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredTopics.length,
                              itemBuilder: (context, index) {
                                final topic = _filteredTopics[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: titleFontSize * 0.75),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: topic['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: titleFontSize,
                                        vertical: titleFontSize * 0.5,
                                      ),
                                      leading: Container(
                                        width: iconSize * 1.2,
                                        height: iconSize * 1.2,
                                        padding:
                                            EdgeInsets.all(titleFontSize * 0.3),
                                        decoration: BoxDecoration(
                                          color:
                                              topic['color'].withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Image.asset(
                                          'assets/images/topics/${topic['iconName']}',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      title: Text(
                                        TextFormatter.formatTitlePreservingCase(
                                            topic['title'].toString()),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white54,
                                        size: titleFontSize * 0.8,
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
                                              const curve =
                                                  Curves.easeInOutCubic;

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
                                            transitionDuration: const Duration(
                                                milliseconds: 300),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
