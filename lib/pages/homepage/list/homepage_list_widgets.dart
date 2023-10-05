import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/homepage/personalization/homepage_personalization.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;

class HomePageTitle extends StatelessWidget {
  const HomePageTitle({
    required this.label,
    this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 19.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        HomePageViewMoreButton(
          onTap: onTap,
        ),
      ],
    );
  }
}

class HomePageViewMoreButton extends StatelessWidget {
  const HomePageViewMoreButton({
    required this.onTap,
    super.key,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.grey,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (onTap != null)
              InkWell(
                onTap: onTap,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20.0),
                ),
                child: const SizedBox(
                  height: double.infinity,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 15.0,
                      end: 9.0,
                    ),
                    child: Center(
                      child: Text(
                        'Voir plus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: AppColors.blackPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.grey,
                  width: 1.0,
                ),
              ),
              child: InkWell(
                onTap: () {
                  HomePagePersonalization.open(context);
                },
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(11.0),
                  child: icons.Personalization(size: 12.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
