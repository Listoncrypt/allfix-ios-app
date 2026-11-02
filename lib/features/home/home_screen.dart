import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../providers/app_providers.dart';
import '../../widgets/entrance_motion.dart';
import '../../widgets/property_card.dart';
import '../../models/vendor_work.dart';
import '../../models/vehicle.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final propertiesState = ref.watch(propertiesProvider);
    final properties = propertiesState.properties;
    final workState = ref.watch(vendorWorksProvider);
    final vehiclesState = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALLFIX',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: 0.25,
            color: AppColors.darkNeutral,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Call Official Hotline',
            icon: const Icon(Icons.phone_in_talk_outlined),
            onPressed: () => UrlLauncherHelper.callHotline(),
          ),
          IconButton(
            tooltip: 'Email Support',
            icon: const Icon(Icons.mail_outline),
            onPressed: () => UrlLauncherHelper.sendSupportEmail(
              subject: 'ALLFIX Mobile Inquiry',
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F7FF),
              Color(0xFFF0F4FF),
              Color(0xFFF5F9FF),
            ],
          ),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
          children: [
            EntranceMotion(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to ALLFIX',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: AppColors.darkNeutral,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBookAction(context),
                  const SizedBox(height: 12),
                  statsAsync.when(
                    data: (stats) => _buildMetrics(
                      '${stats.verifiedVendors}',
                      'Vendor profiles',
                      '${stats.totalRequests}',
                      'Requests',
                      '${stats.totalProperties + stats.totalVehicles}',
                      'Listings',
                    ),
                    loading: () => _buildMetrics('—', 'Vendor profiles', '—',
                        'Requests', '—', 'Listings'),
                    error: (_, __) => _buildMetrics(
                      '—',
                      'Vendor profiles',
                      '—',
                      'Requests',
                      '—',
                      'Listings',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionHeading(
              'Services',
              trailing: '15 categories',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppCategories.allCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = AppCategories.allCategories[index];
                  return EntranceMotion(
                    delay: Duration(milliseconds: 18 * index),
                    child: _buildServiceShortcut(
                      context,
                      category,
                      () => context.push(
                        '/request?category=${Uri.encodeComponent(category.title)}',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionHeading(
              'Artisan work',
              trailing: 'View gallery',
              onTrailingTap: () => context.push('/work'),
            ),
            const SizedBox(height: 9),
            workState.when(
              loading: () => const SizedBox(
                height: 42,
                child: Center(
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => _buildListingsMessage(
                context,
                'The work gallery could not be loaded.',
                () => ref.invalidate(vendorWorksProvider),
              ),
              data: (works) => works.isEmpty
                  ? _buildListingsMessage(
                      context,
                      'No completed work has been shared yet.',
                      null,
                    )
                  : SizedBox(
                      height: 154,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: works.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 9),
                        itemBuilder: (context, index) => _buildWorkPreview(
                          context,
                          works[index],
                          index,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 22),
            _buildSectionHeading(
              'Properties',
              trailing: 'View all',
              onTrailingTap: () => context.go('/properties'),
            ),
            const SizedBox(height: 10),
            if (propertiesState.isLoading && properties.isEmpty)
              const SizedBox(
                height: 112,
                child: Center(
                  child: SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (properties.isEmpty)
              _buildListingsMessage(
                context,
                propertiesState.error == null
                    ? 'No property listings are available right now.'
                    : 'Property listings could not be loaded. Try again.',
                propertiesState.error != null
                    ? () =>
                        ref.read(propertiesProvider.notifier).loadProperties()
                    : null,
              )
            else
              SizedBox(
                height: 236,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: properties.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return EntranceMotion(
                      delay: Duration(milliseconds: 24 * index),
                      child: SizedBox(
                        width: 252,
                        child: PropertyCard(
                          property: property,
                          compact: true,
                          onTap: () => context.push(
                            '/properties/${property.id}',
                            extra: property,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 18),
            _buildSectionHeading(
              'Cars & vehicles',
              trailing: 'View all',
              onTrailingTap: () => context.push('/vehicles'),
            ),
            const SizedBox(height: 10),
            vehiclesState.when(
              loading: () => const SizedBox(
                height: 106,
                child: Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => _buildListingsMessage(
                context,
                'Vehicle listings could not be loaded.',
                () => ref.invalidate(vehiclesProvider),
              ),
              data: (vehicles) => vehicles.isEmpty
                  ? _buildListingsMessage(
                      context,
                      'No vehicle listings are available right now.',
                      null,
                    )
                  : SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: vehicles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) => EntranceMotion(
                          delay: Duration(
                            milliseconds: index < 5 ? index * 24 : 120,
                          ),
                          child: _buildVehiclePreview(
                            context,
                            vehicles[index],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookAction(BuildContext context) {
    return Material(
      color: AppColors.greenDark,
      borderRadius: BorderRadius.circular(20),
      shadowColor: AppColors.accentLavender.withValues(alpha: 0.28),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go('/request'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add_task_outlined,
                    color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Book a service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tell us what you need',
                      style: TextStyle(
                        color: Color(0xFFD8D7EA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetrics(
    String firstValue,
    String firstLabel,
    String secondValue,
    String secondLabel,
    String thirdValue,
    String thirdLabel,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFDFDFFFF),
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x178B7CFF),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _metric(Icons.people_alt_outlined, firstValue, firstLabel),
          _metricDivider(),
          _metric(Icons.assignment_outlined, secondValue, secondLabel),
          _metricDivider(),
          _metric(Icons.apartment_outlined, thirdValue, thirdLabel),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppColors.accentLavender),
              const SizedBox(width: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNeutral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.bodyNeutral,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricDivider() => Container(
        height: 30,
        width: 1,
        color: AppColors.divider,
      );

  Widget _buildSectionHeading(
    String title, {
    required String trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkNeutral,
            ),
          ),
        ),
        TextButton(
          onPressed: onTrailingTap,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            trailing,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onTrailingTap == null
                  ? AppColors.bodyNeutral
                  : AppColors.accentLavender,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceShortcut(
    BuildContext context,
    ServiceCategory category,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 104,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x148B7CFF),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(category.icon,
                    color: AppColors.accentLavender, size: 19),
              ),
              const SizedBox(height: 7),
              Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.75,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  color: AppColors.darkNeutral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingsMessage(
    BuildContext context,
    String message,
    VoidCallback? onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_work_outlined,
              color: AppColors.iconMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.bodyNeutral),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkPreview(BuildContext context, VendorWork work, int index) {
    return EntranceMotion(
      delay: Duration(milliseconds: index < 5 ? index * 24 : 120),
      child: SizedBox(
        width: 190,
        child: Material(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/work/${work.id}', extra: work),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.handyman_outlined,
                      color: AppColors.primaryGreen, size: 20),
                  const Spacer(),
                  Text(work.jobType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(work.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.darkNeutral,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  if (work.vendorName.isNotEmpty)
                    Text(work.vendorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.bodyNeutral, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehiclePreview(BuildContext context, Vehicle vehicle) {
    return SizedBox(
      width: 224,
      child: Material(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/vehicles/${vehicle.id}', extra: vehicle),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 112,
                  width: double.infinity,
                  child: vehicle.imageUrl.isEmpty
                      ? const ColoredBox(
                          color: AppColors.chipBackground,
                          child: Icon(Icons.directions_car_outlined,
                              size: 38, color: AppColors.iconMuted),
                        )
                      : CachedNetworkImage(
                          imageUrl: vehicle.imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 720,
                          memCacheHeight: 360,
                          errorWidget: (_, __, ___) => const ColoredBox(
                            color: AppColors.chipBackground,
                            child: Icon(Icons.directions_car_outlined,
                                size: 38, color: AppColors.iconMuted),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.darkNeutral,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vehicle.price.isEmpty
                                  ? 'Price on request'
                                  : vehicle.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (vehicle.location.isNotEmpty) ...[
                            const Icon(Icons.location_on_outlined,
                                size: 12, color: AppColors.iconMuted),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                vehicle.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.bodyNeutral,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
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
