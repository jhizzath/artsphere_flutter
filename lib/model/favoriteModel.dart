// lib/model/favoriteModel.dart
import 'package:artsphere/model/artworkModel.dart';

class Favorite {
  final int id;
  final ArtworkModel artwork;
  final DateTime addedAt;

  Favorite({
    required this.id,
    required this.artwork,
    required this.addedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      artwork: ArtworkModel.fromJson(json['artwork']),
      addedAt: DateTime.parse(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artwork': artwork.toJson(),
      'added_at': addedAt.toIso8601String(),
    };
  }
}