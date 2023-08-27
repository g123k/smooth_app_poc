import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/homepage/homepage.dart';

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
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      _animateBottomBar(0.0);
    } else if (_sheet!.controller!.size < 1.0 && _navBarTranslation == 0.0) {
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
