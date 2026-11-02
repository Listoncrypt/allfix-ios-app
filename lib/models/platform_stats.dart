class PlatformStats {
  final int totalRequests;
  final int verifiedVendors;
  final int agreementsSigned;
  final int totalProperties;
  final int totalVehicles;

  const PlatformStats({
    this.totalRequests = 0,
    this.verifiedVendors = 0,
    this.agreementsSigned = 0,
    this.totalProperties = 0,
    this.totalVehicles = 0,
  });

  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalRequests: json['totalRequests'] ?? json['total_requests'] ?? 0,
      verifiedVendors: json['verifiedVendors'] ?? json['verified_vendors'] ?? 0,
      agreementsSigned:
          json['agreementsSigned'] ?? json['agreements_signed'] ?? 0,
      totalProperties: json['totalProperties'] ?? json['total_properties'] ?? 0,
      totalVehicles: json['totalVehicles'] ?? json['total_vehicles'] ?? 0,
    );
  }
}
