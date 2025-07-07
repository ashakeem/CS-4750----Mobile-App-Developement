import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/gift.dart';
import '../domain/models/gift_brief.dart';
import '../domain/models/swipe.dart';
import 'gpt_service.dart';
import 'supabase_service.dart';
import 'hive_service.dart';

// Service providers
final gptServiceProvider = Provider<GptService>((ref) => GptService());
final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

// Auth providers
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.client.auth.currentUser;
});

// Gift Brief provider (for wizard state)
final giftBriefProvider = StateNotifierProvider<GiftBriefNotifier, GiftBrief?>((ref) {
  return GiftBriefNotifier();
});

class GiftBriefNotifier extends StateNotifier<GiftBrief?> {
  GiftBriefNotifier() : super(null);

  void updateBrief(GiftBrief brief) {
    state = brief;
  }

  void clearBrief() {
    state = null;
  }
}

// Gift suggestions provider
final giftSuggestionsProvider = StateNotifierProvider<GiftSuggestionsNotifier, AsyncValue<List<Gift>>>((ref) {
  return GiftSuggestionsNotifier(ref.watch(gptServiceProvider));
});

class GiftSuggestionsNotifier extends StateNotifier<AsyncValue<List<Gift>>> {
  final GptService _gptService;

  GiftSuggestionsNotifier(this._gptService) : super(const AsyncValue.data([]));

  Future<void> fetchGiftSuggestions(GiftBrief brief) async {
    state = const AsyncValue.loading();
    try {
      // Use mock data for development/testing
      final gifts = await _gptService.getMockGiftSuggestions(brief);
      state = AsyncValue.data(gifts);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  void clearSuggestions() {
    state = const AsyncValue.data([]);
  }
}

// Swipe provider
final swipeProvider = StateNotifierProvider<SwipeNotifier, AsyncValue<List<Swipe>>>((ref) {
  return SwipeNotifier(
    ref.watch(supabaseServiceProvider),
    ref.watch(hiveServiceProvider),
  );
});

class SwipeNotifier extends StateNotifier<AsyncValue<List<Swipe>>> {
  final SupabaseService _supabaseService;
  final HiveService _hiveService;

  SwipeNotifier(this._supabaseService, this._hiveService) : super(const AsyncValue.data([]));

  Future<void> recordSwipe(Gift gift, SwipeAction action) async {
    final user = SupabaseService.client.auth.currentUser;
    print('DEBUG: Recording swipe - User: $user, Gift: ${gift.name}, Action: $action');
    if (user == null) {
      print('DEBUG: No user found, skipping swipe recording');
      return;
    }

    final swipe = Swipe(
      userId: user.id,
      gift: gift,
      action: action,
      createdAt: DateTime.now(),
    );

    try {
      // Save to Supabase
      await _supabaseService.recordSwipe(swipe);
      print('DEBUG: Swipe saved to Supabase successfully');
      
      // Save to local storage if it's a like
      if (action == SwipeAction.like) {
        await _hiveService.saveLikedSwipe(swipe);
        print('DEBUG: Liked swipe saved to local storage');
      }
    } catch (error) {
      print('DEBUG: Supabase save failed: $error');
      // If Supabase fails, at least save locally
      if (action == SwipeAction.like) {
        await _hiveService.saveLikedSwipe(swipe);
        print('DEBUG: Fallback - Liked swipe saved to local storage');
      }
      // Don't rethrow error to not break user experience
    }
  }

  Future<void> loadLikedSwipes() async {
    print('DEBUG: Loading liked swipes...');
    state = const AsyncValue.loading();
    try {
      // Try to load from Supabase first
      final remoteSwipes = await _supabaseService.getLikedSwipes();
      print('DEBUG: Remote swipes loaded: ${remoteSwipes.length}');
      
      // Sync with local storage
      await _hiveService.syncWithRemote(remoteSwipes);
      
      // Get final list from local storage (in case some were only local)
      final localSwipes = await _hiveService.getSavedLikedSwipes();
      print('DEBUG: Local swipes after sync: ${localSwipes.length}');
      
      state = AsyncValue.data(localSwipes);
    } catch (error) {
      print('DEBUG: Remote load failed: $error');
      // If remote fails, fall back to local storage
      try {
        final localSwipes = await _hiveService.getSavedLikedSwipes();
        print('DEBUG: Fallback local swipes: ${localSwipes.length}');
        state = AsyncValue.data(localSwipes);
      } catch (localError) {
        print('DEBUG: Local load also failed: $localError');
        state = AsyncValue.error(localError, StackTrace.current);
      }
    }
  }

  Future<void> removeSwipe(String userId, String giftName) async {
    try {
      // Remove from local storage
      await _hiveService.removeSavedSwipe(userId, giftName);
      
      // Also try to delete from Supabase (silently fail if it doesn't work)
      try {
        await _supabaseService.deleteSwipeByUserAndGift(userId, giftName);
      } catch (e) {
        print('DEBUG: Failed to delete from Supabase, continuing: $e');
      }
      
      // Reload the list
      await loadLikedSwipes();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> clearAllSwipes() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;
    
    try {
      // Clear from local storage
      await _hiveService.clearAllSavedSwipes();
      
      // Also try to clear from Supabase (silently fail if it doesn't work)
      try {
        await _supabaseService.clearAllUserSwipes(user.id);
      } catch (e) {
        print('DEBUG: Failed to clear from Supabase, continuing: $e');
      }
      
      // Update state to empty list
      state = const AsyncValue.data([]);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
} 