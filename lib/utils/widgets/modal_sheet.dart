import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';

/// The signature of a method that provides a [BuildContext] and
/// [ScrollController] for building a widget that may overflow the draggable
/// [Axis] of the containing [DraggableScrollableLockAtTopSheet].
///
/// Users should apply the [scrollController] to a [ScrollView] subclass, such
/// as a [SingleChildScrollView], [ListView] or [GridView], to have the whole
/// sheet be draggable.
typedef ScrollableWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

typedef ShouldLockDraggableSheetAtTop = bool Function();

/// A container for a [Scrollable] that responds to drag gestures by resizing
/// the scrollable until a limit is reached, and then scrolling.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=Hgw819mL_78}
///
/// This widget can be dragged along the vertical axis between its
/// [minChildSize], which defaults to `0.25` and [maxChildSize], which defaults
/// to `1.0`. These sizes are percentages of the height of the parent container.
///
/// The widget coordinates resizing and scrolling of the widget returned by
/// builder as the user drags along the horizontal axis.
///
/// The widget will initially be displayed at its initialChildSize which
/// defaults to `0.5`, meaning half the height of its parent. Dragging will work
/// between the range of minChildSize and maxChildSize (as percentages of the
/// parent container's height) as long as the builder creates a widget which
/// uses the provided [ScrollController]. If the widget created by the
/// [ScrollableWidgetBuilder] does not use the provided [ScrollController], the
/// sheet will remain at the initialChildSize.
///
/// By default, the widget will stay at whatever size the user drags it to. To
/// make the widget snap to specific sizes whenever they lift their finger
/// during a drag, set [snap] to `true`. The sheet will snap between
/// [minChildSize] and [maxChildSize]. Use [snapSizes] to add more sizes for
/// the sheet to snap between.
///
/// The snapping effect is only applied on user drags. Programmatically
/// manipulating the sheet size via [DraggableLockAtTopScrollableController.animateTo] or
/// [DraggableLockAtTopScrollableController.jumpTo] will ignore [snap] and [snapSizes].
///
/// By default, the widget will expand its non-occupied area to fill available
/// space in the parent. If this is not desired, e.g. because the parent wants
/// to position sheet based on the space it is taking, the [expand] property
/// may be set to false.
///
/// {@tool snippet}
///
/// This is a sample widget which shows a [ListView] that has 25 [ListTile]s.
/// It starts out as taking up half the body of the [Scaffold], and can be
/// dragged up to the full height of the scaffold or down to 25% of the height
/// of the scaffold. Upon reaching full height, the list contents will be
/// scrolled up or down, until they reach the top of the list again and the user
/// drags the sheet back down.
///
/// ```dart
/// class HomePage extends StatelessWidget {
///   const HomePage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: const Text('DraggableScrollableSheet'),
///       ),
///       body: SizedBox.expand(
///         child: DraggableScrollableSheet(
///           builder: (BuildContext context, ScrollController scrollController) {
///             return Container(
///               color: Colors.blue[100],
///               child: ListView.builder(
///                 controller: scrollController,
///                 itemCount: 25,
///                 itemBuilder: (BuildContext context, int index) {
///                   return ListTile(title: Text('Item $index'));
///                 },
///               ),
///             );
///           },
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
class DraggableScrollableLockAtTopSheet extends StatefulWidget {
  /// Creates a widget that can be dragged and scrolled in a single gesture.
  ///
  /// The [builder], [initialChildSize], [minChildSize], [maxChildSize] and
  /// [expand] parameters must not be null.
  const DraggableScrollableLockAtTopSheet({
    super.key,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 1.0,
    this.expand = true,
    this.snap = false,
    this.snapSizes,
    this.snapAnimationDuration,
    this.controller,
    this.shouldCloseOnMinExtent = true,
    this.lockAtTop,
    required this.builder,
  })  : assert(minChildSize >= 0.0),
        assert(maxChildSize <= 1.0),
        assert(minChildSize <= initialChildSize),
        assert(initialChildSize <= maxChildSize),
        assert(snapAnimationDuration == null ||
            snapAnimationDuration > Duration.zero);

  /// The initial fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// Rebuilding the sheet with a new [initialChildSize] will only move
  /// the sheet to the new value if the sheet has not yet been dragged since it
  /// was first built or since the last call to [DraggableScrollableActuator.reset].
  ///
  /// The default value is `0.5`.
  final double initialChildSize;

  /// The minimum fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `0.25`.
  final double minChildSize;

  /// The maximum fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `1.0`.
  final double maxChildSize;

  /// Whether the widget should expand to fill the available space in its parent
  /// or not.
  ///
  /// In most cases, this should be true. However, in the case of a parent
  /// widget that will position this one based on its desired size (such as a
  /// [Center]), this should be set to false.
  ///
  /// The default value is true.
  final bool expand;

