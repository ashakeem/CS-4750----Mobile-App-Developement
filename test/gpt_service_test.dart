import 'package:flutter_test/flutter_test.dart';
import 'package:gift_match/data/gpt_service.dart';
import 'package:gift_match/domain/models/gift_brief.dart';
import 'package:gift_match/domain/models/gift.dart';

void main() {
  group('GPT Service Tests', () {
    late GptService gptService;

    setUp(() {
      gptService = GptService();
    });

    test('should return mock gift suggestions', () async {
      final testBrief = GiftBrief(
        occasion: 'Birthday',
        relationship: 'Best Friend',
        ageRange: '25-35',
        interests: ['Technology', 'Gaming'],
        budget: '\$50-100',
      );

      final gifts = await gptService.getMockGiftSuggestions(testBrief);

      expect(gifts, isA<List<Gift>>());
      expect(gifts.length, greaterThan(0));
      expect(gifts.length, lessThanOrEqualTo(10));
      
      // Check that all gifts have required fields
      for (final gift in gifts) {
        expect(gift.name, isNotEmpty);
        expect(gift.pitch, isNotEmpty);
        expect(gift.price, isNotEmpty);
      }
    });

    test('should return consistent mock data', () async {
      final testBrief = GiftBrief(
        occasion: 'Christmas',
        relationship: 'Family Member',
        ageRange: '18-25',
        interests: ['Music', 'Art & Crafts'],
        budget: '\$25-50',
      );

      final gifts1 = await gptService.getMockGiftSuggestions(testBrief);
      final gifts2 = await gptService.getMockGiftSuggestions(testBrief);

      // Mock data should be consistent
      expect(gifts1.length, equals(gifts2.length));
      for (int i = 0; i < gifts1.length; i++) {
        expect(gifts1[i].name, equals(gifts2[i].name));
        expect(gifts1[i].pitch, equals(gifts2[i].pitch));
        expect(gifts1[i].price, equals(gifts2[i].price));
      }
    });

    test('should have valid gift data structure', () async {
      final testBrief = GiftBrief(
        occasion: 'Anniversary',
        relationship: 'Romantic Partner',
        ageRange: '26-35',
        interests: ['Travel', 'Photography'],
        budget: '\$100-200',
      );

      final gifts = await gptService.getMockGiftSuggestions(testBrief);

      for (final gift in gifts) {
        // Test gift properties
        expect(gift.name, isA<String>());
        expect(gift.pitch, isA<String>());
        expect(gift.price, isA<String>());
        
        // Price should contain dollar sign
        expect(gift.price, contains('\$'));
        
        // Optional fields should be nullable
        expect(gift.onlineLink, anyOf(isNull, isA<String>()));
        expect(gift.imageUrl, anyOf(isNull, isA<String>()));
      }
    });

    test('should simulate realistic delay', () async {
      final testBrief = GiftBrief(
        occasion: 'Graduation',
        relationship: 'Child',
        ageRange: 'Under 18',
        interests: ['Books & Reading'],
        budget: 'Under \$25',
      );

      final stopwatch = Stopwatch()..start();
      await gptService.getMockGiftSuggestions(testBrief);
      stopwatch.stop();

      // Should take at least 1.5 seconds (mock delay is 2 seconds)
      expect(stopwatch.elapsedMilliseconds, greaterThan(1500));
    });

    test('gift brief should generate valid prompt', () {
      final testBrief = GiftBrief(
        occasion: 'Wedding',
        relationship: 'Colleague',
        ageRange: '36-45',
        interests: ['Cooking & Food', 'Home & Garden'],
        budget: '\$50-100',
      );

      final prompt = testBrief.toPrompt();

      expect(prompt, contains('Wedding'));
      expect(prompt, contains('Colleague'));
      expect(prompt, contains('36-45'));
      expect(prompt, contains('Cooking & Food'));
      expect(prompt, contains('Home & Garden'));
      expect(prompt, contains('\$50-100'));
      expect(prompt, contains('JSON'));
      expect(prompt, contains('gifting concierge'));
    });

    test('should contain expected mock gifts', () async {
      final testBrief = GiftBrief(
        occasion: 'Just Because',
        relationship: 'Acquaintance',
        ageRange: '46-55',
        interests: ['Fashion'],
        budget: '\$200-500',
      );

      final gifts = await gptService.getMockGiftSuggestions(testBrief);

      // Check for some expected mock gifts
      final giftNames = gifts.map((g) => g.name).toList();
      
      expect(giftNames, contains('Premium Coffee Set'));
      expect(giftNames, contains('Wireless Bluetooth Headphones'));
      expect(giftNames, contains('Artisan Chocolate Box'));
    });
  });
} 