import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/onboarding/onboarding.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/text_utils.dart';

class OnboardingText extends StatelessWidget {
  const OnboardingText({
    required this.text,
    this.margin,
    super.key,
  });

  final String text;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    double fontMultiplier;
    try {
      fontMultiplier = OnboardingConfig.of(context).fontMultiplier;
    } catch (_) {
      fontMultiplier =
          OnboardingConfig.computeFontMultiplier(MediaQuery.of(context));
    }

    return RichText(
      text: TextSpan(
        children: _extractChunks().map(((String text, bool highlighted) el) {
          if (el.$2) {
            return _createSpan(el.$1, 30 * fontMultiplier);
          } else {
            return TextSpan(text: el.$1);
          }
        }).toList(growable: false),
        style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 30 * fontMultiplier,
              height: 1.53,
              fontWeight: FontWeight.w600,
            ),
      ),
      textAlign: TextAlign.center,
    );
  }

  Iterable<(String, bool)> _extractChunks() {
    final Iterable<RegExpMatch> matches =
        RegExp('\\*(.*?)\\*').allMatches(text);

    if (matches.isEmpty) {
      return [(text, false)];
    }

    List<(String, bool)> chunks = [];

    int lastMatch = 0;

    for (RegExpMatch match in matches) {
      if (matches.first.start > 0) {
        chunks.add((text.substring(lastMatch, match.start), false));
      }

      chunks.add((text.substring(match.start + 1, match.end - 1), true));
      lastMatch = match.end;
    }

    if (lastMatch < text.length) {
      chunks.add((text.substring(lastMatch), false));
    }

    return chunks;
  }

  WidgetSpan _createSpan(String text, double fontSize) => HighlightedTextSpan(
        text: text,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsetsDirectional.only(
          top: 1.0,
          bottom: 5.0,
          start: 15.0,
          end: 15.0,
        ),
        margin: margin ?? const EdgeInsetsDirectional.symmetric(vertical: 2.5),
        backgroundColor: AppColors.orange,
        radius: 30.0,
      );
}