  /// Whether the widget should snap between [snapSizes] when the user lifts
  /// their finger during a drag.
  ///
  /// If the user's finger was still moving when they lifted it, the widget will
  /// snap to the next snap size (see [snapSizes]) in the direction of the drag.
  /// If their finger was still, the widget will snap to the nearest snap size.
  ///
  /// Snapping is not applied when the sheet is programmatically moved by
  /// calling [DraggableLockAtTopScrollableController.animateTo] or [DraggableLockAtTopScrollableController.jumpTo].
  ///
  /// Rebuilding the sheet with snap newly enabled will immediately trigger a
  /// snap unless the sheet has not yet been dragged away from
  /// [initialChildSize] since first being built or since the last call to
  /// [DraggableScrollableActuator.reset].
  final bool snap;

  /// A list of target sizes that the widget should snap to.
  ///
  /// Snap sizes are fractional values of the parent container's height. They
  /// must be listed in increasing order and be between [minChildSize] and
  /// [maxChildSize].
  ///
  /// The [minChildSize] and [maxChildSize] are implicitly included in snap
  /// sizes and do not need to be specified here. For example, `snapSizes = [.5]`
  /// will result in a sheet that snaps between [minChildSize], `.5`, and
  /// [maxChildSize].
  ///
  /// Any modifications to the [snapSizes] list will not take effect until the
  /// `build` function containing this widget is run again.
  ///
  /// Rebuilding with a modified or new list will trigger a snap unless the
  /// sheet has not yet been dragged away from [initialChildSize] since first
  /// being built or since the last call to [DraggableScrollableActuator.reset].
  final List<double>? snapSizes;

  /// Defines a duration for the snap animations.
  ///
  /// If it's not set, then the animation duration is the distance to the snap
  /// target divided by the velocity of the widget.
  final Duration? snapAnimationDuration;

  /// A controller that can be used to programmatically control this sheet.
  final DraggableScrollableLockAtTopController? controller;

  /// Whether the sheet, when dragged (or flung) to its minimum size, should
  /// cause its parent sheet to close.
  ///
  /// Set on emitted [DraggableScrollableLockAtTopNotification]s. It is up to parent
  /// classes to properly read and handle this value.
  final bool shouldCloseOnMinExtent;

  /// The builder that creates a child to display in this widget, which will
  /// use the provided [ScrollController] to enable dragging and scrolling
  /// of the contents.
  final ScrollableWidgetBuilder builder;

  final ShouldLockDraggableSheetAtTop? lockAtTop;

  @override
  State<DraggableScrollableLockAtTopSheet> createState() =>
      _DraggableScrollableLockAtTopSheetState();
}

/// Manages state between [_DraggableScrollableLockAtTopSheetState],
/// [_DraggableScrollableSheetLockAtTopScrollController], and
/// [_DraggableScrollableSheetScrollAtTopPosition].
///
/// The State knows the pixels available along the axis the widget wants to
/// scroll, but expects to get a fraction of those pixels to render the sheet.
///
/// The ScrollPosition knows the number of pixels a user wants to move the sheet.
///
/// The [currentSize] will never be null.
/// The [availablePixels] will never be null, but may be `double.infinity`.
class _DraggableSheetExtent {
  _DraggableSheetExtent({
    required this.minSize,
    required this.maxSize,
    required this.snap,
    required this.snapSizes,
    required this.initialSize,
    this.snapAnimationDuration,
    ValueNotifier<double>? currentSize,
    bool? hasDragged,
    bool? hasChanged,
    this.shouldCloseOnMinExtent = true,
  })  : assert(minSize >= 0),
        assert(maxSize <= 1),
        assert(minSize <= initialSize),
        assert(initialSize <= maxSize),
        _currentSize = currentSize ?? ValueNotifier<double>(initialSize),
        availablePixels = double.infinity,
        hasDragged = hasDragged ?? false,
        hasChanged = hasChanged ?? false;

  VoidCallback? _cancelActivity;

  final double minSize;
  final double maxSize;
  final bool snap;
  final List<double> snapSizes;
  final Duration? snapAnimationDuration;
  final double initialSize;
  final bool shouldCloseOnMinExtent;
  final ValueNotifier<double> _currentSize;
  double availablePixels;

  // Used to disable snapping until the user has dragged on the sheet.
  bool hasDragged;

  // Used to determine if the sheet should move to a new initial size when it
  // changes.
  // We need both `hasChanged` and `hasDragged` to achieve the following
  // behavior:
  //   1. The sheet should only snap following user drags (as opposed to
  //      programmatic sheet changes). See docs for `animateTo` and `jumpTo`.
  //   2. The sheet should move to a new initial child size on rebuild iff the
  //      sheet has not changed, either by drag or programmatic control. See
  //      docs for `initialChildSize`.
  bool hasChanged;

  bool get isAtMin => minSize >= _currentSize.value;

  bool get isAtMax => maxSize <= _currentSize.value;

  double get currentSize => _currentSize.value;

