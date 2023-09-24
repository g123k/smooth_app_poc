import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool foodPreferencesDefined = false;

class FoodPreferencesPage extends StatefulWidget {
  const FoodPreferencesPage({super.key});

  @override
  State<FoodPreferencesPage> createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            if (currentPage > 0) {
              setState(() => currentPage--);
              return false;
            }
            return true;
          },
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              final Size size = MediaQuery.sizeOf(context);
              if (details.localPosition.dy > size.height * 0.9) {
                if (details.localPosition.dx < size.width * 0.4) {
                  if (currentPage > 0) {
                    setState(() => currentPage--);
                  } else {
                    Navigator.of(context).pop(false);
                  }
                }
                if (details.localPosition.dx > size.width * 0.6) {
                  if (currentPage < 7) {
                    setState(() => currentPage++);
                  } else {
                    foodPreferencesDefined = true;
                    Navigator.of(context).pop(true);
                  }
                }
              }
            },
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/foodprefs_${currentPage + 1}.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
