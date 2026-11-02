class Validators {
  Validators._();

  static String? requiredField(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final clean = value.replaceAll(RegExp(r'[\s\-()]'), '');
    // Supports 080..., 23480..., +23480...
    if (!RegExp(r'^(?:\+?234|0)(?:70|80|81|90|91)\d{8}$').hasMatch(clean)) {
      return 'Enter a valid Nigerian phone number (e.g. 08012345678)';
    }
    return null;
  }

  static String? validateEmail(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) return 'Email address is required';
      return null;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
