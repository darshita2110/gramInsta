// providers/feed_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../services/post_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider — singleton
// ---------------------------------------------------------------------------
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

// ---------------------------------------------------------------------------
// Stories provider
// ---------------------------------------------------------------------------
final storiesProvider = FutureProvider<List<StoryModel>>((ref) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.fetchStories();
});

// ---------------------------------------------------------------------------
// Feed pagination state
// ---------------------------------------------------------------------------
class FeedState {
  final List<PostModel> posts;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoadingInitial = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}

// ---------------------------------------------------------------------------
// Feed notifier — handles initial load + pagination
// ---------------------------------------------------------------------------
class FeedNotifier extends StateNotifier<FeedState> {
  final PostRepository _repo;

  FeedNotifier(this._repo) : super(const FeedState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const FeedState(isLoadingInitial: true);
    try {
      final posts = await _repo.fetchFeed(page: 0);
      state = FeedState(
        posts: posts,
        isLoadingInitial: false,
        hasMore: posts.length == 10,
        currentPage: 0,
      );
    } catch (e) {
      state = FeedState(
        isLoadingInitial: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoadingInitial) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final newPosts = await _repo.fetchFeed(page: nextPage);

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoadingMore: false,
        hasMore: newPosts.length == 10,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return FeedNotifier(repo);
});

// ---------------------------------------------------------------------------
// Like state — tracks which posts are liked locally
// ---------------------------------------------------------------------------
class LikeNotifier extends StateNotifier<Map<String, bool>> {
  LikeNotifier() : super({});

  void toggle(String postId) {
    state = {
      ...state,
      postId: !(state[postId] ?? false),
    };
  }

  bool isLiked(String postId) => state[postId] ?? false;
}

final likeProvider = StateNotifierProvider<LikeNotifier, Map<String, bool>>(
      (ref) => LikeNotifier(),
);

// ---------------------------------------------------------------------------
// Save state — tracks which posts are saved locally
// ---------------------------------------------------------------------------
class SaveNotifier extends StateNotifier<Map<String, bool>> {
  SaveNotifier() : super({});

  void toggle(String postId) {
    state = {
      ...state,
      postId: !(state[postId] ?? false),
    };
  }

  bool isSaved(String postId) => state[postId] ?? false;
}

final saveProvider = StateNotifierProvider<SaveNotifier, Map<String, bool>>(
      (ref) => SaveNotifier(),
);