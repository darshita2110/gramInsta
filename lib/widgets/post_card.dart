// widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../providers/feed_provider.dart';
import 'pinch_to_zoom.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  // For the double-tap heart animation
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
    ]).animate(_heartController);

    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final likeNotifier = ref.read(likeProvider.notifier);
    if (!likeNotifier.isLiked(widget.post.id)) {
      likeNotifier.toggle(widget.post.id);
      HapticFeedback.lightImpact();
    }
    setState(() => _showHeart = true);
    _heartController.forward(from: 0);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13.5)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF262626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PostHeader(post: widget.post, onMoreTap: () => _showSnackBar('More options coming soon')),
        _PostMedia(
          post: widget.post,
          onDoubleTap: _handleDoubleTap,
          showHeart: _showHeart,
          heartScale: _heartScale,
        ),
        _PostActions(post: widget.post, onShare: () => _showSnackBar('Share is not implemented yet')),
        _PostLikeCount(post: widget.post),
        _PostCaption(post: widget.post),
        _PostComments(post: widget.post, onTap: () => _showSnackBar('Comments coming soon')),
        _PostTimestamp(timeAgo: widget.post.timeAgo),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Post header
// ---------------------------------------------------------------------------
class _PostHeader extends StatelessWidget {
  final PostModel post;
  final VoidCallback onMoreTap;

  const _PostHeader({required this.post, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Avatar with story ring style
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFBB400), Color(0xFFFF6600), Color(0xFFD8007C)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            padding: const EdgeInsets.all(1.8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              padding: const EdgeInsets.all(1.5),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: post.user.avatarUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFDBDBDB),
                    child: const Icon(Icons.person, size: 16, color: Color(0xFF8E8E8E)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    if (post.user.isVerified) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.verified, color: Color(0xFF0095F6), size: 13),
                    ],
                  ],
                ),
                if (post.location != null)
                  Text(
                    post.location!,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF8E8E8E)),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMoreTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(Icons.more_horiz, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Post media (single image OR carousel)
// ---------------------------------------------------------------------------
class _PostMedia extends StatefulWidget {
  final PostModel post;
  final VoidCallback onDoubleTap;
  final bool showHeart;
  final Animation<double> heartScale;

  const _PostMedia({
    required this.post,
    required this.onDoubleTap,
    required this.showHeart,
    required this.heartScale,
  });

  @override
  State<_PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<_PostMedia> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.post.isCarousel) {
      return _buildSingleImage(widget.post.mediaItems.first.imageUrl);
    }
    return _buildCarousel();
  }

  Widget _buildSingleImage(String url) {
    return GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      child: PinchToZoom(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFFEFEFEF)),
                errorWidget: (_, __, ___) => _ImageError(),
              ),
              if (widget.showHeart) _HeartOverlay(scale: widget.heartScale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: widget.onDoubleTap,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.post.mediaItems.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return PinchToZoom(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.post.mediaItems[index].imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFEFEFEF)),
                        errorWidget: (_, __, ___) => _ImageError(),
                      ),
                      if (widget.showHeart && index == _currentPage)
                        _HeartOverlay(scale: widget.heartScale),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Page indicator dots
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: _DotIndicator(
            count: widget.post.mediaItems.length,
            currentIndex: _currentPage,
          ),
        ),
        // Page count badge (top right)
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPage + 1}/${widget.post.mediaItems.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dot indicator for carousels
// ---------------------------------------------------------------------------
class _DotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _DotIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: isActive ? 6.0 : 5.0,
          height: isActive ? 6.0 : 5.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF0095F6)
                : Colors.white.withOpacity(0.7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 1,
                offset: const Offset(0, 0.5),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Heart overlay for double-tap
// ---------------------------------------------------------------------------
class _HeartOverlay extends StatelessWidget {
  final Animation<double> scale;

  const _HeartOverlay({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: scale,
        builder: (_, __) => Transform.scale(
          scale: scale.value,
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 80,
            shadows: [
              Shadow(color: Colors.black38, blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Post actions bar
// ---------------------------------------------------------------------------
class _PostActions extends ConsumerWidget {
  final PostModel post;
  final VoidCallback onShare;

  const _PostActions({required this.post, required this.onShare});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(likeProvider)[post.id] ?? false;
    final isSaved = ref.watch(saveProvider)[post.id] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          // Like
          _ActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? const Color(0xFFED4956) : null,
            onTap: () {
              ref.read(likeProvider.notifier).toggle(post.id);
              HapticFeedback.lightImpact();
            },
          ),
          // Comment
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Comments coming soon',
                      style: TextStyle(fontSize: 13.5)),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 3),
                  margin: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFF262626),
                ),
              );
            },
          ),
          // Share
          _ActionButton(
            icon: Icons.send_outlined,
            onTap: onShare,
          ),
          const Spacer(),
          // Save
          _ActionButton(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved
                ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black)
                : null,
            onTap: () {
              ref.read(saveProvider.notifier).toggle(post.id);
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Icon(icon, size: 26, color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Like count
// ---------------------------------------------------------------------------
class _PostLikeCount extends ConsumerWidget {
  final PostModel post;

  const _PostLikeCount({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(likeProvider)[post.id] ?? false;
    final adjustedCount = isLiked ? post.likeCount + 1 : post.likeCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '${_formatCount(adjustedCount)} likes',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// ---------------------------------------------------------------------------
// Caption with "more" expansion
// ---------------------------------------------------------------------------
class _PostCaption extends StatefulWidget {
  final PostModel post;

  const _PostCaption({required this.post});

  @override
  State<_PostCaption> createState() => _PostCaptionState();
}

class _PostCaptionState extends State<_PostCaption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final caption = widget.post.caption;
    final isLong = caption.length > 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: widget.post.user.username + ' ',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
            TextSpan(
              text: (!_expanded && isLong)
                  ? caption.substring(0, 100) + '... '
                  : caption,
              style: const TextStyle(fontSize: 13.5),
            ),
            if (isLong && !_expanded)
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => setState(() => _expanded = true),
                  child: const Text(
                    'more',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Comments link
// ---------------------------------------------------------------------------
class _PostComments extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const _PostComments({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (post.commentCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Text(
          'View all ${post.commentCount} comments',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF8E8E8E)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timestamp
// ---------------------------------------------------------------------------
class _PostTimestamp extends StatelessWidget {
  final String timeAgo;

  const _PostTimestamp({required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Text(
        timeAgo,
        style: const TextStyle(fontSize: 10.5, color: Color(0xFF8E8E8E)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error fallback for images
// ---------------------------------------------------------------------------
class _ImageError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFEFEF),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Color(0xFF8E8E8E), size: 36),
      ),
    );
  }
}