// widgets/story_tray.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';

class StoryTray extends StatelessWidget {
  final List<StoryModel> stories;

  const StoryTray({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final story = stories[index];
          return _StoryItem(story: story);
        },
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final StoryModel story;

  const _StoryItem({required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Stories viewer not implemented — snackbar per spec
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar('Stories viewer coming soon'),
        );
      },
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            _StoryRing(story: story),
            const SizedBox(height: 5),
            Text(
              story.isOwn ? 'Your story' : story.username,
              style: const TextStyle(fontSize: 11.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  final StoryModel story;

  const _StoryRing({required this.story});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (story.isOwn) {
      return Stack(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF3D3D3D)
                    : const Color(0xFFDBDBDB),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: story.avatarUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
              ),
            ),
          ),
          // "+" button
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF0095F6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 12),
            ),
          ),
        ],
      );
    }

    // Gradient ring or greyed out if seen
    final gradient = story.isSeen
        ? const LinearGradient(colors: [Color(0xFFDBDBDB), Color(0xFFDBDBDB)])
        : const LinearGradient(
      colors: [Color(0xFFFBB400), Color(0xFFFF6600), Color(0xFFD8007C)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.black : Colors.white,
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: story.avatarUrl,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
          ),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDBDBDB),
      child: const Icon(Icons.person, color: Color(0xFF8E8E8E)),
    );
  }
}

SnackBar _buildSnackBar(String message) {
  return SnackBar(
    content: Text(message, style: const TextStyle(fontSize: 13.5)),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(16),
    backgroundColor: const Color(0xFF262626),
  );
}