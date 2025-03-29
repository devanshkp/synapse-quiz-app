import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TextFormatter {
  static Widget formatText(
    String text, {
    TextStyle? style,
    TextAlign textAlign = TextAlign.center,
    double minFontSize = 9.0,
    int? maxLines,
  }) {
    if (text.isEmpty) {
      return Text('', style: style, textAlign: textAlign);
    }

    // Base font style
    final TextStyle baseStyle = (style ?? const TextStyle()).copyWith(
        fontFamily: 'NotoSansMath',
        fontFeatures: <FontFeature>[
          const FontFeature.subscripts(),
          const FontFeature.superscripts()
        ]);

    // If there are no subscripts or superscripts, return regular text
    if (!text.contains('_{') && !text.contains('^{')) {
      return AutoSizeText(
        text,
        style: baseStyle,
        textAlign: textAlign,
        minFontSize: minFontSize,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        wrapWords: true,
        stepGranularity: 1,
      );
    }

    // Parse the text and create spans
    List<InlineSpan> spans = _parseText(text, baseStyle);

    return AutoSizeText.rich(
      TextSpan(
        style: baseStyle,
        children: spans,
      ),
      minFontSize: minFontSize,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      wrapWords: true,
      stepGranularity: 1,
    );
  }

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

        // Determine the appropriate font features and vertical positioning
        TextStyle scriptStyle = style.copyWith(
          fontSize: style.fontSize,
          fontFamily: '',

          fontFeatures: <FontFeature>[
            isSubscript
                ? const FontFeature.subscripts()
                : const FontFeature.superscripts()
          ],
          // Fine-tune vertical positioning if font features don't perfectly align
          height: isSubscript ? 1.5 : 0.8,
          textBaseline: TextBaseline.alphabetic,
        );

        // Recursively parse the content for nested scripts
        List<InlineSpan> nestedSpans = _parseText(scriptContent, scriptStyle);

        // Create a TextSpan for the subscript/superscript
        spans.add(TextSpan(
          style: scriptStyle,
          children: nestedSpans,
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
