import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:smoothapp_poc/pages/onboarding/onboarding.dart';
import 'package:smoothapp_poc/pages/onboarding/onboarding_bottom_hills.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/widgets/page_view.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double fontMultiplier = OnboardingConfig.of(context).fontMultiplier;

    final double hillsHeight = OnboardingBottomHills.height(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: hillsHeight * 0.5 + MediaQuery.viewPaddingOf(context).top,
        bottom: hillsHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 15,
            child: Text(
              'Bienvenue !',
              style: TextStyle(
                fontSize: 45 * fontMultiplier,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            flex: 37,
            child: _SunAndCloud(),
          ),
          const Expanded(
            flex: 45,
            child: FractionallySizedBox(
              widthFactor: 0.65,
              child: Align(
                alignment: Alignment(0, -0.2),
                child: OnboardingText(
                  text:
                      'L’application qui vous aide à choisir des aliments bons pour *vous* et pour la *planète* !',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunAndCloud extends StatefulWidget {
  const _SunAndCloud();

  @override
  State<_SunAndCloud> createState() => _SunAndCloudState();
}

class _SunAndCloudState extends State<_SunAndCloud>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() => setState(() {}));
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final PageController controller = context.watch<PageController>();

    if (!controller.isReady()) {
      return EMPTY_WIDGET;
    }

    return RepaintBoundary(
      child: LayoutBuilder(builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        return Opacity(
          opacity: 1 - controller.page!.progressAndClamp(0, 0.8, 1.0),
          child: Stack(
            children: [
              Positioned.directional(
                top: constraints.maxHeight * 0.3,
                bottom: constraints.maxHeight * 0.2,
                start: (_animation.value * 161.0) * 0.3,
                textDirection: textDirection,
                child: SvgPicture.asset('assets/onboarding/cloud.svg'),
              ),
              const Align(
                alignment: Alignment.center,
                child: RiveAnimation.asset(
                  'assets/animations/off.riv',
                  artboard: 'Success',
                  animations: ['Timeline 1'],
                ),
              ),
              Positioned.directional(
                top: constraints.maxHeight * 0.22,
                bottom: constraints.maxHeight * 0.35,
                end: (_animation.value * 40.0) - 31,
                textDirection: textDirection,
                child: SvgPicture.asset('assets/onboarding/cloud.svg'),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
