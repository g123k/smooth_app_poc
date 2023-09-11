import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductForMeTab extends StatelessWidget {
  const ProductForMeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: (constraints.maxWidth / 428) * 808,
        child: SvgPicture.asset(
          'assets/images/product_forme.svg',
          // 428 x 808
          width: constraints.maxWidth,
          height: (constraints.maxWidth / 428) * 808,
          alignment: AlignmentDirectional.topCenter,
        ),
      );
    });
  }
}
