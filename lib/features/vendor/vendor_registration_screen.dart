import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_categories.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../core/utils/validators.dart';
import '../../models/vendor.dart';
import '../../providers/app_providers.dart';
import '../../widgets/allfix_button.dart';
import '../../widgets/custom_text_field.dart';

class VendorRegistrationScreen extends ConsumerStatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  ConsumerState<VendorRegistrationScreen> createState() => _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends ConsumerState<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _operatingAreasController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialtyInputController = TextEditingController();

  late ServiceCategory _selectedCategory;
  final List<String> _specialties = [];
  bool _termsAccepted = false;
  bool _isSubmitting = false;
  Vendor? _registeredVendor;

  @override
  void initState() {
    super.initState();
    _selectedCategory = AppCategories.allCategories.firstWhere(
      (c) => c.title == 'Home Services',
      orElse: () => AppCategories.allCategories.first,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _experienceYearsController.dispose();
    _operatingAreasController.dispose();
    _regNumberController.dispose();
    _addressController.dispose();
    _specialtyInputController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct form errors.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the Vendor Terms v1.0 to apply.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final vendor = Vendor(
      fullName: _fullNameController.text.trim(),
      businessName: _businessNameController.text.trim().isNotEmpty
          ? _businessNameController.text.trim()
          : null,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      category: _selectedCategory.title,
      specialties: _specialties,
      experienceYears: _experienceYearsController.text.trim(),
      operatingAreas: _operatingAreasController.text.trim(),
      regNumber: _regNumberController.text.trim().isNotEmpty ? _regNumberController.text.trim() : null,
      address: _addressController.text.trim(),
      termsAccepted: true,
      termsVersion: AppStrings.defaultTermsVersion,
    );

    final api = ref.read(apiServiceProvider);
    final response = await api.registerVendor(vendor);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (response.success && response.data != null) {
        _registeredVendor = response.data;
      }
    });
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Your application could not be submitted.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_registeredVendor != null) {
      return _buildSuccessView(_registeredVendor!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artisan & Vendor KYC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Value proposition header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.cardBorder)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join the ALLFIX Verified Network',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNeutral,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Get consistent, pre-screened client bookings across Abuja and major metropolitan centres. All vendors undergo criminal record & skill credential checks.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.bodyNeutral,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Personal & Business Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNeutral),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _fullNameController,
                label: 'Full Legal Name',
                hintText: 'e.g. Tunde Bakare',
                prefixIcon: Icons.badge_outlined,
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Legal Name'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _businessNameController,
                label: 'Registered Enterprise / Brand Name (Optional)',
                hintText: 'e.g. Bakare Electricals & Engineering',
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phoneController,
                label: 'WhatsApp / Phone Number',
                hintText: 'e.g. 08023456789',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                isRequired: true,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _emailController,
                label: 'Business Email',
                hintText: 'e.g. tunde@bakare.ng',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) => Validators.validateEmail(v, required: false),
              ),

              const SizedBox(height: 24),
              const Text(
                'Trade Category & Skill Specialties',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNeutral),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ServiceCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
                    items: AppCategories.allCategories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (cat) {
                      if (cat != null) setState(() => _selectedCategory = cat);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _specialtyInputController,
                      label: 'Add Specialty Tag',
                      hintText: 'e.g. Generator repair, 3D Wall decor',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 26),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(60, 52)),
                      onPressed: () {
                        final text = _specialtyInputController.text.trim();
                        if (text.isNotEmpty && !_specialties.contains(text)) {
                          setState(() {
                            _specialties.add(text);
                            _specialtyInputController.clear();
                          });
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _specialties.map((s) {
                  return Chip(
                    label: Text(s),
                    onDeleted: () => setState(() => _specialties.remove(s)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              CustomTextField(
                controller: _experienceYearsController,
                label: 'Years of Experience',
                hintText: 'e.g. 5 Years',
                prefixIcon: Icons.history_outlined,
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Experience Years'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _operatingAreasController,
                label: 'Operating Areas Covered',
                hintText: 'e.g. Abuja (Maitama, Wuse, Gwarinpa, Lugbe)',
                prefixIcon: Icons.map_outlined,
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Operating Areas'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _regNumberController,
                label: 'CAC Registration / Trade License / ID Number',
                hintText: 'e.g. BN-2938491 or NIN / Voter ID',
                prefixIcon: Icons.verified_user_outlined,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _addressController,
                label: 'Workshop / Office Physical Address',
                hintText: 'e.g. Zone 4, Wuse, Abuja',
                prefixIcon: Icons.home_work_outlined,
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Address'),
              ),

              const SizedBox(height: 20),
              // Vendor Terms Checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'I accept the ALLFIX Vendor Code of Conduct & Terms (v1.0). I agree to honest quotes, timely arrivals, customer respect, and ID verification background checks.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.bodyNeutral,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              AllfixButton(
                label: 'Submit Artisan KYC Application',
                isLoading: _isSubmitting,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(Vendor v) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Received')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_outlined, color: AppColors.primaryGreen, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Artisan KYC Profile Received!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkNeutral),
              ),
              const SizedBox(height: 8),
              Text(
                'Vendor ID: ${v.id ?? "VEN-PENDING"}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Our Abuja dispatch vetting team will contact you via WhatsApp for document review and skills assessment before your profile is activated.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.bodyNeutral, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              AllfixButton(
                label: 'Chat with Artisan Onboarding Desk',
                type: AllfixButtonType.whatsapp,
                icon: Icons.chat_outlined,
                onPressed: () {
                  UrlLauncherHelper.launchWhatsApp(
                    customMessage: 'Hello ALLFIX Onboarding Desk, I just submitted vendor KYC profile ${v.id} for ${v.fullName}.',
                  );
                },
              ),
              const SizedBox(height: 12),
              AllfixButton(
                label: 'Done',
                type: AllfixButtonType.outline,
                onPressed: () => setState(() => _registeredVendor = null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
