import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            if (currentPage > 0) {
              setState(() => currentPage--);
              return false;
            }
            return true;
          },
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              final Size size = MediaQuery.sizeOf(context);
              if (details.localPosition.dx > size.width * 0.5) {
                setState(() => currentPage = math.min(currentPage + 1, 3));
              } else {
                setState(() => currentPage = math.max(currentPage - 1, 0));
              }
            },
            child: SizedBox.expand(
              child: Image.asset(
                'assets/shopping/shopping_${currentPage + 1}.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
