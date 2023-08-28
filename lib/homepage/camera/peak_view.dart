import 'package:flutter/material.dart';
import 'package:smoothapp_poc/homepage/homepage.dart';

class PeakView extends StatelessWidget {
  const PeakView({
    required this.opacity,
    required this.onTap,
    super.key,
  });

  final double opacity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: opacity > 0.0 ? onTap : null,
        child: SizedBox(
          height: size.height * HomePage.CAMERA_PEAK,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 25.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                const FractionallySizedBox(
                  widthFactor: 0.75,
                  child: Text(
                    'Cliquez pour rechercher un produit en scannant son code-barres',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.8,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
