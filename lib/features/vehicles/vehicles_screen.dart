import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../models/vehicle.dart';
import '../../providers/app_providers.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Vehicles'),
        actions: [
          IconButton(
            tooltip: 'List an asset',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => context.push('/list-asset'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search make, model or location',
                prefixIcon: Icon(Icons.search_outlined),
              ),
            ),
          ),
          Expanded(
            child: vehiclesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _MessageState(
                icon: Icons.cloud_off_outlined,
                title: 'Vehicles could not be loaded',
                message: 'Check your connection and try again.',
                actionLabel: 'Try again',
                onAction: () => ref.invalidate(vehiclesProvider),
              ),
              data: (allVehicles) {
                final vehicles = allVehicles.where((vehicle) {
                  final searchable = '${vehicle.title} ${vehicle.brand} '
                          '${vehicle.modelYear} ${vehicle.location} ${vehicle.type}'
                      .toLowerCase();
                  return searchable.contains(_query);
                }).toList();
                if (vehicles.isEmpty) {
                  return _MessageState(
                    icon: Icons.directions_car_outlined,
                    title: _query.isEmpty
                        ? 'No vehicles listed'
                        : 'No matching vehicles',
                    message: _query.isEmpty
                        ? 'Available vehicles will appear here when listed.'
                        : 'Try a different make, model or location.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(vehiclesProvider.future).then<void>((_) {}),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _VehicleCard(
                      vehicle: vehicles[index],
                      onTap: () => context.push(
                        '/vehicles/${vehicles[index].id}',
                        extra: vehicles[index],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const _VehicleCard({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 174,
              width: double.infinity,
              child: vehicle.imageUrl.isEmpty
                  ? const ColoredBox(
                      color: AppColors.chipBackground,
                      child: Icon(Icons.directions_car_outlined,
                          size: 46, color: AppColors.iconMuted),
                    )
                  : CachedNetworkImage(
                      imageUrl: vehicle.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 960,
                      memCacheHeight: 600,
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppColors.chipBackground,
                        child: Icon(Icons.directions_car_outlined,
                            size: 46, color: AppColors.iconMuted),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.price,
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 4),
                  Text(vehicle.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.darkNeutral,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.iconMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(vehicle.location,
                            style: const TextStyle(
                              color: AppColors.bodyNeutral,
                              fontSize: 12,
                            )),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.iconMuted),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.iconMuted),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkNeutral,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.bodyNeutral, fontSize: 13)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
