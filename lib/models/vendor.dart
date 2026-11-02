class Vendor {
  final String? id;
  final String fullName;
  final String? businessName;
  final String phone;
  final String? email;
  final String category;
  final List<String> specialties;
  final String? experienceYears;
  final String? operatingAreas;
  final String? regNumber;
  final String? address;
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final String? adminNotes;
  final String? agreementId;
  final bool termsAccepted;
  final String termsVersion;
  final String? createdAt;

  const Vendor({
    this.id,
    required this.fullName,
    this.businessName,
    required this.phone,
    this.email,
    required this.category,
    this.specialties = const [],
    this.experienceYears,
    this.operatingAreas,
    this.regNumber,
    this.address,
    this.verificationStatus = 'pending',
    this.adminNotes,
    this.agreementId,
    this.termsAccepted = true,
    this.termsVersion = 'v1.0',
    this.createdAt,
  });

  Vendor copyWith({String? id}) => Vendor(
        id: id ?? this.id,
        fullName: fullName,
        businessName: businessName,
        phone: phone,
        email: email,
        category: category,
        specialties: specialties,
        experienceYears: experienceYears,
        operatingAreas: operatingAreas,
        regNumber: regNumber,
        address: address,
        verificationStatus: verificationStatus,
        adminNotes: adminNotes,
        agreementId: agreementId,
        termsAccepted: termsAccepted,
        termsVersion: termsVersion,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'full_name': fullName,
      if (businessName != null) 'businessName': businessName,
      if (businessName != null) 'business_name': businessName,
      'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      'category': category,
      'specialties': specialties,
      if (experienceYears != null) 'experienceYears': experienceYears,
      if (experienceYears != null) 'experience_years': experienceYears,
      if (operatingAreas != null) 'operatingAreas': operatingAreas,
      if (operatingAreas != null) 'operating_areas': operatingAreas,
      if (regNumber != null) 'regNumber': regNumber,
      if (regNumber != null) 'reg_number': regNumber,
      if (address != null) 'address': address,
      'verification_status': verificationStatus,
      if (adminNotes != null) 'admin_notes': adminNotes,
      if (agreementId != null) 'agreement_id': agreementId,
      'termsAccepted': termsAccepted,
      'termsVersion': termsVersion,
      'terms_version': termsVersion,
    };
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return Vendor(
      id: json['id']?.toString(),
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      businessName: json['business_name'] ?? json['businessName'],
      phone: json['phone'] ?? '',
      email: json['email'],
      category: json['category'] ?? '',
      specialties: parseList(json['specialties']),
      experienceYears: json['experience_years'] ?? json['experienceYears'],
      operatingAreas: json['operating_areas'] ?? json['operatingAreas'],
      regNumber: json['reg_number'] ?? json['regNumber'],
      address: json['address'],
      verificationStatus: json['verification_status'] ??
          json['verificationStatus'] ??
          'pending',
      adminNotes: json['admin_notes'] ?? json['adminNotes'],
      agreementId: json['agreement_id'] ?? json['agreementId'],
      termsAccepted: json['termsAccepted'] ?? true,
      termsVersion: json['terms_version'] ?? json['termsVersion'] ?? 'v1.0',
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }
}
