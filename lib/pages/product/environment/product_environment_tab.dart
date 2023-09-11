import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductEnvironmentTab extends StatelessWidget {
  const ProductEnvironmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: (constraints.maxWidth / 428) * 1449,
        child: SvgPicture.asset(
          'assets/images/product_env.svg',
          // 428 x 1449
          width: constraints.maxWidth,
          height: (constraints.maxWidth / 428) * 1449,
          alignment: AlignmentDirectional.topCenter,
        ),
      );
    });
  }
}
