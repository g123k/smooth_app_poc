import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/onboarding/onboarding_bottom_hills.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_camera_permission_page.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_explanation_page.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_project_page.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_welcome_page.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/text_utils.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';

// TODO REMOVE THIS IN THE PROD APP
bool onBoardingVisited = false;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  final List<OnboardingPageScrollNotifier> _notifiers =
      <OnboardingPageScrollNotifier>[
    OnboardingPageScrollNotifier(),
    OnboardingPageScrollNotifier(),
    OnboardingPageScrollNotifier(),
    OnboardingPageScrollNotifier(),
    OnboardingPageScrollNotifier(),
  ];

  @override
  void initState() {
    super.initState();
    _checkSize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controller.addListener(_onPageScrolled);
  }

  /// When the app is launched the height == 0
  /// We have to wait for a few frames before the content is ready
  void _checkSize() {
    onNextFrame(() {
      if (MediaQuery.sizeOf(context).height == 0.0) {
        _checkSize();
      } else {
        setState(() {});
      }
    });
  }

  void _onPageScrolled() {
    final int minPage = _controller.page!.floor();
    final int maxPage = _controller.page!.ceil();

    _notifiers[minPage].visibility = _controller.page! - minPage;
    _notifiers[maxPage].visibility = _controller.page! - maxPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F3FE),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: _controller,
          ),
          Provider.value(
            value: OnboardingConfig._(MediaQuery.of(context)),
          ),
        ],
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PageView.builder(
                controller: _controller,
                itemBuilder: (BuildContext context, int position) {
                  return ChangeNotifierProvider.value(
                    value: _notifiers[position],
                    child: switch (position) {
                      0 => const OnboardingWelcomePage(),
                      1 => const OnboardingProjectPage(),
                      2 => const OnboardingExplanationPage(),
                      3 || _ => const OnboardingCameraPermissionPage(),
                    },
                  );
                },
                itemCount: 4,
              ),
            ),
            const OnboardingBottomHills(
              maxPage: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Expose for each page its visibility (between -1 and 1)
class OnboardingPageScrollNotifier extends ValueNotifier<double> {
  OnboardingPageScrollNotifier() : super(0.0);

  @protected
  set visibility(double value) {
    this.value = value;
    notifyListeners();
  }

  double get visibility => value;

  @override
  @protected
  double get value => super.value;

  static OnboardingPageScrollNotifier of(BuildContext context) =>
      context.watch<OnboardingPageScrollNotifier>();
}

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
    final double fontMultiplier = OnboardingConfig.of(context).fontMultiplier;

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

class OnboardingConfig {
  final double fontMultiplier;

  OnboardingConfig._(MediaQueryData mediaQuery)
      : fontMultiplier = ((mediaQuery.size.width * 45) / 428) / 45;

  static OnboardingConfig of(BuildContext context) =>
      context.watch<OnboardingConfig>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingConfig &&
          runtimeType == other.runtimeType &&
          fontMultiplier == other.fontMultiplier;

  @override
  int get hashCode => fontMultiplier.hashCode;
}
