// models/artist_profile_model.dart
class Post {
  final String username;
  final String email;
  final String phoneNo;
  final ArtistProfile? artistProfile;
  final String? errorMessage;

  Post({
    required this.username,
    required this.email,
    required this.phoneNo,
    this.artistProfile,
    this.errorMessage,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      username: json["username"] ?? '',
      email: json["email"] ?? '',
      phoneNo: json["phone_no"] ?? '',
      artistProfile: json["artist_profile"] != null
          ? ArtistProfile.fromJson(json["artist_profile"])
          : null,
      errorMessage: json["detail"],
    );
  }
}

class ArtistProfile {
  final int id;
  final int user;
  final String? name;
  final String? profession;
  final Category category;
  final List<Subcategory> subcategories;
  final String? bio;
  final String? portfolioLink;
  final String? profilePicture;

  ArtistProfile({
    required this.id,
    required this.user,
    this.name,
    this.profession,
    required this.category,
    required this.subcategories,
    this.bio,
    this.portfolioLink,
    this.profilePicture,
  });

  factory ArtistProfile.fromJson(Map<String, dynamic> json) {
    return ArtistProfile(
      id: json["id"] ?? 0,
      user: json["user"] ?? 0,
      name: json["name"],
      profession: json["profession"],
      category: Category.fromJson(json["category"] ?? {}),
      subcategories: List<Subcategory>.from(
        (json["subcategories"] ?? []).map((x) => Subcategory.fromJson(x ?? {}))
      ),
      bio: json["bio"],
      portfolioLink: json["portfolio_link"],
       profilePicture: _parseImageUrl(json["profile_picture"]),
    );
  }
static String? _parseImageUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http')) return url;
    return 'http://192.168.99.221:8000/$url';
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user,
    "name": name,
    "profession": profession,
    "category": category.toJson(),
    "subcategories": List<dynamic>.from(subcategories.map((x) => x.toJson())),
    "bio": bio,
    "portfolio_link": portfolioLink,
    "profile_picture": profilePicture,
  };
}

class Category {
  final int id;
  final String name;
  final List<Subcategory> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      subcategories: List<Subcategory>.from(
        (json["subcategories"] ?? []).map((x) => Subcategory.fromJson(x ?? {}))
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "subcategories": List<dynamic>.from(subcategories.map((x) => x.toJson())),
  };
}

class Subcategory {
  final int id;
  final String name;
  final int category;

  Subcategory({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      category: json["category"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "category": category,
  };
}