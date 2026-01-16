import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF0F9F8),
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  OnboardingPage(
                    icon: Icons.recycling,
                    title: 'Recycle Smarter. Earn\nRewards.',
                    description:
                        'Turn your recyclables into valuable rewards\nwhile helping the environment',
                  ),
                  OnboardingPage(
                    icon: Icons.people_outline,
                    title: 'Connect with Your\nCommunity',
                    description:
                        'Find nearby collectors or list your recyclables\nfor easy pickup',
                  ),
                  OnboardingPage(
                    icon: Icons.eco_outlined,
                    title: 'Build Sustainable Habits',
                    description:
                        'Track your impact and earn points for every\nsuccessful exchange',
                  ),
                ],
              ),
            ),
            // Progress Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF0D9488)
                          : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == 2 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
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

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF064E3B) : const Color(0xFFA7F3D0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
