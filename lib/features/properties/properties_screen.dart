import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/entrance_motion.dart';
import '../../widgets/property_card.dart';

class PropertiesScreen extends ConsumerWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesState = ref.watch(propertiesProvider);
    final propertiesNotifier = ref.read(propertiesProvider.notifier);

    final categories = ['All', 'Residential', 'Commercial', 'Land'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.directions_car_outlined, size: 18),
            label: const Text('Cars'),
            onPressed: () => context.push('/vehicles'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => propertiesNotifier.loadProperties(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => propertiesNotifier.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText:
                        'Search location (e.g. Guzape, Lugbe) or title...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.iconMuted),
                    filled: true,
                    fillColor: AppColors.backgroundSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryGreen, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = propertiesState.selectedType == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.greenDark,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.darkNeutral,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (_) =>
                            propertiesNotifier.setSelectedType(cat),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/list-asset'),
                icon: const Icon(Icons.add_home_work_outlined, size: 18),
                label: const Text('List a property or vehicle'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // Properties List
          Expanded(
            child: propertiesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : propertiesState.error != null &&
                        propertiesState.properties.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off_outlined,
                                  size: 42, color: AppColors.iconMuted),
                              const SizedBox(height: 12),
                              const Text(
                                'Listings could not be loaded',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkNeutral,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Check your connection and try again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.bodyNeutral,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    propertiesNotifier.loadProperties(),
                                icon: const Icon(Icons.refresh_outlined),
                                label: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : propertiesState.filteredProperties.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  propertiesState.properties.isEmpty
                                      ? Icons.home_work_outlined
                                      : Icons.search_off_outlined,
                                  size: 44,
                                  color: AppColors.iconMuted,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No property listings available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkNeutral,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  propertiesState.properties.isEmpty
                                      ? 'Check back later for available listings.'
                                      : 'Try adjusting your search or filter.',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.bodyNeutral),
                                ),
                                const SizedBox(height: 16),
                                if (propertiesState.properties.isNotEmpty)
                                  ElevatedButton(
                                    onPressed: () {
                                      propertiesNotifier.setSearchQuery('');
                                      propertiesNotifier.setSelectedType('All');
                                    },
                                    child: const Text('Reset Filters'),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                propertiesNotifier.loadProperties(),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  propertiesState.filteredProperties.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final property =
                                    propertiesState.filteredProperties[index];
                                return EntranceMotion(
                                  delay: Duration(
                                    milliseconds: index < 6 ? 24 * index : 144,
                                  ),
                                  child: PropertyCard(
                                    property: property,
                                    onTap: () {
                                      context.push('/properties/${property.id}',
                                          extra: property);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
