import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/utils/num_utils.dart';
import 'package:smoothapp_poc/utils/widgets/circled_icon.dart';

class NewsPage extends StatelessWidget {
  const NewsPage._({
    required this.title,
    required this.image,
    required this.backgroundColor,
  });

  final String title;
  final String image;
  final Color backgroundColor;

  static Future<void> open(
    BuildContext context, {
    required String title,
    required String image,
    required Color backgroundColor,
  }) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<NewsPage>(
        pageBuilder: (context, animation1, animation2) => NewsPage._(
          title: title,
          image: image,
          backgroundColor: backgroundColor,
        ),
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          const Offset begin = Offset(0.0, 1.0);
          const Offset end = Offset.zero;
          final Tween<Offset> tween = Tween(begin: begin, end: end);
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          final Animation<double> fadeAnimation =
              animation.drive(_CustomAnimatable());

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        top: false,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 250.0 + MediaQuery.viewPaddingOf(context).top,
                color: backgroundColor,
                child: Stack(
                  children: [
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      top: MediaQuery.viewPaddingOf(context).top,
                      start: null,
                      end: 15.0,
                      bottom: 0.0,
                      child: Hero(
                        tag: 'news_image',
                        child: Image.asset('assets/images/guides1_image.webp'),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Positioned.fill(
                      top: null,
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 28.0,
                          right: 28.0,
                          top: 30.0,
                          bottom: 10.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              backgroundColor.withOpacity(0.0),
                              backgroundColor.withOpacity(0.5),
                              backgroundColor.withOpacity(0.9),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Hero(
                          tag: 'news_title',
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 20.0,
                                  color: AppColors.white,
                                ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      start: 12.0,
                      top: MediaQuery.viewPaddingOf(context).top,
                      child: const CloseCircledIcon(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: PrimaryScrollController.of(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 30.0,
                    ),
                    child: Text(
                      generateContent(),
                      style: const TextStyle(
                        fontSize: 15.0,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String generateContent() {
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i != 100; i++) {
      buffer.writeln(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, quis aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, quis aliquam nisl nisl vitae nisl.');
    }

    return buffer.toString();
  }
}

class _CustomAnimatable extends Animatable<double> {
  @override
  double transform(double t) {
    if (t < 0.6) {
      return 0.0;
    }

    return t.progressAndClamp(0.6, 1.0, 1.0);
  }
}
