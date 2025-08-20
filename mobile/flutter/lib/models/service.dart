// lib/models/service.dart

class Service {
  final int id;
  final String serviceType;
  final String description;
  final double price;
  final String status;
  final String providerName;

  Service({
    required this.id,
    required this.serviceType,
    required this.description,
    required this.price,
    required this.status,
    required this.providerName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      serviceType: json['service_type'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      providerName: json['provider_name'],
    );
  }
}
