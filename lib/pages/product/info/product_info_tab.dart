import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductInfoTab extends StatelessWidget {
  const ProductInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: (constraints.maxWidth / 428) * 1180,
        child: SvgPicture.asset(
          'assets/images/product_info.svg',
          // 428 x 1180
          width: constraints.maxWidth,
          height: (constraints.maxWidth / 428) * 1180,
          alignment: AlignmentDirectional.topCenter,
        ),
      );
    });
  }
}
