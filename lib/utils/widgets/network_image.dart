import 'package:flutter/material.dart';
import 'package:smoothapp_poc/utils/widgets/app_widget.dart';

import '../../resources/app_colors.dart';

class NetworkAppImage extends StatefulWidget {
  const NetworkAppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.topRadius = true,
    this.bottomRadius = true,
    this.backgroundColor,
    this.onTap,
  });

  final String url;
  final double? width;
  final double? height;
  final bool bottomRadius;
  final bool topRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  State<NetworkAppImage> createState() => _NetworkAppImageState();
}

class _NetworkAppImageState extends State<NetworkAppImage> {
  late final ImageProvider _provider;
  Color? _imageBackgroundColor;
  Color? _imagePrimaryColor;

  @override
  void initState() {
    super.initState();

    if (widget.backgroundColor != null) {
      _imageBackgroundColor = widget.backgroundColor;
    }

    _provider = NetworkImage(widget.url);
    _detectColor();
  }

  void _detectColor() async {
    await ColorScheme.fromImageProvider(provider: _provider).then((value) {
      _imageBackgroundColor ??= value.primaryContainer;
      _imagePrimaryColor = value.primary;
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: widget.topRadius ? const Radius.circular(10.0) : Radius.zero,
        bottom: widget.bottomRadius ? const Radius.circular(10.0) : Radius.zero,
      ),
      child: ColoredBox(
        color: _imageBackgroundColor ?? AppColors.greyLight2,
        child: Image.network(
          widget.url,
          width: widget.width,
          height: widget.height,
          errorBuilder: (_, __, ___) => const ImagePlaceholder(),
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) =>
              loadingProgress == null ||
                      loadingProgress.cumulativeBytesLoaded ==
                          loadingProgress.expectedTotalBytes
                  ? child
                  : const ImagePlaceholder(),
        ),
      ),
    );

    if (widget.onTap != null) {
      return InkWell(
        onTap: widget.onTap,
        highlightColor: _imagePrimaryColor?.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: child,
        ),
      );
    } else {
      return child;
    }
  }
}
