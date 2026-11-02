import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../models/property.dart';
import '../../widgets/allfix_button.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final images = property.images.isNotEmpty
        ? property.images
        : [if (property.imageUrl.isNotEmpty) property.imageUrl];
    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Sharing listing: ${property.title} (${property.id})'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Photo
            Stack(
              children: [
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: images.isEmpty
                      ? const ColoredBox(
                          color: AppColors.chipBackground,
                          child: Icon(Icons.apartment_outlined,
                              size: 56, color: AppColors.iconMuted),
                        )
                      : PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) => CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            memCacheWidth: 1400,
                            memCacheHeight: 900,
                            placeholder: (_, __) => const ColoredBox(
                              color: AppColors.chipBackground,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) => const ColoredBox(
                              color: AppColors.chipBackground,
                              child: Icon(Icons.apartment_outlined,
                                  size: 56, color: AppColors.iconMuted),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkNeutral.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Title document: ${property.titleDocument}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkNeutral.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      property.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.price,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNeutral,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 18, color: AppColors.iconMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.bodyNeutral,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Specifications Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpec(Icons.square_foot_rounded, 'Land / Size',
                            property.size),
                        Container(
                            height: 40, width: 1, color: AppColors.cardBorder),
                        _buildSpec(Icons.category_rounded, 'Category',
                            property.propertyType),
                        Container(
                            height: 40, width: 1, color: AppColors.cardBorder),
                        _buildSpec(Icons.description_outlined, 'Title document',
                            property.titleDocument),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Property Description',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNeutral,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.bodyNeutral,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const SizedBox(height: 32),

                  // WhatsApp Deep-link Rule Button (Section 8)
                  AllfixButton(
                    label: 'Book Physical Inspection via WhatsApp',
                    type: AllfixButtonType.whatsapp,
                    icon: Icons.chat_bubble_rounded,
                    onPressed: () {
                      UrlLauncherHelper.launchPropertyInquiry(
                        propertyTitle: property.title,
                        location: property.location,
                        propertyId: property.id,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AllfixButton(
                    label: 'Call Abuja HQ Hotline (+234 705 809 9045)',
                    type: AllfixButtonType.outline,
                    icon: Icons.phone_rounded,
                    onPressed: () => UrlLauncherHelper.callHotline(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpec(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(fontSize: 11, color: AppColors.iconMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.darkNeutral),
        ),
      ],
    );
  }
}
