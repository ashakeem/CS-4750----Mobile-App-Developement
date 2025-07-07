import 'package:flutter_test/flutter_test.dart';
import 'package:gift_match/domain/models/gift.dart';

void main() {
  group('Gift Model Tests', () {
    const testGift = Gift(
      name: 'Test Gift',
      pitch: 'Perfect for testing',
      price: '\$50',
      onlineLink: 'https://example.com',
      imageUrl: 'https://example.com/image.jpg',
    );

    test('Gift should create from valid data', () {
      expect(testGift.name, 'Test Gift');
      expect(testGift.pitch, 'Perfect for testing');
      expect(testGift.price, '\$50');
      expect(testGift.onlineLink, 'https://example.com');
      expect(testGift.imageUrl, 'https://example.com/image.jpg');
    });

    test('Gift should serialize to JSON correctly', () {
      final json = testGift.toJson();
      
      expect(json['name'], 'Test Gift');
      expect(json['pitch'], 'Perfect for testing');
      expect(json['price'], '\$50');
      expect(json['onlineLink'], 'https://example.com');
      expect(json['imageUrl'], 'https://example.com/image.jpg');
    });

    test('Gift should deserialize from JSON correctly', () {
      final json = {
        'name': 'JSON Gift',
        'pitch': 'Created from JSON',
        'price': '\$25',
        'onlineLink': 'https://json.example.com',
        'imageUrl': null,
      };

      final gift = Gift.fromJson(json);
      
      expect(gift.name, 'JSON Gift');
      expect(gift.pitch, 'Created from JSON');
      expect(gift.price, '\$25');
      expect(gift.onlineLink, 'https://json.example.com');
      expect(gift.imageUrl, null);
    });

    test('Gift equality should work correctly', () {
      const gift1 = Gift(
        name: 'Same Gift',
        pitch: 'Same pitch',
        price: '\$30',
      );

      const gift2 = Gift(
        name: 'Same Gift',
        pitch: 'Same pitch',
        price: '\$30',
      );

      const gift3 = Gift(
        name: 'Different Gift',
        pitch: 'Same pitch',
        price: '\$30',
      );

      expect(gift1, equals(gift2));
      expect(gift1, isNot(equals(gift3)));
    });

    test('Gift hashCode should be consistent', () {
      const gift1 = Gift(
        name: 'Hash Test',
        pitch: 'Test pitch',
        price: '\$40',
      );

      const gift2 = Gift(
        name: 'Hash Test',
        pitch: 'Test pitch',
        price: '\$40',
      );

      expect(gift1.hashCode, equals(gift2.hashCode));
    });

    test('Gift toString should contain key information', () {
      final giftString = testGift.toString();
      
      expect(giftString, contains('Test Gift'));
      expect(giftString, contains('Perfect for testing'));
      expect(giftString, contains('\$50'));
    });
  });
} 