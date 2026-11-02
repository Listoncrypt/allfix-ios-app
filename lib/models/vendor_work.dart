class VendorWork {
  final String id;
  final String vendorName;
  final String jobType;
  final String title;
  final String description;
  final String location;
  final String image;
  final List<String> photos;
  final String completedAt;

  const VendorWork({
    required this.id,
    required this.vendorName,
    required this.jobType,
    required this.title,
    required this.description,
    required this.location,
    required this.image,
    required this.photos,
    required this.completedAt,
  });

  factory VendorWork.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photos'];
    final photos = rawPhotos is List
        ? rawPhotos.map((photo) => photo.toString()).toList()
        : <String>[];
    final image = json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        '';
    return VendorWork(
      id: json['id']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ??
          json['vendor_name']?.toString() ?? '',
      jobType: json['jobType']?.toString() ??
          json['job_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      image: image,
      photos: photos,
      completedAt: json['completedAt']?.toString() ??
          json['completed_at']?.toString() ?? '',
    );
  }
}
