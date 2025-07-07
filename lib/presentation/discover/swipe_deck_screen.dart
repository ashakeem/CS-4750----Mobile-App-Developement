import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../../domain/models/gift.dart';
import '../../domain/models/swipe.dart' as domain_swipe;
import '../../data/providers.dart';
import '../widgets/gift_card.dart';
import '../home/home_screen.dart';

class SwipeDeckScreen extends ConsumerStatefulWidget {
  final List<Gift> gifts;

  const SwipeDeckScreen({
    super.key,
    required this.gifts,
  });

  @override
  ConsumerState<SwipeDeckScreen> createState() => _SwipeDeckScreenState();
}

class _SwipeDeckScreenState extends ConsumerState<SwipeDeckScreen> {
  late AppinioSwiperController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AppinioSwiperController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSwipe(domain_swipe.SwipeAction action) {
    if (_currentIndex < widget.gifts.length) {
      final gift = widget.gifts[_currentIndex];
      
      ref.read(swipeProvider.notifier).recordSwipe(gift, action);

      setState(() {
        _currentIndex++;
      });

      if (action == domain_swipe.SwipeAction.like) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white),
                const SizedBox(width: 8),
                Text('Added "${gift.name}" to saved!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      if (_currentIndex >= widget.gifts.length) {
        _showCompleteDialog();
      }
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All done! 🎉'),
        content: const Text(
          'You\'ve gone through all the gift suggestions. Check your saved gifts or start a new search!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(giftBriefProvider.notifier).clearBrief();
              ref.read(giftSuggestionsProvider.notifier).clearSuggestions();
            },
            child: const Text('New Search'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Switch to Saved tab
              final homeState = context.findAncestorStateOfType<HomeScreenState>();
              if (homeState != null) {
                homeState.goToSavedTab();
              }
            },
            child: const Text('View Saved'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gifts.isEmpty) {
      return const Center(
        child: Text('No gifts to show'),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with remaining count
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gift ${_currentIndex + 1} of ${widget.gifts.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / widget.gifts.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Swipe Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Icon(Icons.swipe_left, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      const Text('Swipe left to pass', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Swipe right to like', style: TextStyle(color: Colors.green)),
                      const SizedBox(width: 4),
                      Icon(Icons.swipe_right, color: Colors.green[400]),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Swiper with Gift Cards
            Expanded(
              child: _currentIndex >= widget.gifts.length
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'All done!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text('Check your saved gifts or start a new search'),
                        ],
                      ),
                    )
                  : AppinioSwiper(
                      controller: _controller,
                      cardCount: widget.gifts.length,
                      cardBuilder: (BuildContext context, int index) {
                        return GiftCard(gift: widget.gifts[index]);
                      },
                      onSwipeEnd: (int previousIndex, int? targetIndex, SwiperActivity activity) {
                        // Handle swipe completion based on activity type
                        if (activity is Swipe) {
                          domain_swipe.SwipeAction action;
                          // Check swipe direction using the activity's direction
                          switch (activity.direction.name) {
                            case 'right':
                              action = domain_swipe.SwipeAction.like;
                              break;
                            case 'left':
                              action = domain_swipe.SwipeAction.pass;
                              break;
                            default:
                              return; // Unknown direction, ignore
                          }
                          
                          _handleSwipe(action);
                        }
                      },
                      onEnd: () {
                        // All cards swiped
                        _showCompleteDialog();
                      },
                      // Customization options
                      maxAngle: 30,
                      threshold: 80,
                      duration: const Duration(milliseconds: 300),
                      isDisabled: false,
                    ),
            ),

            // Action Buttons (still available as backup/accessibility)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'pass',
                    onPressed: _currentIndex >= widget.gifts.length
                        ? null
                        : () {
                            _controller.swipeLeft();
                          },
                    backgroundColor: Colors.red[100],
                    icon: Icon(Icons.close, color: Colors.red[600]),
                    label: Text('Pass', style: TextStyle(color: Colors.red[600])),
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'like',
                    onPressed: _currentIndex >= widget.gifts.length
                        ? null
                        : () {
                            _controller.swipeRight();
                          },
                    backgroundColor: Colors.green[100],
                    icon: Icon(Icons.favorite, color: Colors.green[600]),
                    label: Text('Like', style: TextStyle(color: Colors.green[600])),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 