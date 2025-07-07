import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/swipe.dart';
import '../core/env.dart';

class SupabaseService {
  static late Supabase _instance;
  static SupabaseClient get client => _instance.client;

  static Future<void> initialize() async {
    _instance = await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  }

  // Auth methods
  Future<void> signInWithEmail(String email) async {
    await client.auth.signInWithOtp(email: email);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Swipe methods
  Future<void> recordSwipe(Swipe swipe) async {
    await client.from('swipes').insert(swipe.toJson());
  }

  Future<List<Swipe>> getLikedSwipes() async {
    final response = await client
        .from('swipes')
        .select()
        .eq('action', 'like')
        .order('created_at', ascending: false);

    return response
        .map((json) => Swipe.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Swipe>> getAllSwipes() async {
    final response = await client
        .from('swipes')
        .select()
        .order('created_at', ascending: false);

    return response
        .map((json) => Swipe.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteSwipe(String swipeId) async {
    await client.from('swipes').delete().eq('id', swipeId);
  }

  Future<void> deleteSwipeByUserAndGift(String userId, String giftName) async {
    await client
        .from('swipes')
        .delete()
        .eq('user_id', userId)
        .filter('gift->>name', 'eq', giftName);
  }

  Future<void> clearAllUserSwipes(String userId) async {
    await client.from('swipes').delete().eq('user_id', userId);
  }

  Future<bool> hasUserSwipedGift(String giftName) async {
    final response = await client
        .from('swipes')
        .select()
        .eq('gift->name', giftName)
        .limit(1);

    return response.isNotEmpty;
  }
} 