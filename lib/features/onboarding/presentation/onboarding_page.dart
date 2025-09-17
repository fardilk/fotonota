import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../../core/utils/prefs_helper.dart';
import '../../../core/config/route_names.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  List<PageViewModel> _pages() => [
        PageViewModel(
          title: 'Capture Receipts',
          body: 'Snap receipts quickly with the built-in camera and OCR.',
          image: _placeholderImage(),
        ),
        PageViewModel(
          title: 'Track Spending',
            body: 'Automatically categorize and monitor your expenses.',
          image: _placeholderImage(),
        ),
        PageViewModel(
          title: 'Generate Reports',
          body: 'Visualize trends and export summaries easily.',
          image: _placeholderImage(),
        ),
      ];

  static Widget _placeholderImage() => const FlutterLogo(size: 140);

  Future<void> _complete(BuildContext context) async {
    await PrefsHelper.setOnboardingSeen();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: _pages(),
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Start', style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () => _complete(context),
      onSkip: () => _complete(context),
      dotsDecorator: const DotsDecorator(activeColor: Colors.deepPurple),
    );
  }
}
