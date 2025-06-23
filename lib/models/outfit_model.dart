import 'package:cloud_firestore/cloud_firestore.dart';

class OutfitModel {
  final String id; // Firebase document ID
  final String title;
  final String description;
  final String imageId; // Local image file identifier
  final List<String> categories;
  final String clothingType;
  final String weatherRange; // e.g. '10-20°C', 'Hot', 'Cold'
  final String season; // e.g. 'Winter', 'Summer'
  final bool isFavorite;
  final bool isDonated;
  final DateTime createdAt;

  OutfitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageId,
    required this.categories,
    required this.clothingType,
    required this.weatherRange,
    required this.season,
    this.isFavorite = false,
    this.isDonated = false,
    required this.createdAt,
  });

  factory OutfitModel.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return OutfitModel(
      id: documentId ?? json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageId: json['imageId'] as String? ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      clothingType: json['clothingType'] as String? ?? '',
      weatherRange: json['weatherRange'] as String? ?? '',
      season: json['season'] as String? ?? '',
      isFavorite: json['isFavorite'] ?? false,
      isDonated: json['isDonated'] ?? false,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageId': imageId,
      'categories': categories,
      'clothingType': clothingType,
      'weatherRange': weatherRange,
      'season': season,
      'isFavorite': isFavorite,
      'isDonated': isDonated,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  OutfitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageId,
    List<String>? categories,
    String? clothingType,
    String? weatherRange,
    String? season,
    bool? isFavorite,
    bool? isDonated,
    DateTime? createdAt,
  }) {
    return OutfitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageId: imageId ?? this.imageId,
      categories: categories ?? this.categories,
      clothingType: clothingType ?? this.clothingType,
      weatherRange: weatherRange ?? this.weatherRange,
      season: season ?? this.season,
      isFavorite: isFavorite ?? this.isFavorite,
      isDonated: isDonated ?? this.isDonated,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 