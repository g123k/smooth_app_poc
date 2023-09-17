import 'package:flutter/material.dart';

//ignore_for_file: constant_identifier_names
class GuidesList extends StatelessWidget {
  const GuidesList({super.key});

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
              'Nos guides :',
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 15.0),
            InkWell(
              borderRadius: BorderRadius.circular(20.0),
              onTap: () {},
              child: Ink.image(
                height: 120.0,
                width: double.infinity,
                image: AssetImage('assets/images/guides1.webp'),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10.0),
            Image.asset('assets/images/guides2.webp'),
          ],
        ),
      ),
    );
  }
}
