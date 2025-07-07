import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/gift.dart';

class ProductSearchService {
  
  /// Generate real product search links for gifts
  static String getAmazonSearchUrl(String productName, String priceRange) {
    // Clean up the product name for search
    final searchQuery = Uri.encodeComponent(productName.toLowerCase());
    
    // Extract price range for filtering
    final priceFilter = _extractPriceFilter(priceRange);
    
    return 'https://www.amazon.com/s?k=$searchQuery$priceFilter&ref=giftmatch_app';
  }
  
  /// Generate Google Shopping search URL
  static String getGoogleShoppingUrl(String productName) {
    final searchQuery = Uri.encodeComponent(productName);
    return 'https://shopping.google.com/search?q=$searchQuery&source=giftmatch';
  }
  
  /// Generate eBay search URL  
  static String getEbaySearchUrl(String productName) {
    final searchQuery = Uri.encodeComponent(productName);
    return 'https://www.ebay.com/sch/i.html?_nkw=$searchQuery&_sacat=0&_from=giftmatch';
  }
  
  /// Generate Etsy search URL (great for unique/handmade gifts)
  static String getEtsySearchUrl(String productName) {
    final searchQuery = Uri.encodeComponent(productName);
    return 'https://www.etsy.com/search?q=$searchQuery&ref=giftmatch_app';
  }
  
  /// Get multiple shopping options for a gift
  static Map<String, String> getAllShoppingLinks(String productName, String priceRange) {
    return {
      'Amazon': getAmazonSearchUrl(productName, priceRange),
      'Google Shopping': getGoogleShoppingUrl(productName),
      'eBay': getEbaySearchUrl(productName),
      'Etsy': getEtsySearchUrl(productName),
    };
  }
  
  /// Extract price filter for Amazon URL
  static String _extractPriceFilter(String priceRange) {
    try {
      // Parse price range like "$25-40" or "$45-65"
      final regex = RegExp(r'\$(\d+)-(\d+)');
      final match = regex.firstMatch(priceRange);
      
      if (match != null) {
        final minPrice = match.group(1);
        final maxPrice = match.group(2);
        return '&rh=p_36:${minPrice}00-${maxPrice}00'; // Amazon price format (cents)
      }
    } catch (e) {
      // If parsing fails, return empty filter
    }
    return '';
  }
  
  /// Get specific product recommendations with real links
  static List<Map<String, String>> getSpecificProductRecommendations(String giftName) {
    final name = giftName.toLowerCase();
    
    // Return specific product recommendations based on gift type
    if (name.contains('coffee')) {
      return [
        {
          'name': 'Keurig K-Mini Coffee Maker',
          'price': '\$79.99',
          'link': 'https://www.amazon.com/dp/B0C2Z6XQCF',
          'store': 'Amazon'
        },
        {
          'name': 'French Press Coffee Maker',
          'price': '\$25-35',
          'link': 'https://www.amazon.com/s?k=french+press+coffee+maker',
          'store': 'Amazon'
        },
      ];
    }
    
    if (name.contains('headphones')) {
      return [
        {
          'name': 'Sony WH-CH720N Wireless Headphones',
          'price': '\$89.99',
          'link': 'https://www.amazon.com/dp/B0BTNRWNTB',
          'store': 'Amazon'
        },
        {
          'name': 'Apple AirPods Pro (2nd Gen)',
          'price': '\$249.00',
          'link': 'https://www.amazon.com/dp/B0BDHWDR12',
          'store': 'Amazon'
        },
      ];
    }
    
    if (name.contains('plant') || name.contains('succulent')) {
      return [
        {
          'name': 'Succulent Plant Pack (12 Pack)',
          'price': '\$35.99',
          'link': 'https://www.amazon.com/dp/B07D84L3B6',
          'store': 'Amazon'
        },
        {
          'name': 'Live Pothos Plant',
          'price': '\$16.99',
          'link': 'https://www.amazon.com/dp/B08F7JXBY4',
          'store': 'Amazon'
        },
      ];
    }
    
    if (name.contains('chocolate')) {
      return [
        {
          'name': 'Godiva Chocolatier Assorted Chocolate Gift Box',
          'price': '\$19.95',
          'link': 'https://www.amazon.com/dp/B001RXQH6S',
          'store': 'Amazon'
        },
        {
          'name': 'Lindt Assorted Chocolate Truffles',
          'price': '\$12.99',
          'link': 'https://www.amazon.com/dp/B00I4WW7Q8',
          'store': 'Amazon'
        },
      ];
    }
    
    // Default: return search links
    return [
      {
        'name': 'Search on Amazon',
        'price': 'Various prices',
        'link': getAmazonSearchUrl(giftName, ''),
        'store': 'Amazon'
      },
      {
        'name': 'Search on Google Shopping',
        'price': 'Compare prices',
        'link': getGoogleShoppingUrl(giftName),
        'store': 'Google Shopping'
      },
    ];
  }
}

/// Enhanced Gift model with actual product links
class RealGift extends Gift {
  final List<Map<String, String>> productOptions;
  final Map<String, String> shoppingLinks;
  
  const RealGift({
    required super.name,
    required super.pitch,
    required super.price,
    super.onlineLink,
    super.imageUrl,
    this.productOptions = const [],
    this.shoppingLinks = const {},
  });
  
  factory RealGift.fromGift(Gift gift) {
    final productOptions = ProductSearchService.getSpecificProductRecommendations(gift.name);
    final shoppingLinks = ProductSearchService.getAllShoppingLinks(gift.name, gift.price);
    
    return RealGift(
      name: gift.name,
      pitch: gift.pitch,
      price: gift.price,
      onlineLink: shoppingLinks['Amazon'], // Default to Amazon
      imageUrl: gift.imageUrl,
      productOptions: productOptions,
      shoppingLinks: shoppingLinks,
    );
  }
} 