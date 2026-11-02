import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/property.dart';
import '../../widgets/allfix_button.dart';
import '../../widgets/custom_text_field.dart';

class AddPropertyModal extends StatefulWidget {
  final Future<bool> Function(Property) onPropertyAdded;

  const AddPropertyModal({
    super.key,
    required this.onPropertyAdded,
  });

  @override
  State<AddPropertyModal> createState() => _AddPropertyModalState();
}

class _AddPropertyModalState extends State<AddPropertyModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _propertyType = 'Residential Duplex';
  String _titleDocument = 'C of O';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final newProp = Property(
      id: '',
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      propertyType: _propertyType,
      price: _priceController.text.trim(),
      size: _sizeController.text.trim(),
      titleDocument: _titleDocument,
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      status: 'available',
    );

    final saved = await widget.onPropertyAdded(newProp);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'The listing could not be saved. Check admin access and try again.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Verified Property',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNeutral,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _titleController,
                label: 'Property Title',
                hintText: 'e.g. 5 Bedroom Fully Detached Luxury Villa',
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Title'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Price in Naira (₦)',
                      hintText: '₦120,000,000',
                      isRequired: true,
                      validator: (v) => Validators.requiredField(v, 'Price'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _sizeController,
                      label: 'Size / Land Area',
                      hintText: '650 sqm',
                      isRequired: true,
                      validator: (v) => Validators.requiredField(v, 'Size'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _locationController,
                label: 'Location / Address',
                hintText: 'e.g. Guzape, Abuja',
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Location'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Property Type',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _propertyType,
                          items: [
                            'Residential Duplex',
                            'Luxury Apartment',
                            'Commercial Land',
                            'Office Complex'
                          ]
                              .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: const TextStyle(fontSize: 12.5))))
                              .toList(),
                          onChanged: (v) => setState(() => _propertyType = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Title Document',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _titleDocument,
                          items: [
                            'C of O',
                            'R of O',
                            'Governor Consent',
                            'Deed of Assignment'
                          ]
                              .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: const TextStyle(fontSize: 12.5))))
                              .toList(),
                          onChanged: (v) => setState(() => _titleDocument = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _imageUrlController,
                label: 'Image URL (Cloudinary / Web CDN)',
                hintText: 'Paste an image URL from your approved media host',
                isRequired: true,
                validator: (v) => Validators.requiredField(v, 'Image URL'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description & Features',
                hintText: 'Details on access road, solar power, security, etc.',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              AllfixButton(
                label: 'Save & Publish Listing',
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
