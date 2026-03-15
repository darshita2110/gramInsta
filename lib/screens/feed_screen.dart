// screens/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/shimmer_feed.dart';
import '../widgets/story_tray.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Trigger pagination when user is ~2 posts from the bottom.
  /// Two posts ≈ roughly 2× the average post height (~500px), so ~1000px.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const threshold = 1000.0;

    if (currentScroll >= maxScroll - threshold) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(),
              const Divider(height: 0.5, thickness: 0.5),
              Expanded(child: _FeedBody(scrollController: _scrollController)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top navigation bar
// ---------------------------------------------------------------------------
class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          // Instagram wordmark – using styled text as close as possible
          Image.asset(
            'assets/logo.jpg',
            height: 32,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Notification bell
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notifications coming soon',
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
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.favorite_border, size: 26),
            ),
          ),
          const SizedBox(width: 4),
          // Messenger icon
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Messages coming soon',
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
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.send_outlined, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main feed body
// ---------------------------------------------------------------------------
class _FeedBody extends ConsumerWidget {
  final ScrollController scrollController;

  const _FeedBody({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    final storiesAsync = ref.watch(storiesProvider);

    // Full-screen shimmer on initial load
    if (feedState.isLoadingInitial) {
      return const ShimmerFeed();
    }

    // Error state
    if (feedState.error != null && feedState.posts.isEmpty) {
      return _ErrorView(
        onRetry: () => ref.read(feedProvider.notifier).loadInitial(),
      );
    }

    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // Stories tray
        SliverToBoxAdapter(
          child: storiesAsync.when(
            data: (stories) => StoryTray(stories: stories),
            loading: () => const SizedBox(
              height: 106,
              child: Center(child: SizedBox.shrink()),
            ),
            error: (_, __) => const SizedBox(height: 106),
          ),
        ),
        SliverToBoxAdapter(
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: Theme.of(context).dividerColor,
          ),
        ),

        // Post cards
        SliverList.separated(
          itemCount: feedState.posts.length,
          separatorBuilder: (_, __) => Divider(
            height: 0.5,
            thickness: 0.5,
            color: Theme.of(context).dividerColor,
          ),
          itemBuilder: (context, index) {
            return PostCard(
              key: ValueKey(feedState.posts[index].id),
              post: feedState.posts[index],
            );
          },
        ),

        // Load more indicator OR end-of-feed message
        SliverToBoxAdapter(
          child: feedState.isLoadingMore
              ? const LoadMoreShimmer()
              : feedState.hasMore
              ? const SizedBox(height: 20)
              : const _EndOfFeed(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// End of feed
// ---------------------------------------------------------------------------
class _EndOfFeed extends StatelessWidget {
  const _EndOfFeed();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.person_outline, size: 28, color: Color(0xFF8E8E8E)),
          ),
          const SizedBox(height: 12),
          const Text(
            "You're all caught up",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            'You have seen all new posts from the\npast 3 days.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF8E8E8E)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 48, color: Color(0xFF8E8E8E)),
          const SizedBox(height: 16),
          const Text(
            'Unable to load feed',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check your connection and try again.',
            style: TextStyle(fontSize: 13, color: Color(0xFF8E8E8E)),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}