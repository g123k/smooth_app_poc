import 'package:flutter/material.dart';

class ProductContributeTab extends StatelessWidget {
  const ProductContributeTab({super.key});

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
