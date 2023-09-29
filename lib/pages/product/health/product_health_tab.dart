import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductHealthTab extends StatefulWidget {
  const ProductHealthTab({super.key});

  @override
  State<ProductHealthTab> createState() => _ProductHealthTabState();
}

class _ProductHealthTabState extends State<ProductHealthTab>
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
          height: (constraints.maxWidth / 428) * (_isExpanded ? 1300 : 808),
          child: Image.asset(
            'assets/images/product_nutrition_${!_isExpanded ? 'min' : 'max'}.webp',
            // 428 x 1300
            width: constraints.maxWidth,
            height: (constraints.maxWidth / 428) * 1300,
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
