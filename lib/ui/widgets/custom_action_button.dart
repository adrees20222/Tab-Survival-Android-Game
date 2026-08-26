import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLocked;
  final double widthPercent;
  final double height;
  final Widget? leading;

  const CustomActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isLocked = false,
    this.widthPercent = 0.78,
    this.height = 56,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * widthPercent,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: isLocked
            ? AppColors.surfaceVariant
            : isPrimary
                ? AppColors.primaryContainer
                : AppColors.surface,
        borderRadius: BorderRadius.circular(height / 2),
        elevation: isPrimary ? 6 : 2,
        shadowColor: isPrimary ? AppColors.primary.withValues(alpha: 0.4) : Colors.black45,
        child: InkWell(
          onTap: isLocked ? null : onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          splashColor: AppColors.primary.withValues(alpha: 0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: isLocked
                    ? AppColors.outline.withValues(alpha: 0.4)
                    : isPrimary
                        ? AppColors.primary
                        : AppColors.outline,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: isLocked
                        ? AppColors.onSurfaceVariant
                        : isPrimary
                            ? AppColors.onPrimaryContainer
                            : AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
