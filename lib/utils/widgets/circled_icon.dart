import 'package:flutter/material.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart';

class CircledIcon extends StatelessWidget {
  const CircledIcon({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.iconColor,
    this.borderColor,
    this.backgroundColor,
    super.key,
  });

  final AppIcon icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      enableFeedback: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? AppColors.orange,
                width: 1.0,
              ),
              color: backgroundColor ?? AppColors.orangeVeryLight,
            ),
            padding: const EdgeInsets.all(12.0),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class CloseCircledIcon extends StatelessWidget {
  const CloseCircledIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CircledIcon(
      icon: const Close(),
      onPressed: () {
        Navigator.of(context).maybePop();
      },
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
    );
  }
}
