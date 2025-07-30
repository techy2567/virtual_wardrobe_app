class OrganizationModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    this.description,
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
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrganizationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrganizationModel(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
} 