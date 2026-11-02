class Agreement {
  final String id;
  final String userName;
  final String contact;
  final String agreementType; // 'Client Terms' or 'Vendor Terms'
  final String version;
  final bool status;
  final String? context;
  final String? relatedEntityId;
  final String? acceptedAt;

  const Agreement({
    required this.id,
    required this.userName,
    required this.contact,
    required this.agreementType,
    this.version = 'v1.0',
    this.status = true,
    this.context,
    this.relatedEntityId,
    this.acceptedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'contact': contact,
      'agreement_type': agreementType,
      'version': version,
      'status': status,
      if (context != null) 'context': context,
      if (relatedEntityId != null) 'related_entity_id': relatedEntityId,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
    };
  }

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      contact: json['contact'] ?? '',
      agreementType: json['agreement_type'] ?? json['agreementType'] ?? 'Client Terms',
      version: json['version'] ?? 'v1.0',
      status: json['status'] ?? true,
      context: json['context'],
      relatedEntityId: json['related_entity_id'] ?? json['relatedEntityId'],
      acceptedAt: json['accepted_at'] ?? json['acceptedAt'],
    );
  }
}
