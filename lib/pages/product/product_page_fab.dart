import 'package:flutter/material.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/pages/product/header/product_header_body.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;

mixin ProductPageFABContainer<T extends StatefulWidget> on State<T> {
  final Map<ProductHeaderTabs, OverlayEntry> _entries = {};

  void showFAB(ProductPageFAB fab, ProductHeaderTabs tab) {
    _hideFABOtherThan(tab);
    _entries[tab] = OverlayEntry(builder: (context) {
      return fab;
    });

    _showFABForTab(tab);
  }

  void _hideFABOtherThan(ProductHeaderTabs tabToHide) {
    for (ProductHeaderTabs tab in _entries.keys) {
      if (tab != tabToHide && _entries[tab]?.mounted == true) {
        _entries[tab]!.remove();
      }
    }
  }

  void onPageChanged(ProductHeaderTabs tab) {
    _hideFABOtherThan(tab);
    _showFABForTab(tab);
  }

  void _showFABForTab(ProductHeaderTabs tab) {
    try {
      if (_entries[tab]?.mounted == false &&
          NavApp.of(context).isSheetFullyVisible) {
        //onNextFrame(() => Overlay.of(context).insert(_entries[tab]!));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _entries.forEach((key, value) {
      if (value.mounted) {
        value.remove();
      }
      value.dispose();
    });
    _entries.clear();
    super.dispose();
  }
}

class ProductPageFAB extends StatefulWidget {
  const ProductPageFAB({
    required this.label,
    this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final icons.AppIcon? icon;
  final VoidCallback onTap;

  @override
  State<ProductPageFAB> createState() => _ProductPageFABState();
}

class _ProductPageFABState extends State<ProductPageFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 250,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (widget.icon == null) {
      child = _createLabel();
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: const IconThemeData(
              color: Colors.white,
              size: 15.0,
            ),
            child: widget.icon!,
          ),
          const SizedBox(width: 8.0),
          _createLabel(),
        ],
      );
    }

    return Positioned.directional(
      textDirection: Directionality.of(context),
      end: 18.0,
      bottom: 18.0,
      child: OutlinedButton(
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(
            AppColors.primary,
          ),
        ),
        onPressed: widget.onTap,
        child: child,
      ),
    );
  }

  Text _createLabel() {
    return Text(
      widget.label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
