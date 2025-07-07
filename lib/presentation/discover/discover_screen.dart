import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../wizard/wizard_screen.dart';
import 'swipe_deck_screen.dart';
import '../../data/supabase_service.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.signOut();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final giftBrief = ref.watch(giftBriefProvider);
    final giftSuggestions = ref.watch(giftSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Match'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sign_out') {
                _signOut(context, ref);
              } else if (value == 'new_search') {
                ref.read(giftBriefProvider.notifier).clearBrief();
                ref.read(giftSuggestionsProvider.notifier).clearSuggestions();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_search',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('New Search'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sign_out',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: giftBrief == null
          ? const WizardScreen()
          : giftSuggestions.when(
              data: (gifts) {
                if (gifts.isEmpty) {
                  return const Center(
                    child: Text('No gift suggestions available'),
                  );
                }
                return SwipeDeckScreen(gifts: gifts);
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Finding perfect gifts for you...'),
                  ],
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Failed to load gift suggestions'),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (giftBrief != null) {
                          ref.read(giftSuggestionsProvider.notifier)
                              .fetchGiftSuggestions(giftBrief);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 