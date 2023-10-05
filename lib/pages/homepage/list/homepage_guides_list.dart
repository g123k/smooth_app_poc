import 'package:flutter/material.dart';
import 'package:smoothapp_poc/pages/homepage/list/homepage_list_widgets.dart';
import 'package:smoothapp_poc/pages/news/news_page.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';

//ignore_for_file: constant_identifier_names
class GuidesList extends StatelessWidget {
  const GuidesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20.0,
          bottom: 15.0,
          left: 24.0,
          right: 24.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomePageTitle(
              label: 'Cela pourrait vous intéresser…',
            ),
            const SizedBox(height: 15.0),
            const _GuideItem(
              title: 'Pourquoi le Nesquik a-t-il un Nutri-Score A ?',
              image: 'assets/images/guides1.webp',
            ),
            const SizedBox(height: 10.0),
            Image.asset('assets/images/guides2.webp'),
            const SizedBox(height: 10.0),
            Image.asset('assets/images/guides3.webp'),
            const SizedBox(height: 10.0),
            Image.asset('assets/images/guides4.webp'),
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.title,
    required this.image,
  });

  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NewsPage.open(
          context,
          title: title,
          image: image,
          backgroundColor: AppColors.blackPrimary,
        );
      },
      borderRadius: BorderRadius.circular(20.0),
      child: SizedBox(
        width: double.infinity,
        height: 120.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.blackPrimary,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 48,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 25.0,
                      end: 10.0,
                    ),
                    child: Hero(
                      tag: 'news_title',
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 52,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10.0),
                      child: Hero(
                        tag: 'news_image',
                        child: Image.asset('assets/images/guides1.webp'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
