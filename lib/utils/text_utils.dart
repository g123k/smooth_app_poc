import 'package:diacritic/diacritic.dart';
import 'package:flutter/painting.dart';

class TextHighlighter {
  /// Returns a List containing parts of the text with the right style
  /// according to the [filter]
  static List<(String, TextStyle?)> getParts({
    required String text,
    required String filter,
    required TextStyle? defaultStyle,
    required TextStyle? highlightedStyle,
  }) {
    final Iterable<RegExpMatch> highlightedParts =
        RegExp(removeDiacritics(filter).toLowerCase().trim()).allMatches(
      removeDiacritics(text).toLowerCase(),
    );

    final List<(String, TextStyle?)> parts = <(String, TextStyle?)>[];

    if (highlightedParts.isEmpty) {
      parts.add((text, defaultStyle));
    } else {
      parts
          .add((text.substring(0, highlightedParts.first.start), defaultStyle));
      for (int i = 0; i != highlightedParts.length; i++) {
        final RegExpMatch subPart = highlightedParts.elementAt(i);

        parts.add(
          (text.substring(subPart.start, subPart.end), highlightedStyle),
        );

        if (i < highlightedParts.length - 1) {
          parts.add((
            text.substring(
                subPart.end, highlightedParts.elementAt(i + 1).start),
            defaultStyle
          ));
        } else if (subPart.end < text.length) {
          parts.add((text.substring(subPart.end, text.length), defaultStyle));
        }
      }
    }
    return parts;
  }
}
