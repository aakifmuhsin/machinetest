import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/feed_item.dart';
import 'add_feeds_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      feedProvider.loadCategories();
      feedProvider.loadFeeds();
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: AppColors.primaryText,
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontFamily: 'Montserrat',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLogout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.accentRed,
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Category tabs
            _buildCategoryTabs(),
            // Feeds list
            Expanded(
              child: _buildFeedsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddFeedsScreen()),
          );
        },
        backgroundColor: AppColors.accentRed,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello Maria',
                      style: TextStyle(
    fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Welcome back to Section',
                      style: TextStyle(
    fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Profile picture
              GestureDetector(
                onTap: _showLogoutDialog,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardBackground,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        if (feedProvider.isLoading && feedProvider.categories.isEmpty) {
          return const SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
              ),
            ),
          );
        }

        // Build chips from API-provided category_dict (already mapped into Category models)
        final categories = [
          ...feedProvider.categories.map((c) => c.name),
        ];
        // Ensure required defaults are present and at front
        final Set<String> base = {'Explore', 'Trending', 'All Categories'};
        final List<String> withBase = [
          ...base,
          ...categories.where((e) => !base.contains(e)),
        ];

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: withBase.length,
            itemBuilder: (context, index) {
              final category = withBase[index];
              final isSelected = feedProvider.selectedCategory == category || 
                                (index == 0 && feedProvider.selectedCategory == null);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    feedProvider.selectCategory(index == 0 ? null : category);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accentRed : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.accentRed : AppColors.borderColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category == 'Explore')
                          const Icon(
                            Icons.explore,
                            color: AppColors.primaryText,
                            size: 16,
                          ),
                        if (category == 'Explore') const SizedBox(width: 4),
                        Text(
                          category,
                          style: TextStyle(
    fontFamily: 'Montserrat',
                            color: AppColors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeedsList() {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        if (feedProvider.isLoading && feedProvider.feeds.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
            ),
          );
        }

        if (feedProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  feedProvider.error!,
                  style: const TextStyle(
    fontFamily: 'Montserrat',
                    color: AppColors.error,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    feedProvider.loadFeeds();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredFeeds = feedProvider.filteredFeeds;

        if (filteredFeeds.isEmpty) {
          return const Center(
            child: Text(
              'No feeds available',
              style: TextStyle(
    fontFamily: 'Montserrat',
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredFeeds.length,
          itemBuilder: (context, index) {
            return FeedItem(feed: filteredFeeds[index]);
          },
        );
      },
    );
  }
}

