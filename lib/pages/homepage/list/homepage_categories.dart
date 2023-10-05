import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smoothapp_poc/pages/homepage/list/homepage_list_widgets.dart';

class HomePageCategories extends StatelessWidget {
  const HomePageCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20.0,
          bottom: 10.0,
          left: 24.0,
          right: 24.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomePageTitle(
              label: 'Les catégories du moment',
            ),
            SizedBox(height: 15.0),
            Row(
              children: [
                Expanded(
                  child: _CategoryItem(
                    label: 'Potiron',
                    fileName: 'cat1.svg',
                    color: Color(0xFFffeacb),
                  ),
                ),
                Expanded(
                  child: _CategoryItem(
                    label: 'Epinard',
                    fileName: 'cat2.svg',
                    color: Color(0xFFe3f2ce),
                  ),
                ),
                Expanded(
                  child: _CategoryItem(
                    label: 'Confitures',
                    fileName: 'cat3.svg',
                    color: Color(0xFFeddbd5),
                  ),
                ),
                Expanded(
                  child: _CategoryItem(
                    label: 'Gâteaux',
                    fileName: 'cat4.svg',
                    color: Color(0xFFfff5de),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.color,
    required this.fileName,
  });

  final String label;
  final Color color;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SvgPicture.asset('assets/images/$fileName'),
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
