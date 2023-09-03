import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
    );
  }
}

class RevealRoute extends PageRouteBuilder {
  RevealRoute({
    required super.pageBuilder,
    Offset? offset,
  }) : super(
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return CircularRevealAnimation(
              animation: animation,
              centerOffset: offset,
              child: child,
            );
          },
        );
}
