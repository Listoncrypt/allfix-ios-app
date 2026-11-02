import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_providers.dart';
import '../../widgets/allfix_button.dart';
import '../../widgets/custom_text_field.dart';

class MarketingRequestScreen extends ConsumerStatefulWidget {
  const MarketingRequestScreen({super.key});

  @override
  ConsumerState<MarketingRequestScreen> createState() =>
      _MarketingRequestScreenState();
}

class _MarketingRequestScreenState
    extends ConsumerState<MarketingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _landSize = TextEditingController();
  final _carModelYear = TextEditingController();
  final _carColour = TextEditingController();
  String _assetType = 'property';
  String _propertyType = 'Residential Duplex';
  String _listingPurpose = 'For Sale';
  String _titleDocument = 'Not specified';
  String _carType = 'SUV / Jeep';
  String _carCondition = 'Fairly Used (Foreign / Tokunbo)';
  String _customDuty = 'Not stated';
  String _accidentStatus = 'Not stated';
  String _engineGearStatus = 'Not stated';
  String _firstBody = 'Not stated';
  bool _termsAccepted = false;
  bool _isSubmitting = false;
  String? _submittedId;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _location.dispose();
    _price.dispose();
    _description.dispose();
    _landSize.dispose();
    _carModelYear.dispose();
    _carColour.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accept the Marketing & Inspection Terms to continue.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final payload = <String, dynamic>{
      'assetType': _assetType,
      'ownerName': _name.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'location': _location.text.trim(),
      'price': _price.text.trim(),
      'description': _description.text.trim(),
      'termsAccepted': true,
      'termsVersion': AppStrings.defaultTermsVersion,
      if (_assetType == 'property') ...{
        'propertyType': _propertyType,
        'listingPurpose': _listingPurpose,
        'titleDocument': _titleDocument,
        'landSize': _landSize.text.trim(),
      },
      if (_assetType == 'car') ...{
        'carType': _carType,
        'carModelYear': _carModelYear.text.trim(),
        'carColour': _carColour.text.trim(),
        'carCondition': _carCondition,
        'customDutyPaid': _customDuty,
        'accidentStatus': _accidentStatus,
        'engineGearStatus': _engineGearStatus,
        'firstBody': _firstBody,
      },
    };

    final response =
        await ref.read(apiServiceProvider).submitMarketingRequest(payload);
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (response.success) _submittedId = response.id;
    });
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response.message ?? 'Your listing could not be submitted.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedId != null) return _buildSuccess();
    return Scaffold(
      appBar: AppBar(title: const Text('List with ALLFIX')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            const Text(
              'Submit a property or vehicle for ALLFIX to review and market.',
              style: TextStyle(color: AppColors.bodyNeutral, fontSize: 13),
            ),
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'property',
                  label: Text('Property'),
                  icon: Icon(Icons.apartment_outlined),
                ),
                ButtonSegment(
                  value: 'car',
                  label: Text('Vehicle'),
                  icon: Icon(Icons.directions_car_outlined),
                ),
              ],
              selected: {_assetType},
              onSelectionChanged: (values) =>
                  setState(() => _assetType = values.first),
            ),
            const SizedBox(height: 18),
            _field(_name, 'Owner full name', 'Name on the listing',
                required: true),
            _field(_phone, 'Phone number', 'e.g. 08012345678',
                required: true,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone),
            _field(_email, 'Email (optional)', 'Email address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    Validators.validateEmail(value, required: false)),
            _field(_location, 'Asset location', 'Area, city and state',
                required: true),
            _field(_price, 'Expected price', 'Price in Naira'),
            if (_assetType == 'property') ...[
              _dropdown(
                'Property type',
                _propertyType,
                const [
                  'Residential Duplex',
                  'Apartment',
                  'Land / Plot',
                  'Commercial'
                ],
                (value) => setState(() => _propertyType = value),
              ),
              _dropdown(
                'Listing purpose',
                _listingPurpose,
                const ['For Sale', 'For Rent / Lease'],
                (value) => setState(() => _listingPurpose = value),
              ),
              _dropdown(
                'Title document',
                _titleDocument,
                const [
                  'Not specified',
                  'C of O',
                  'R of O',
                  'Governor Consent',
                  'Deed of Assignment'
                ],
                (value) => setState(() => _titleDocument = value),
              ),
              _field(_landSize, 'Land size (optional)', 'e.g. 500 sqm'),
            ] else ...[
              _dropdown(
                'Vehicle type',
                _carType,
                const [
                  'SUV / Jeep',
                  'Sedan / Saloon',
                  'Pickup',
                  'Van',
                  'Other'
                ],
                (value) => setState(() => _carType = value),
              ),
              _field(_carModelYear, 'Make, model and year',
                  'e.g. Toyota Camry 2021',
                  required: true),
              _field(_carColour, 'Colour (optional)', 'Vehicle colour'),
              _dropdown(
                'Condition',
                _carCondition,
                const [
                  'Brand New',
                  'Fairly Used (Foreign / Tokunbo)',
                  'Fairly Used (Nigerian)'
                ],
                (value) => setState(() => _carCondition = value),
              ),
              _dropdown(
                'Custom duty',
                _customDuty,
                const ['Not stated', 'Yes', 'No'],
                (value) => setState(() => _customDuty = value),
              ),
              _dropdown(
                'Accident history',
                _accidentStatus,
                const ['Not stated', 'Accident Free', 'Accidented'],
                (value) => setState(() => _accidentStatus = value),
              ),
              _dropdown(
                'Engine and gear status',
                _engineGearStatus,
                const ['Not stated', 'Untempered', 'Tempered'],
                (value) => setState(() => _engineGearStatus = value),
              ),
              _dropdown(
                'First body',
                _firstBody,
                const ['Not stated', 'Yes', 'No'],
                (value) => setState(() => _firstBody = value),
              ),
            ],
            _field(
                _description, 'Description', 'Condition, features or details',
                maxLines: 3),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _termsAccepted,
                onChanged: (value) =>
                    setState(() => _termsAccepted = value ?? false),
                title: const Text(
                  'I accept the ALLFIX Marketing & Inspection Authorization Terms (v1.0). I authorize ALLFIX to review this asset and contact me about inspection and marketing.',
                  style: TextStyle(
                      color: AppColors.bodyNeutral, fontSize: 12, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            AllfixButton(
              label: 'Submit for review',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomTextField(
        controller: controller,
        label: label,
        hintText: hint,
        isRequired: required,
        keyboardType: keyboardType ?? TextInputType.text,
        maxLines: maxLines,
        validator: validator ??
            (required
                ? (value) => Validators.requiredField(value, label)
                : null),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> choices,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: choices
            .map((choice) => DropdownMenuItem(
                  value: choice,
                  child: Text(choice, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      appBar: AppBar(title: const Text('Submission received')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 56, color: AppColors.primaryGreen),
              const SizedBox(height: 14),
              const Text('Your asset is under review',
                  style: TextStyle(
                      color: AppColors.darkNeutral,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Reference: $_submittedId',
                  style: const TextStyle(color: AppColors.bodyNeutral)),
              const SizedBox(height: 22),
              AllfixButton(
                label: 'Done',
                type: AllfixButtonType.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
