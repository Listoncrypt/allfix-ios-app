class ServiceRequest {
  final String? id;
  final String customerName;
  final String phone;
  final String? email;
  final String category;
  final String? service;
  final String? location;
  final String urgency; // 'High', 'Medium', 'Low'
  final String? preferredDate;
  final String description;

  // Real Estate workflow fields
  final String? bedrooms;
  final List<String> preferredLocations;
  final String? propertyBudget;
  final String? propertyTimeline;
  final List<String> propertyTypes;
  final String? propertyTypeOther;

  // Cars & Vehicles workflow fields
  final String? carType;
  final String? carModelYear;
  final String? isElectricVehicle;
  final List<String> carColours;
  final String? carBudget;

  // Construction & Land workflow fields
  final String? constructionDescription;
  final String? landSize;
  final String? landSizeOther;
  final String? landStatus; // 'already-have-land' / 'help-finding-land'

  // Admin & Compliance
  final String status; // 'pending_matching', 'contacted', 'matched', 'completed'
  final String? adminNotes;
  final String? agreementId;
  final bool termsAccepted;
  final String termsVersion;
  final String? createdAt;

  const ServiceRequest({
    this.id,
    required this.customerName,
    required this.phone,
    this.email,
    required this.category,
    this.service,
    this.location,
    this.urgency = 'Medium',
    this.preferredDate,
    required this.description,
    this.bedrooms,
    this.preferredLocations = const [],
    this.propertyBudget,
    this.propertyTimeline,
    this.propertyTypes = const [],
    this.propertyTypeOther,
    this.carType,
    this.carModelYear,
    this.isElectricVehicle,
    this.carColours = const [],
    this.carBudget,
    this.constructionDescription,
    this.landSize,
    this.landSizeOther,
    this.landStatus,
    this.status = 'pending_matching',
    this.adminNotes,
    this.agreementId,
    this.termsAccepted = true,
    this.termsVersion = 'v1.0',
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customerName': customerName,
      'customer_name': customerName,
      'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      'category': category,
      if (service != null) 'service': service,
      if (location != null) 'location': location,
      'urgency': urgency,
      if (preferredDate != null) 'preferredDate': preferredDate,
      if (preferredDate != null) 'preferred_date': preferredDate,
      'description': description,
      if (bedrooms != null) 'bedrooms': bedrooms,
      'preferredLocations': preferredLocations,
      'preferred_locations': preferredLocations,
      if (propertyBudget != null) 'propertyBudget': propertyBudget,
      if (propertyBudget != null) 'property_budget': propertyBudget,
      if (propertyTimeline != null) 'propertyTimeline': propertyTimeline,
      if (propertyTimeline != null) 'property_timeline': propertyTimeline,
      'propertyTypes': propertyTypes,
      'property_types': propertyTypes,
      if (propertyTypeOther != null) 'property_type_other': propertyTypeOther,
      if (carType != null) 'carType': carType,
      if (carType != null) 'car_type': carType,
      if (carModelYear != null) 'carModelYear': carModelYear,
      if (carModelYear != null) 'car_model_year': carModelYear,
      if (isElectricVehicle != null) 'isElectricVehicle': isElectricVehicle,
      if (isElectricVehicle != null) 'is_electric_vehicle': isElectricVehicle,
      'carColours': carColours,
      'car_colours': carColours,
      if (carBudget != null) 'carBudget': carBudget,
      if (carBudget != null) 'car_budget': carBudget,
      if (constructionDescription != null) 'construction_description': constructionDescription,
      if (landSize != null) 'landSize': landSize,
      if (landSize != null) 'land_size': landSize,
      if (landSizeOther != null) 'land_size_other': landSizeOther,
      if (landStatus != null) 'landStatus': landStatus,
      if (landStatus != null) 'land_status': landStatus,
      'status': status,
      if (adminNotes != null) 'admin_notes': adminNotes,
      if (agreementId != null) 'agreement_id': agreementId,
      'termsAccepted': termsAccepted,
      'termsVersion': termsVersion,
      'terms_version': termsVersion,
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ServiceRequest(
      id: json['id']?.toString(),
      customerName: json['customer_name'] ?? json['customerName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      category: json['category'] ?? '',
      service: json['service'],
      location: json['location'],
      urgency: json['urgency'] ?? 'Medium',
      preferredDate: json['preferred_date'] ?? json['preferredDate'],
      description: json['description'] ?? '',
      bedrooms: json['bedrooms'],
      preferredLocations: parseList(json['preferred_locations'] ?? json['preferredLocations']),
      propertyBudget: json['property_budget'] ?? json['propertyBudget'],
      propertyTimeline: json['property_timeline'] ?? json['propertyTimeline'],
      propertyTypes: parseList(json['property_types'] ?? json['propertyTypes']),
      propertyTypeOther: json['property_type_other'] ?? json['propertyTypeOther'],
      carType: json['car_type'] ?? json['carType'],
      carModelYear: json['car_model_year'] ?? json['carModelYear'],
      isElectricVehicle: json['is_electric_vehicle'] ?? json['isElectricVehicle'],
      carColours: parseList(json['car_colours'] ?? json['carColours']),
      carBudget: json['car_budget'] ?? json['carBudget'],
      constructionDescription: json['construction_description'] ?? json['constructionDescription'],
      landSize: json['land_size'] ?? json['landSize'],
      landSizeOther: json['land_size_other'] ?? json['landSizeOther'],
      landStatus: json['land_status'] ?? json['landStatus'],
      status: json['status'] ?? 'pending_matching',
      adminNotes: json['admin_notes'] ?? json['adminNotes'],
      agreementId: json['agreement_id'] ?? json['agreementId'],
      termsAccepted: json['termsAccepted'] ?? true,
      termsVersion: json['terms_version'] ?? json['termsVersion'] ?? 'v1.0',
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }

  ServiceRequest copyWith({
    String? id,
    String? customerName,
    String? phone,
    String? email,
    String? category,
    String? service,
    String? location,
    String? urgency,
    String? preferredDate,
    String? description,
    String? bedrooms,
    List<String>? preferredLocations,
    String? propertyBudget,
    String? propertyTimeline,
    List<String>? propertyTypes,
    String? propertyTypeOther,
    String? carType,
    String? carModelYear,
    String? isElectricVehicle,
    List<String>? carColours,
    String? carBudget,
    String? constructionDescription,
    String? landSize,
    String? landSizeOther,
    String? landStatus,
    String? status,
    String? adminNotes,
    String? agreementId,
    bool? termsAccepted,
    String? termsVersion,
    String? createdAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      service: service ?? this.service,
      location: location ?? this.location,
      urgency: urgency ?? this.urgency,
      preferredDate: preferredDate ?? this.preferredDate,
      description: description ?? this.description,
      bedrooms: bedrooms ?? this.bedrooms,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      propertyBudget: propertyBudget ?? this.propertyBudget,
      propertyTimeline: propertyTimeline ?? this.propertyTimeline,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      propertyTypeOther: propertyTypeOther ?? this.propertyTypeOther,
      carType: carType ?? this.carType,
      carModelYear: carModelYear ?? this.carModelYear,
      isElectricVehicle: isElectricVehicle ?? this.isElectricVehicle,
      carColours: carColours ?? this.carColours,
      carBudget: carBudget ?? this.carBudget,
      constructionDescription: constructionDescription ?? this.constructionDescription,
      landSize: landSize ?? this.landSize,
      landSizeOther: landSizeOther ?? this.landSizeOther,
      landStatus: landStatus ?? this.landStatus,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      agreementId: agreementId ?? this.agreementId,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      termsVersion: termsVersion ?? this.termsVersion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
