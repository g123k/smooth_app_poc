import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/appbar/search_bar.dart';
import 'package:smoothapp_poc/appbar/settings_icon.dart';
import 'package:smoothapp_poc/camera/camera_view.dart';
import 'package:smoothapp_poc/camera/expandable_camera.dart';
import 'package:smoothapp_poc/list/history_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'DroidSans',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffffc589)),
        useMaterial3: true,
      ),
      home: const NavApp(),
    );
  }
}

class NavApp extends StatefulWidget {
  const NavApp({super.key});

  @override
  State<NavApp> createState() => NavAppState();

  static NavAppState of(BuildContext context) {
    return context.read<NavAppState>();
  }
}

class NavAppState extends State<NavApp> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Animation<double>? _animation;

  DraggableScrollableSheet? _sheet;
  double _navBarHeight = kBottomNavigationBarHeight;
  double _navBarTranslation = kBottomNavigationBarHeight;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navBarHeight = _navBarTranslation = kBottomNavigationBarHeight +
          MediaQuery.of(context).viewPadding.bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const Expanded(
                  child: HomePage(),
                ),
                Transform.translate(
                  offset: Offset(0.0, _navBarHeight - _navBarTranslation),
                  child: BottomNavigationBar(
                    currentIndex: 1,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.camera_alt),
                        label: 'Camera',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_sheet != null)
            Positioned.fill(
              bottom: _navBarTranslation,
              child: _sheet!,
            ),
        ],
      ),
    );
  }

  void showSheet(DraggableScrollableSheet sheet) {
    assert(sheet.controller != null, 'A controller is mandatory');
    sheet.controller!.addListener(_onSheetScrolled);
    setState(() => _sheet = sheet);
  }

  void hideSheet() {
    _sheet?.controller?.removeListener(_onSheetScrolled);
    setState(() => _sheet = null);
  }

  bool get hasSheet => _sheet != null;

  void _onSheetScrolled() {
    if (_sheet!.controller!.size == 1.0 &&
        _navBarTranslation == _navBarHeight) {
      print('dark');
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      _animateBottomBar(0.0);
    } else if (_sheet!.controller!.size < 1.0 && _navBarTranslation == 0.0) {
      print('light');
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      _animateBottomBar(_navBarHeight);
    }
  }

  void _animateBottomBar(double end) {
    _animController.stop();

    _animation = Tween<double>(begin: _navBarTranslation, end: end)
        .animate(_animController)
      ..addListener(
        () => setState(
          () {
            _navBarTranslation = _animation!.value;
          },
        ),
      );
    _animController.reset();
    _animController.forward();
  }

  @override
  void dispose() {
    _sheet?.controller?.removeListener(_onSheetScrolled);
    _animController.dispose();
    super.dispose();
  }
}

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
            if (notification.metrics.axis != Axis.vertical) {
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

  onDispose() {
    _controller.dispose();
    super.dispose();
  }

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

    if (notification.metrics.pixels < cameraHeight * 0.1) {
      newValue = SettingsIconType.invisible;
    } else if (notification.metrics.pixels < cameraHeight) {
      newValue = SettingsIconType.floating;
    } else {
      newValue = SettingsIconType.appBar;
    }

    if (newValue != _floatingSettingsType) {
      setState(() => _floatingSettingsType = newValue);
    }
  }

  void _onScrollEnded(ScrollEndNotification notification) {
    final double height = cameraHeight;
    final double scrollPosition = notification.metrics.pixels;

    print(
        'POSITION : $scrollPosition / $_ignoreNextEvent / ${notification.metrics.axisDirection}');

    if ([0.0, cameraPeak, height].contains(scrollPosition) ||
        scrollPosition.roundToDouble() >= height ||
        _ignoreNextEvent) {
      _ignoreNextEvent = false;
      return;
    }

    print(scrollPosition);

    final double position;

    if (scrollPosition < (height * (1 - CAMERA_PEAK))) {
      if (_direction == ScrollDirection.reverse) {
        position = _initialOffset;
      } else {
        position = 0.0;
      }
    } else if (scrollPosition < height) {
      if (_direction == ScrollDirection.reverse) {
        position = height;
      } else {
        position = height * (1 - CAMERA_PEAK);
      }
    } else if (_direction == ScrollDirection.reverse) {
      position = height + _appBarHeight;
    } else {
      position = height;
    }

    print('Move to $position');

    Future.delayed(Duration.zero, () {
      _controller.animateTo(position,
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 500));
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

    var (double? min, double? max) = getRange(position.pixels);
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

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      proposedPixels,
      velocity,
    );
  }

  (double?, double?) getRange(double position) {
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
}
