import 'package:flutter/material.dart';

class ProductPhotosTab extends StatelessWidget {
  const ProductPhotosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: (constraints.maxWidth / 856) * 1616,
        child: Image.asset(
          'assets/images/product_photos.webp',
          // 856 x 1616
          width: constraints.maxWidth,
          height: (constraints.maxWidth / 856) * 1616,
          alignment: AlignmentDirectional.topCenter,
        ),
      );
    });
  }
}
