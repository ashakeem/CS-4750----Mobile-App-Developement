import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/swipe.dart';
import '../../data/providers.dart';
import '../../data/supabase_service.dart';
import '../widgets/gift_details_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved swipes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      print('DEBUG: Current user in SavedScreen: $user');
      ref.read(swipeProvider.notifier).loadLikedSwipes();
    });
  }

  Future<void> _shareGift(Swipe swipe) async {
    final gift = swipe.gift;
    final shareText = '''
🎁 ${gift.name}

${gift.pitch}

💰 ${gift.price}

${gift.onlineLink ?? 'Find it online or at your favorite store!'}

Shared from Gift Match - Find the perfect gifts!
''';

    try {
      await Share.share(shareText, subject: 'Gift Idea: ${gift.name}');
      _showTopToast('Share sheet opened', backgroundColor: Theme.of(context).primaryColor);
    } catch (error) {
      if (mounted) {
        _showTopToast('Failed to share: $error', backgroundColor: Colors.red);
      }
    }
  }

  Future<void> _removeFromSaved(Swipe swipe) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(swipeProvider.notifier).removeSwipe(user.id, swipe.gift.name);
      
      if (mounted) {
        _showTopToast('Removed "${swipe.gift.name}"', backgroundColor: Colors.orange);
      }
    }
  }

  void _showTopToast(String message, {Color backgroundColor = Colors.black87}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2)).then((_) => overlayEntry.remove());
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showTopToast('Could not open link', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final swipesAsyncValue = ref.watch(swipeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved ❤️'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'refresh') {
                ref.read(swipeProvider.notifier).loadLikedSwipes();
              } else if (value == 'clear_all') {
                _showClearAllDialog();
              } else if (value == 'new_search') {
                ref.read(giftBriefProvider.notifier).clearBrief();
                ref.read(giftSuggestionsProvider.notifier).clearSuggestions();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Start a new search from Discover tab')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'new_search',
                child: Row(
                  children: [
                    Icon(Icons.explore),
                    SizedBox(width: 8),
                    Text('New Search'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: swipesAsyncValue.when(
        data: (swipes) {
          if (swipes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No saved gifts yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Swipe right on gifts you like to save them here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(swipeProvider.notifier).loadLikedSwipes();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: swipes.length,
              itemBuilder: (context, index) {
                final swipe = swipes[index];
                return _buildGiftCard(swipe);
              },
            ),
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading saved gifts...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load saved gifts'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(swipeProvider.notifier).loadLikedSwipes();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGiftCard(Swipe swipe) {
    final gift = swipe.gift;
    
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => GiftDetailsDialog(gift: gift),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gift Image and Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gift Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: gift.imageUrl != null
                          ? Image.network(
                              gift.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    Icons.card_giftcard,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.card_giftcard,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gift.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gift.price,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'share') {
                        _shareGift(swipe);
                      } else if (value == 'remove') {
                        _removeFromSaved(swipe);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Remove', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Gift Description
              Text(
                gift.pitch,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              if (gift.onlineLink != null) ...[
                const SizedBox(height: 12),
                // Online Link Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (gift.onlineLink != null) {
                        _openLink(gift.onlineLink!);
                      }
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('View Online'),
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Saved Date
              Text(
                'Saved ${_formatDate(swipe.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
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

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Saved Gifts?'),
        content: const Text(
          'This will remove all your saved gifts. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(swipeProvider.notifier).clearAllSwipes();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All saved gifts cleared'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
} 