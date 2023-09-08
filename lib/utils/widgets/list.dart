import 'package:flutter/material.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    required this.child,
    this.leading,
    this.trailing = ListItemTrailingType.none,
    this.onTap,
    this.padding,
    super.key,
  });

  ListItem.text(
    String label, {
    this.leading,
    this.trailing = ListItemTrailingType.none,
    this.onTap,
    this.padding,
    super.key,
  }) : child = Text(label);

  final Widget child;
  final ListItemLeading? leading;
  final ListItemTrailingType trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _computePadding(),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: leading!.build(context),
              ),
            Expanded(child: child),
            if (trailing == ListItemTrailingType.chevron)
              const Icon(
                Icons.chevron_right,
                color: AppColors.greyLight2,
              ),
          ],
        ),
      ),
    );
  }

  EdgeInsetsGeometry _computePadding() {
    if (padding != null) {
      return padding!;
    } else if (onTap != null) {
      return const EdgeInsets.symmetric(
        horizontal: 28.0,
        vertical: 5.0,
      );
    } else {
      return const EdgeInsets.symmetric(
        horizontal: 28.0,
        vertical: 16.0,
      );
    }
  }
}

enum ListItemTrailingType { none, chevron }

sealed class ListItemLeading {
  const ListItemLeading._();

  Widget build(BuildContext context);
}

class ListItemLeadingWidget extends ListItemLeading {
  const ListItemLeadingWidget({
    required this.child,
  }) : super._();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ListItemLeadingIcon extends ListItemLeading {
  const ListItemLeadingIcon({
    required this.icon,
    this.color,
  }) : super._();

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color);
  }
}

class ListItemLeadingScore extends ListItemLeading {
  const ListItemLeadingScore.high()
      : color = AppColors.compatibilityHigh,
        super._();

  const ListItemLeadingScore.medium()
      : color = AppColors.compatibilityMedium,
        super._();

  const ListItemLeadingScore.low()
      : color = AppColors.compatibilityLow,
        super._();

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ListItemDivider extends StatelessWidget {
  const ListItemDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1.0,
      color: AppColors.greyLight2,
    );
  }
}