  double get currentPixels => sizeToPixels(_currentSize.value);

  List<double> get pixelSnapSizes => snapSizes.map(sizeToPixels).toList();

  /// Start an activity that affects the sheet and register a cancel call back
  /// that will be called if another activity starts.
  ///
  /// The `onCanceled` callback will get called even if the subsequent activity
  /// started after this one finished, so `onCanceled` must be safe to call at
  /// any time.
  void startActivity({required VoidCallback onCanceled}) {
    _cancelActivity?.call();
    _cancelActivity = onCanceled;
  }

  /// The scroll position gets inputs in terms of pixels, but the size is
  /// expected to be expressed as a number between 0..1.
  ///
  /// This should only be called to respond to a user drag. To update the
  /// size in response to a programmatic call, use [updateSize] directly.
  void addPixelDelta(double delta, BuildContext context) {
    // Stop any playing sheet animations.
    _cancelActivity?.call();
    _cancelActivity = null;
    // The user has interacted with the sheet, set `hasDragged` to true so that
    // we'll snap if applicable.
    hasDragged = true;
    hasChanged = true;
    if (availablePixels == 0) {
      return;
    }
    updateSize(currentSize + pixelsToSize(delta), context);
  }

  /// Set the size to the new value. [newSize] should be a number between
  /// [minSize] and [maxSize].
  ///
  /// This can be triggered by a programmatic (e.g. controller triggered) change
  /// or a user drag.
  void updateSize(double newSize, BuildContext context) {
    final double clampedSize = clampDouble(newSize, minSize, maxSize);
    if (_currentSize.value == clampedSize) {
      return;
    }
    _currentSize.value = clampedSize;
    DraggableScrollableNotification(
      minExtent: minSize,
      maxExtent: maxSize,
      extent: currentSize,
      initialExtent: initialSize,
      context: context,
      shouldCloseOnMinExtent: shouldCloseOnMinExtent,
    ).dispatch(context);
  }

  double pixelsToSize(double pixels) {
    return pixels / availablePixels * maxSize;
  }

  double sizeToPixels(double size) {
    return size / maxSize * availablePixels;
  }

  void dispose() {
    _currentSize.dispose();
  }

  _DraggableSheetExtent copyWith({
    required double minSize,
    required double maxSize,
    required bool snap,
    required List<double> snapSizes,
    required double initialSize,
    Duration? snapAnimationDuration,
    bool shouldCloseOnMinExtent = true,
  }) {
    return _DraggableSheetExtent(
      minSize: minSize,
      maxSize: maxSize,
      snap: snap,
      snapSizes: snapSizes,
      snapAnimationDuration: snapAnimationDuration,
      initialSize: initialSize,
      // Set the current size to the possibly updated initial size if the sheet
      // hasn't changed yet.
      currentSize: ValueNotifier<double>(hasChanged
          ? clampDouble(_currentSize.value, minSize, maxSize)
          : initialSize),
      hasDragged: hasDragged,
      hasChanged: hasChanged,
      shouldCloseOnMinExtent: shouldCloseOnMinExtent,
    );
  }
}

