import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A [Material] where the elevation is animated based on the scroll position
/// and provided by [elevationThreshold].
class DynamicMaterial extends StatefulWidget {
  const DynamicMaterial({
    super.key,
    required this.type,
    required this.elevationThreshold,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground,
    this.clipBehavior,
    this.animationDuration,
    this.child,
  });

  final MaterialType type;
  final double elevationThreshold;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final bool? borderOnForeground;
  final Clip? clipBehavior;
  final Duration? animationDuration;
  final Widget? child;

  @override
  State<DynamicMaterial> createState() => _DynamicMaterialState();
}

class _DynamicMaterialState extends State<DynamicMaterial> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: widget.type,
      elevation:
          context.watch<ScrollController>().offset >= widget.elevationThreshold
              ? 2.0
              : 0.0,
      color: widget.color,
      shadowColor: widget.shadowColor,
      surfaceTintColor: widget.surfaceTintColor,
      textStyle: widget.textStyle,
      borderRadius: widget.borderRadius,
      shape: widget.shape,
      borderOnForeground: widget.borderOnForeground ?? true,
      clipBehavior: widget.clipBehavior ?? Clip.none,
      animationDuration: widget.animationDuration ?? kThemeChangeDuration,
      child: widget.child,
    );
  }
}
