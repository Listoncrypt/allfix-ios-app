import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../models/vendor_work.dart';
import '../../providers/app_providers.dart';

class VendorWorksScreen extends ConsumerWidget {
  const VendorWorksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(vendorWorksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Artisan Work Gallery')),
      body: worksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _GalleryMessage(
          icon: Icons.cloud_off_outlined,
          title: 'Gallery could not be loaded',
          message: 'Check your connection and try again.',
          onRetry: () => ref.invalidate(vendorWorksProvider),
        ),
        data: (works) => works.isEmpty
            ? const _GalleryMessage(
                icon: Icons.handyman_outlined,
                title: 'No work has been shared yet',
                message:
                    'Completed artisan work will appear here when available.',
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(vendorWorksProvider.future).then<void>((_) {}),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: works.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _WorkCard(
                    work: works[index],
                    onTap: () => context.push(
                      '/work/${works[index].id}',
                      extra: works[index],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  final VendorWork work;
  final VoidCallback onTap;

  const _WorkCard({required this.work, required this.onTap});

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
              height: 180,
              width: double.infinity,
              child: work.image.isEmpty
                  ? const ColoredBox(
                      color: AppColors.chipBackground,
                      child: Icon(Icons.handyman_outlined,
                          size: 42, color: AppColors.iconMuted),
                    )
                  : CachedNetworkImage(
                      imageUrl: work.image,
                      fit: BoxFit.cover,
                      memCacheWidth: 840,
                      memCacheHeight: 560,
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppColors.chipBackground,
                        child: Icon(Icons.handyman_outlined,
                            size: 42, color: AppColors.iconMuted),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(work.jobType.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 5),
                  Text(work.title,
                      style: const TextStyle(
                          color: AppColors.darkNeutral,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(work.vendorName,
                            style: const TextStyle(
                                color: AppColors.bodyNeutral, fontSize: 12)),
                      ),
                      if (work.location.isNotEmpty) ...[
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.iconMuted),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(work.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.bodyNeutral, fontSize: 11)),
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
    );
  }
}

class VendorWorkDetailScreen extends StatelessWidget {
  final VendorWork work;

  const VendorWorkDetailScreen({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    final images = <String>{
      if (work.image.isNotEmpty) work.image,
      ...work.photos.where((photo) => photo.isNotEmpty),
    }.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Work details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (images.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    memCacheWidth: 1400,
                    memCacheHeight: 900,
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: AppColors.chipBackground,
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text(work.jobType.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(work.title,
              style: const TextStyle(
                  color: AppColors.darkNeutral,
                  fontSize: 21,
                  fontWeight: FontWeight.w700)),
          if (work.vendorName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(work.vendorName,
                style: const TextStyle(
                    color: AppColors.bodyNeutral, fontSize: 14)),
          ],
          if (work.location.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(work.location,
                style: const TextStyle(
                    color: AppColors.bodyNeutral, fontSize: 13)),
          ],
          if (work.description.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(work.description,
                style: const TextStyle(
                    color: AppColors.bodyNeutral, fontSize: 14, height: 1.5)),
          ],
        ],
      ),
    );
  }
}

class _GalleryMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _GalleryMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
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
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.bodyNeutral, fontSize: 13)),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                  onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