class _DraggableScrollableLockAtTopSheetState
    extends State<DraggableScrollableLockAtTopSheet> {
  late _DraggableScrollableSheetLockAtTopScrollController _scrollController;
  late _DraggableSheetExtent _extent;

  @override
  void initState() {
    super.initState();
    _extent = _DraggableSheetExtent(
      minSize: widget.minChildSize,
      maxSize: widget.maxChildSize,
      snap: widget.snap,
      snapSizes: _impliedSnapSizes(),
      snapAnimationDuration: widget.snapAnimationDuration,
      initialSize: widget.initialChildSize,
      shouldCloseOnMinExtent: widget.shouldCloseOnMinExtent,
    );
    _scrollController = _DraggableScrollableSheetLockAtTopScrollController(
      extent: _extent,
      shouldLockAtTop: widget.lockAtTop,
    );
    widget.controller?._attach(_scrollController);
  }

  List<double> _impliedSnapSizes() {
    for (int index = 0; index < (widget.snapSizes?.length ?? 0); index += 1) {
      final double snapSize = widget.snapSizes![index];
      assert(snapSize >= widget.minChildSize && snapSize <= widget.maxChildSize,
          '${_snapSizeErrorMessage(index)}\nSnap sizes must be between `minChildSize` and `maxChildSize`. ');
      assert(index == 0 || snapSize > widget.snapSizes![index - 1],
          '${_snapSizeErrorMessage(index)}\nSnap sizes must be in ascending order. ');
    }
    // Ensure the snap sizes start and end with the min and max child sizes.
    if (widget.snapSizes == null || widget.snapSizes!.isEmpty) {
      return <double>[
        widget.minChildSize,
        widget.maxChildSize,
      ];
    }
    return <double>[
      if (widget.snapSizes!.first != widget.minChildSize) widget.minChildSize,
      ...widget.snapSizes!,
      if (widget.snapSizes!.last != widget.maxChildSize) widget.maxChildSize,
    ];
  }

  @override
  void didUpdateWidget(covariant DraggableScrollableLockAtTopSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(_scrollController);
    }
    _replaceExtent(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_InheritedResetNotifier.shouldReset(context)) {
      _scrollController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _extent._currentSize,
      builder: (BuildContext context, double currentSize, Widget? child) =>
          LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _extent.availablePixels =
              widget.maxChildSize * constraints.biggest.height;
          final Widget sheet = FractionallySizedBox(
            heightFactor: currentSize,
            alignment: Alignment.bottomCenter,
            child: child,
          );

          return CustomPaint(
              foregroundPainter: _ShadowPainter(
                opacity: 1 -
                    currentSize.progressAndClamp(
                      widget.minChildSize,
                      widget.minChildSize + 0.05,
                      1.0,
                    ),
              ),
              child: widget.expand ? SizedBox.expand(child: sheet) : sheet);
        },
      ),
      child: widget.builder(context, _scrollController),
    );
  }

  @override
  void dispose() {
    widget.controller?._detach(disposeExtent: true);
    _scrollController.dispose();
    super.dispose();
  }

  void _replaceExtent(covariant DraggableScrollableLockAtTopSheet oldWidget) {
    final _DraggableSheetExtent previousExtent = _extent;
    _extent = previousExtent.copyWith(
      minSize: widget.minChildSize,
      maxSize: widget.maxChildSize,
      snap: widget.snap,
      snapSizes: _impliedSnapSizes(),
      snapAnimationDuration: widget.snapAnimationDuration,
      initialSize: widget.initialChildSize,
    );
    // Modify the existing scroll controller instead of replacing it so that
    // developers listening to the controller do not have to rebuild their listeners.
    _scrollController.extent = _extent;
    // If an external facing controller was provided, let it know that the
    // extent has been replaced.
    widget.controller?._onExtentReplaced(previousExtent);
    previousExtent.dispose();
    if (widget.snap &&
        (widget.snap != oldWidget.snap ||
            widget.snapSizes != oldWidget.snapSizes) &&
        _scrollController.hasClients) {
      // Trigger a snap in case snap or snapSizes has changed and there is a
      // scroll position currently attached. We put this in a post frame
      // callback so that `build` can update `_extent.availablePixels` before
      // this runs-we can't use the previous extent's available pixels as it may
      // have changed when the widget was updated.
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        for (int index = 0;
            index < _scrollController.positions.length;
            index++) {
          final _DraggableScrollableSheetScrollAtTopPosition position =
              _scrollController.positions.elementAt(index)
                  as _DraggableScrollableSheetScrollAtTopPosition;
          position.goBallistic(0);
        }
      });
    }
  }

  String _snapSizeErrorMessage(int invalidIndex) {
    final List<String> snapSizesWithIndicator =
        widget.snapSizes!.asMap().keys.map(
      (int index) {
        final String snapSizeString = widget.snapSizes![index].toString();
        if (index == invalidIndex) {
          return '>>> $snapSizeString <<<';
        }
        return snapSizeString;
      },
    ).toList();
    return "Invalid snapSize '${widget.snapSizes![invalidIndex]}' at index $invalidIndex of:\n"
        '  $snapSizesWithIndicator';
  }
}

class _ShadowPainter extends CustomPainter {
  _ShadowPainter({required this.opacity});

  final double opacity;

  final Paint _paint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity >= 0.0) {
      _paint.color = Colors.black12.withValues(alpha: opacity * 0.12);
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          size.height - 10.0,
          size.width,
          size.height,
        ),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ShadowPainter oldDelegate) =>
      opacity != oldDelegate.opacity;

  @override
  bool shouldRebuildSemantics(_ShadowPainter oldDelegate) => false;
}

