import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchPageLoading extends StatelessWidget {
  const SearchPageLoading({required this.search, super.key});

  final String search;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/search.svg',
            width: MediaQuery.of(context).size.height * 0.16,
          ),
          const SizedBox(height: 47.0),
          RichText(
            text: TextSpan(children: <TextSpan>[
              const TextSpan(text: 'Votre recherche de "'),
              TextSpan(text: search),
              const TextSpan(
                  text:
                      '" esr en cours.\nMerci de patienter quelques instants'),
            ], style: const TextStyle(height: 1.6)),
          )
        ],
      ),
    );
  }
}
