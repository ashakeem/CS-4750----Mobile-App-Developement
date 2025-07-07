import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/swipe.dart';
import '../domain/models/gift.dart';

class HiveService {
  static const String savedSwipesBoxName = 'saved_swipes';
  static late Box<String> _savedSwipesBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    _savedSwipesBox = await Hive.openBox<String>(savedSwipesBoxName);
  }

  // Save a liked swipe locally
  Future<void> saveLikedSwipe(Swipe swipe) async {
    if (swipe.action == SwipeAction.like) {
      final key = '${swipe.userId}_${swipe.gift.name}';
      final jsonString = json.encode(swipe.toJson());
      await _savedSwipesBox.put(key, jsonString);
    }
  }

  // Get all locally saved liked swipes
  Future<List<Swipe>> getSavedLikedSwipes() async {
    final List<Swipe> swipes = [];
    
    for (final key in _savedSwipesBox.keys) {
      final jsonString = _savedSwipesBox.get(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final swipe = Swipe.fromJson(json);
          if (swipe.action == SwipeAction.like) {
            swipes.add(swipe);
          }
        } catch (e) {
          // Remove corrupted data
          await _savedSwipesBox.delete(key);
        }
      }
    }
    
    // Sort by creation date (newest first)
    swipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return swipes;
  }

  // Remove a saved swipe
  Future<void> removeSavedSwipe(String userId, String giftName) async {
    final key = '${userId}_$giftName';
    await _savedSwipesBox.delete(key);
  }

  // Clear all saved swipes
  Future<void> clearAllSavedSwipes() async {
    await _savedSwipesBox.clear();
  }

  // Check if a gift is already saved locally
  bool isGiftSaved(String userId, String giftName) {
    final key = '${userId}_$giftName';
    return _savedSwipesBox.containsKey(key);
  }

  // Sync with remote (merge local and remote data)
  Future<void> syncWithRemote(List<Swipe> remoteSwipes) async {
    for (final remoteSwipe in remoteSwipes) {
      if (remoteSwipe.action == SwipeAction.like) {
        await saveLikedSwipe(remoteSwipe);
      }
    }
  }

  // Get saved swipes count
  int getSavedSwipesCount() {
    return _savedSwipesBox.length;
  }
} 