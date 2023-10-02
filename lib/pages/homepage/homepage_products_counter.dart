import 'package:flutter/material.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/text_utils.dart';
import 'package:smoothapp_poc/utils/widgets/search_bar/search_bar.dart';

class HomePageProductCounter extends StatelessWidget
    implements SearchBarFooterWidget {
  const HomePageProductCounter({
    required this.textScaleFactor,
    super.key,
  });

  final double textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icons.Info(
                  size: 24.0,
                  color: AppColors.blackSecondary,
                ),
                SizedBox(width: 18.0),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.blackSecondary,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Text(
                    'Le saviez-vous ?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 42.0),
              child: RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    const TextSpan(
                      text:
                          'Open Food Facts est une base de données ouverte de plus de ',
                    ),
                    HighlightedTextSpan(
                      text: '2 834 456 produits',
                      textStyle: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 1.0,
                      ),
                      backgroundColor: AppColors.primaryAlt,
                      radius: 11.0,
                    ),
                    const TextSpan(text: ' plus ceux que vous contribuerez !'),
                  ],
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 15.0,
                        color: AppColors.blackSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.8,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get height => (110.0 * textScaleFactor);

  @override
  Color get color => AppColors.primaryVeryLight;
}
