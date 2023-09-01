import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/homepage/homepage.dart';
import 'package:smoothapp_poc/navigation.dart';

class CameraView extends StatefulWidget {
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
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  String? _currentBarcode;

  @override
  Widget build(BuildContext context) {
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
              controller: widget.controller._controller,
              placeholderBuilder: (_, __) =>
                  const SizedBox.expand(child: ColoredBox(color: Colors.black)),
              onDetect: (BarcodeCapture capture) {
                if (HomePage.of(context).isCameraFullyVisible) {
                  if (capture.barcodes.first.rawValue != _currentBarcode) {
                    _currentBarcode = capture.barcodes.first.rawValue;
                    showProduct(_currentBarcode!);
                  }
                }
              },
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Offstage(
              offstage: widget.progress > 0.02,
              child: AppBar(
                forceMaterialTransparency: true,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white, shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 10.0,
                  ),
                ]),
                leading: CloseButton(
                  onPressed: () {
                    if (NavApp.of(context).hasSheet) {
                      NavApp.of(context).hideSheet();
                      HomePage.of(context).ignoreAllEvents(false);
                      _currentBarcode = null;
                    } else {
                      widget.onClosed.call();
                    }
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.camera_rear),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on_outlined),
                    onPressed: () {
                      showProduct('12365465');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showProduct(String barcode) {
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

class CustomScannerController {
  final MobileScannerController _controller;
  bool _isStarted = false;
  bool _isClosing = false;
  bool _isClosed = false;

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
}
