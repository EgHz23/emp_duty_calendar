class Vehicle {
  final String? imagePath;
  final String brand;
  final String model;
  final int year;
  final double pricePerDay;

  Vehicle({
    this.imagePath,
    required this.brand,
    required this.model,
    required this.year,
    required this.pricePerDay,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      imagePath: json['imagePath']?.toString(), 
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      pricePerDay: json['pricePerDay'].toDouble(), 
    );
  }
}
