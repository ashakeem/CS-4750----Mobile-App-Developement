import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  // Using Unsplash's public API - no auth required for basic usage
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _accessKey = 'unsplash_demo_key'; // Demo key for testing
  
  /// Get an image URL for a gift based on its name or category
  static Future<String?> getGiftImageUrl(String giftName) async {
    try {
      // Extract keywords from gift names for better search
      final searchQuery = _extractSearchKeywords(giftName);
      
      // Use Unsplash Source API (no auth required)
      // Format: https://source.unsplash.com/featured/?{query}
      final imageUrl = 'https://source.unsplash.com/400x300/?$searchQuery';
      
      return imageUrl;
    } catch (e) {
      // Return a placeholder image if API fails
      return _getPlaceholderImage(giftName);
    }
  }
  
  /// Extract search keywords from gift names for better image matching
  static String _extractSearchKeywords(String giftName) {
    final name = giftName.toLowerCase();
    
    // Map gift names to better search terms
    if (name.contains('coffee')) return 'coffee,drink';
    if (name.contains('headphones') || name.contains('earbuds')) return 'headphones,music';
    if (name.contains('plant') || name.contains('succulent')) return 'plant,green,nature';
    if (name.contains('chocolate')) return 'chocolate,dessert';
    if (name.contains('blanket') || name.contains('throw')) return 'blanket,cozy,home';
    if (name.contains('book') || name.contains('journal')) return 'book,reading,paper';
    if (name.contains('tea')) return 'tea,drink,herbs';
    if (name.contains('candle')) return 'candle,aromatherapy';
    if (name.contains('jewelry') || name.contains('necklace') || name.contains('bracelet')) return 'jewelry,accessories';
    if (name.contains('watch')) return 'watch,time,accessory';
    if (name.contains('bag') || name.contains('purse')) return 'bag,fashion,accessory';
    if (name.contains('phone') || name.contains('tech')) return 'technology,gadget';
    if (name.contains('art') || name.contains('print')) return 'art,creative,design';
    if (name.contains('game') || name.contains('puzzle')) return 'game,entertainment,fun';
    if (name.contains('fitness') || name.contains('yoga')) return 'fitness,health,exercise';
    
    // Default: use the first word of the gift name
    final firstWord = name.split(' ').first;
    return '$firstWord,gift';
  }
  
  /// Get a placeholder image based on gift category
  static String _getPlaceholderImage(String giftName) {
    final name = giftName.toLowerCase();
    
    // Return category-based placeholder images
    if (name.contains('coffee')) return 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=300&fit=crop';
    if (name.contains('book')) return 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop';
    if (name.contains('plant')) return 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop';
    if (name.contains('chocolate')) return 'https://images.unsplash.com/photo-1511381939415-e44015466834?w=400&h=300&fit=crop';
    if (name.contains('headphones')) return 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=300&fit=crop';
    
    // Default gift image
    return 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&h=300&fit=crop';
  }
} 