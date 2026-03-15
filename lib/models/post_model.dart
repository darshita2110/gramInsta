// models/post_model.dart

class UserModel {
  final String id;
  final String username;
  final String avatarUrl;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.isVerified = false,
  });
}

class CarouselItem {
  final String imageUrl;
  final double aspectRatio;

  const CarouselItem({
    required this.imageUrl,
    this.aspectRatio = 1.0,
  });
}

enum PostMediaType { single, carousel, video }

class PostModel {
  final String id;
  final UserModel user;
  final PostMediaType mediaType;
  final List<CarouselItem> mediaItems;
  final String caption;
  final int likeCount;
  final int commentCount;
  final String timeAgo;
  final String? location;
  final bool isSponsoredPost;

  const PostModel({
    required this.id,
    required this.user,
    required this.mediaType,
    required this.mediaItems,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.timeAgo,
    this.location,
    this.isSponsoredPost = false,
  });

  // Convenience getter for single-image posts
  String get primaryImageUrl => mediaItems.first.imageUrl;
  bool get isCarousel => mediaItems.length > 1;
}

class StoryModel {
  final String id;
  final String username;
  final String avatarUrl;
  final bool isSeen;
  final bool isOwn;

  const StoryModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.isSeen = false,
    this.isOwn = false,
  });
}