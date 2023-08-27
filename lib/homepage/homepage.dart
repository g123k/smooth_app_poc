import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/homepage/appbar/search_bar.dart';
import 'package:smoothapp_poc/homepage/appbar/settings_icon.dart';
import 'package:smoothapp_poc/homepage/camera/camera_view.dart';
import 'package:smoothapp_poc/homepage/camera/expandable_camera.dart';
import 'package:smoothapp_poc/homepage/list/history_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();

  static HomePageState of(BuildContext context) {
    return context.read<HomePageState>();
  }
}

class HomePageState extends State<HomePage> {
  static const double CAMERA_PEAK = 0.4;
  static const double BORDER_RADIUS = 30.0;
  static const double APP_BAR_HEIGHT = 160.0;

  // Lazy values (used to minimize the time required on each frame)
  double? _screenPaddingTop;
  double? _cameraPeakHeight;

  late ScrollController _controller;
  late CustomScannerController _cameraController;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _cameraController = CustomScannerController(
      controller: MobileScannerController(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_initialOffset);
    });
  }

  bool _ignoreNextEvent = false;
  bool _ignoreAllEvents = false;
  SettingsIconType _floatingSettingsType = SettingsIconType.floating;
  ScrollDirection _direction = ScrollDirection.forward;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: NotificationListener(
        onNotification: (Object? notification) {
          if (_ignoreAllEvents) {
            return false;
          }

          if (notification is UserScrollNotification) {
            _direction = notification.direction;
          } else if (notification is ScrollEndNotification) {
            if (notification.metrics.axis != Axis.vertical ||
                notification.dragDetails == null) {
              return false;
            }

            _onScrollEnded(notification);
          } else if (notification is ScrollUpdateNotification) {
            if (notification.metrics.axis != Axis.vertical) {
              return false;
            }
            _onScrollUpdate(notification);
          }
          return false;
        },
        child: Provider.value(
          value: this,
          child: Stack(
            children: [
              ChangeNotifierProvider(
                create: (_) => _controller,
                child: CustomScrollView(
                  physics: _ignoreAllEvents
                      ? const NeverScrollableScrollPhysics()
                      : _CustomPhysics(steps: [
                          0.0,
                          cameraPeak,
                          cameraHeight,
                        ]),
                  controller: _controller,
                  slivers: [
                    ExpandableCamera(
                      controller: _cameraController,
                      height: MediaQuery.of(context).size.height,
                    ),
                    const ExpandableAppBar(),
                    const ProductHistoryList(),
                    const ProductHistoryList(),
                    const ProductHistoryList(),
                    const ProductHistoryList(),
                    const ProductHistoryList(),
                    const SliverListBldr(),
                  ],
                ),
              ),
              SettingsIcon(
                type: _floatingSettingsType,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double get cameraHeight => MediaQuery.of(context).size.height;

  double get cameraPeak => _initialOffset;

  double get _appBarHeight =>
      ExpandableAppBar.HEIGHT + MediaQuery.paddingOf(context).top;

  double get _initialOffset => cameraHeight * (1 - CAMERA_PEAK);

  bool get isCameraVisible => _controller.offset == 0.0;

  bool get isExpanded => _controller.offset < _initialOffset;

  void ignoreAllEvents(bool value) {
    setState(() => _ignoreAllEvents = value);
  }

  void expandCamera({Duration? duration}) {
    _controller.animateTo(
      0,
      duration: duration ?? const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void collapseCamera() {
    _controller.animateTo(
      _initialOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void showAppBar() {
    _controller.animateTo(
      MediaQuery.sizeOf(context).height,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );

    _ignoreNextEvent = true;
  }

  onDispose() {
    _controller.dispose();
    super.dispose();
  }

  /// On scroll, update:
  /// - The status bar theme (light/dark)
  /// - Start/stop the camera
  /// - Update the type of the settings icon
  void _onScrollUpdate(ScrollUpdateNotification notification) {
    SettingsIconType newValue;

    if (_controller.offset < cameraHeight) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      if (!_cameraController.isStarting) {
        _cameraController.start();
      }
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      _cameraController.stop();
    }

    _screenPaddingTop ??= MediaQuery.of(context).padding.top;

    if (notification.metrics.pixels < 20.0) {
      newValue = SettingsIconType.invisible;
    } else if (notification.metrics.pixels <
        cameraHeight - _screenPaddingTop!) {
      newValue = SettingsIconType.floating;
    } else {
      newValue = SettingsIconType.appBar;
    }

    if (newValue != _floatingSettingsType) {
      setState(() => _floatingSettingsType = newValue);
    }
  }

  /// When a scroll is finished, animate the content to the correct position
  void _onScrollEnded(ScrollEndNotification notification) {
    final double cameraViewHeight = cameraHeight;
    final double scrollPosition = notification.metrics.pixels;

    if ([0.0, cameraPeak, cameraViewHeight].contains(scrollPosition) ||
        scrollPosition.roundToDouble() >= cameraViewHeight ||
        _direction == ScrollDirection.idle ||
        _ignoreNextEvent) {
      _ignoreNextEvent = false;
      return;
    }

    final double position;
    _cameraPeakHeight ??= cameraViewHeight * (1 - CAMERA_PEAK);

    if (scrollPosition < (_cameraPeakHeight!)) {
      if (_direction == ScrollDirection.reverse) {
        position = 0.0;
      } else {
        position = _initialOffset;
      }
    } else if (scrollPosition < cameraViewHeight) {
      if (_direction == ScrollDirection.reverse) {
        position = _cameraPeakHeight!;
      } else {
        position = cameraViewHeight;
      }
    } else if (_direction == ScrollDirection.reverse) {
      position = cameraViewHeight + _appBarHeight;
    } else {
      position = cameraViewHeight;
    }

    Future.delayed(Duration.zero, () {
      _controller.animateTo(
        position,
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 500),
      );
      _ignoreNextEvent = true;
    });
  }
}

class SliverListBldr extends StatelessWidget {
  const SliverListBldr({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 20, right: 10),
            child: SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: const Text('Text'),
            ),
          );
        },
        childCount: 20,
      ),
    );
  }
}

/// A custom [ScrollPhysics] that snaps to specific [steps].
/// ignore: must_be_immutable
class _CustomPhysics extends ClampingScrollPhysics {
  _CustomPhysics({
    required List<double> steps,
    super.parent,
  }) : steps = steps.toList()..sort();

  final List<double> steps;

  @override
  ClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CustomPhysics(parent: buildParent(ancestor), steps: steps);
  }

  double _lastPixels = 0.0;

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent) {
      return null;
    }

    Simulation? simulation =
        super.createBallisticSimulation(position, velocity);
    double? proposedPixels = simulation?.x(double.infinity);

    if (simulation == null || proposedPixels == null) {
      return null;
    }

    var (double? min, double? max) = _getRange(position.pixels);
    if (min != null && max == null) {
      if (proposedPixels < min) {
        proposedPixels = min;
      }
    } else if (min != null && max != null) {
      if (position.pixels - proposedPixels > 0) {
        proposedPixels = min;
      } else {
        proposedPixels = max;
      }
    }

    _lastPixels = _fixInconsistency(proposedPixels);

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      _lastPixels,
      velocity,
    );
  }

  (double?, double?) _getRange(double position) {
    for (int i = steps.length - 1; i >= 0; i--) {
      final double step = steps[i];

      if (i == steps.length - 1 && position > step) {
        return (step, null);
      } else if (position > step && position < steps[i + 1]) {
        return (step, steps[i + 1]);
      }
    }

    return (null, null);
  }

  // In some cases, the proposed pixels have a giant space and findind the range
  // is incorrect. In that case, we ensure to have a contiguous range.
  double _fixInconsistency(double proposedPixels) {
    int newPosition = _getStepPosition(proposedPixels);
    int oldPosition = _getStepPosition(_lastPixels);

    if (newPosition - oldPosition >= 2) {
      return steps[math.min(newPosition - 1, 0)];
    } else if (newPosition - oldPosition <= -2) {
      return steps[math.min(newPosition + 1, steps.length - 1)];
    }

    return proposedPixels;
  }

  int _getStepPosition(double pixels) {
    for (int i = steps.length - 1; i >= 0; i--) {
      final double step = steps[i];

      if (pixels >= step) {
        return i;
      }
    }

    return 0;
  }
}
