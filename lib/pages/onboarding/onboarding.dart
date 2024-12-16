import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_analytics_page.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_camera_permission_page.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_explanation_page.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_project_page.dart';
import 'package:smoothapp_poc/pages/onboarding/pages/onboarding_welcome_page.dart';
import 'package:smoothapp_poc/pages/onboarding/widgets/onboarding_bottom_hills.dart';
import 'package:smoothapp_poc/utils/rive_utils.dart';
import 'package:smoothapp_poc/utils/system_ui.dart';
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

  int _numberOfPages = 4;

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUIStyle.dark,
      child: Scaffold(
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
          child: RiveAnimationsLoader<OffOnboardingAnimation>(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: PageView.builder(
                    controller: _controller,
                    physics: _numberOfPages == 5
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    itemBuilder: (BuildContext context, int position) {
                      return ChangeNotifierProvider.value(
                        value: _notifiers[position],
                        child: switch (position) {
                          0 => const OnboardingWelcomePage(),
                          1 => const OnboardingProjectPage(),
                          2 => const OnboardingExplanationPage(),
                          3 => OnboardingCameraPermissionPage(
                              onPermissionValidated: () {
                                setState(() {
                                  _numberOfPages = 5;
                                  onNextFrame(() {
                                    _controller.animateToPage(
                                      4,
                                      duration:
                                          const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                });
                              },
                            ),
                          4 || _ => const OnboardingAnalyticsPage(),
                        },
                      );
                    },
                    itemCount: _numberOfPages,
                  ),
                ),
                const OnboardingBottomHills(
                  maxPage: 2,
                ),
              ],
            ),
          ),
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
  set visibility(double value) => this.value = value;

  double get visibility => value;

  /// Hide the value getter & setter
  @override
  @protected
  double get value => super.value;

  @override
  @protected
  set value(double newValue) => super.value = newValue;

  static OnboardingPageScrollNotifier of(BuildContext context) =>
      context.watch<OnboardingPageScrollNotifier>();
}

class OnboardingConfig {
  final double fontMultiplier;

  OnboardingConfig._(MediaQueryData mediaQuery)
      : fontMultiplier = computeFontMultiplier(mediaQuery);

  static double computeFontMultiplier(MediaQueryData mediaQuery) =>
      ((mediaQuery.size.width * 45) / 428) / 45;

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