/// A [ScrollController] suitable for use in a [ScrollableWidgetBuilder] created
/// by a [DraggableScrollableLockAtTopSheet].
///
/// If a [DraggableScrollableLockAtTopSheet] contains content that is exceeds the height
/// of its container, this controller will allow the sheet to both be dragged to
/// fill the container and then scroll the child content.
///
/// See also:
///
///  * [_DraggableScrollableSheetScrollAtTopPosition], which manages the positioning logic for
///    this controller.
///  * [PrimaryScrollController], which can be used to establish a
///    [_DraggableScrollableSheetLockAtTopScrollController] as the primary controller for
///    descendants.
class _DraggableScrollableSheetLockAtTopScrollController
    extends ScrollController {
  _DraggableScrollableSheetLockAtTopScrollController({
    required this.extent,
    this.shouldLockAtTop,
  });

  _DraggableSheetExtent extent;
  VoidCallback? onPositionDetached;
  final ShouldLockDraggableSheetAtTop? shouldLockAtTop;

  @override
  _DraggableScrollableSheetScrollAtTopPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _DraggableScrollableSheetScrollAtTopPosition(
      physics: physics.applyTo(const AlwaysScrollableScrollPhysics()),
      context: context,
      oldPosition: oldPosition,
      getExtent: () => extent,
      shouldLockAtTop: shouldLockAtTop,
    );
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('extent: $extent');
  }

  @override
  _DraggableScrollableSheetScrollAtTopPosition get position =>
      super.position as _DraggableScrollableSheetScrollAtTopPosition;

  Future<void> reset() async {
    extent._cancelActivity?.call();
    extent.hasDragged = false;
    extent.hasChanged = false;
    // jumpTo can result in trying to replace semantics during build.
    // Just animate really fast.
    // Avoid doing it at all if the offset is already 0.0.
    if (offset != 0.0) {
      await animateTo(
        0.0,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    }
    extent.updateSize(
      extent.initialSize,
      position.context.notificationContext!,
    );
  }

  @override
  void detach(ScrollPosition position) {
    onPositionDetached?.call();
    super.detach(position);
  }
}

/// A scroll position that manages scroll activities for
/// [_DraggableScrollableSheetLockAtTopScrollController].
///
/// This class is a concrete subclass of [ScrollPosition] logic that handles a
/// single [ScrollContext], such as a [Scrollable]. An instance of this class
/// manages [ScrollActivity] instances, which changes the
/// [_DraggableSheetExtent.currentSize] or visible content offset in the
/// [Scrollable]'s [Viewport]
///
/// See also:
///
///  * [_DraggableScrollableSheetLockAtTopScrollController], which uses this as its [ScrollPosition].
class _DraggableScrollableSheetScrollAtTopPosition
    extends ScrollPositionWithSingleContext {
  _DraggableScrollableSheetScrollAtTopPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
    this.shouldLockAtTop,
    required this.getExtent,
  });

  VoidCallback? _dragCancelCallback;
  final _DraggableSheetExtent Function() getExtent;
  final Set<AnimationController> _ballisticControllers =
      <AnimationController>{};
  final ShouldLockDraggableSheetAtTop? shouldLockAtTop;

  bool lockAtTop = false;

  _DraggableSheetExtent get extent => getExtent();

  bool get listShouldScroll {
    if (extent.isAtMax && shouldLockAtTop?.call() == true && pixels > 0.0) {
      lockAtTop = true;
    }

    return lockAtTop;
  }

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);
    assert(_dragCancelCallback == null);

    if (other is! _DraggableScrollableSheetScrollAtTopPosition) {
      return;
    }

    if (other._dragCancelCallback != null) {
      _dragCancelCallback = other._dragCancelCallback;
      other._dragCancelCallback = null;
    }
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (newActivity is IdleScrollActivity && lockAtTop && pixels == 0) {
      lockAtTop = false;
    }

    // Cancel the running ballistic simulations
    for (final AnimationController ballisticController
        in _ballisticControllers) {
      ballisticController.stop();
    }
    super.beginActivity(newActivity);
  }

  @override
  void applyUserOffset(double delta) {
    if (!listShouldScroll &&
        (!(extent.isAtMin || extent.isAtMax) ||
            (extent.isAtMin && delta < 0) ||
            (extent.isAtMax && delta > 0))) {
      extent.addPixelDelta(-delta, context.notificationContext!);
    } else {
      super.applyUserOffset(delta);
    }
  }

  bool get _isAtSnapSize {
    return extent.snapSizes.any(
      (double snapSize) {
        return (extent.currentSize - snapSize).abs() <=
            extent.pixelsToSize(physics.toleranceFor(this).distance);
      },
    );
  }

  bool get _shouldSnap => extent.snap && extent.hasDragged && !_isAtSnapSize;

  @override
  void dispose() {
    for (final AnimationController ballisticController
        in _ballisticControllers) {
      ballisticController.dispose();
    }
    _ballisticControllers.clear();
    super.dispose();
  }

  @override
  void goBallistic(double velocity) {
    if ((velocity == 0.0 && !_shouldSnap) ||
        (velocity < 0.0 && listShouldScroll) ||
        (velocity > 0.0 && extent.isAtMax)) {
      super.goBallistic(velocity);
      return;
    }
    // Scrollable expects that we will dispose of its current _dragCancelCallback
    _dragCancelCallback?.call();
    _dragCancelCallback = null;

    late final Simulation simulation;
    if (extent.snap) {
      // Snap is enabled, simulate snapping instead of clamping scroll.
      simulation = _SnappingSimulation(
        position: extent.currentPixels,
        initialVelocity: velocity,
        pixelSnapSize: extent.pixelSnapSizes,
        snapAnimationDuration: extent.snapAnimationDuration,
        tolerance: physics.toleranceFor(this),
      );
    } else {
      // The iOS bouncing simulation just isn't right here - once we delegate
      // the ballistic back to the ScrollView, it will use the right simulation.
      simulation = ClampingScrollSimulation(
        // Run the simulation in terms of pixels, not extent.
        position: extent.currentPixels,
        velocity: velocity,
        tolerance: physics.toleranceFor(this),
      );
    }

    final AnimationController ballisticController =
        AnimationController.unbounded(
      debugLabel: objectRuntimeType(this, '_DraggableScrollableSheetPosition'),
      vsync: context.vsync,
    );
    _ballisticControllers.add(ballisticController);

    double lastPosition = extent.currentPixels;
    void tick() {
      final double delta = ballisticController.value - lastPosition;
      lastPosition = ballisticController.value;
      extent.addPixelDelta(delta, context.notificationContext!);
      if ((velocity > 0 && extent.isAtMax) ||
          (velocity < 0 && extent.isAtMin)) {
        // Make sure we pass along enough velocity to keep scrolling - otherwise
        // we just "bounce" off the top making it look like the list doesn't
        // have more to scroll.
        velocity = ballisticController.velocity +
            (physics.toleranceFor(this).velocity *
                ballisticController.velocity.sign);
        super.goBallistic(velocity);
        ballisticController.stop();
      } else if (ballisticController.isCompleted) {
        super.goBallistic(0);
      }
    }

    ballisticController
      ..addListener(tick)
      ..animateWith(simulation).whenCompleteOrCancel(
        () {
          if (_ballisticControllers.contains(ballisticController)) {
            _ballisticControllers.remove(ballisticController);
            ballisticController.dispose();
          }
        },
      );
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    // Save this so we can call it later if we have to [goBallistic] on our own.
    _dragCancelCallback = dragCancelCallback;
    return super.drag(details, dragCancelCallback);
  }
}

