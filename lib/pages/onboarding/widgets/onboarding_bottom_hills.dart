import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/provider_utils.dart';

class OnboardingBottomHills extends StatefulWidget {
  const OnboardingBottomHills({
    required this.maxPage,
    super.key,
  });

  final int maxPage;

  @override
  State<OnboardingBottomHills> createState() => _OnboardingBottomHillsState();

  static double height(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    return screenHeight * (0.12 + (bottomPadding / screenHeight));
  }
}

class _OnboardingBottomHillsState extends State<OnboardingBottomHills> {
  PageController? _controller;
  double _progress = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controller = context.read<PageController>();
    _controller!.replaceListener(_onPageScrolled);
  }

  void _onPageScrolled() {
    if (_controller!.page! <= widget.maxPage) {
      return;
    }

    double progress =
        _controller!.page!.progress(widget.maxPage, widget.maxPage + 1);

    if (progress != _progress) {
      setState(() => _progress = progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final double maxHeight = OnboardingBottomHills.height(context);

    return Positioned(
      top: null,
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      height: maxHeight,
      child: Offstage(
        offstage: _progress == 1.0,
        child: Opacity(
          opacity: 1.0 - _progress,
          child: SizedBox(
            child: Stack(
              children: [
                Positioned.directional(
                  start: 0.0,
                  bottom: 0.0,
                  textDirection: textDirection,
                  child: Transform.translate(
                    offset: Offset(
                      0.0,
                      _progress * maxHeight,
                    ),
                    child: SvgPicture.asset(
                      'assets/onboarding/hill_left.svg',
                      height: maxHeight,
                    ),
                  ),
                ),
                Positioned.directional(
                  end: 0.0,
                  bottom: 0.0,
                  textDirection: textDirection,
                  child: Transform.translate(
                    offset: Offset(
                      0.0,
                      _progress.progress2(0.0, 0.8) * maxHeight,
                    ),
                    child: SvgPicture.asset(
                      'assets/onboarding/hill_right.svg',
                      height: maxHeight * 0.965,
                    ),
                  ),
                ),
                Positioned.directional(
                  textDirection: textDirection,
                  bottom: bottomPadding + (Platform.isIOS ? 0.0 : 15.0),
                  end: 15.0,
                  child: Transform.translate(
                    offset: Offset(
                      0.0,
                      _progress.progress2(0.0, 0.6) * maxHeight,
                    ),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          AppColors.white,
                        ),
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsetsDirectional.only(
                            start: 17.0,
                            end: 16.0,
                            top: 10.0,
                            bottom: 10.0,
                          ),
                        ),
                        elevation: WidgetStateProperty.all<double>(4.0),
                        iconColor: WidgetStateProperty.all<Color>(
                          AppColors.orange,
                        ),
                        foregroundColor: WidgetStateProperty.all<Color>(
                          AppColors.orange,
                        ),
                        iconSize: WidgetStateProperty.all<double>(21.0),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        shadowColor: WidgetStateProperty.all<Color>(
                          AppColors.blackPrimary.withOpacity(0.50),
                        ),
                      ),
                      onPressed: () {
                        final PageController controller =
                            context.read<PageController>();
                        controller.animateToPage(
                          (controller.page!.floor() + 1).toInt(),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Continuer',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                          SizedBox(width: 15.0),
                          icons.Arrow.right(),
                        ],
                      ),
                    ),
                  ),
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
    _controller?.removeListener(_onPageScrolled);
    super.dispose();
  }
}
