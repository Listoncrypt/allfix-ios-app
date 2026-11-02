import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class UrgencyBadge extends StatelessWidget {
  final String urgency; // 'High', 'Medium', 'Low'

  const UrgencyBadge({
    super.key,
    required this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (urgency.toLowerCase()) {
      case 'high':
        bg = const Color(0xFFFEE2E2);
        fg = AppColors.urgencyHigh;
        label = 'High / Immediate';
        icon = Icons.bolt_rounded;
        break;
      case 'low':
        bg = AppColors.greenLight;
        fg = AppColors.urgencyLow;
        label = 'Flexible Schedule';
        icon = Icons.schedule_rounded;
        break;
      case 'medium':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = AppColors.urgencyMedium;
        label = 'Within 24–48 hrs';
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
