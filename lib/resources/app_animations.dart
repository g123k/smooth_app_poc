import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class AnimationLoader extends StatefulWidget {
  const AnimationLoader({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AnimationLoader> createState() => _AnimationLoaderState();

  static RiveFile of(BuildContext context) {
    return context.read<_AnimationLoaderState>()._file;
  }
}

class _AnimationLoaderState extends State<AnimationLoader> {
  late final RiveFile _file;

  @override
  void initState() {
    super.initState();
    preload();
  }

  Future<void> preload() async {
    rootBundle.load('assets/animations/off.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        setState(() {
          _file = RiveFile.import(data);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: widget.child,
    );
  }
}

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
      child: RiveAnimation.direct(
        AnimationLoader.of(context),
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

class SearchEyeAnimation extends StatelessWidget {
  const SearchEyeAnimation({
    this.size,
    super.key,
  });

  final double? size;

  @override
  Widget build(BuildContext context) {
    final double size = this.size ?? IconTheme.of(context).size ?? 24.0;

    return SizedBox(
      width: size,
      height: (80 / 87) * size,
      child: RiveAnimation.direct(
        AnimationLoader.of(context),
        artboard: 'Search eye',
        stateMachines: const <String>['LoopMachine'],
      ),
    );
  }
}

class SunAnimation extends StatelessWidget {
  const SunAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.direct(
      AnimationLoader.of(context),
      artboard: 'Success',
      animations: const ['Timeline 1'],
    );
  }
}

class SearchAnimation extends StatefulWidget {
  const SearchAnimation({
    super.key,
    this.type = SearchAnimationType.search,
    this.size,
  });

  final double? size;
  final SearchAnimationType type;

  @override
  State<SearchAnimation> createState() => _SearchAnimationState();
}

class _SearchAnimationState extends State<SearchAnimation> {
  StateMachineController? _controller;

  @override
  void didUpdateWidget(SearchAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeAnimation(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? IconTheme.of(context).size ?? 24.0;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation.direct(
        AnimationLoader.of(context),
        artboard: 'Search icon',
        onInit: (Artboard artboard) {
          _controller = StateMachineController.fromArtboard(
            artboard,
            'StateMachine',
          );

          artboard.addController(_controller!);
          if (widget.type != SearchAnimationType.search) {
            _changeAnimation(widget.type);
          }
        },
      ),
    );
  }

  void _changeAnimation(SearchAnimationType type) {
    SMINumber step = _controller?.findInput<double>('step') as SMINumber;
    step.change(type.step.toDouble());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

enum SearchAnimationType {
  search(0),
  cancel(1),
  edit(2);

  const SearchAnimationType(this.step);

  final int step;
}
