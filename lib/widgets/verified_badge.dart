import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  final String text;
  final bool isSmall;

  const VerifiedBadge({
    super.key,
    required this.text,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_outlined,
            size: isSmall ? 13 : 16,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: AppColors.greenDark,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
