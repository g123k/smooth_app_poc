import 'package:flutter/material.dart';

//ignore_for_file: constant_identifier_names
class NewsList extends StatelessWidget {
  const NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20.0,
          bottom: 10.0,
          left: 24.0,
          right: 24.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nos actualités :',
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 15.0),
            Image.asset('assets/images/news1.webp'),
          ],
        ),
      ),
    );
  }
}