/// A widget that can notify a descendent [DraggableScrollableLockAtTopSheet] that it
/// should reset its position to the initial state.
///
/// The [Scaffold] uses this widget to notify a persistent bottom sheet that
/// the user has tapped back if the sheet has started to cover more of the body
/// than when at its initial position. This is important for users of assistive
/// technology, where dragging may be difficult to communicate.
///
/// This is just a wrapper on top of [DraggableLockAtTopScrollableController]. It is
/// primarily useful for controlling a sheet in a part of the widget tree that
/// the current code does not control (e.g. library code trying to affect a sheet
/// in library users' code). Generally, it's easier to control the sheet
/// directly by creating a controller and passing the controller to the sheet in
/// its constructor (see [DraggableScrollableLockAtTopSheet.controller]).
class DraggableScrollableActuator extends StatelessWidget {
  /// Creates a widget that can notify descendent [DraggableScrollableLockAtTopSheet]s
  /// to reset to their initial position.
  ///
  /// The [child] parameter is required.
  DraggableScrollableActuator({
    super.key,
    required this.child,
  });

  /// This child's [DraggableScrollableLockAtTopSheet] descendant will be reset when the
  /// [reset] method is applied to a context that includes it.
  ///
  /// Must not be null.
  final Widget child;

  final _ResetNotifier _notifier = _ResetNotifier();

  /// Notifies any descendant [DraggableScrollableLockAtTopSheet] that it should reset
  /// to its initial position.
  ///
  /// Returns `true` if a [DraggableScrollableActuator] is available and
  /// some [DraggableScrollableLockAtTopSheet] is listening for updates, `false`
  /// otherwise.
  static bool reset(BuildContext context) {
    final _InheritedResetNotifier? notifier =
        context.dependOnInheritedWidgetOfExactType<_InheritedResetNotifier>();
    if (notifier == null) {
      return false;
    }
    return notifier._sendReset();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedResetNotifier(notifier: _notifier, child: child);
  }
}

/// A [ChangeNotifier] to use with [InheritedResetNotifier] to notify
/// descendants that they should reset to initial state.
class _ResetNotifier extends ChangeNotifier {
  /// Whether someone called [sendReset] or not.
  ///
  /// This flag should be reset after checking it.
  bool _wasCalled = false;

  /// Fires a reset notification to descendants.
  ///
  /// Returns false if there are no listeners.
  bool sendReset() {
    if (!hasListeners) {
      return false;
    }
    _wasCalled = true;
    notifyListeners();
    return true;
  }
}

class _InheritedResetNotifier extends InheritedNotifier<_ResetNotifier> {
  /// Creates an [InheritedNotifier] that the [DraggableScrollableLockAtTopSheet] will
  /// listen to for an indication that it should reset itself back to [DraggableScrollableLockAtTopSheet.initialChildSize].
  ///
  /// The [child] and [notifier] properties must not be null.
  const _InheritedResetNotifier({
    required super.child,
    required _ResetNotifier super.notifier,
  });

  bool _sendReset() => notifier!.sendReset();

