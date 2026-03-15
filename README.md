# Graminsta 📸

A pixel-perfect Instagram Home Feed clone built with Flutter 3.22+ and Riverpod. Every detail — scroll physics, spacing, typography, gesture interactions — has been crafted to match the real Instagram experience as closely as possible.

---

## Demo

| Feature | Status |
|---|---|
| Shimmer loading state (1.5s simulated latency) | ✅ |
| Stories tray with gradient rings + seen state | ✅ |
| Post feed with pixel-perfect spacing | ✅ |
| Carousel posts with PageView + dot indicator + page badge | ✅ |
| Pinch-to-Zoom with overlay + spring snap-back animation | ✅ |
| Double-tap like with animated heart overlay | ✅ |
| Like / Save toggle with haptic feedback | ✅ |
| Like count updates locally in real time | ✅ |
| Caption "more" expand | ✅ |
| Infinite scroll — triggers 2 posts from bottom | ✅ |
| Load-more shimmer animation | ✅ |
| End-of-feed "You're all caught up" screen | ✅ |
| Camera opens on top bar camera icon tap | ✅ |
| Snackbar for all unimplemented actions | ✅ |
| Image caching — memory + disk (cached_network_image) | ✅ |
| Shimmer placeholder while individual images load | ✅ |
| Image error fallback | ✅ |
| Light + Dark theme (follows system) | ✅ |
| Error state with retry | ✅ |

---

## State Management — Riverpod

**Why Riverpod over Provider, Bloc, or GetX?**

Riverpod was chosen for three concrete reasons:

**1. Compile-time safety.**
Every provider is a top-level constant. There is no `context.read<SomeType>()` that can throw at runtime if the provider isn't in the tree. The compiler catches every mistake before the app runs.

**2. Zero boilerplate for simple state.**
`likeProvider` and `saveProvider` are each a `StateNotifier` backed by a `Map<String, bool>`. Adding like/save state for a new post is a single map update — no events, no streams, no reducers. The code reads exactly like what it does.

**3. Clean separation of concerns.**
`FeedNotifier` owns 100% of the pagination logic — initial load, load-more guard, error handling, hasMore flag. The UI (`FeedScreen`) only calls `loadMore()` and reads `FeedState`. No business logic leaks into widgets.

### Provider map

| Provider | Type | Responsibility |
|---|---|---|
| `postRepositoryProvider` | `Provider` | Singleton repository instance |
| `storiesProvider` | `FutureProvider` | Fetches stories once with 600ms latency |
| `feedProvider` | `StateNotifierProvider<FeedNotifier, FeedState>` | Pagination — initial load + load more |
| `likeProvider` | `StateNotifierProvider<LikeNotifier, Map<String, bool>>` | Local like toggle per post |
| `saveProvider` | `StateNotifierProvider<SaveNotifier, Map<String, bool>>` | Local save toggle per post |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, light + dark theme setup
├── models/
│   └── post_model.dart        # PostModel, UserModel, StoryModel, CarouselItem
├── services/
│   └── post_repository.dart   # Mock data layer — 30 posts, simulated latency
├── providers/
│   └── feed_provider.dart     # All Riverpod providers and state notifiers
├── screens/
│   ├── splash_screen.dart     # SplashScreen — animated logo fade+scale, routes to FeedScreen
│   └── feed_screen.dart       # FeedScreen, TopBar, FeedBody, EndOfFeed, ErrorView
└── widgets/
    ├── post_card.dart          # PostCard, carousel, actions, caption, like animation
    ├── story_tray.dart         # Stories horizontal list with gradient rings
    ├── shimmer_feed.dart       # Shimmer skeleton for initial load + pagination
    └── pinch_to_zoom.dart      # Pinch-to-zoom overlay with elastic spring return
```

---

## How to Run

### Prerequisites

- Flutter **3.22+** — verify with `flutter --version`
- Dart **3.3+**
- Android Studio / Xcode for a connected device or emulator
- Java **17 or 21** (64-bit) — point Flutter to Android Studio's bundled JDK if needed:
  ```bash
  flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"
  ```

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/graminsta.git
cd graminsta

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

### Build a release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build for iOS

```bash
flutter build ios --release
```

### Run with performance profiling

```bash
flutter run --profile
```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `cached_network_image` | ^3.3.1 | Memory + disk image caching |
| `shimmer` | ^3.0.0 | Shimmer loading skeletons |
| `google_fonts` | ^6.2.1 | Pacifico font for the wordmark |
| `image_picker` | ^1.1.2 | Native camera access |

---

## Architecture Notes

### PostRepository
Returns a `Future<List<PostModel>>` with a simulated 1.5s delay on the first page and 800ms on subsequent pages. This forces the shimmer states to be clearly visible during the demo — matching the spec requirement of demonstrating loading states.

### Pinch-to-Zoom
Uses a custom `_ConditionalScaleRecognizer` that extends `ScaleGestureRecognizer`. It only calls `resolve(GestureDisposition.accepted)` — winning the gesture arena — when two or more fingers are detected. Single-finger gestures pass through transparently to the `PageView` (carousel swipe) and `CustomScrollView` (feed scroll) below it. The zoomed image renders in a root `Overlay` above the entire widget tree, so it is never clipped by parent layout constraints.

### Infinite Scroll
A `ScrollController` attached to the `CustomScrollView` checks the scroll offset on every frame. When the user is within 1000px of the bottom (approximately 2 posts away), `FeedNotifier.loadMore()` is called. The method is guarded by an `isLoadingMore` flag so concurrent requests are impossible.

### Image Loading
Every network image uses `CachedNetworkImage` with a shimmer placeholder while loading and a broken-image icon on error. The cache is shared across the app via the package's default singleton cache manager.

---

Built with Flutter 3.22+ · Riverpod 2.x · Dart 3.3+