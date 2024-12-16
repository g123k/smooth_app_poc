import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/rive_utils.dart';
import 'package:smoothapp_poc/utils/widgets/page_view.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

class OnboardingSunAndCloudAnimation extends StatefulWidget {
  const OnboardingSunAndCloudAnimation({super.key});

  @override
  State<OnboardingSunAndCloudAnimation> createState() =>
      _OnboardingSunAndCloudAnimationState();
}

class _OnboardingSunAndCloudAnimationState
    extends State<OnboardingSunAndCloudAnimation>
    with SingleTickerProviderStateMixin {
  /// An animation for clouds only
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    /// We don't call `setState` here, because the controller is inserted
    /// via Provider
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = context.watch<PageController>();
    final RiveFile? riveFile = RiveAnimationsLoader.of<OffOnboardingAnimation>(
      context,
    );

    if (!controller.isReady() || riveFile == null) {
      return EMPTY_WIDGET;
    }

    return ListenableProvider<Animation<double>>(
      create: (_) => _animation,
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) {
            return Opacity(
              opacity: 1 - controller.page!.progressAndClamp(0, 0.8, 1.0),
              child: Stack(
                children: [
                  _OnboardingCloudAnimation.start(
                    top: constraints.maxHeight * 0.3,
                    bottom: constraints.maxHeight * 0.2,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: RiveAnimation.direct(
                      riveFile,
                      artboard: 'Sun',
                      animations: const ['Timeline 1'],
                    ),
                  ),
                  _OnboardingCloudAnimation.end(
                    top: constraints.maxHeight * 0.22,
                    bottom: constraints.maxHeight * 0.35,
                  ),
                ],
              ),
            );
          },
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

class _OnboardingCloudAnimation extends StatelessWidget {
  const _OnboardingCloudAnimation.start({
    required this.top,
    required this.bottom,
  })  : start = true,
        end = false;

  const _OnboardingCloudAnimation.end({
    required this.top,
    required this.bottom,
  })  : end = true,
        start = false;

  final double top;
  final double bottom;
  final bool end;
  final bool start;

  @override
  Widget build(BuildContext context) {
    return Consumer<Animation<double>>(
      builder: (BuildContext context, Animation<double> animation, _) {
        return Positioned.directional(
          top: top,
          bottom: bottom,
          start: start == true ? (animation.value * 161.0) * 0.3 : null,
          end: end == true ? (animation.value * 40.0) - 31 : null,
          textDirection: Directionality.of(context),
          child: SvgPicture.asset('assets/onboarding/cloud.svg'),
        );
      },
    );
  }
}

class OnboardingPlanetAnimations extends StatelessWidget {
  const OnboardingPlanetAnimations({super.key});

  @override
  Widget build(BuildContext context) {
    return RiveAnimationBuilder<OffOnboardingAnimation>(
      builder: (BuildContext context, RiveFile riveFile) {
        return RiveAnimation.direct(
          riveFile,
          artboard: 'Planet',
          animations: const ['Loop'],
        );
      },
    );
  }
}

class OnboardingConsentAnimation extends StatelessWidget {
  const OnboardingConsentAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiveAnimationBuilder<OffOnboardingAnimation>(
      builder: (BuildContext context, RiveFile riveFile) {
        return RiveAnimation.direct(
          riveFile,
          artboard: 'Consent',
          animations: const ['Loop1'],
        );
      },
    );
  }
}
