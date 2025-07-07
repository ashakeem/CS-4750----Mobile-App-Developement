import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import '../domain/models/gift.dart';
import '../domain/models/gift_brief.dart';
import '../core/env.dart';
import 'image_service.dart';
import 'product_search_service.dart';

class GptService {
  static void initialize() {
    OpenAI.apiKey = Environment.openaiApiKey;
  }

  Future<List<Gift>> getGiftSuggestions(GiftBrief brief) async {
    try {
      final completion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                brief.toPrompt(),
              ),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
        maxTokens: 2000,
        temperature: 0.7,
      );

      final content = completion.choices.first.message.content?.first.text;
      if (content == null) {
        throw Exception('No content received from OpenAI');
      }

      // Extract JSON from the response
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
      if (jsonMatch == null) {
        throw Exception('No valid JSON array found in response');
      }

      final jsonString = jsonMatch.group(0)!;
      final List<dynamic> giftsJson = json.decode(jsonString);

      return giftsJson
          .map((json) => Gift.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get gift suggestions: $e');
    }
  }

  Future<List<Gift>> getMockGiftSuggestions(GiftBrief brief) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Base gift data
    final baseGifts = [
      {
        'name': 'Premium Coffee Set',
        'pitch': 'Perfect for coffee lovers who appreciate quality beans and brewing equipment',
        'price': '\$45-65',
        'onlineLink': 'https://example.com/coffee-set',
      },
      {
        'name': 'Wireless Bluetooth Headphones',
        'pitch': 'Great for music enthusiasts and remote work professionals',
        'price': '\$80-120',
        'onlineLink': 'https://example.com/headphones',
      },
      {
        'name': 'Succulent Plant Collection',
        'pitch': 'Low-maintenance plants perfect for home decoration and plant lovers',
        'price': '\$25-40',
        'onlineLink': 'https://example.com/succulents',
      },
      {
        'name': 'Artisan Chocolate Box',
        'pitch': 'Luxury chocolates for special occasions and chocolate connoisseurs',
        'price': '\$30-50',
        'onlineLink': 'https://example.com/chocolates',
      },
      {
        'name': 'Cozy Reading Blanket',
        'pitch': 'Soft and warm blanket perfect for book lovers and cozy nights',
        'price': '\$35-55',
        'onlineLink': 'https://example.com/blanket',
      },
      {
        'name': 'Portable Phone Stand',
        'pitch': 'Convenient stand for video calls and content consumption',
        'price': '\$15-25',
        'onlineLink': 'https://example.com/phone-stand',
      },
      {
        'name': 'Gourmet Tea Sampler',
        'pitch': 'Variety pack of premium teas for tea enthusiasts',
        'price': '\$25-40',
        'onlineLink': 'https://example.com/tea-sampler',
      },
      {
        'name': 'Personalized Journal',
        'pitch': 'Custom journal for writers, planners, and reflective thinkers',
        'price': '\$20-35',
        'onlineLink': 'https://example.com/journal',
      },
 {
        'name': 'Smart Fitness Band',
        'pitch': 'Track workouts and health metrics for fitness enthusiasts',
        'price': '\$25-40',
        'onlineLink': 'https://example.com/fitness-band',
      },
      {
        'name': 'Aromatherapy Diffuser',
        'pitch': 'Creates a relaxing atmosphere with essential oils',
        'price': '\$30-45',
        'onlineLink': 'https://example.com/diffuser',
      },
      {
        'name': 'Creative Lego Set',
        'pitch': 'Fun building blocks for kids and adults alike',
        'price': '\$40-60',
        'onlineLink': 'https://example.com/lego',
      },
      {
        'name': 'Travel Scratch Map',
        'pitch': 'Scratch-off world map for avid travelers',
        'price': '\$25-35',
        'onlineLink': 'https://example.com/scratch-map',
      },
    ];

    // Add images and real product links to each gift
    final List<Gift> giftsWithImages = [];
    for (final giftData in baseGifts) {
      final imageUrl = await ImageService.getGiftImageUrl(giftData['name']!);
      final realProductLink = ProductSearchService.getAmazonSearchUrl(
        giftData['name']!, 
        giftData['price']!
      );
      
      giftsWithImages.add(Gift(
        name: giftData['name']!,
        pitch: giftData['pitch']!,
        price: giftData['price']!,
        onlineLink: realProductLink, // Now links to real Amazon search
        imageUrl: imageUrl,
      ));
    }

    return giftsWithImages;
  }
} 