import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/camera_state_manager.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/ui/camera_buttons_bar.dart';
import 'package:smoothapp_poc/pages/homepage/homepage.dart';
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
                        final String barcode = capture.barcodes.first.rawValue!;

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
                if (isCameraFullyVisible)
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
              ],
            ),
          );
        }),
      ),
    );
  }

  bool _isCameraFullyVisible() => progress < 0.02;

  void showProduct(BuildContext context, String barcode) {
    HomePage.of(context).ignoreAllEvents(true);
    NavApp.of(context).showSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.3,
        expand: true,
        snap: true,
        controller: DraggableScrollableController(),
        builder: (
          BuildContext context,
          ScrollController scrollController,
        ) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarBrightness: Theme.of(context).brightness,
            ),
            child: Material(
              type: MaterialType.card,
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (BuildContext context, int position) {
                  return ListTile(
                    title: Text('Item $position'),
                  );
                },
                itemCount: 100,
              ),
            ),
          );
        },
      ),
    );
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
}
