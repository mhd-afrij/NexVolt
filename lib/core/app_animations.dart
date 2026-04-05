import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ╔══════════════════════════════════════════════════════╗
/// ║            NexVolt — App Animations                 ║
/// ║  Every animation in ONE file. Import this and use   ║
/// ║  AppAnimations.xxx() on any screen — no copy-paste. ║
/// ╚══════════════════════════════════════════════════════╝

class AppAnimations {
  AppAnimations._(); // prevent instantiation

  // ── 1. ANIMATED GRADIENT BUTTON ───────────────────────
  /// The signature green→blue shimmer button used on every screen.
  /// Usage:
  ///   AppAnimations.gradientButton(
  ///     controller: _controller,
  ///     text: 'Login',
  ///     onTap: _handleLogin,
  ///     isLoading: _isLoading,
  ///   )
  static Widget gradientButton({
    required AnimationController controller,
    required String text,
    required VoidCallback? onTap,
    bool isLoading = false,
    double verticalPadding = 18,
    double borderRadius = 30,
    Widget? icon, // optional trailing icon
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final color = Color.lerp(
          AppColors.emeraldGreen,
          AppColors.electricBlue,
          controller.value,
        );
        return ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            backgroundColor: color,
            disabledBackgroundColor: AppColors.buttonDisabled,
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.buttonTextColor,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      icon,
                    ],
                  ],
                ),
        );
      },
    );
  }

  // ── 2. SPLASH FADE + SCALE ENTRANCE ──────────────────
  /// Wraps any widget with a fade-in + scale-up entrance animation.
  /// Usage: AppAnimations.splashEntrance(controller: _ctrl, child: myWidget)
  static Widget splashEntrance({
    required AnimationController controller,
    required Widget child,
  }) {
    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    final scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => FadeTransition(
        opacity: fadeAnim,
        child: ScaleTransition(scale: scaleAnim, child: child),
      ),
    );
  }

  // ── 3. SLIDE-UP PAGE TRANSITION ───────────────────────
  /// Use instead of MaterialPageRoute for a smooth upward slide.
  /// Usage: Navigator.push(context, AppAnimations.slideUp(MyScreen()))
  static PageRoute<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // ── 4. FADE PAGE TRANSITION ───────────────────────────
  /// Smooth fade for screen replacements (e.g. splash → home).
  static PageRoute<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  // ── 5. SLIDE-RIGHT PAGE TRANSITION ───────────────────
  /// For going "forward" in a flow (left → right feel).
  static PageRoute<T> slideRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  // ── 6. GRADIENT BACKGROUND ───────────────────────────
  /// The full-screen gradient background used on every screen.
  /// Usage: AppAnimations.gradientBackground(child: myColumnContent)
  static Widget gradientBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: child,
    );
  }

  // ── 7. WHITE CARD CONTAINER ───────────────────────────
  /// The white bottom card with rounded top corners used on every screen.
  /// Usage:
  ///   AppAnimations.whiteCard(
  ///     padding: EdgeInsets.all(25),
  ///     child: myContent,
  ///   )
  static Widget whiteCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(25),
  }) {
    return Expanded(
      child: Container(
        padding: padding,
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppColors.cardBorderRadius,
        ),
        child: child,
      ),
    );
  }

  // ── 8. ANIMATED STEP INDICATOR DOTS ──────────────────
  /// The step progress dots used on VehicleDetailsScreen.
  /// Usage: AppAnimations.stepIndicator(currentStep: _currentStep, totalSteps: 3)
  static Widget stepIndicator({
    required int currentStep,
    required int totalSteps,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.stepActive
                : isDone
                    ? AppColors.stepDone
                    : AppColors.stepInactive,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  // ── 9. PAGE INDICATOR DOTS (welcome screen) ──────────
  /// Animated dots for the welcome screen page view.
  static Widget pageIndicator({
    required int currentPage,
    required int totalPages,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: currentPage == i ? 22 : 8,
          decoration: BoxDecoration(
            color: currentPage == i ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  // ── 10. PULSING LOADING INDICATOR ────────────────────
  /// Branded loading spinner used on AuthCheckScreen / splash.
  static Widget brandedLoader({String label = 'Please wait...'}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('⚡', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 20),
        const Text(
          'NexVolt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  // ── 11. ERROR SNACKBAR ────────────────────────────────
  /// Shows a styled error snackbar.
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.snackBarError,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── 12. SUCCESS SNACKBAR ──────────────────────────────
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.snackBarSuccess,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── 13. INFO SNACKBAR ─────────────────────────────────
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.snackBarInfo,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── 14. ANIMATED LANGUAGE / SELECTOR TILE ────────────
  /// Animated selection tile used on LanguageSelectionScreen
  /// and vehicle type selector.
  static Widget selectionTile({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    double borderRadius = 16,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.langSelectedBg
              : AppColors.langUnselectedBg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color:
                isSelected ? AppColors.langSelectedBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: child,
      ),
    );
  }

  // ── 15. VEHICLE TYPE CHIP ─────────────────────────────
  /// Small animated chip for connector/category selection.
  static Widget selectorChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.dropdownSelected
              : AppColors.dropdownUnselected,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── 16. SCREEN HEADER (gradient top section) ──────────
  /// Reusable gradient top section with title + optional subtitle.
  /// Usage:
  ///   AppAnimations.screenHeader(
  ///     title: 'Vehicle Details',
  ///     subtitle: 'Tell us about your EV',
  ///     emoji: '🚗',
  ///     showBack: true,
  ///     onBack: () => Navigator.pop(context),
  ///   )
  static Widget screenHeader({
    required String title,
    String? subtitle,
    String? emoji,
    bool showBack = false,
    VoidCallback? onBack,
    List<Widget> extraWidgets = const [],
  }) {
    return Column(
      children: [
        const SizedBox(height: 50),
        if (showBack)
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack,
            ),
          )
        else
          const SizedBox(height: 8),
        if (emoji != null)
          Text(emoji, style: const TextStyle(fontSize: 44)),
        if (emoji != null) const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.5),
            ),
          ),
        ],
        ...extraWidgets,
        const SizedBox(height: 24),
      ],
    );
  }

  // ── 17. CREATE STANDARD ANIMATION CONTROLLER ─────────
  /// Creates the standard 2-second repeating controller used by buttons.
  /// Call in initState, dispose in dispose().
  /// Usage:
  ///   late AnimationController _controller;
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     _controller = AppAnimations.createButtonController(this);
  ///   }
  static AnimationController createButtonController(
      TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  // ── 18. CREATE SPLASH CONTROLLER ─────────────────────
  /// Creates the one-shot splash entrance controller (1.4s).
  static AnimationController createSplashController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1400),
    );
  }
}
