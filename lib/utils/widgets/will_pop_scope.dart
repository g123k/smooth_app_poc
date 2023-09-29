import 'dart:io';

import 'package:flutter/material.dart';

class PlatformAwareWillPopScope extends StatefulWidget {
  const PlatformAwareWillPopScope({
    required this.child,
    this.onWillPop,
    super.key,
  });

  final Widget child;
  final WillPopCallback? onWillPop;

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
      return WillPopScope(
        onWillPop: widget.onWillPop,
        child: widget.child,
      );
    }
  }
}
