import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'whatsapp_mark.dart';

enum AllfixButtonType { primary, secondary, outline, whatsapp }

class AllfixButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AllfixButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const AllfixButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AllfixButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? border;

    switch (type) {
      case AllfixButtonType.primary:
        bgColor = AppColors.darkNeutral;
        fgColor = Colors.white;
        border = BorderSide.none;
        break;
      case AllfixButtonType.secondary:
        bgColor = AppColors.accentLavender;
        fgColor = Colors.white;
        border = BorderSide.none;
        break;
      case AllfixButtonType.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.accentLavender;
        border = const BorderSide(color: AppColors.accentLilac, width: 1.3);
        break;
      case AllfixButtonType.whatsapp:
        bgColor = const Color(0xFF25D366); // Official WhatsApp Green
        fgColor = Colors.white;
        border = BorderSide.none;
        break;
    }

    final content = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (type == AllfixButtonType.whatsapp) ...[
                WhatsAppMark(color: fgColor, size: 21),
                const SizedBox(width: 8),
              ] else if (icon != null) ...[
                Icon(icon, size: 20, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: fgColor,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: content,
      ),
    );
  }
}
