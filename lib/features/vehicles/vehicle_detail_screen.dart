import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../models/vehicle.dart';
import '../../widgets/allfix_button.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final images = vehicle.images.isNotEmpty
        ? vehicle.images
        : [if (vehicle.imageUrl.isNotEmpty) vehicle.imageUrl];
    final facts = <(String, String)>[
      ('Make', vehicle.brand),
      ('Model / year', vehicle.modelYear),
      ('Vehicle type', vehicle.type),
      ('Condition', vehicle.condition),
      ('Colour', vehicle.colour),
      ('Location', vehicle.location),
      ('Reference', vehicle.id),
    ].where((fact) => fact.$2.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle details')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 250,
            child: images.isEmpty
                ? const ColoredBox(
                    color: AppColors.chipBackground,
                    child: Icon(Icons.directions_car_outlined,
                        size: 56, color: AppColors.iconMuted),
                  )
                : PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) => CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      memCacheWidth: 1400,
                      memCacheHeight: 900,
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppColors.chipBackground,
                        child: Icon(Icons.directions_car_outlined,
                            size: 56, color: AppColors.iconMuted),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.price,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 6),
                Text(vehicle.title,
                    style: const TextStyle(
                      color: AppColors.darkNeutral,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    )),
                if (vehicle.location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 17, color: AppColors.iconMuted),
                      const SizedBox(width: 4),
                      Text(vehicle.location,
                          style: const TextStyle(
                              color: AppColors.bodyNeutral, fontSize: 14)),
                    ],
                  ),
                ],
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < facts.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, indent: 14, endIndent: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(facts[i].$1,
                                      style: const TextStyle(
                                          color: AppColors.bodyNeutral,
                                          fontSize: 13)),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: Text(facts[i].$2,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          color: AppColors.darkNeutral,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (vehicle.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Description',
                      style: TextStyle(
                          color: AppColors.darkNeutral,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(vehicle.description,
                      style: const TextStyle(
                          color: AppColors.bodyNeutral,
                          fontSize: 14,
                          height: 1.5)),
                ],
                const SizedBox(height: 24),
                AllfixButton(
                  label: 'Ask ALLFIX about this vehicle',
                  icon: Icons.chat_outlined,
                  type: AllfixButtonType.whatsapp,
                  onPressed: () => UrlLauncherHelper.launchWhatsApp(
                    customMessage:
                        'Hello ALLFIX, I am inquiring about ${vehicle.title}'
                        '${vehicle.location.isNotEmpty ? ' in ${vehicle.location}' : ''}'
                        ' (Ref: ${vehicle.id}). Is it available for inspection?',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
