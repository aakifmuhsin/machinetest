import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/feed.dart';
import '../constants/app_colors.dart';
import 'video_player_widget.dart';

class FeedItem extends StatefulWidget {
  final Feed feed;

  const FeedItem({super.key, required this.feed});

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.cardBackground,
                backgroundImage: widget.feed.user.profilePicture.isNotEmpty
                    ? CachedNetworkImageProvider(widget.feed.user.profilePicture)
                    : null,
                child: widget.feed.user.profilePicture.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: AppColors.primaryText,
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // User name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.feed.user.name,
                      style: const TextStyle(
    fontFamily: 'Montserrat',
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(widget.feed.createdAt),
                      style: const TextStyle(
    fontFamily: 'Montserrat',
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Video player
          VideoPlayerWidget(
            videoUrl: widget.feed.videoUrl,
            thumbnailUrl: widget.feed.thumbnail,
            autoPlay: false,
            onPlayPause: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            widget.feed.description,
            style: const TextStyle(
    fontFamily: 'Montserrat',
              color: AppColors.primaryText,
              fontSize: 16,
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // See more link
          if (widget.feed.description.length > 100)
            GestureDetector(
              onTap: () {
                // TODO: Show full description
              },
              child: const Text(
                'See More',
                style: TextStyle(
    fontFamily: 'Montserrat',
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              // Like button
              _buildActionButton(
                icon: Icons.favorite_border,
                label: widget.feed.likes.toString(),
                onTap: () {
                  // TODO: Handle like
                },
              ),
              const SizedBox(width: 24),
              // Comment button
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: widget.feed.comments.toString(),
                onTap: () {
                  // TODO: Handle comment
                },
              ),
              const SizedBox(width: 24),
              // Share button
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () {
                  // TODO: Handle share
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.secondaryText,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
    fontFamily: 'Montserrat',
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

