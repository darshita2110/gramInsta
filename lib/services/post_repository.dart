// services/post_repository.dart

import '../models/post_model.dart';

/// PostRepository is the single source of truth for feed data.
/// It simulates a real API with a 1.5 second latency on first load
/// and slightly shorter latency on pagination requests.
class PostRepository {
  static const Duration _initialDelay = Duration(milliseconds: 1500);
  static const Duration _paginationDelay = Duration(milliseconds: 800);
  static const int _pageSize = 10;

  // ---------------------------------------------------------------------------
  // Stories mock data
  // ---------------------------------------------------------------------------
  Future<List<StoryModel>> fetchStories() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockStories;
  }

  // ---------------------------------------------------------------------------
  // Feed mock data with pagination
  // ---------------------------------------------------------------------------
  Future<List<PostModel>> fetchFeed({
    required int page,
    int pageSize = _pageSize,
  }) async {
    // Simulate network latency
    await Future.delayed(page == 0 ? _initialDelay : _paginationDelay);

    final allPosts = _buildMockPosts();
    final start = page * pageSize;
    if (start >= allPosts.length) return [];

    final end = (start + pageSize).clamp(0, allPosts.length);
    return allPosts.sublist(start, end);
  }

  // ---------------------------------------------------------------------------
  // Mock stories
  // ---------------------------------------------------------------------------
  static final List<StoryModel> _mockStories = [
    const StoryModel(
      id: 'own',
      username: 'Your story',
      avatarUrl:
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
      isOwn: true,
    ),
    const StoryModel(
      id: 's1',
      username: 'alex.ray',
      avatarUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&q=80',
    ),
    const StoryModel(
      id: 's2',
      username: 'nikhil_dev',
      avatarUrl:
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
      isSeen: true,
    ),
    const StoryModel(
      id: 's3',
      username: 'priya.design',
      avatarUrl:
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&q=80',
    ),
    const StoryModel(
      id: 's4',
      username: 'wanderlust',
      avatarUrl:
      'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=150&q=80',
      isSeen: true,
    ),
    const StoryModel(
      id: 's5',
      username: 'foodie.finds',
      avatarUrl:
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80',
    ),
    const StoryModel(
      id: 's6',
      username: 'urban.lens',
      avatarUrl:
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150&q=80',
    ),
    const StoryModel(
      id: 's7',
      username: 'tech.talks',
      avatarUrl:
      'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&q=80',
      isSeen: true,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Mock posts — 30 total across 3 pages
  // ---------------------------------------------------------------------------
  List<PostModel> _buildMockPosts() {
    return [
      // ---- PAGE 0 ----
      PostModel(
        id: 'p1',
        user: const UserModel(
          id: 'u1',
          username: 'alex.ray',
          avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80'),
        ],
        caption:
        'Weekend escape to the Alps 🏔️ Three days of pure bliss. Nothing compares to waking up at 3,000m.',
        likeCount: 4821,
        commentCount: 132,
        timeAgo: '2 hours ago',
        location: 'Swiss Alps, Switzerland',
      ),
      PostModel(
        id: 'p2',
        user: const UserModel(
          id: 'u2',
          username: 'nikhil_dev',
          avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80'),
        ],
        caption:
        'Late night debugging sessions hitting different when the coffee is good ☕ #flutter #opensource',
        likeCount: 1203,
        commentCount: 47,
        timeAgo: '4 hours ago',
      ),
      PostModel(
        id: 'p3',
        user: const UserModel(
          id: 'u3',
          username: 'priya.design',
          avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1545235617-9465d2a55698?w=800&q=80'),
        ],
        caption:
        'New brand identity drop — six months of iteration, one final morning ✨ Client loved it.',
        likeCount: 9341,
        commentCount: 302,
        timeAgo: '5 hours ago',
        location: 'Mumbai, India',
      ),
      PostModel(
        id: 'p4',
        user: const UserModel(
          id: 'u4',
          username: 'foodie.finds',
          avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80',
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80'),
        ],
        caption:
        'Sunday brunch spread 🥞🍳 Tried five new spots this month and this one wins by a mile.',
        likeCount: 6102,
        commentCount: 218,
        timeAgo: '7 hours ago',
        location: 'Bangalore, India',
      ),
      PostModel(
        id: 'p5',
        user: const UserModel(
          id: 'u5',
          username: 'urban.lens',
          avatarUrl:
          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=800&q=80'),
        ],
        caption:
        'City lights never get old 🌆 Caught this at golden hour from the rooftop.',
        likeCount: 3499,
        commentCount: 88,
        timeAgo: '10 hours ago',
        location: 'New York, USA',
      ),
      PostModel(
        id: 'p6',
        user: const UserModel(
          id: 'u6',
          username: 'wanderlust',
          avatarUrl:
          'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800&q=80'),
        ],
        caption:
        'There is no wifi in the forest but I promise you will find a better connection 🌿',
        likeCount: 12040,
        commentCount: 450,
        timeAgo: '12 hours ago',
        location: 'Fiordland, New Zealand',
      ),
      PostModel(
        id: 'p7',
        user: const UserModel(
          id: 'u7',
          username: 'tech.talks',
          avatarUrl:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&q=80',
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&q=80'),
        ],
        caption:
        'Just finished building my custom mechanical keyboard ⌨️ Two months of research, totally worth it.',
        likeCount: 2870,
        commentCount: 97,
        timeAgo: '15 hours ago',
      ),
      PostModel(
        id: 'p8',
        user: const UserModel(
          id: 'u8',
          username: 'surf.stories',
          avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=800&q=80'),
        ],
        caption:
        'Dawn patrol pays off every single time 🌊🏄 5am alarm but look at this wave.',
        likeCount: 5621,
        commentCount: 144,
        timeAgo: '18 hours ago',
        location: 'Bali, Indonesia',
      ),
      PostModel(
        id: 'p9',
        user: const UserModel(
          id: 'u3',
          username: 'priya.design',
          avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80'),
        ],
        caption:
        'Color theory is everything 🎨 New series coming next week. Stay tuned.',
        likeCount: 7234,
        commentCount: 190,
        timeAgo: '1 day ago',
      ),
      PostModel(
        id: 'p10',
        user: const UserModel(
          id: 'u9',
          username: 'arch.collective',
          avatarUrl:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80'),
        ],
        caption:
        'Brutalism is misunderstood. These structures are raw honesty in concrete form 🏛️',
        likeCount: 8802,
        commentCount: 312,
        timeAgo: '1 day ago',
        location: 'Tokyo, Japan',
      ),

      // ---- PAGE 1 ----
      PostModel(
        id: 'p11',
        user: const UserModel(
          id: 'u10',
          username: 'moto.diaries',
          avatarUrl:
          'https://images.unsplash.com/photo-1499996860823-5214fcc65f8f?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1558618047-3c1ac1b2cd81?w=800&q=80'),
        ],
        caption:
        'Leh–Manali in 3 days. Every kilometre worth it 🏍️ The road is the destination.',
        likeCount: 4200,
        commentCount: 167,
        timeAgo: '2 days ago',
        location: 'Leh, Ladakh',
      ),
      PostModel(
        id: 'p12',
        user: const UserModel(
          id: 'u11',
          username: 'botanica.lab',
          avatarUrl:
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&q=80',
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=800&q=80'),
        ],
        caption:
        'Spring propagation haul 🌱 Over 40 new cuttings this week. My apartment is becoming a jungle.',
        likeCount: 3980,
        commentCount: 113,
        timeAgo: '2 days ago',
      ),
      PostModel(
        id: 'p13',
        user: const UserModel(
          id: 'u2',
          username: 'nikhil_dev',
          avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&q=80'),
        ],
        caption:
        'Open source contribution #100 🎉 A year of showing up every single day.',
        likeCount: 6780,
        commentCount: 241,
        timeAgo: '2 days ago',
      ),
      PostModel(
        id: 'p14',
        user: const UserModel(
          id: 'u12',
          username: 'cine.frame',
          avatarUrl:
          'https://images.unsplash.com/photo-1614289371518-722f2615943d?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800&q=80'),
        ],
        caption:
        'Shot on film 📽️ There is something irreplaceable about analog grain.',
        likeCount: 11230,
        commentCount: 389,
        timeAgo: '3 days ago',
        location: 'Los Angeles, USA',
      ),
      PostModel(
        id: 'p15',
        user: const UserModel(
          id: 'u4',
          username: 'foodie.finds',
          avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80',
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=800&q=80'),
        ],
        caption: 'Fine dining done right 🍽️ Course 7 of 12 and I am in heaven.',
        likeCount: 8440,
        commentCount: 270,
        timeAgo: '3 days ago',
        location: 'Paris, France',
      ),
      PostModel(
        id: 'p16',
        user: const UserModel(
          id: 'u13',
          username: 'minimalist.room',
          avatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80'),
        ],
        caption:
        'The bedroom renovation is finally done 🏠 Less is more, always.',
        likeCount: 4550,
        commentCount: 102,
        timeAgo: '3 days ago',
      ),
      PostModel(
        id: 'p17',
        user: const UserModel(
          id: 'u5',
          username: 'urban.lens',
          avatarUrl:
          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800&q=80'),
        ],
        caption: 'Monsoon in the city hits differently 🌧️ Pure cinema.',
        likeCount: 6890,
        commentCount: 175,
        timeAgo: '4 days ago',
        location: 'Mumbai, India',
      ),
      PostModel(
        id: 'p18',
        user: const UserModel(
          id: 'u6',
          username: 'wanderlust',
          avatarUrl:
          'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1471922694854-ff1b63b20054?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1533371452382-d45a9da51ad9?w=800&q=80'),
        ],
        caption:
        'Maldives was a dream but the Andamans just hit different 🌊 Budget paradise.',
        likeCount: 15620,
        commentCount: 560,
        timeAgo: '4 days ago',
        location: 'Andaman Islands, India',
      ),
      PostModel(
        id: 'p19',
        user: const UserModel(
          id: 'u14',
          username: 'coffee.ritual',
          avatarUrl:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80'),
        ],
        caption:
        'V60 pour-over is a meditation ☕ Slow down. The coffee can wait thirty seconds.',
        likeCount: 3210,
        commentCount: 82,
        timeAgo: '5 days ago',
      ),
      PostModel(
        id: 'p20',
        user: const UserModel(
          id: 'u9',
          username: 'arch.collective',
          avatarUrl:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?w=800&q=80'),
        ],
        caption:
        'Glass and steel, light and shadow 🏢 Modern architecture is poetry in structure.',
        likeCount: 9980,
        commentCount: 330,
        timeAgo: '5 days ago',
        location: 'Dubai, UAE',
      ),

      // ---- PAGE 2 ----
      PostModel(
        id: 'p21',
        user: const UserModel(
          id: 'u1',
          username: 'alex.ray',
          avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&q=80'),
        ],
        caption:
        'Northern lights on the last night 🌌 I cried and I am not ashamed.',
        likeCount: 22100,
        commentCount: 740,
        timeAgo: '6 days ago',
        location: 'Tromsø, Norway',
      ),
      PostModel(
        id: 'p22',
        user: const UserModel(
          id: 'u15',
          username: 'fit.formula',
          avatarUrl:
          'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80'),
        ],
        caption:
        '6am gym, cold shower, green smoothie — the holy trinity 💪 Day 180 of 365.',
        likeCount: 5430,
        commentCount: 145,
        timeAgo: '6 days ago',
      ),
      PostModel(
        id: 'p23',
        user: const UserModel(
          id: 'u11',
          username: 'botanica.lab',
          avatarUrl:
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&q=80',
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1446071103084-c257b5f70672?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1453904300235-0f2f60b15b5c?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800&q=80'),
        ],
        caption: 'Autumn walk 🍂 The colours this year are unreal.',
        likeCount: 7760,
        commentCount: 202,
        timeAgo: '1 week ago',
        location: 'Kyoto, Japan',
      ),
      PostModel(
        id: 'p24',
        user: const UserModel(
          id: 'u12',
          username: 'cine.frame',
          avatarUrl:
          'https://images.unsplash.com/photo-1614289371518-722f2615943d?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1560169897-fc0cdbdfa4d5?w=800&q=80'),
        ],
        caption:
        'Behind the scenes of our short film 🎬 60 people, 18 hours, one shot.',
        likeCount: 8920,
        commentCount: 295,
        timeAgo: '1 week ago',
      ),
      PostModel(
        id: 'p25',
        user: const UserModel(
          id: 'u10',
          username: 'moto.diaries',
          avatarUrl:
          'https://images.unsplash.com/photo-1499996860823-5214fcc65f8f?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1558981408-db0ecd8a1ee4?w=800&q=80'),
        ],
        caption:
        'Empty roads, full tank, zero plans 🛣️ This is what freedom feels like.',
        likeCount: 6340,
        commentCount: 180,
        timeAgo: '1 week ago',
        location: 'Spiti Valley, India',
      ),
      PostModel(
        id: 'p26',
        user: const UserModel(
          id: 'u8',
          username: 'surf.stories',
          avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&q=80',
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1455264745730-cb3b76250de8?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1474524955719-b9f87c50ce47?w=800&q=80'),
        ],
        caption:
        'Competition week wrap-up 🏆 Didn\'t podium but learned more than I ever have.',
        likeCount: 4890,
        commentCount: 127,
        timeAgo: '1 week ago',
        location: 'Pipeline, Hawaii',
      ),
      PostModel(
        id: 'p27',
        user: const UserModel(
          id: 'u13',
          username: 'minimalist.room',
          avatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80'),
        ],
        caption:
        'Living room complete 🛋️ The rule was simple: if it doesn\'t spark joy, it doesn\'t stay.',
        likeCount: 5120,
        commentCount: 148,
        timeAgo: '1 week ago',
      ),
      PostModel(
        id: 'p28',
        user: const UserModel(
          id: 'u14',
          username: 'coffee.ritual',
          avatarUrl:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&q=80',
        ),
        mediaType: PostMediaType.carousel,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?w=800&q=80'),
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800&q=80'),
        ],
        caption:
        'New single origin from Ethiopia 🌍 Blueberry and jasmine notes. Unreal.',
        likeCount: 2970,
        commentCount: 73,
        timeAgo: '2 weeks ago',
      ),
      PostModel(
        id: 'p29',
        user: const UserModel(
          id: 'u15',
          username: 'fit.formula',
          avatarUrl:
          'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=150&q=80',
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80'),
        ],
        caption:
        'PR on deadlift today 🏋️ 160kg. A year ago I could barely squat my own bodyweight.',
        likeCount: 7230,
        commentCount: 255,
        timeAgo: '2 weeks ago',
      ),
      PostModel(
        id: 'p30',
        user: const UserModel(
          id: 'u1',
          username: 'alex.ray',
          avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&q=80',
          isVerified: true,
        ),
        mediaType: PostMediaType.single,
        mediaItems: const [
          CarouselItem(
              imageUrl:
              'https://images.unsplash.com/photo-1502239608882-93b729c6af43?w=800&q=80'),
        ],
        caption:
        'Desert sunset — proof that the world will always be more beautiful than our problems 🌅',
        likeCount: 18700,
        commentCount: 620,
        timeAgo: '2 weeks ago',
        location: 'Sahara Desert, Morocco',
      ),
    ];
  }
}