import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/utils/system_ui.dart';

class HomePagePersonalization extends StatelessWidget {
  const HomePagePersonalization({super.key});

  static void open(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CustomPageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomePagePersonalization(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = context.watch<PageRouterAnimationProvider>().value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUIStyle.dark,
      child: Scaffold(
        body: GestureDetector(
          onTapDown: (TapDownDetails details) {
            final Size size = MediaQuery.sizeOf(context);
            if (details.localPosition.dy > size.height * 0.9) {
              Navigator.of(context).pop();
            }
          },
          child: Opacity(
            opacity: progress,
            child: Column(
              children: [
                Transform.translate(
                  offset: Offset(0.0, (1 - progress) * -219),
                  child: Image.asset(
                    'assets/images/homepage_custom_header.webp',
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: Offset((1 - progress) * 150, 0.0),
                    child: SingleChildScrollView(
                      child: Image.asset(
                        'assets/images/homepage_custom_content.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, (1 - progress) * 100),
                  child: Image.asset(
                    'assets/images/homepage_custom_footer.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomPageRouteBuilder<T> extends PageRoute<T> {
  final RoutePageBuilder pageBuilder;
  final PageTransitionsBuilder
      matchingBuilder; // Default iOS/macOS (to get the swipe right to go back gesture)

  CustomPageRouteBuilder({
    required this.pageBuilder,
  }) : matchingBuilder = Platform.isIOS
            ? CupertinoPageTransitionsBuilder()
            : OpenUpwardsPageTransitionsBuilder();

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return pageBuilder(context, animation, secondaryAnimation);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return matchingBuilder.buildTransitions<T>(
      this,
      context,
      animation,
      secondaryAnimation,
      ChangeNotifierProvider<PageRouterAnimationProvider>.value(
        value: PageRouterAnimationProvider(
          Platform.isIOS ? animation.value : 1.0,
        ),
        child: child,
      ),
    );
  }

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String? get barrierLabel => null;
}

class PageRouterAnimationProvider extends ValueNotifier<double> {
  PageRouterAnimationProvider(super._value);
}
