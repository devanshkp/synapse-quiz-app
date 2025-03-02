import 'package:flutter/material.dart';

class TextFormatter {
  /// Formats text with subscripts (t_{0}) and superscripts (t^{2})
  /// Returns a RichText widget with properly formatted text
  /// Supports nested subscripts and superscripts like a_{b_{c}} or a^{b^{c}}
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
}
