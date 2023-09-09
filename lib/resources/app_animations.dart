import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class TorchAnimation extends StatefulWidget {
  const TorchAnimation.on({
    this.size,
    super.key,
  }) : isOn = true;

  const TorchAnimation.off({
    this.size,
    super.key,
  }) : isOn = false;

  final bool isOn;
  final double? size;

  @override
  State<TorchAnimation> createState() => _TorchAnimationState();
}

class _TorchAnimationState extends State<TorchAnimation> {
  StateMachineController? _controller;

  @override
  void didUpdateWidget(covariant TorchAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeTorchValue(widget.isOn);
  }

  void _changeTorchValue(bool isOn) {
    SMIBool toggle = _controller?.findInput<bool>('enable') as SMIBool;
    if (toggle.value != isOn) {
      toggle.value = isOn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? IconTheme.of(context).size ?? 24.0;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation.asset(
        'assets/animations/off.riv',
        artboard: 'Torch',
        fit: BoxFit.cover,
        onInit: (Artboard artboard) {
          _controller = StateMachineController.fromArtboard(
            artboard,
            'Switch',
          );

          artboard.addController(_controller!);
          _changeTorchValue(widget.isOn);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class DoubleChevronAnimation extends StatefulWidget {
  const DoubleChevronAnimation.animate({
    this.size,
    super.key,
  }) : animated = true;

  const DoubleChevronAnimation.stopped({
    this.size,
    super.key,
  }) : animated = false;

  final double? size;
  final bool animated;

  @override
  State<DoubleChevronAnimation> createState() => _DoubleChevronAnimationState();
}

class _DoubleChevronAnimationState extends State<DoubleChevronAnimation> {
  StateMachineController? _controller;

  @override
  void didUpdateWidget(covariant DoubleChevronAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeAnimation(widget.animated);
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? IconTheme.of(context).size ?? 24.0;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation.asset(
        'assets/animations/off.riv',
        artboard: 'Double chevron',
        onInit: (Artboard artboard) {
          _controller = StateMachineController.fromArtboard(
            artboard,
            'Loop',
          );

          artboard.addController(_controller!);
          _changeAnimation(widget.animated);
        },
      ),
    );
  }

  void _changeAnimation(bool animated) {
    SMIBool toggle = _controller?.findInput<bool>('loop') as SMIBool;
    if (toggle.value != animated) {
      toggle.value = animated;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
