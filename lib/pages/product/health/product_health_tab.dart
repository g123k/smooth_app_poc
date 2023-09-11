import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductHealthTab extends StatelessWidget {
  const ProductHealthTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: (constraints.maxWidth / 428) * 1300,
        child: SvgPicture.asset(
          'assets/images/product_nutrition.svg',
          // 428 x 1300
          width: constraints.maxWidth,
          height: (constraints.maxWidth / 428) * 1300,
          fit: BoxFit.fitWidth,
          alignment: AlignmentDirectional.topCenter,
        ),
      );
    });
  }
}
