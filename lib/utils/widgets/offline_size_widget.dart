import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Use this class to compute the size of a widget before it is rendered.
/// It's basically a hack which consist to inject the view in an overlay, but
/// never render it.
class ComputeOfflineSize {
  final Widget widget;
  final Function(Size) onSizeAvailable;
  late OverlayEntry _overlayEntry;

  // The first time the app is launched, the size is incorrect, that's why we
  // will wait for the second frame
  Timer? _timer;

  ComputeOfflineSize({
    required BuildContext context,
    required this.widget,
    required this.onSizeAvailable,
  }) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return OfflineMeasureWidget(
          onSizeChanged: _onSizeChanged,
          drawWidgets: false,

          /// Injecting a Material widget is mandatory, otherwise fonts
          /// won't be computed correctly
          child: Material(
            child: widget,
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry);
  }

  void _onSizeChanged(Size size) {
    // We ignore the first call because it's not accurate
    if (_timer == null) {
      _timer = Timer(const Duration(milliseconds: 1000 ~/ 30), () {
        _onSizeChanged(size);
      });
      return;
    } else {
      _timer?.cancel();
    }

    onSizeAvailable(size);
    _overlayEntry.remove();
  }
}

class OfflineMeasureWidget extends SingleChildRenderObjectWidget {
  const OfflineMeasureWidget({
    super.key,
    required this.onSizeChanged,
    this.drawWidgets = true,
    required super.child,
  });

  final Function(Size) onSizeChanged;
  final bool drawWidgets;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _OfflineSizeRenderObject(
      onSizeChanged,
      drawWidgets,
    );
  }
}

class _OfflineSizeRenderObject extends RenderProxyBox {
  _OfflineSizeRenderObject(this.onChange, this.drawWidgets);

  Size? oldSize;
  final bool drawWidgets;
  final Function(Size) onChange;

  @override
  void performLayout() {
    super.performLayout();

    if (child != null) {
      child!.layout(
        constraints.copyWith(minHeight: 0.0, maxHeight: double.infinity),
        parentUsesSize: true,
      );
    }

    Size? newSize = child?.size;
    if (newSize == null || oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (drawWidgets) {
      super.paint(context, offset);
    }
  }
}
