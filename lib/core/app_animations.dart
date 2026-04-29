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

import 'constants/app_colors.dart';

class AppAnimations {
  AppAnimations._();  

  // ── 1. ENERGY GRADIENT BUTTON ───────────────────────────────
  /// The signature Electric Volt → Primary gradient button.
  static Widget gradientButton({
    required AnimationController controller,
    required String text,
    required VoidCallback? onTap,
    bool isLoading = false,
    double verticalPadding = 18,
    double borderRadius = 30,
    Widget? icon, // optional trailing icon
    double borderRadius = 12,
    Widget? icon,
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
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.onPrimary,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      if (icon != null) ...[const SizedBox(width: 8), icon],
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ── 2. SPLASH FADE + SCALE ENTRANCE ────────────────────────
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
      builder: (_, _) => FadeTransition(
    final scaleAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    return AnimatedBuilder(
      animation: controller,
      builder: (context, childWidget) => FadeTransition(
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
      pageBuilder: (_, animation, _) => page,
      transitionsBuilder: (_, animation, _, child) {
  // ── 3. SLIDE-UP PAGE TRANSITION ────────────────────────────
  static PageRoute<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // ── 4. FADE PAGE TRANSITION ───────────────────────────
  /// Smooth fade for screen replacements (e.g. splash → home).
  static PageRoute<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, _) => page,
      transitionsBuilder: (_, animation, _, child) =>
  // ── 4. FADE PAGE TRANSITION ────────────────────────────────
  static PageRoute<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  // ── 5. SLIDE-RIGHT PAGE TRANSITION ───────────────────
  /// For going "forward" in a flow (left → right feel).
  static PageRoute<T> slideRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, _) => page,
      transitionsBuilder: (_, animation, _, child) {
  // ── 5. SLIDE-RIGHT PAGE TRANSITION ────────────────────────
  static PageRoute<T> slideRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
        return SlideTransition(position: animation.drive(tween), child: child);
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
  // ── 6. VOID BACKGROUND (No gradient) ────────────────────────
  /// The Void Base background - no gradient, just pure dark.
  static Widget voidBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.surface,
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
  // ── 7. GLASS CARD CONTAINER ────────────────────────────────
  /// The glassmorphic card with tonal depth.
  static Widget glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
    Color? backgroundColor,
    double borderRadius = 16,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.ghostBorder, width: 1),
      ),
      child: child,
    );
  }

  // ── 8. ANIMATED STEP INDICATOR DOTS ────────────────────────
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
  // ── 9. PAGE INDICATOR DOTS ─────────────────────────────────
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
            color: currentPage == i
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
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
  // ── 10. PULSING LOADING INDICATOR ──────────────────────────
  static Widget brandedLoader({String label = 'Initializing...'}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PulseIndicator(size: 60),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'NexVolt',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _PulseIndicator(size: 32),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ── 11. ERROR SNACKBAR ─────────────────────────────────────
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Public Sans'),
              ),
            ),
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
  // ── 12. SUCCESS SNACKBAR ────────────────────────────────────
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Public Sans'),
              ),
            ),
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
  // ── 13. INFO SNACKBAR ───────────────────────────────────────
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Public Sans'),
              ),
            ),
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
  // ── 14. ENERGY SELECTION TILE ───────────────────────────────
  /// Glassmorphic selection tile.
  static Widget selectionTile({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
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
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.ghostBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }

  // ── 15. VEHICLE TYPE CHIP ─────────────────────────────
  /// Small animated chip for connector/category selection.
  // ── 15. ENERGY SELECTOR CHIP ────────────────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.ghostBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontFamily: 'Inter',
            color: isSelected
                ? AppColors.onPrimary
                : AppColors.onSurfaceVariant,
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
  // ── 16. SCREEN HEADER ───────────────────────────────────────
  /// Reusable header with Void background and accent.
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
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: onBack,
            ),
          )
        else
          const SizedBox(height: 8),
        if (emoji != null)
          Text(emoji, style: const TextStyle(fontSize: 44)),
        if (emoji != null) Text(emoji, style: const TextStyle(fontSize: 44)),
        if (emoji != null) const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
            color: AppColors.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02,
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
                fontFamily: 'Public Sans',
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
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
  // ── 17. CREATE STANDARD ANIMATION CONTROLLER ────────────────
  static AnimationController createButtonController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  // ── 18. CREATE SPLASH CONTROLLER ─────────────────────
  /// Creates the one-shot splash entrance controller (1.4s).
  // ── 18. CREATE SPLASH CONTROLLER ────────────────────────────
  static AnimationController createSplashController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1400),
    );
  }

  // ── 19. PULSE INDICATOR COMPONENT ───────────────────────────
  /// Custom pulse dot with glow for "Live" status.
  static Widget pulseIndicator({double size = 8}) {
    return _PulseIndicator(size: size);
  }
}

class _PulseIndicator extends StatefulWidget {
  final double size;

  const _PulseIndicator({required this.size});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(
                      alpha: _opacityAnimation.value,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4039FF14),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
