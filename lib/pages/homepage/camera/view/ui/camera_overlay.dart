import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/homepage/camera/view/ui/camera_view.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/widgets/useful_widgets.dart';

class CameraOverlay extends StatefulWidget {
  const CameraOverlay({
    required this.barcodes,
    super.key,
  });

  final Stream<DetectedBarcode> barcodes;

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> {
  DetectedBarcode? _currentBarcode;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.barcodes.listen(_onBarcodeDetected);
  }

  void _onBarcodeDetected(DetectedBarcode code) {
    _timer?.cancel();
    setState(() {
      _currentBarcode = code;
    });

    _timer = Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _currentBarcode = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentBarcode == null || _currentBarcode!.hasSize != true) {
      return EMPTY_WIDGET;
    }

    return CustomPaint(
      foregroundPainter: _CameraBarcodePainter(
        barcode: _currentBarcode!,
      ),
      size: MediaQuery.sizeOf(context),
    );
  }
}

class _CameraBarcodePainter extends CustomPainter {
  _CameraBarcodePainter({
    required this.barcode,
  });

  final DetectedBarcode barcode;
  final Paint _paint = Paint()
    ..color = AppColors.primaryLight
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..isAntiAlias = true;
  final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    double widthFactor = size.width / barcode.width!;
    double heightFactor = size.height / barcode.height!;

    _path.reset();

    for (int i = 0; i < barcode.corners.length; i++) {
      if (i == 0) {
        _path.moveTo(barcode.corners[i].dx * widthFactor,
            barcode.corners[i].dy * heightFactor);
      } else {
        _path.lineTo(barcode.corners[i].dx * widthFactor,
            barcode.corners[i].dy * heightFactor);
      }
    }

    _path.close();

    canvas.drawPath(_path, _paint);
    canvas.drawShadow(_path, Colors.white.withOpacity(0.5), 2.0, false);
  }

  @override
  bool shouldRepaint(_CameraBarcodePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_CameraBarcodePainter oldDelegate) => true;
}
