import 'package:flutter/material.dart';

class TextFormatter {
  static Widget formatText(
    String text, {
    TextStyle? style,
    TextAlign textAlign = TextAlign.center,
  }) {
    if (text.isEmpty) {
      return Text('', style: style, textAlign: textAlign);
    }

    // Ensure the style includes Poppins font family
    final TextStyle baseStyle = (style ?? const TextStyle()).copyWith(
      fontFamily: 'Poppins',
    );

    // If there are no subscripts or superscripts, return regular text
    if (!text.contains('_{') && !text.contains('^{')) {
      return Text(text, style: baseStyle, textAlign: textAlign);
    }

    // Parse the text and create spans
    List<InlineSpan> spans = _parseText(text, baseStyle);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
      textAlign: textAlign,
    );
  }

  /// Recursively parses text to handle nested subscripts and superscripts
  static List<InlineSpan> _parseText(String text, TextStyle style) {
    List<InlineSpan> spans = [];
    int currentIndex = 0;

    // Find the first occurrence of a subscript or superscript
    int nextSubIndex = text.indexOf('_{', currentIndex);
    int nextSupIndex = text.indexOf('^{', currentIndex);

    while (nextSubIndex != -1 || nextSupIndex != -1) {
      // Determine which comes first
      bool isSubscript;
      int nextIndex;

      if (nextSubIndex == -1) {
        isSubscript = false;
        nextIndex = nextSupIndex;
      } else if (nextSupIndex == -1) {
        isSubscript = true;
        nextIndex = nextSubIndex;
      } else {
        isSubscript = nextSubIndex < nextSupIndex;
        nextIndex = isSubscript ? nextSubIndex : nextSupIndex;
      }

      // Add text before the script
      if (nextIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, nextIndex),
          style: style,
        ));
      }

      // Find the matching closing brace
      int openBraces = 1;
      int closeIndex = nextIndex + 2; // Skip the '_{' or '^{'

      while (openBraces > 0 && closeIndex < text.length) {
        if (text[closeIndex] == '{') {
          openBraces++;
        } else if (text[closeIndex] == '}') {
          openBraces--;
        }
        closeIndex++;
      }

      if (openBraces > 0) {
        // No matching closing brace found, treat as plain text
        spans.add(TextSpan(
          text: text.substring(nextIndex, nextIndex + 2),
          style: style,
        ));
        currentIndex = nextIndex + 2;
      } else {
        // Extract the content inside the braces
        String scriptContent = text.substring(nextIndex + 2, closeIndex - 1);

        // Recursively parse the content for nested scripts
        List<InlineSpan> nestedSpans = _parseText(
            scriptContent,
            style.copyWith(
              fontSize: (style.fontSize ?? 14) * 0.7,
            ));

        // Create the script widget
        spans.add(WidgetSpan(
          alignment: isSubscript
              ? PlaceholderAlignment.bottom
              : PlaceholderAlignment.top,
          child: Transform.translate(
            offset: Offset(0, isSubscript ? 4 : -7),
            child: RichText(
              text: TextSpan(
                style: style.copyWith(
                  fontSize: (style.fontSize ?? 14) * 0.7,
                ),
                children: nestedSpans,
              ),
            ),
          ),
        ));

        currentIndex = closeIndex;
      }

      // Find the next occurrence
      nextSubIndex = text.indexOf('_{', currentIndex);
      nextSupIndex = text.indexOf('^{', currentIndex);
    }

    // Add any remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: style,
      ));
    }

    return spans;
  }

  /// Formats a title string by replacing underscores with spaces while preserving capitalization
  static String formatTitlePreservingCase(String title) {
    if (title.isEmpty) return title;

    // Replace underscores with spaces
    String result = title.replaceAll('_', ' ');

    // Split the string into words
    List<String> words = result.split(' ');

    // Process each word to capitalize first letter if not already capitalized
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        // Check if the word is an acronym (all uppercase)
        bool isAcronym =
            words[i].toUpperCase() == words[i] && words[i].length > 1;

        // If it's not an acronym, capitalize only the first letter
        if (!isAcronym) {
          words[i] = words[i][0].toUpperCase() +
              (words[i].length > 1 ? words[i].substring(1) : '');
        }
        // If it is an acronym, leave it as is
      }
    }

    // Join the words back together
    return words.join(' ');
  }
}
