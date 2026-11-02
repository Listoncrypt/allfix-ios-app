import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../providers/app_providers.dart';
import '../../widgets/allfix_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/urgency_badge.dart';
import 'add_property_modal.dart';

class AdminPortalScreen extends ConsumerStatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  ConsumerState<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends ConsumerState<AdminPortalScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late TabController _tabController;
  String _selectedUrgencyFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AdminAuthState>(adminAuthProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        ref.read(requestsProvider.notifier).loadAdminRequests();
      }
    });
    final authState = ref.watch(adminAuthProvider);

    if (!authState.isAuthenticated) {
      return _buildLoginView(authState);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abuja Dispatch HQ Portal'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon:
                const Icon(Icons.logout_outlined, color: AppColors.urgencyHigh),
            onPressed: () => ref.read(adminAuthProvider.notifier).logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.bodyNeutral,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(
                text: 'Incoming Requests',
                icon: Icon(Icons.assignment_outlined, size: 20)),
            Tab(
                text: 'Properties',
                icon: Icon(Icons.apartment_outlined, size: 20)),
            Tab(
                text: 'Platform Stats',
                icon: Icon(Icons.analytics_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildPropertiesManagerTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  // 1. Server-authenticated admin login
  Widget _buildLoginView(AdminAuthState authState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Authentication'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: AppColors.greenDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline,
                    size: 34, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Abuja HQ Dispatch Access',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNeutral),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in with your dispatch administrator account to manage requests and property inventory.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppColors.bodyNeutral),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _usernameController,
                label: 'Username',
                hintText: 'Admin username',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Admin password',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 16),
              AllfixButton(
                label: 'Sign in to Dispatch',
                isLoading: authState.isLoading,
                onPressed: () async {
                  final success =
                      await ref.read(adminAuthProvider.notifier).login(
                            _usernameController.text.trim(),
                            _passwordController.text,
                          );
                  if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ref.read(adminAuthProvider).error ??
                            'Sign in failed.'),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Incoming Requests Tab
  Widget _buildRequestsTab() {
    final requestsState = ref.watch(requestsProvider);
    final notifier = ref.read(requestsProvider.notifier);

    final filteredRequests = requestsState.requests.where((r) {
      if (_selectedUrgencyFilter == 'All') return true;
      return r.urgency.toLowerCase() == _selectedUrgencyFilter.toLowerCase();
    }).toList();

    return Column(
      children: [
        if (requestsState.error != null)
          MaterialBanner(
            content: Text(requestsState.error!),
            leading: const Icon(Icons.error_outline, color: AppColors.errorRed),
            actions: [
              TextButton(
                onPressed: () => notifier.loadAdminRequests(),
                child: const Text('Retry'),
              ),
            ],
          ),
        // Urgency filter pills
        Container(
          color: AppColors.surfaceWhite,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: ['All', 'High', 'Medium', 'Low'].map((urg) {
              final isSelected = _selectedUrgencyFilter == urg;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(urg == 'All' ? 'All Urgencies' : '$urg Urgency'),
                  selected: isSelected,
                  selectedColor: AppColors.greenLight,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.greenDark
                        : AppColors.darkNeutral,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedUrgencyFilter = urg),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: filteredRequests.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 60, color: AppColors.iconMuted),
                      SizedBox(height: 12),
                      Text(
                        'No requests in queue',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Incoming bookings will appear here in real-time.',
                        style: TextStyle(
                            color: AppColors.bodyNeutral, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = filteredRequests[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  req.id ?? 'REQ-NEW',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                UrgencyBadge(urgency: req.urgency),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              req.customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkNeutral,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${req.category} • ${req.location ?? "Abuja"}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.bodyNeutral),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSubtle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                req.description,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.darkNeutral),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Status updater & Actions
                            Row(
                              children: [
                                const Text('Status:',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: [
                                    'pending_matching',
                                    'contacted',
                                    'matched',
                                    'completed'
                                  ].contains(req.status)
                                      ? req.status
                                      : 'pending_matching',
                                  underline: const SizedBox(),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGreen,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'pending_matching',
                                        child: Text('Pending Matching')),
                                    DropdownMenuItem(
                                        value: 'contacted',
                                        child: Text('Contacted')),
                                    DropdownMenuItem(
                                        value: 'matched',
                                        child: Text('Artisan Matched')),
                                    DropdownMenuItem(
                                        value: 'completed',
                                        child: Text('Completed')),
                                  ],
                                  onChanged: (val) async {
                                    if (val != null && req.id != null) {
                                      final updated = await notifier
                                          .updateStatus(req.id!, val);
                                      if (!updated && context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Request status could not be updated.'),
                                            backgroundColor: AppColors.errorRed,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.chat_outlined,
                                      color: Color(0xFF25D366)),
                                  tooltip: 'WhatsApp Client',
                                  onPressed: () {
                                    UrlLauncherHelper.launchWhatsApp(
                                      customMessage:
                                          'Hello ${req.customerName}, this is ALLFIX Dispatch regarding your request ${req.id}.',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 3. Properties Manager Tab
  Widget _buildPropertiesManagerTab() {
    final propertiesState = ref.watch(propertiesProvider);
    final notifier = ref.read(propertiesProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddPropertyModal(
              onPropertyAdded: (newProp) => notifier.addProperty(newProp),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Listing',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: propertiesState.properties.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final prop = propertiesState.properties[index];
          return Card(
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apartment_outlined,
                    color: AppColors.primaryGreen),
              ),
              title: Text(
                prop.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: Text(
                '${prop.price} • ${prop.location}',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.bodyNeutral),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.urgencyHigh),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Listing?'),
                      content: Text(
                          'Remove "${prop.title}" from ALLFIX verified inventory?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.errorRed),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await notifier.removeProperty(prop.id);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. Platform Stats Tab
  Widget _buildStatsTab() {
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ALLFIX Platform Metrics',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNeutral),
            ),
            const SizedBox(height: 4),
            const Text(
              'Real-time data audited under nationwide coordination standards.',
              style: TextStyle(color: AppColors.bodyNeutral, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildMetricTile(
                '1+ Artisans',
                'Verified Background-Checked Artisans',
                Icons.verified_user_outlined),
            _buildMetricTile('${stats.totalRequests}',
                'Customer Requests Processed', Icons.task_alt_rounded),
            _buildMetricTile('${stats.agreementsSigned}',
                'Legal Client & Vendor Agreements (v1.0)', Icons.gavel_rounded),
            _buildMetricTile('${stats.totalProperties}',
                'Verified Properties & Land Plots', Icons.villa_rounded),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Abuja HQ Hotline Escalation',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text(AppStrings.hotline,
                      style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  AllfixButton(
                    label: 'Call Official Hotline Desk',
                    type: AllfixButtonType.outline,
                    onPressed: () => UrlLauncherHelper.callHotline(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load metrics')),
    );
  }

  Widget _buildMetricTile(String value, String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: AppColors.greenLight, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNeutral)),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.bodyNeutral)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
