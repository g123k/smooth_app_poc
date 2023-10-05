import 'package:flutter/material.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';

class OnboardingPositiveButton extends StatelessWidget {
  const OnboardingPositiveButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OnboardingButton(
      label: label,
      onTap: onTap,
      backgroundColor: AppColors.green,
      foregroundColor: AppColors.white,
    );
  }
}

class OnboardingNegativeButton extends StatelessWidget {
  const OnboardingNegativeButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OnboardingButton(
      label: label,
      onTap: onTap,
      backgroundColor: AppColors.lightBlue,
      foregroundColor: const Color(0xFF001C2F),
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  const _OnboardingButton({
    required this.label,
    required this.onTap,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(42.0)),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(42.0)),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