  /// Specifies whether the [DraggableScrollableLockAtTopSheet] should reset to its
  /// initial position.
  ///
  /// Returns true if the notifier requested a reset, false otherwise.
  static bool shouldReset(BuildContext context) {
    final InheritedWidget? widget =
        context.dependOnInheritedWidgetOfExactType<_InheritedResetNotifier>();
    if (widget == null) {
      return false;
    }
    assert(widget is _InheritedResetNotifier);
    final _InheritedResetNotifier inheritedNotifier =
        widget as _InheritedResetNotifier;
    final bool wasCalled = inheritedNotifier.notifier!._wasCalled;
    inheritedNotifier.notifier!._wasCalled = false;
    return wasCalled;
  }
}

class _SnappingSimulation extends Simulation {
  _SnappingSimulation({
    required this.position,
    required double initialVelocity,
    required List<double> pixelSnapSize,
    Duration? snapAnimationDuration,
    super.tolerance,
  }) {
    _pixelSnapSize = _getSnapSize(initialVelocity, pixelSnapSize);

    if (snapAnimationDuration != null &&
        snapAnimationDuration.inMilliseconds > 0) {
      velocity = (_pixelSnapSize - position) *
          1000 /
          snapAnimationDuration.inMilliseconds;
    }
    // Check the direction of the target instead of the sign of the velocity because
    // we may snap in the opposite direction of velocity if velocity is very low.
    else if (_pixelSnapSize < position) {
      velocity = math.min(-minimumSpeed, initialVelocity);
    } else {
      velocity = math.max(minimumSpeed, initialVelocity);
    }
  }

  final double position;
  late final double velocity;

  // A minimum speed to snap at. Used to ensure that the snapping animation
  // does not play too slowly.
  static const double minimumSpeed = 1600.0;

  late final double _pixelSnapSize;

  @override
  double dx(double time) {
    if (isDone(time)) {
      return 0;
    }
    return velocity;
  }

  @override
  bool isDone(double time) {
    return x(time) == _pixelSnapSize;
  }

  @override
  double x(double time) {
    final double newPosition = position + velocity * time;
    if ((velocity >= 0 && newPosition > _pixelSnapSize) ||
        (velocity < 0 && newPosition < _pixelSnapSize)) {
      // We're passed the snap size, return it instead.
      return _pixelSnapSize;
    }
    return newPosition;
  }

  // Find the two closest snap sizes to the position. If the velocity is
  // non-zero, select the size in the velocity's direction. Otherwise,
  // the nearest snap size.
  double _getSnapSize(double initialVelocity, List<double> pixelSnapSizes) {
    final int indexOfNextSize =
        pixelSnapSizes.indexWhere((double size) => size >= position);
    if (indexOfNextSize == 0) {
      return pixelSnapSizes.first;
    }
    final double nextSize = pixelSnapSizes[indexOfNextSize];
    final double previousSize = pixelSnapSizes[indexOfNextSize - 1];
    if (initialVelocity.abs() <= tolerance.velocity) {
      // If velocity is zero, snap to the nearest snap size with the minimum velocity.
      if (position - previousSize < nextSize - position) {
        return previousSize;
      } else {
        return nextSize;
      }
    }
    // Snap forward or backward depending on current velocity.
    if (initialVelocity < 0.0) {
      return pixelSnapSizes[indexOfNextSize - 1];
    }
    return pixelSnapSizes[indexOfNextSize];
  }
}

class DraggableScrollableLockAtTopController extends ChangeNotifier {
  _DraggableScrollableSheetLockAtTopScrollController? _attachedController;
  final Set<AnimationController> _animationControllers =
      <AnimationController>{};

  /// Get the current size (as a fraction of the parent height) of the attached sheet.
  double get size {
    _assertAttached();
    return _attachedController!.extent.currentSize;
  }

  bool get isScrolled => _attachedController == null
      ? false
      : _attachedController?.extent.initialSize !=
          _attachedController?.extent.currentSize;

  bool get isExpanded => size > 0.999;

  /// Get the current pixel height of the attached sheet.
  double get pixels {
    _assertAttached();
    return _attachedController!.extent.currentPixels;
  }

  /// Convert a sheet's size (fractional value of parent container height) to pixels.
  double sizeToPixels(double size) {
    _assertAttached();
    return _attachedController!.extent.sizeToPixels(size);
  }

  /// Returns Whether any [DraggableScrollableLockAtTopController] objects have attached themselves to the
  /// [DraggableScrollableSheet].
  ///
  /// If this is false, then members that interact with the [ScrollPosition],
  /// such as [sizeToPixels], [size], [animateTo], and [jumpTo], must not be
  /// called.
  bool get isAttached =>
      _attachedController != null && _attachedController!.hasClients;

  /// Convert a sheet's pixel height to size (fractional value of parent container height).
  double pixelsToSize(double pixels) {
    _assertAttached();
    return _attachedController!.extent.pixelsToSize(pixels);
  }

