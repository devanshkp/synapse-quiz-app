import 'package:flutter/material.dart';

class TextFormatter {
  /// Formats text with subscripts (t_{0}) and superscripts (t^{2})
  /// Returns a RichText widget with properly formatted text
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

    List<InlineSpan> spans = [];
    int currentIndex = 0;

    // Regular expression to match both subscript and superscript patterns
    RegExp regExp = RegExp(r'([_^])\{([^{}]*)\}');

    // Find all matches in the text
    Iterable<RegExpMatch> matches = regExp.allMatches(text);

    for (RegExpMatch match in matches) {
      // Add text before the match
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: baseStyle,
        ));
      }

      // Determine if it's a subscript or superscript
      bool isSubscript = match.group(1) == '_';
      String scriptText = match.group(2) ?? '';

      // Create the subscript or superscript
      spans.add(WidgetSpan(
        alignment: isSubscript
            ? PlaceholderAlignment.bottom
            : PlaceholderAlignment.top,
        child: Transform.translate(
          offset: Offset(0, isSubscript ? 4 : -7),
          child: Text(
            scriptText,
            style: baseStyle.copyWith(
              fontSize: (baseStyle.fontSize ?? 14) * 0.7,
            ),
          ),
        ),
      ));

      currentIndex = match.end;
    }

    // Add any remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
      textAlign: textAlign,
    );
  }
}
