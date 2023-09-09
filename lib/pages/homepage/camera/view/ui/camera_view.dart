import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/camera_state_manager.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/ui/camera_buttons_bar.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
import 'package:smoothapp_poc/pages/product/product_page.dart';
import 'package:smoothapp_poc/resources/app_animations.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/provider_utils.dart';
import 'package:smoothapp_poc/utils/widgets/offline_size_widget.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

import 'camera_message.dart';

class CameraView extends StatelessWidget {
  const CameraView({
    required this.controller,
    required this.progress,
    required this.onClosed,
    super.key,
  });

  final CustomScannerController controller;
  final double progress;
  final VoidCallback onClosed;

  @override
  Widget build(BuildContext context) {
    final bool isCameraFullyVisible = _isCameraFullyVisible();

    return Provider.value(
      value: controller,
      child: ChangeNotifierProvider(
        create: (_) => CameraViewStateManager(),
        child: ValueListener<CameraViewStateManager, CameraViewState>(
          onValueChanged: (CameraViewState state) {
            if (state is CameraViewProductAvailableState) {
              showProduct(context, state.product);
            }
          },
          child: Builder(builder: (BuildContext context) {
            return Consumer<SheetVisibilityNotifier>(
              builder: (
                BuildContext context,
                SheetVisibilityNotifier notifier,
                Widget? child,
              ) {
                return Offstage(
                  offstage: notifier.isFullyVisible,
                  child: child!,
                );
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MobileScanner(
                      controller: controller._controller,
                      placeholderBuilder: (_, __) => const SizedBox.expand(
                          child: ColoredBox(color: Colors.black)),
                      onDetect: (BarcodeCapture capture) {
                        if (HomePage.of(context).isCameraFullyVisible) {
                          final String barcode =
                              capture.barcodes.first.rawValue!;

                          CameraViewStateManager.of(context)
                              .onBarcodeDetected(barcode);
                        }
                      },
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Offstage(
                      offstage: !isCameraFullyVisible,
                      child: CameraButtonBars(
                        onClosed: onClosed,
                      ),
                    ),
                  ),
                  if (isCameraFullyVisible &&
                      SheetVisibilityNotifier.of(context).isGone)
                    Positioned(
                      bottom: kBottomNavigationBarHeight + 20.0,
                      left: 0.0,
                      right: 0.0,
                      child: SafeArea(
                        bottom: true,
                        child: _MessageOverlay(),
                      ),
                    ),
                  Positioned.fill(
                    child: _OpaqueOverlay(
                      isCameraFullyVisible: isCameraFullyVisible,
                      progress: progress,
                    ),
                  ),
                  Positioned(
                    top: 200,
                    child: CloseButton(
                      onPressed: () =>
                          CameraViewStateManager.of(context).onBarcodeDetected(
                        '${math.Random().nextInt(100)}01234567${math.Random().nextInt(100)}',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  bool _isCameraFullyVisible() => progress < 0.02;

  void showProduct(BuildContext topContext, Product product) {
    HomePage.of(topContext).ignoreAllEvents(true);

    final Widget header = ProductPage.buildHeader(product);
    ComputeOfflineSize(
      context: topContext,
      widget: header,
      onSizeAvailable: (Size size) {
        final DraggableScrollableController draggableScrollableController =
            DraggableScrollableController();

        // The fraction should allow to view the header
        // + the hint (slide up to see details)
        // + a slight padding

        final double fraction =
            (size.height + _MagicBackgroundState.HINT_SIZE + 40.0) /
                (MediaQuery.of(topContext).size.height -
                    NavApp.of(topContext).navBarHeight);

        NavApp.of(topContext).showSheet(
          DraggableScrollableSheet(
            initialChildSize: fraction,
            minChildSize: fraction,
            expand: true,
            snap: true,
            controller: draggableScrollableController,
            builder: (
              BuildContext context,
              ScrollController scrollController,
            ) {
              return ListenableProvider<DraggableScrollableController>(
                create: (_) => draggableScrollableController,
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarBrightness: Theme.of(context).brightness,
                  ),
                  child: _MagicBackground(
                    scrollController: draggableScrollableController,
                    style: DefaultTextStyle.of(topContext).style,
                    minFraction: fraction,
                    child: ProductPage(
                      product: product,
                      scrollController: scrollController,
                      topSliver: _MagicTopPadding(
                        scrollController: draggableScrollableController,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MagicBackground extends StatefulWidget {
  const _MagicBackground({
    required this.scrollController,
    required this.style,
    required this.minFraction,
    required this.child,
  });

  final DraggableScrollableController scrollController;
  final double minFraction;
  final TextStyle style;
  final Widget child;

  @override
  State<_MagicBackground> createState() => _MagicBackgroundState();
}

class _MagicBackgroundState extends State<_MagicBackground> {
  //ignore: constant_identifier_names
  static const double HINT_SIZE = 50.0;

  double _topRadius = 20.0;
  double _hintOpacity = 1.0;
  double _hintSize = HINT_SIZE;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.scrollController.replaceListener(_onScroll);
  }

  void _onScroll() {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double screenTopPadding = mediaQueryData.viewPadding.top;
    final double screenHeight =
        widget.scrollController.pixels / widget.scrollController.size;

    final double startPoint = screenHeight - screenTopPadding;

    _updateHint(startPoint, screenHeight);
    _updateRadius(startPoint, screenHeight);
  }

  void _updateHint(double startPoint, double screenHeight) {
    final double maxFraction = widget.minFraction + 0.1;

    final double opacity;

    if (widget.scrollController.size > maxFraction) {
      opacity = 0.0;
    } else {
      opacity = 1.0 * 1 -
          (widget.scrollController.size.progress(
            widget.minFraction,
            maxFraction,
          ));
    }

    if (opacity != _hintOpacity) {
      setState(() => _hintOpacity = opacity);
    }

    final double hintSize;
    final double hintSizeThreshold = startPoint * 0.8;
    if (opacity > 0.0 || widget.scrollController.pixels < hintSizeThreshold) {
      hintSize = HINT_SIZE;
    } else if (widget.scrollController.pixels > startPoint) {
      hintSize = 0.0;
    } else {
      hintSize = HINT_SIZE *
          (1 -
              (widget.scrollController.pixels.progress(
                hintSizeThreshold,
                startPoint,
              )));
    }

    if (hintSize != _hintSize) {
      setState(() => _hintSize = hintSize);
    }
  }

  void _updateRadius(double startPoint, double screenHeight) {
    final double radius;

    if (widget.scrollController.pixels < startPoint) {
      radius = 20.0;
    } else {
      radius = 20 * 1 -
          (widget.scrollController.pixels.progress(
            startPoint,
            screenHeight,
          ));
    }

    if (radius != _topRadius) {
      setState(() => _topRadius = radius);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Material(
      type: MaterialType.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_topRadius),
        ),
      ),
      child: widget.child,
    );

    if (_topRadius > 0.0) {
      content = ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_topRadius),
        ),
        child: content,
      );
    }

    return Column(
      children: [
        DefaultTextStyle(
          style: widget.style,
          child: GestureDetector(
            onTap: () => _onHintTapped(),
            onPanStart: (_) => _onHintTapped(),
            child: _MagicHint(
              opacity: _hintOpacity,
              height: _hintSize,
            ),
          ),
        ),
        Expanded(child: content),
      ],
    );
  }

  void _onHintTapped() {
    if (widget.scrollController.size < 1.0) {
      widget.scrollController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInExpo,
      );
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
}

class _MagicHint extends StatelessWidget {
  const _MagicHint({
    required this.height,
    required this.opacity,
  });

  final double opacity;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (height == 0.0) {
      return EMPTY_WIDGET;
    }

    final DoubleChevronAnimation chevronAnimation;
    if (opacity == 1.0) {
      chevronAnimation = const DoubleChevronAnimation.animate();
    } else {
      chevronAnimation = const DoubleChevronAnimation.stopped();
    }

    return SizedBox(
      height: height,
      child: Opacity(
        opacity: opacity,
        child: DefaultTextStyle(
            style: const TextStyle(),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 18.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 20.0,
                ),
                child: Row(
                  children: [
                    chevronAnimation,
                    const Expanded(
                      child: Text(
                        'Glissez vers le haut pour voir les détails',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    chevronAnimation,
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class _MagicTopPadding extends StatefulWidget {
  const _MagicTopPadding({
    required this.scrollController,
  });

  final DraggableScrollableController scrollController;

  @override
  State<_MagicTopPadding> createState() => _MagicTopPaddingState();
}

class _MagicTopPaddingState extends State<_MagicTopPadding> {
  double _topPadding = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.scrollController.replaceListener(_onScroll);
  }

  void _onScroll() {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double screenTopPadding = mediaQueryData.viewPadding.top;

    final double screenHeight =
        widget.scrollController.pixels / widget.scrollController.size;
    final double startPoint = screenHeight - screenTopPadding;
    final double padding;

    if (widget.scrollController.pixels < startPoint) {
      padding = 0.0;
    } else {
      padding = math.min(
        widget.scrollController.pixels - startPoint,
        screenTopPadding,
      );
    }

    if (padding != _topPadding) {
      setState(() => _topPadding = padding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPinnedHeader(
      child: ColoredBox(
        color: Theme.of(context).bottomSheetTheme.backgroundColor ??
            AppColors.white,
        child: SizedBox(height: _topPadding),
      ),
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
}

/// The message overlay is only visible when the [CameraViewStateManager] emits
/// a [CameraViewNoBarcodeState] or a [CameraViewInvalidBarcodeState].
class _MessageOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SheetVisibilityNotifier>(
      builder: (BuildContext context, SheetVisibilityNotifier notifier, _) {
        return Selector<CameraViewStateManager, CameraViewState>(
          selector: (_, CameraViewStateManager state) => state.value,
          shouldRebuild: (CameraViewState previous, CameraViewState next) {
            return next is CameraViewNoBarcodeState ||
                next is CameraViewInvalidBarcodeState ||
                previous is CameraViewNoBarcodeState ||
                previous is CameraViewInvalidBarcodeState;
          },
          builder: (BuildContext context, CameraViewState state, _) {
            return switch (state) {
              CameraViewNoBarcodeState _ => const CameraMessageOverlay(
                  message: 'Scannez un produit en approchant son code-barres',
                ),
              CameraViewInvalidBarcodeState(barcode: final String barcode) =>
                CameraMessageOverlay(
                  message:
                      'Nous avons détecté le code $barcode, mais ce n’est pas un code-barres valide',
                ),
              _ => EMPTY_WIDGET,
            };
          },
        );
      },
    );
  }
}

class _OpaqueOverlay extends StatelessWidget {
  const _OpaqueOverlay({
    required this.isCameraFullyVisible,
    required this.progress,
  });

  final bool isCameraFullyVisible;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isCameraFullyVisible,
      child: Opacity(
        opacity: progress,
        child: const ColoredBox(
          color: Colors.black,
        ),
      ),
    );
  }
}

class CustomScannerController {
  final MobileScannerController _controller;
  bool _isStarted = false;
  bool _isClosing = false;
  bool _isClosed = false;

  /// Internal value to store the previous torch state, when we start/stop
  /// the camera
  bool _isTorchOn = false;

  CustomScannerController({
    required MobileScannerController controller,
  }) : _controller = controller;

  Future<void> start() async {
    if (isStarting || isStarted || isClosing) {
      return;
    }

    _isClosed = false;
    try {
      await _controller.start();
      _isStarted = true;

      if (_isTorchOn) {
        // Slight delay, because it doesn't always work if called immediately
        Future.delayed(const Duration(milliseconds: 250), () {
          turnTorchOn();
        });
      }
    } catch (_) {}
  }

  void onPause() {
    _isStarted = false;
    _isClosing = false;
    _isClosed = false;
  }

  bool get isStarting => _controller.isStarting;

  bool get isStarted => _isStarted;

  bool get isClosing => _isClosing;

  bool get isClosed => _isClosed;

  Future<void> stop() async {
    if (isStarting || isClosed || isClosing) {
      return;
    }

    _isClosing = true;
    _isStarted = false;
    try {
      await _controller.stop();
      _isClosing = false;
      _isClosed = true;
    } catch (_) {}
  }

  bool get hasTorch => _controller.hasTorch;

  ValueNotifier<bool?> get hasTorchState => _controller.hasTorchState;

  bool get isTorchOn => _controller.torchState.value == TorchState.on;

  void turnTorchOff() {
    if (isTorchOn) {
      _controller.toggleTorch();
      _isTorchOn = false;
    }
  }

  void turnTorchOn() {
    if (!isTorchOn) {
      _controller.toggleTorch();
      _isTorchOn = true;
    }
  }

  void toggleCamera() {
    _controller.switchCamera();
  }
}
