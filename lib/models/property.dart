class Property {
  final String id;
  final String title;
  final String location;
  final String propertyType;
  final String price;
  final String size;
  final String titleDocument; // 'C of O', 'R of O', 'Deed', etc.
  final String description;
  final String imageUrl;
  final List<String> images;
  final String status; // 'available', 'under_offer', 'sold'
  final String? createdAt;

  const Property({
    required this.id,
    required this.title,
    required this.location,
    this.propertyType = 'Residential',
    required this.price,
    required this.size,
    required this.titleDocument,
    required this.description,
    required this.imageUrl,
    this.images = const [],
    this.status = 'available',
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'propertyType': propertyType,
      'property_type': propertyType,
      'price': price,
      'size': size,
      'titleDocument': titleDocument,
      'title_document': titleDocument,
      'description': description,
      'imageUrl': imageUrl,
      'image_url': imageUrl,
      'images': images,
      'status': status,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      propertyType: json['property_type'] ?? json['propertyType'] ?? 'Residential',
      price: json['price'] ?? '',
      size: json['size'] ?? '',
      titleDocument: json['title_document'] ?? json['titleDocument'] ?? 'Verified',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      images: json['images'] is List
          ? (json['images'] as List).map((image) => image.toString()).toList()
          : const [],
      status: json['status'] ?? 'available',
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }
}
