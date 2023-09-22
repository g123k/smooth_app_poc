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
  });

  final String url;
  final double? width;
  final double? height;
  final bool bottomRadius;
  final bool topRadius;
  final Color? backgroundColor;

  @override
  State<NetworkAppImage> createState() => _NetworkAppImageState();
}

class _NetworkAppImageState extends State<NetworkAppImage> {
  late final ImageProvider _provider;
  Color? _imageColor;

  @override
  void initState() {
    super.initState();

    if (widget.backgroundColor != null) {
      _imageColor = widget.backgroundColor;
    } else {
      _provider = NetworkImage(widget.url);
      _detectColor();
    }
  }

  void _detectColor() async {
    _imageColor = await ColorScheme.fromImageProvider(provider: _provider)
        .then((value) => value.primaryContainer);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: widget.topRadius ? const Radius.circular(10.0) : Radius.zero,
        bottom: widget.bottomRadius ? const Radius.circular(10.0) : Radius.zero,
      ),
      child: ColoredBox(
        color: _imageColor ?? AppColors.greyLight2,
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
  }
}
