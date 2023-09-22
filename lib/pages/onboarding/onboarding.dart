import 'package:flutter/material.dart';
import 'package:smoothapp_poc/navigation.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';
import 'package:video_player/video_player.dart';

bool onBoardingVisited = false;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (onBoardingVisited) {
      onNextFrame(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const NavApp(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;

    if (_currentPage == 2) {
      child = const _VideoOnboarding();
    } else if (_currentPage < 2) {
      child = _ImageOnboarding(position: _currentPage + 1);
    } else {
      child = _ImageOnboarding(position: _currentPage);
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_currentPage == 4) {
            onBoardingVisited = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NavApp(),
              ),
            );
          } else {
            setState(() => _currentPage++);
          }
        },
        child: child,
      ),
    );
  }
}

class _ImageOnboarding extends StatelessWidget {
  const _ImageOnboarding({required this.position});

  final int position;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/onboarding/$position.PNG',
    );
  }
}

class _VideoOnboarding extends StatefulWidget {
  const _VideoOnboarding();

  @override
  State<_VideoOnboarding> createState() => _VideoOnboardingState();
}

class _VideoOnboardingState extends State<_VideoOnboarding> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/onboarding/video.mp4')
      ..initialize().then((_) {
        _controller.setVolume(0.8);
        _controller.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
