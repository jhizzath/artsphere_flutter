// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

List<ArtworkModel> postFromJson(String str) => List<ArtworkModel>.from(json.decode(str).map((x) => ArtworkModel.fromJson(x)));

String postToJson(List<ArtworkModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArtworkModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final int count;
  final String artist;
  final Category category;
  final List<Subcategory> subcategories;
  final List<ArtImage> images;
  final bool isApproved;
  final bool isFeatured;
  final String approvalStatus;

  ArtworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.count,
    required this.artist,
    required this.category,
    required this.subcategories,
    required this.images,
    required this.isApproved,
    required this.isFeatured,
    required this.approvalStatus,
  });

  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    return ArtworkModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] != null 
          ? (json['price'] is double 
              ? json['price'] 
              : double.tryParse(json['price'].toString()) ?? 0.0)
          : 0.0,
      count: json['count'] as int? ?? 0,
      artist: json['artist'] as String? ?? '',
      category: Category.fromJson(json['category'] ?? {}),
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((e) => Subcategory.fromJson(e))
          .toList() ?? [],
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ArtImage.fromJson(e))
          .toList() ?? [],
          isApproved: json['is_approved'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      approvalStatus: json['approval_status'] as String? ?? 'Pending',
    );
  }



    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "price": price,
        "count": count,
        "artist": artist,
        "category": category.toJson(),
        "subcategories": List<dynamic>.from(subcategories.map((x) => x.toJson())),
        "images": List<dynamic>.from(images.map((x) => x.toJson())),
    };
}

class Category {
    int id;
    String name;
    List<Subcategory> subcategories;

    Category({
        required this.id,
        required this.name,
        required this.subcategories,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        subcategories: List<Subcategory>.from(json["subcategories"].map((x) => Subcategory.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "subcategories": List<dynamic>.from(subcategories.map((x) => x.toJson())),
    };
}

class Subcategory {
    int id;
    String name;
    int category;

    Subcategory({
        required this.id,
        required this.name,
        required this.category,
    });

    factory Subcategory.fromJson(Map<String, dynamic> json) => Subcategory(
        id: json["id"],
        name: json["name"],
        category: json["category"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category,
    };
}

class ArtImage {
    int id;
    String image;

    ArtImage({
        required this.id,
        required this.image,
    });

    factory ArtImage.fromJson(Map<String, dynamic> json) => ArtImage(
        id: json["id"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
    };
}
