// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

List<Post> postFromJson(String str) => List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

// String postToJson(List<Post> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Post {
    int id;
    String name;
    List<Subcategory> subcategories;

    Post({
        required this.id,
        required this.name,
        required this.subcategories,
    });

    factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        name: json["name"],
        subcategories: List<Subcategory>.from(json["subcategories"].map((x) => Subcategory.fromJson(x))),
    );

  get artistProfile => null;

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
