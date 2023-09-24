import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';
import 'package:smoothapp_poc/utils/widgets/circled_icon.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar/search_bar.dart';

//ignore_for_file: constant_identifier_names
class SearchBarTop extends StatefulWidget {
  const SearchBarTop({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  State<SearchBarTop> createState() => _SearchBarTopState();
}

class _SearchBarTopState extends State<SearchBarTop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => setState(() {}));

    onNextFrame(() {
      final SearchAppBarData data = SearchAppBarData.of(context);

      if (data.backButton) {
        _animation = Tween<double>(
          begin: 0.0,
          end: _BackButton.SIZE,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.0,
              0.5,
              curve: Curves.easeIn,
            ),
          ),
        );

        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool backButton = SearchAppBarData.of(context).backButton;
    return WillPopScope(
      onWillPop: () async {
        if (_animation == null) {
          return true;
        }

        _controller.duration = Duration(
          milliseconds: _controller.duration!.inMilliseconds ~/ 2,
        );
        await _controller.reverse();
        if (mounted) {
          Navigator.of(context).pop();
        }

        return false;
      },
      child: SizedBox.expand(
        child: Padding(
          padding: ExpandableSearchAppBar.CONTENT_PADDING,
          child: Stack(
            children: [
              if (backButton)
                Opacity(
                  opacity: _animation != null ? _controller.value : 1.0,
                  child: _BackButton(
                    onTap: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                top: 0.0,
                bottom: 0.0,
                end: 0.0,
                start: _animation != null
                    ? ((_BackButton.SIZE + 8.0) * _controller.value)
                    : 0.0,
                child: AppBarLogo(progress: widget.progress),
              ),
              if (SearchAppBarData.of(context).actionIcon != null)
                _SuffixButton(progress: widget.progress),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarLogo extends StatelessWidget {
  const AppBarLogo({
    super.key,
    required this.progress,
  });

  /// The image max width
  static const double MAX_WIDTH = 346.0;

  /// The image min height
  static const double MIN_HEIGHT = 35.0;

  /// The image max height
  static const double MAX_HEIGHT = 61.0;

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.0,
      margin: ExpandableSearchAppBar.LOGO_CONTENT_PADDING,
      child: LayoutBuilder(builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final SearchAppBarData data = SearchAppBarData.of(context);
        final double width = constraints.maxWidth;
        double imageWidth = AppBarLogo.MAX_WIDTH;

        if (imageWidth > width * 0.8) {
          double tmp = width;

          if (data.actionIcon != null) {
            tmp -= data.backButton
                ? _SuffixButton.SIZE_WITH_PREFIX
                : _SuffixButton.SIZE_WITHOUT_PREFIX;
          }

          imageWidth = math.min(
            width * 0.8,
            tmp,
          );
        }

        return Container(
          width: imageWidth,
          height: math.max(
              AppBarLogo.MAX_HEIGHT * (1 - progress), AppBarLogo.MIN_HEIGHT),
          margin: EdgeInsetsDirectional.only(
            start: math.max((1 - progress) * ((width - imageWidth) / 2), 10.0),
            bottom: 5.0,
          ),
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: imageWidth * progress.progress2(1.0, 1.0),
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              width: 346.0,
              height: 61.0,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
        );
      }),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onTap,
  });

  static const double SIZE = 36.0;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox.square(
        dimension: SIZE,
        child: CircledIcon(
          padding: EdgeInsets.zero,
          icon: const icons.Arrow.left(),
          onPressed: onTap,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ),
    );
  }
}

class _SuffixButton extends StatelessWidget {
  const _SuffixButton({
    required this.progress,
  });

  static const double SIZE_WITHOUT_PREFIX = 48.0;
  static const double SIZE_WITH_PREFIX = 36.0;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final SearchAppBarData data = SearchAppBarData.of(context);

    return Positioned.directional(
      top: 0.0,
      bottom: 0.0,
      end: 2.0,
      textDirection: Directionality.of(context),
      child: SizedBox.square(
        dimension: data.backButton
            ? SIZE_WITH_PREFIX
            : SIZE_WITHOUT_PREFIX *
                progress.progressAndClamp(
                  // Those values are clearly hand-crafted
                  0.55,
                  0.90,
                  1.0,
                ),
        child: Semantics(
          value: data.actionSemantics,
          excludeSemantics: data.actionSemantics != null,
          child: IconButton(
            icon: LayoutBuilder(
              builder: (context, BoxConstraints constraints) {
                return IconTheme(
                  data: IconThemeData(
                    color: AppColors.blackPrimary,
                    size: math.min(28.0, constraints.minSide),
                  ),
                  child: data.actionIcon!,
                );
              },
            ),
            onPressed: data.onActionButtonClicked,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              side: MaterialStateProperty.all(
                const BorderSide(color: AppColors.primary),
              ),
              foregroundColor: MaterialStateProperty.all(Colors.black),
              shape: MaterialStateProperty.all(
                const CircleBorder(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
