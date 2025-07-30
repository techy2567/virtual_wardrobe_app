class TailorModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final List<String> specialties;
  final String organizationId;
  final String? contact;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TailorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.specialties,
    required this.organizationId,
    this.contact,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'specialties': specialties,
      'organizationId': organizationId,
      'contact': contact,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory TailorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TailorModel(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      organizationId: map['organizationId'] ?? '',
      contact: map['contact'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
} 