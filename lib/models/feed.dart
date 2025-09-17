import 'user.dart';

class Feed {
  final String id;
  final String videoUrl;
  final String thumbnail;
  final String description;
  final User user;
  final List<int> categories;
  final DateTime createdAt;
  final int likes;
  final int comments;

  Feed({
    required this.id,
    required this.videoUrl,
    required this.thumbnail,
    required this.description,
    required this.user,
    required this.categories,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    // Be flexible with API keys: support both our original keys and server keys
    final String video = json['video_url'] ?? json['video'] ?? '';
    final String thumb = json['thumbnail'] ?? json['image'] ?? '';
    final dynamic likesField = json['likes'];
    int likeCount = 0;
    if (likesField is int) likeCount = likesField;
    if (likesField is List) likeCount = likesField.length;

    return Feed(
      id: json['id']?.toString() ?? '',
      videoUrl: video,
      thumbnail: thumb,
      description: json['description']?.toString() ?? '',
      user: User.fromJson(json['user'] ?? {}),
      categories: List<int>.from((json['categories'] ?? []).map((e) => int.tryParse(e.toString()) ?? -1)),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      likes: likeCount,
      comments: json['comments'] is int ? json['comments'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'description': description,
      'user': user.toJson(),
      'categories': categories,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }
}

