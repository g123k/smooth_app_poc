import 'dart:io';

import 'package:flutter/material.dart';

class PlatformAwareWillPopScope extends StatefulWidget {
  const PlatformAwareWillPopScope({
    required this.child,
    this.onWillPop,
    super.key,
  });

  final Widget child;
  final WillPop2Callback? onWillPop;

  @override
  State<PlatformAwareWillPopScope> createState() =>
      _PlatformAwareWillPopScopeState();
}

class _PlatformAwareWillPopScopeState extends State<PlatformAwareWillPopScope> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return widget.child;
    } else {
      return WillPopScope2(
        onWillPop: widget.onWillPop,
        child: widget.child,
      );
    }
  }
}

/// Brings the same behavior as WillPopScope, which is now deprecated
/// [onWillPop] is a bit different and still asks as the first value if we should block the pop
/// The second value is used, if [Navigator.pop()] should provide a specific value (can be null)
class WillPopScope2 extends StatelessWidget {
  const WillPopScope2({
    required this.child,
    required this.onWillPop,
    super.key,
  });

  final Widget child;
  final WillPop2Callback? onWillPop;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }

        final (bool shouldClose, dynamic res) =
            await onWillPop?.call() ?? (true, null);
        if (shouldClose == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop(res);
          });
        }
      },
      child: child,
    );
  }
}

typedef WillPop2Callback = Future<(bool shouldClose, dynamic res)> Function();
