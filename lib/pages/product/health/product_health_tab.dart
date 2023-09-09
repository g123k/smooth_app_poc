import 'package:flutter/material.dart';

class ProductHealthTab extends StatelessWidget {
  const ProductHealthTab({super.key});

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
