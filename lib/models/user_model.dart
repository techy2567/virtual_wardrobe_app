class UserModel {
  final String? id;
  final String email;
  final String? name;
  final String? gender;
  final String? photoUrl;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.email,
    this.name,
    this.gender,
    this.photoUrl,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name']??'',
      gender: map['gender']??"",
      photoUrl: map['photoUrl']??'',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'gender': gender,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }
}