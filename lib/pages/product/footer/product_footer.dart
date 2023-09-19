import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;

class ProductFooter extends StatefulWidget {
  const ProductFooter({super.key});

  @override
  State<ProductFooter> createState() => _ProductFooterState();
}

class _ProductFooterState extends State<ProductFooter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    SheetVisibilityNotifier? sheetController =
        context.watch<SheetVisibilityNotifier?>();

    if (sheetController == null) {
      _controller.value = 0.0;
    } else if (sheetController.isFullyVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(
        0.0,
        _animation.value *
            (16.0 + 46.0 + MediaQuery.viewPaddingOf(context).bottom),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackPrimary.withOpacity(0.1),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: 16.0,
            bottom: MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: const _ProductFooterButtonsBar(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ProductFooterButtonsBar extends StatelessWidget {
  const _ProductFooterButtonsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.0,
      child: OutlinedButtonTheme(
        data: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            side: const BorderSide(color: AppColors.grey),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 19.0,
              vertical: 14.0,
            ),
          ),
        ),
        child: ListView(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20.0),
          scrollDirection: Axis.horizontal,
          children: [
            _ProductFooterFilledButton(
              label: 'Comparer',
              icon: const icons.Compare(),
              onTap: () {},
            ),
            const SizedBox(width: 10.0),
            _ProductFooterOutlinedButton(
              label: 'Ajouter à une liste',
              icon: const icons.AddToList(),
              onTap: () {},
            ),
            const SizedBox(width: 10.0),
            _ProductFooterOutlinedButton(
              label: 'Modifier',
              icon: const icons.Edit(),
              onTap: () {},
            ),
            const SizedBox(width: 10.0),
            _ProductFooterOutlinedButton(
              label: 'Partager',
              icon: icons.Share(),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFooterFilledButton extends StatelessWidget {
  const _ProductFooterFilledButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final icons.AppIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.primary,
        side: BorderSide.none,
      ),
      child: Row(
        children: [
          IconTheme(
            data: const IconThemeData(
              color: AppColors.white,
              size: 18.0,
            ),
            child: icon,
          ),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductFooterOutlinedButton extends StatelessWidget {
  const _ProductFooterOutlinedButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final icons.AppIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
          IconTheme(
            data: const IconThemeData(
              color: AppColors.primary,
              size: 18.0,
            ),
            child: icon,
          ),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
