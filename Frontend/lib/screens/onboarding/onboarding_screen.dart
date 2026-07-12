// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/landing/landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../auth/login_screen.dart';
import 'splash_screen.dart' show kOnboardingSeenKey;

class _OnboardPage {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;

  const _OnboardPage({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });
}

const List<_OnboardPage> _pages = [
  _OnboardPage(
    icon: Icons.storefront_outlined,
    titleKey: 'onboarding_title_1',
    descriptionKey: 'onboarding_desc_1',
  ),
  _OnboardPage(
    icon: Icons.two_wheeler_outlined,
    titleKey: 'onboarding_title_2',
    descriptionKey: 'onboarding_desc_2',
  ),
  _OnboardPage(
    icon: Icons.handshake_outlined,
    titleKey: 'onboarding_title_3',
    descriptionKey: 'onboarding_desc_3',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingSeenKey, true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    tr.t('skip'), 
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 72,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          tr.t(page.titleKey),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr.t(page.descriptionKey), 
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey[600], height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      _finishOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    isLastPage 
                        ? tr.t('get_started')  
                        : tr.t('next'),       
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}