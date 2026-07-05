import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to CareSync',
      description:
          'Manage patient records efficiently with our comprehensive healthcare management system.',
      animationPath: 'assets/animations/welcome.json',
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'Appointment Scheduling',
      description:
          'Schedule, track, and manage appointments with real-time updates and reminders.',
      animationPath: 'assets/animations/appointments.json',
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: 'Medical Records',
      description:
          'Securely store and access patient medical records with biometric protection.',
      animationPath: 'assets/animations/medical.json',
      color: AppColors.success,
    ),
    OnboardingPage(
      title: 'Medication Reminders',
      description:
          'Never miss a dose with smart medication reminders and tracking.',
      animationPath: 'assets/animations/medication.json',
      color: AppColors.warning,
    ),
    OnboardingPage(
      title: 'Get Started',
      description:
          'Join thousands of healthcare professionals managing their practice efficiently.',
      animationPath: 'assets/animations/get_started.json',
      color: AppColors.info,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      setState(() {
        _currentPage = page;
        _isLastPage = page == _pages.length - 1;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Navigate to login screen
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage].color,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Pattern
            _buildBackgroundPattern(),

            // Main Content
            Column(
              children: [
                // Skip Button (only show on first 4 pages)
                if (!_isLastPage && _currentPage < _pages.length - 1)
                  _buildSkipButton(),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                        _isLastPage = page == _pages.length - 1;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),

                // Navigation Controls
                _buildNavigationControls(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/pattern_${_currentPage + 1}.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: _skipToEnd,
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text(
            'Skip',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Illustration
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: OnboardingIllustration(
                animationPath: page.animationPath,
                color: page.color,
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            page.title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Description
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Page Indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.white,
              dotColor: Colors.white.withValues(alpha: 0.4),
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
              expansionFactor: 3,
            ),
          ),
          const SizedBox(height: 32),
          // Next/Get Started Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _pages[_currentPage].color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.2),
              ),
              child: Text(
                _isLastPage ? 'Get Started' : 'Next',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Back Button (only show on last page)
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Back'),
            ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String animationPath;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.animationPath,
    required this.color,
  });
}

class OnboardingIllustration extends StatefulWidget {
  final String animationPath;
  final Color color;

  const OnboardingIllustration({
    super.key,
    required this.animationPath,
    required this.color,
  });

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    if (widget.animationPath.contains('welcome')) {
      return Icons.health_and_safety_outlined;
    } else if (widget.animationPath.contains('appointments')) {
      return Icons.calendar_month_outlined;
    } else if (widget.animationPath.contains('medical')) {
      return Icons.assignment_outlined;
    } else if (widget.animationPath.contains('medication')) {
      return Icons.medication_outlined;
    } else {
      return Icons.rocket_launch_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glowing ring
            Container(
              width: 190 + (_controller.value * 25),
              height: 190 + (_controller.value * 25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.06 * (1.0 - _controller.value)),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.12 * (1.0 - _controller.value)),
                  width: 1.5,
                ),
              ),
            ),
            // Middle ring
            Container(
              width: 150 + (_controller.value * 15),
              height: 150 + (_controller.value * 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.10 * (1.0 - _controller.value * 0.5)),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.20 * (1.0 - _controller.value * 0.5)),
                  width: 2,
                ),
              ),
            ),
            // Inner solid pulsing circle with gradient
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    widget.color,
                    widget.color.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.35),
                    blurRadius: 12 + (_controller.value * 8),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  iconData,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
