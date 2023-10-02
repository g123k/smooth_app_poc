import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';

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

class HighlightedTextSpan extends WidgetSpan {
  HighlightedTextSpan({
    required String text,
    required TextStyle textStyle,
    required EdgeInsetsGeometry padding,
    required Color backgroundColor,
    required double radius,
    EdgeInsetsGeometry? margin,
  })  : assert(radius > 0.0),
        super(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(
                Radius.circular(radius),
              ),
            ),
            margin: margin,
            padding: padding,
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        );
}
