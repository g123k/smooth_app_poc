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

    buffer.writeln('''
Le Nutri-Score est un logo nutritionnel facultatif adopté par certains pays européens, dont la France. Il a pour but d\'informer les consommateurs sur la qualité nutritionnelle des aliments, en utilisant un code couleur allant du vert foncé (A) pour les produits les plus sains au rouge foncé (E) pour les moins sains. Le Nutri-Score est calculé sur la base d\'une formule qui prend en compte à la fois les éléments nutritionnels à favoriser (fibres, protéines, fruits, légumes, légumineuses, huiles de colza, noix, olive) et ceux à limiter (énergie, acides gras saturés, sucres, sel).

Pour le Nesquik, plusieurs facteurs peuvent contribuer à un Nutri-Score A :

Faible teneur en matières grasses : Le Nesquik, étant principalement composé de cacao en poudre, a généralement une faible teneur en matières grasses, ce qui améliore son Nutri-Score.

Présence de fibres : Le cacao est également une source de fibres, ce qui peut améliorer le Nutri-Score.

Faible teneur en sel : Le Nesquik contient généralement peu ou pas de sel, ce qui est également un facteur positif.

Portion recommandée : Le Nutri-Score est souvent calculé sur la base de la portion recommandée. Si cette portion est petite, cela peut également contribuer à un meilleur score.

Formulation spécifique : Certains produits Nesquik peuvent être formulés pour être plus sains, avec par exemple moins de sucre ajouté, ce qui peut contribuer à un meilleur Nutri-Score.

Produits similaires : Le Nutri-Score est également relatif à la catégorie de produits. Si la plupart des produits similaires ont un profil nutritionnel moins favorable, le Nesquik peut se distinguer avec un meilleur score.

Il est important de noter que le Nutri-Score ne prend pas en compte tous les aspects de la santé nutritionnelle d\'un produit. Par exemple, il ne tient pas compte de la présence d\'additifs, de pesticides ou de la qualité globale des ingrédients.

Pour une évaluation complète et spécifique, il serait utile de consulter la liste des ingrédients et les valeurs nutritionnelles sur l\'emballage du produit ou dans la base de données de Open Food Facts.''');

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
