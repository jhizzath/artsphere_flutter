class FeedbackModel {
  final int id;
  final String feedbackType;
  final int? artworkId;
  final int? rating;
  final String comment;
  final DateTime createdAt;
  final String userName;
  final String? userProfilePic; // Add this field

  FeedbackModel({
    required this.id,
    required this.feedbackType,
    this.artworkId,
    this.rating,
    required this.comment,
    required this.createdAt,
    required this.userName,
    this.userProfilePic, // Add to constructor
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      feedbackType: json['feedback_type'],
      artworkId: json['artwork'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user'] is Map ? json['user']['username'] : 'Anonymous',
      userProfilePic: json['user'] is Map ? json['user']['profile_picture'] : null,
    );
  }
}