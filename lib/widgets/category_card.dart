import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_categories.dart';

class CategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(8)),
                child: Icon(
                  category.icon,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNeutral,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
