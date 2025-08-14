class ArtistVideo {
  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final String videoFile;
  final int likesCount;
  final int views;
  final bool isLiked;
  final String artistName;
  final String artistProfilePic;

  ArtistVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoFile,
    required this.likesCount,
    required this.views,
    required this.isLiked,
    required this.artistName,
    required this.artistProfilePic,
  });

  factory ArtistVideo.fromJson(Map<String, dynamic> json) {
    return ArtistVideo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      videoFile: json['video_file'],
      likesCount: json['likes_count'] ?? 0,
      views: json['views'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      artistName: json['artist_name'] ?? 'Unknown Artist',
      artistProfilePic: json['artist_profile'] ?? '',
    );
  }
 
}