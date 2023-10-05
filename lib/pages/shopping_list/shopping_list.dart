import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smoothapp_poc/utils/system_ui.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUIStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/shopping/shopping_1_01.png',
                  fit: BoxFit.fitWidth,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(
                      builder: (context) => const Shopping2(),
                    ));
                  },
                  child: Image.asset(
                    'assets/shopping/shopping_1_02.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Image.asset(
                  'assets/shopping/shopping_1_03.png',
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Shopping2 extends StatelessWidget {
  const Shopping2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/shopping/shopping_2_01.png',
                fit: BoxFit.fitWidth,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const Shopping3(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_2_02.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Image.asset(
                'assets/shopping/shopping_2_03.png',
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Shopping3 extends StatelessWidget {
  const Shopping3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/shopping/shopping_3_01.png',
                fit: BoxFit.fitWidth,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ShoppingSessions1(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_3_02.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ShoppingSessionsInsights(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_3_03.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const Scan1(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_3_04.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const Onboarding(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_3_05.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ScanBarcodes1(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_3_06.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ShoppingSessionsInsights(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_3_07.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Scan1 extends StatelessWidget {
  const Scan1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/shopping/scan_1_01.png',
                fit: BoxFit.fitWidth,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const Scan2(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/scan_1_02.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const Scan2(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/scan_1_03.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  'assets/shopping/scan_1_04.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Scan2 extends StatelessWidget {
  const Scan2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/shopping/scan_2_01.png',
                fit: BoxFit.fitWidth,
              ),
              Image.asset(
                'assets/shopping/scan_2_02.png',
                fit: BoxFit.fitWidth,
              ),
              Image.asset(
                'assets/shopping/scan_2_03.png',
                fit: BoxFit.fitWidth,
              ),
              Image.asset(
                'assets/shopping/scan_2_04.png',
                fit: BoxFit.fitWidth,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const Scan3(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/scan_2_05.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Scan3 extends StatelessWidget {
  const Scan3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Image.asset(
                  'assets/shopping/scan_3_01.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (currentPage < 6) {
                    setState(() => currentPage++);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Image.asset(
                  'assets/shopping/onboarding_${currentPage + 1}.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoppingSessions1 extends StatelessWidget {
  const ShoppingSessions1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/shopping/shopping_session_1_01.png',
                fit: BoxFit.fitWidth,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const Shopping3(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_session_1_02.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ShoppingSessionsInsights(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_session_1_03.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Image.asset(
                'assets/shopping/shopping_session_1_04.png',
                fit: BoxFit.fitWidth,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ShoppingSessionsPastSession(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_session_1_05.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoppingSessionsPastSession extends StatelessWidget {
  const ShoppingSessionsPastSession({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTapDown: (TapDownDetails details) {
                  if (details.localPosition.dy > 50) {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(
                      builder: (context) => const EditFoodItem(),
                    ));
                  }
                },
                child: Image.asset(
                  'assets/shopping/shopping_session_2_01.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ShoppingSessionsInsights(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shopping_session_2_02.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditFoodItem extends StatelessWidget {
  const EditFoodItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/shopping/editfooditem_1_01.png',
                fit: BoxFit.fitWidth,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  'assets/shopping/editfooditem_1_02.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoppingSessionsInsights extends StatelessWidget {
  const ShoppingSessionsInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/shopping/insights_1_01.png',
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanBarcodes1 extends StatelessWidget {
  const ScanBarcodes1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/shopping/shoppinglocation_1_01.png',
                fit: BoxFit.fitWidth,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ScanBarcodes2(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shoppinglocation_1_02.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanBarcodes2 extends StatelessWidget {
  const ScanBarcodes2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                    builder: (context) => const ScanBarcodes3(),
                  ));
                },
                child: Image.asset(
                  'assets/shopping/shoppinglocation_2_01.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanBarcodes3 extends StatelessWidget {
  const ScanBarcodes3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  'assets/shopping/shoppinglocation_3_01.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
