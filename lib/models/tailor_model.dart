class TailorModel {
  final String id;
  final String name;
  final String organizationId;
  final String? contact;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TailorModel({
    required this.id,
    required this.name,
    required this.organizationId,
    this.contact,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organizationId': organizationId,
      'contact': contact,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory TailorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TailorModel(
      id: documentId,
      name: map['name'],
      organizationId: map['organizationId'],
      contact: map['contact'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
} 