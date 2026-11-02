class Vehicle {
  final String id;
  final String title;
  final String brand;
  final String modelYear;
  final String type;
  final String price;
  final String location;
  final String colour;
  final String condition;
  final String description;
  final String imageUrl;
  final List<String> images;
  final String status;

  const Vehicle({
    required this.id,
    required this.title,
    this.brand = '',
    this.modelYear = '',
    this.type = '',
    this.price = '',
    this.location = '',
    this.colour = '',
    this.condition = '',
    this.description = '',
    this.imageUrl = '',
    this.images = const [],
    this.status = 'available',
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      brand: json['brand']?.toString() ?? json['make']?.toString() ?? '',
      modelYear: json['model_year']?.toString() ??
          json['modelYear']?.toString() ??
          json['year']?.toString() ?? '',
      type: json['car_type']?.toString() ??
          json['carType']?.toString() ??
          json['vehicleType']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      colour: json['colour']?.toString() ?? json['color']?.toString() ?? '',
      condition: json['condition']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      images: json['images'] is List
          ? (json['images'] as List).map((image) => image.toString()).toList()
          : const [],
      status: json['status']?.toString() ?? 'available',
    );
  }
}
