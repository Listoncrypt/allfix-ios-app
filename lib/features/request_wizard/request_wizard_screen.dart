import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_categories.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../core/utils/validators.dart';
import '../../models/service_request.dart';
import '../../providers/app_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/allfix_button.dart';
import '../../widgets/custom_text_field.dart';

class RequestWizardScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const RequestWizardScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<RequestWizardScreen> createState() =>
      _RequestWizardScreenState();
}

class _RequestWizardScreenState extends ConsumerState<RequestWizardScreen> {
  final _formKey = GlobalKey<FormState>();

  // Category State
  late ServiceCategory _selectedCategory;

  // Common Contact & Urgency
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController(text: 'Abuja');
  final _serviceDetailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _preferredDateController = TextEditingController();
  String _urgency = 'Medium';
  bool _termsAccepted = false;
  String? _otpChallengeId;
  String? _contactVerificationToken;
  final _otpController = TextEditingController();
  bool _emailVerified = false;
  bool _sendingOtp = false;
  bool _checkingOtp = false;

  // 1. Property Sales & Rentals fields
  final List<String> _selectedPropertyTypes = [];
  String _selectedBedrooms = '3 Bedrooms';
  final List<String> _selectedPreferredLocations = [];
  String _propertyBudget = '₦30M – ₦70M';
  final String _propertyTimeline = 'Within 1 month';

  // 2. Cars & Vehicles fields
  String _carType = 'SUV / Jeep';
  final _carModelYearController =
      TextEditingController(text: 'Toyota RAV4 2022');
  String _isElectricVehicle = 'No';
  final List<String> _selectedCarColours = ['Black'];
  final String _carBudget = '₦15M – ₦30M';

  // 3. Construction & Land fields
  final _constructionDescController = TextEditingController();
  String _landSize = '1 Plot (500–650 sqm)';
  String _landStatus = 'already-have-land'; // or 'help-finding-land'

  // Submission result state
  ServiceRequest? _submittedRequest;

