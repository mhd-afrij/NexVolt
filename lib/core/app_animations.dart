import 'package:flutter/material.dart';
import 'app_colors.dart';

// ==================== ANIMATIONS ====================

class AppAnimations {
  // Standard Duration
  static const Duration standardDuration = Duration(milliseconds: 300);
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Curve Animations
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.fastOutSlowIn;
}

// ==================== REUSABLE WIDGETS ====================

/// Custom AppBar with consistent styling
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;
  final bool showMenu;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onMenuPressed,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      actions: [
        if (showMenu)
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textWhite),
            onPressed: onMenuPressed ?? () {},
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// Custom Button with consistent styling
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: backgroundColor ?? AppColors.primaryColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isLoading ? null : onPressed,
              child: _buildButtonContent(),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: isLoading ? null : onPressed,
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor ?? Colors.black),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: textColor ?? Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Custom Card with consistent styling
class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.5,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.cardBg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ??
              Border.all(
                color: borderColor ?? AppColors.borderColor,
                width: borderWidth,
              ),
        ),
        child: child,
      ),
    );
  }
}

/// Custom Text Field with consistent styling
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: AppColors.textGrey),
        hintStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primaryColor) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }
}

/// Custom BottomNav Item
class CustomBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CustomBottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryColor : AppColors.textGrey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primaryColor : AppColors.textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Tab Button for AppBar
class CustomTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomTabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.primaryColor : AppColors.textGrey,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                height: 2,
                width: 24,
                color: AppColors.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// FadeIn Animation Widget
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final int delay;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeIn,
    this.delay = 0,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// SlideIn Animation Widget
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset begin;
  final int delay;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
    this.begin = const Offset(0, 0.3),
    this.delay = 0,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<Offset>(begin: widget.begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}

/// Scale Animation Widget
class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;
  final int delay;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.elasticOut,
    this.begin = 0.8,
    this.delay = 0,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: widget.begin, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

/// Custom Dialog Helper
class AppDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textWhite),
        ),
        content: Text(
          content,
          style: const TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: onCancel ?? () => Navigator.pop(context),
              child: Text(
                cancelText,
                style: const TextStyle(color: AppColors.textGrey),
              ),
            ),
          if (confirmText != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: onConfirm,
              child: Text(
                confirmText,
                style: const TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom SnackBar Helper
class AppSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  static void success({
    required BuildContext context,
    required String message,
  }) {
    show(context: context, message: message, backgroundColor: AppColors.successGreen);
  }

  static void error({
    required BuildContext context,
    required String message,
  }) {
    show(context: context, message: message, backgroundColor: AppColors.errorRed);
  }

  static void info({
    required BuildContext context,
    required String message,
  }) {
    show(context: context, message: message, backgroundColor: AppColors.infoBlue);
  }
}

/// Custom Divider
class CustomDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final EdgeInsets padding;

  const CustomDivider({
    super.key,
    this.height = 1,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Divider(
        height: height,
        color: color ?? AppColors.borderColor,
      ),
    );
  }
}

/// Custom Loading Spinner
class CustomLoadingSpinner extends StatelessWidget {
  final Color? color;
  final double size;

  const CustomLoadingSpinner({
    super.key,
    this.color,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(
            color ?? AppColors.primaryColor,
          ),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

/// Custom Empty State
class CustomEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const CustomEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textGrey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: CustomButton(
                text: 'Retry',
                onPressed: onRetry!,
                width: 120,
              ),
            ),
        ],
      ),
    );
  }
}
