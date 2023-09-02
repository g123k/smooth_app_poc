import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';

class NavApp extends StatefulWidget {
  const NavApp({super.key});

  @override
  State<NavApp> createState() => NavAppState();

  static NavAppState of(BuildContext context) {
    return context.read<NavAppState>();
  }
}

class NavAppState extends State<NavApp> with TickerProviderStateMixin {
  late AnimationController _bottomSheetAndNavBarController;
  late AnimationController _bottomSheetController;
  late Animation<Offset> _bottomSheetAnimation;
  late SheetVisibilityNotifier _sheetVisibility;

  Animation<double>? _bottomSheetAndNavBarAnimation;

  DraggableScrollableSheet? _sheet;
  double _navBarHeight = kBottomNavigationBarHeight;
  double _navBarTranslation = kBottomNavigationBarHeight;

  @override
  void initState() {
    super.initState();
    _bottomSheetAndNavBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bottomSheetController = BottomSheet.createAnimationController(
      this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          setState(() => _sheet = null);
        }
      });

    _bottomSheetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -100.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _bottomSheetController,
        curve: Curves.easeInCubic,
      ),
    );

    _sheetVisibility = SheetVisibilityNotifier(_SheetVisibility.gone);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navBarHeight = _navBarTranslation = kBottomNavigationBarHeight +
          MediaQuery.of(context).viewPadding.bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_sheet != null) {
          setState(() => _sheet = null);
          return false;
        } else {
          return true;
        }
      },
      child: MultiProvider(
        providers: [
          Provider.value(value: this),
          ChangeNotifierProvider<SheetVisibilityNotifier>.value(
            value: _sheetVisibility,
          ),
        ],
        child: Stack(
          children: [
            Positioned.fill(
              child: Offstage(
                offstage: _sheetVisibility.isFullyVisible,
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
            ),
            if (_sheet != null)
              Positioned.fill(
                bottom: _navBarTranslation,
                child: SlideTransition(
                  position: _bottomSheetAnimation,
                  child: _sheet!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showSheet(DraggableScrollableSheet sheet) {
    assert(sheet.controller != null, 'A controller is mandatory');
    _sheetVisibility.value = _SheetVisibility.partiallyVisible;
    sheet.controller!.addListener(_onSheetScrolled);
    _sheet = sheet;
    _bottomSheetController.forward();
    setState(() {});
  }

  void hideSheet() {
    _sheet?.controller?.removeListener(_onSheetScrolled);
    _sheetVisibility.value = _SheetVisibility.gone;
    _bottomSheetController.reverse();
    //setState(() => _sheet = null);
  }

  bool get hasSheet => _sheet != null;

  bool get isSheetFullyVisible =>
      _sheetVisibility.value == _SheetVisibility.fullyVisible;

  void _onSheetScrolled() {
    if (_sheet!.controller!.size >= 0.999999999999 &&
        _navBarTranslation == _navBarHeight) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      _animateBottomBar(0.0);
      if (_sheetVisibility.value != _SheetVisibility.fullyVisible) {
        _sheetVisibility.value = _SheetVisibility.fullyVisible;
      }
    } else if (_sheet!.controller!.size < 1.0 && _navBarTranslation == 0.0) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      _animateBottomBar(_navBarHeight);

      if (_sheetVisibility.value != _SheetVisibility.partiallyVisible) {
        _sheetVisibility.value = _SheetVisibility.partiallyVisible;
      }
    }
  }

  void _animateBottomBar(double end) {
    _bottomSheetAndNavBarController.stop();

    _bottomSheetAndNavBarAnimation =
        Tween<double>(begin: _navBarTranslation, end: end)
            .animate(_bottomSheetAndNavBarController)
          ..addListener(
            () => setState(
              () {
                _navBarTranslation = _bottomSheetAndNavBarAnimation!.value;
              },
            ),
          );
    _bottomSheetAndNavBarController.reset();
    _bottomSheetAndNavBarController.forward();
  }

  @override
  void dispose() {
    _sheet?.controller?.removeListener(_onSheetScrolled);
    _bottomSheetController.dispose();
    _bottomSheetAndNavBarController.dispose();
    super.dispose();
  }
}

class SheetVisibilityNotifier extends ValueNotifier<_SheetVisibility> {
  // ignore: library_private_types_in_public_api
  SheetVisibilityNotifier(super.value);

  bool get isFullyVisible => value == _SheetVisibility.fullyVisible;

  bool get isPartiallyVisible => value == _SheetVisibility.partiallyVisible;

  bool get isGone => value == _SheetVisibility.gone;
}

enum _SheetVisibility {
  fullyVisible,
  partiallyVisible,
  gone,
}