  /// Animates the attached sheet from its current size to the given [size], a
  /// fractional value of the parent container's height.
  ///
  /// Any active sheet animation is canceled. If the sheet's internal scrollable
  /// is currently animating (e.g. responding to a user fling), that animation is
  /// canceled as well.
  ///
  /// An animation will be interrupted whenever the user attempts to scroll
  /// manually, whenever another activity is started, or when the sheet hits its
  /// max or min size (e.g. if you animate to 1 but the max size is .8, the
  /// animation will stop playing when it reaches .8).
  ///
  /// The duration must not be zero. To jump to a particular value without an
  /// animation, use [jumpTo].
  ///
  /// The sheet will not snap after calling [animateTo] even if [DraggableScrollableSheet.snap]
  /// is true. Snapping only occurs after user drags.
  ///
  /// When calling [animateTo] in widget tests, `await`ing the returned
  /// [Future] may cause the test to hang and timeout. Instead, use
  /// [WidgetTester.pumpAndSettle].
  Future<void> animateTo(
    double size, {
    required Duration duration,
    required Curve curve,
  }) async {
    _assertAttached();
    assert(size >= 0 && size <= 1);
    assert(duration != Duration.zero);
    final AnimationController animationController =
        AnimationController.unbounded(
      vsync: _attachedController!.position.context.vsync,
      value: _attachedController!.extent.currentSize,
    );
    _animationControllers.add(animationController);
    _attachedController!.position.goIdle();
    // This disables any snapping until the next user interaction with the sheet.
    _attachedController!.extent.hasDragged = false;
    _attachedController!.extent.hasChanged = true;
    _attachedController!.extent.startActivity(onCanceled: () {
      // Don't stop the controller if it's already finished and may have been disposed.
      if (animationController.isAnimating) {
        animationController.stop();
      }
    });
    animationController.addListener(() {
      _attachedController!.extent.updateSize(
        animationController.value,
        _attachedController!.position.context.notificationContext!,
      );
    });
    await animationController.animateTo(
      clampDouble(size, _attachedController!.extent.minSize,
          _attachedController!.extent.maxSize),
      duration: duration,
      curve: curve,
    );
  }

  /// Jumps the attached sheet from its current size to the given [size], a
  /// fractional value of the parent container's height.
  ///
  /// If [size] is outside of a the attached sheet's min or max child size,
  /// [jumpTo] will jump the sheet to the nearest valid size instead.
  ///
  /// Any active sheet animation is canceled. If the sheet's inner scrollable
  /// is currently animating (e.g. responding to a user fling), that animation is
  /// canceled as well.
  ///
  /// The sheet will not snap after calling [jumpTo] even if [DraggableScrollableSheet.snap]
  /// is true. Snapping only occurs after user drags.
  void jumpTo(double size) {
    _assertAttached();
    assert(size >= 0 && size <= 1);
    // Call start activity to interrupt any other playing activities.
    _attachedController!.extent.startActivity(onCanceled: () {});
    _attachedController!.position.goIdle();
    _attachedController!.extent.hasDragged = false;
    _attachedController!.extent.hasChanged = true;
    _attachedController!.extent.updateSize(
        size, _attachedController!.position.context.notificationContext!);
  }

  /// Reset the attached sheet to its initial size (see: [DraggableScrollableSheet.initialChildSize]).
  Future<void> reset() async {
    _assertAttached();
    await _attachedController!.reset();
  }

  void _assertAttached() {
    assert(
      isAttached,
      'DraggableScrollableLockAtTopControllerer is not attached to a sheet. A DraggableScrollableLockAtTopControllerer '
      'must be used in a DraggableScrollableSheet before any of its methods are called.',
    );
  }

  void _attach(
      _DraggableScrollableSheetLockAtTopScrollController scrollController) {
    assert(_attachedController == null,
        'Draggable scrollable controller is already attached to a sheet.');
    _attachedController = scrollController;
    _attachedController!.extent._currentSize.addListener(notifyListeners);
    _attachedController!.onPositionDetached = _disposeAnimationControllers;
  }

  void _onExtentReplaced(_DraggableSheetExtent previousExtent) {
    // When the extent has been replaced, the old extent is already disposed and
    // the controller will point to a new extent. We have to add our listener to
    // the new extent.
    _attachedController!.extent._currentSize.addListener(notifyListeners);
    if (previousExtent.currentSize != _attachedController!.extent.currentSize) {
      // The listener won't fire for a change in size between two extent
      // objects so we have to fire it manually here.
      notifyListeners();
    }
  }

  void _detach({bool disposeExtent = false}) {
    if (disposeExtent) {
      _attachedController?.extent.dispose();
    } else {
      _attachedController?.extent._currentSize.removeListener(notifyListeners);
    }
    _disposeAnimationControllers();
    _attachedController = null;
  }

  void _disposeAnimationControllers() {
    for (final AnimationController animationController
        in _animationControllers) {
      animationController.dispose();
    }
    _animationControllers.clear();
  }
}
