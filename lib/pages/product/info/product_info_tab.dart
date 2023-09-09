import 'package:flutter/material.dart';

class ProductInfoTab extends StatelessWidget {
  const ProductInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemBuilder: (BuildContext context, int index) {
        return const Placeholder();
      },
      itemCount: 20,
    );
  }
}