  @override
  void initState() {
    super.initState();
    _selectedCategory = AppCategories.allCategories.first;
    if (widget.initialCategory != null) {
      final found = AppCategories.allCategories.firstWhere(
        (c) => c.title.toLowerCase() == widget.initialCategory!.toLowerCase(),
        orElse: () => AppCategories.allCategories.first,
      );
      _selectedCategory = found;
    }
    _selectedPropertyTypes.add('Duplex');
    _selectedPreferredLocations.addAll(['Lugbe', 'Maitama']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _serviceDetailController.dispose();
    _descriptionController.dispose();
    _preferredDateController.dispose();
    _carModelYearController.dispose();
    _constructionDescController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmission() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all mandatory fields.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (!_emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Verify your email address before submitting your request.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You must accept the legally audited Client Terms v1.0 to proceed.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final newRequest = ServiceRequest(
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      category: _selectedCategory.title,
      service: _serviceDetailController.text.trim().isNotEmpty
          ? _serviceDetailController.text.trim()
          : _selectedCategory.popularServices.first,
      location: _locationController.text.trim(),
      urgency: _urgency,
      preferredDate: _preferredDateController.text.trim().isNotEmpty
          ? _preferredDateController.text.trim()
          : null,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Service booking request for ${_selectedCategory.title}',
      // Property branch
      bedrooms: _selectedCategory.workflowType == CategoryWorkflowType.property
          ? _selectedBedrooms
          : null,
      preferredLocations:
          _selectedCategory.workflowType == CategoryWorkflowType.property
              ? _selectedPreferredLocations
              : [],
      propertyBudget:
          _selectedCategory.workflowType == CategoryWorkflowType.property
              ? _propertyBudget
              : null,
      propertyTimeline:
          _selectedCategory.workflowType == CategoryWorkflowType.property
              ? _propertyTimeline
              : null,
      propertyTypes:
          _selectedCategory.workflowType == CategoryWorkflowType.property
              ? _selectedPropertyTypes
              : [],
      // Car branch
      carType: _selectedCategory.workflowType == CategoryWorkflowType.car
          ? _carType
          : null,
      carModelYear: _selectedCategory.workflowType == CategoryWorkflowType.car
          ? _carModelYearController.text.trim()
          : null,
      isElectricVehicle:
          _selectedCategory.workflowType == CategoryWorkflowType.car
              ? _isElectricVehicle
              : null,
      carColours: _selectedCategory.workflowType == CategoryWorkflowType.car
          ? _selectedCarColours
          : [],
      carBudget: _selectedCategory.workflowType == CategoryWorkflowType.car
          ? _carBudget
          : null,
      // Construction branch
      constructionDescription:
          _selectedCategory.workflowType == CategoryWorkflowType.construction
              ? _constructionDescController.text.trim()
              : null,
      landSize:
          _selectedCategory.workflowType == CategoryWorkflowType.construction
              ? _landSize
              : null,
      landStatus:
          _selectedCategory.workflowType == CategoryWorkflowType.construction
              ? _landStatus
              : null,
      termsAccepted: true,
      termsVersion: AppStrings.defaultTermsVersion,
    );

    final res = await ref.read(requestsProvider.notifier).submitRequest(
          newRequest,
          contactVerificationToken: _contactVerificationToken,
        );
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _submittedRequest = res.data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Your request could not be submitted.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedRequest != null) {
      return _buildSuccessScreen(_submittedRequest!);
    }

    final requestsState = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Verified Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined,
                        color: AppColors.primaryGreen),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Direct Human Dispatch • Transparent Quotes • Background Checked Specialists',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bodyNeutral,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector
              const Text(
                '1. Select Service Category',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNeutral),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ServiceCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: AppColors.primaryGreen),
                    items: AppCategories.allCategories.map((cat) {
                      return DropdownMenuItem<ServiceCategory>(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon,
                                color: AppColors.primaryGreen, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cat.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (cat) {
                      if (cat != null) {
                        setState(() {
                          _selectedCategory = cat;
                          _serviceDetailController.clear();
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Dynamic Workflow Branch
              const Text(
                '2. Service & Requirement Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNeutral),
              ),
              const SizedBox(height: 12),
              _buildDynamicWorkflowFields(),

              const SizedBox(height: 24),

              // 3. Urgency Selector
              const Text(
                '3. Urgency & Preferred Schedule',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNeutral),
              ),
              const SizedBox(height: 10),
              _buildUrgencySelector(),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _preferredDateController,
                label: 'Preferred Appointment Date',
                hintText: 'e.g. 2026-10-15 or Tomorrow morning',
                prefixIcon: Icons.calendar_today_outlined,
              ),

              const SizedBox(height: 24),

              // 4. Contact Information
              const Text(
                '4. Contact Information',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNeutral),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                label: 'Your Full Name',
                hintText: 'e.g. Adeola Olawale',
                prefixIcon: Icons.person_outline,
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Full Name'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phoneController,
                label: 'Nigerian Phone Number',
                hintText: 'e.g. 08012345678',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                isRequired: true,
                validator: Validators.validatePhone,
                onChanged: (_) {
                  if (_emailVerified || _otpChallengeId != null) {
                    setState(() {
                      _emailVerified = false;
                      _otpChallengeId = null;
                      _contactVerificationToken = null;
                      _otpController.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'e.g. adeola@gmail.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                isRequired: true,
                validator: (v) => Validators.validateEmail(v, required: true),
                onChanged: (_) {
                  if (_emailVerified || _otpChallengeId != null) {
                    setState(() {
                      _emailVerified = false;
                      _otpChallengeId = null;
                      _contactVerificationToken = null;
                      _otpController.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 9),
              if (_emailVerified)
                const Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        color: AppColors.primaryGreen, size: 17),
                    SizedBox(width: 6),
                    Text('Email address verified',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                )
              else if (_otpChallengeId == null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _sendingOtp ? null : _sendEmailOtp,
                    icon: _sendingOtp
                        ? const SizedBox.square(
                            dimension: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mark_email_read_outlined, size: 17),
                    label: Text(
                        _sendingOtp ? 'Sending code…' : 'Verify email address'),
                  ),
                )
              else ...[
                Text(
                  'Enter the 6-digit code sent to ${_emailController.text.trim()}.',
                  style: const TextStyle(
                    color: AppColors.bodyNeutral,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: '6-digit code',
                          counterText: '',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed:
                          _checkingOtp || _sendingOtp ? null : _verifyEmailOtp,
                      child: _checkingOtp
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirm'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _sendingOtp ? null : _sendEmailOtp,
                  child: Text(_sendingOtp ? 'Sending…' : 'Send a new code'),
                ),
              ],
              const SizedBox(height: 14),
              CustomTextField(
                controller: _locationController,
                label: 'Location / Area in Nigeria',
                hintText: 'e.g. Wuse 2, Abuja or Lekki Phase 1, Lagos',
                prefixIcon: Icons.location_on_outlined,
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Location'),
              ),

              const SizedBox(height: 20),

              // Mandatory Compliance Terms Checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        setState(() {
                          _termsAccepted = val ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'I accept the ALLFIX Client Terms (v1.0). I understand that ALLFIX acts as a dedicated coordination bridge and connects me with vetted specialists under audited inspection standards.',
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

              // Submit Button
              AllfixButton(
                label: 'Submit Service Request',
                isLoading: requestsState.isSubmitting,
                onPressed: _handleSubmission,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendEmailOtp() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final emailError = Validators.validateEmail(email, required: true);
    final phoneError = Validators.validatePhone(phone);
    if (emailError != null || phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError ?? phoneError!),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    setState(() => _sendingOtp = true);
    final result =
        await ApiService().requestEmailOtp(email: email, phone: phone);
    if (!mounted) return;
    setState(() => _sendingOtp = false);
    if (result.success &&
        result.data != null &&
        _phoneController.text.trim() == phone &&
        _emailController.text.trim() == email) {
      setState(() {
        _otpChallengeId = result.data;
        _emailVerified = false;
        _contactVerificationToken = null;
        _otpController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent to your email.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result.message ?? 'Could not send a verification code.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _verifyEmailOtp() async {
    final challengeId = _otpChallengeId;
    final code = _otpController.text.trim();
    if (challengeId == null || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter the 6-digit code from your email.')),
      );
      return;
    }
    setState(() => _checkingOtp = true);
    final phoneAtVerification = _phoneController.text.trim();
    final emailAtVerification = _emailController.text.trim();
    final result = await ApiService().verifyEmailOtp(
      challengeId: challengeId,
      code: code,
    );
    if (!mounted) return;
    if (_phoneController.text.trim() != phoneAtVerification ||
        _emailController.text.trim() != emailAtVerification) {
      setState(() => _checkingOtp = false);
      return;
    }
    setState(() {
      _checkingOtp = false;
      _emailVerified = result.success && result.data != null;
      _contactVerificationToken = result.data;
      if (!_emailVerified) _otpChallengeId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Could not verify email address.'),
        backgroundColor:
            result.success ? AppColors.primaryGreen : AppColors.errorRed,
      ),
    );
  }

  Widget _buildDynamicWorkflowFields() {
    switch (_selectedCategory.workflowType) {
      case CategoryWorkflowType.property:
        return _buildPropertyWorkflow();
      case CategoryWorkflowType.car:
        return _buildCarWorkflow();
      case CategoryWorkflowType.construction:
        return _buildConstructionWorkflow();
      case CategoryWorkflowType.general:
        return _buildGeneralWorkflow();
    }
  }

  // Branch 1: Property
  Widget _buildPropertyWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Types (Select all that apply):',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyNeutral),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'Duplex',
            'Bungalow',
            'Land / Plot',
            'Commercial Plaza',
            'Shortlet Apartment'
          ].map((type) {
            final isSelected = _selectedPropertyTypes.contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPropertyTypes.add(type);
                  } else {
                    _selectedPropertyTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Bedrooms',
                value: _selectedBedrooms,
                items: [
                  '1 Bedroom',
                  '2 Bedrooms',
                  '3 Bedrooms',
                  '4 Bedrooms',
                  '5+ Bedrooms',
                  'Commercial / Land'
                ],
                onChanged: (v) => setState(() => _selectedBedrooms = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                label: 'Target Budget',
                value: _propertyBudget,
                items: [
                  'Under ₦30M',
                  '₦30M – ₦70M',
                  '₦70M – ₦150M',
                  'Above ₦150M'
                ],
                onChanged: (v) => setState(() => _propertyBudget = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _descriptionController,
          label: 'Specific Requirements / Details',
          hintText:
              'e.g. Looking for a detached 4-bedroom duplex in Guzape or Katampe with good access road.',
          maxLines: 3,
        ),
      ],
    );
  }

  // Branch 2: Cars
  Widget _buildCarWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Car Type',
                value: _carType,
                items: [
                  'SUV / Jeep',
                  'Sedan / Saloon',
                  'Hatchback',
                  'Pickup Truck',
                  'Commercial Bus'
                ],
                onChanged: (v) => setState(() => _carType = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                label: 'Electric Vehicle (EV)?',
                value: _isElectricVehicle,
                items: ['No', 'Yes (100% Electric EV)'],
                onChanged: (v) => setState(() => _isElectricVehicle = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _carModelYearController,
          label: 'Vehicle Model & Year',
          hintText: 'e.g. Toyota RAV4 2022 or Mercedes Benz C300 2018',
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _descriptionController,
          label: 'Issue / Service Needed',
          hintText:
              'e.g. Computer diagnostic scan, AC blowing warm air, or full engine tune-up.',
          maxLines: 3,
        ),
      ],
    );
  }

  // Branch 3: Construction & Land
  Widget _buildConstructionWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Land Size',
                value: _landSize,
                items: [
                  'Half Plot (250–350 sqm)',
                  '1 Plot (500–650 sqm)',
                  '2 Plots (1,000+ sqm)',
                  'Acreage / Hectares'
                ],
                onChanged: (v) => setState(() => _landSize = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                label: 'Land Status',
                value: _landStatus,
                items: ['already-have-land', 'help-finding-land'],
                onChanged: (v) => setState(() => _landStatus = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _constructionDescController,
          label: 'Scope of Project',
          hintText:
              'e.g. Architectural CAD drawing, borehole drilling, or full foundation building.',
          maxLines: 3,
        ),
      ],
    );
  }

  // Branch 4: General Artisan
  Widget _buildGeneralWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _serviceDetailController,
          label: 'Specific Task / Service',
          hintText:
              'e.g. Barber home visit, Generator servicing, or Inverter installation',
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _descriptionController,
          label: 'Problem Description',
          hintText: 'Describe the issue or exact requirement in detail...',
          maxLines: 3,
          isRequired: true,
          validator: (v) => Validators.requiredField(v, 'Description'),
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    final urgencyOptions = [
      {
        'val': 'High',
        'title': 'High / Immediate',
        'color': AppColors.urgencyHigh,
        'icon': Icons.bolt_outlined
      },
      {
        'val': 'Medium',
        'title': '24–48 Hours',
        'color': AppColors.urgencyMedium,
        'icon': Icons.hourglass_top_outlined
      },
      {
        'val': 'Low',
        'title': 'Flexible',
        'color': AppColors.urgencyLow,
        'icon': Icons.schedule_outlined
      },
    ];

    return Row(
      children: urgencyOptions.map((opt) {
        final isSelected = _urgency == opt['val'];
        final color = opt['color'] as Color;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => _urgency = opt['val'] as String),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.12)
                      : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : AppColors.cardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(opt['icon'] as IconData,
                        color: isSelected ? color : AppColors.iconMuted,
                        size: 20),
                    const SizedBox(height: 4),
                    Text(
                      opt['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : AppColors.darkNeutral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkNeutral),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkNeutral,
                  fontWeight: FontWeight.w500),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // 5. Success Screen
  Widget _buildSuccessScreen(ServiceRequest req) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primaryGreen,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Service Request Submitted!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNeutral,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reference ID: ${req.id ?? "REQ-PENDING"}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Customer', req.customerName),
                    _buildSummaryRow('Category', req.category),
                    _buildSummaryRow('Urgency', req.urgency),
                    _buildSummaryRow('Location', req.location ?? 'Abuja HQ'),
                    if (req.agreementId != null)
                      _buildSummaryRow('Agreement', req.agreementId!),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Direct WhatsApp Dispatch Rule (Section 8)
              AllfixButton(
                label: 'Connect with Dispatch on WhatsApp',
                type: AllfixButtonType.whatsapp,
                icon: Icons.chat_outlined,
                onPressed: () {
                  UrlLauncherHelper.launchRequestDispatch(
                    requestId: req.id ?? 'REQ-ALLFIX',
                    category: req.category,
                  );
                },
              ),
              const SizedBox(height: 12),
              AllfixButton(
                label: 'Back to Home Dashboard',
                type: AllfixButtonType.outline,
                onPressed: () {
                  setState(() {
                    _submittedRequest = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.bodyNeutral, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.darkNeutral,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
