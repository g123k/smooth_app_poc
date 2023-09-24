import 'package:flutter/material.dart';
import 'package:smoothapp_poc/resources/app_animations.dart';

class SearchPageLoading extends StatelessWidget {
  const SearchPageLoading({required this.search, super.key});

  final String search;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchEyeAnimation(
              size: MediaQuery.of(context).size.height * 0.16,
            ),
            const SizedBox(height: 47.0),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(text: 'Votre recherche de "'),
                  TextSpan(text: search),
                  const TextSpan(
                      text:
                          '" est en cours.\nMerci de patienter quelques instants'),
                ],
                style: DefaultTextStyle.of(context).style.copyWith(
                      height: 1.6,
                    ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
