import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

/// Widget to inject in the hierarchy to have a single instance of the RiveFile
/// (assets/animations/off.riv)
class RiveAnimationsLoader<T extends OffRiveAnimation> extends StatefulWidget {
  const RiveAnimationsLoader({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<RiveAnimationsLoader> createState() => _RiveAnimationsLoaderState<T>();

  static RiveFile? of<OffRiveAnimation>(
    BuildContext context, {
    bool listen = true,
  }) {
    try {
      return context.read<OffRiveAnimationProvider<OffRiveAnimation>>().value;
    } catch (_) {
      return null;
    }
  }
}

class _RiveAnimationsLoaderState<T extends OffRiveAnimation>
    extends State<RiveAnimationsLoader> {
  RiveFile? _file;

  @override
  void initState() {
    super.initState();
    _preload();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OffRiveAnimationProvider<T>>.value(
      value: OffRiveAnimationProvider<T>(_file),
      child: widget.child,
    );
  }

  String get _asset {
    return switch (T) {
      const (OffAppAnimation) => 'assets/animations/off.riv',
      const (OffOnboardingAnimation) => 'assets/animations/onboarding.riv',
      _ => throw Exception('Invalid animation type'),
    };
  }

  Future<void> _preload() async {
    rootBundle.load(_asset).then(
      (ByteData data) async {
        // Load the RiveFile from the binary data.
        setState(() {
          _file = RiveFile.import(data);
        });
      },
      onError: (dynamic error) => log(
        'Unable to load Rive file $_asset',
        error: error,
      ),
    );
  }
}

class OffRiveAnimationProvider<OffRiveAnimation>
    extends ValueNotifier<RiveFile?> {
  OffRiveAnimationProvider(super.value);
}

sealed class OffRiveAnimation {
  const OffRiveAnimation();
}

class OffAppAnimation extends OffRiveAnimation {
  const OffAppAnimation();
}

class OffOnboardingAnimation extends OffRiveAnimation {
  const OffOnboardingAnimation();
}
