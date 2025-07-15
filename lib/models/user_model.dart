class UserModel {
  final String id;
  final String? name;
  final String? email;
  final String? gender;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.name,
    this.email,
    this.gender,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'],
      email: map['email'],
      gender: map['gender'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
