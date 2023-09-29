import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductEnvironmentTab extends StatefulWidget {
  const ProductEnvironmentTab({super.key});

  @override
  State<ProductEnvironmentTab> createState() => _ProductEnvironmentTabState();
}

class _ProductEnvironmentTabState extends State<ProductEnvironmentTab>
    with AutomaticKeepAliveClientMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onLongPress: () {
          HapticFeedback.heavyImpact();
          setState(() => _isExpanded = !_isExpanded);
        },
        child: SizedBox(
          width: constraints.maxWidth,
          height: (constraints.maxWidth / 428) * (_isExpanded ? 1449 : 808),
          child: Image.asset(
            'assets/images/product_env_${!_isExpanded ? 'min' : 'max'}.webp',
            // 428 x 1300
            width: constraints.maxWidth,
            height: (constraints.maxWidth / 428) * (_isExpanded ? 1449 : 808),
            fit: BoxFit.fitWidth,
            alignment: AlignmentDirectional.topCenter,
          ),
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
