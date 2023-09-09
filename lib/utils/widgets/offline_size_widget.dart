import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Use this class to compute the size of a widget before it is rendered.
/// It's basically a hack which consist to inject the view in an overlay, but
/// never render it.
class ComputeOfflineSize {
  final Widget widget;
  final Function(Size) onSizeAvailable;
  late OverlayEntry _overlayEntry;

  ComputeOfflineSize({
    required BuildContext context,
    required this.widget,
    required this.onSizeAvailable,
  }) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _OfflineMeasureWidget(
          onSizeChanged: _onSizeChanged,

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
    _overlayEntry.remove();
    onSizeAvailable(size);
  }
}

class _OfflineMeasureWidget extends SingleChildRenderObjectWidget {
  const _OfflineMeasureWidget({
    required this.onSizeChanged,
    required super.child,
  });

  final Function(Size) onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _OfflineSizeRenderObject(onSizeChanged);
  }
}

class _OfflineSizeRenderObject extends RenderProxyBox {
  _OfflineSizeRenderObject(this.onChange);

  Size? oldSize;
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
    // Don't paint anything.
  }
}
