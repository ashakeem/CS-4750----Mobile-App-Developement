import 'package:flutter_test/flutter_test.dart';
import 'package:gift_match/domain/models/swipe.dart';
import 'package:gift_match/domain/models/gift.dart';

void main() {
  group('Swipe Model Tests', () {
    const testGift = Gift(
      name: 'Test Gift',
      pitch: 'Perfect for testing',
      price: '\$50',
      onlineLink: 'https://example.com',
    );

    final testDateTime = DateTime(2024, 1, 15, 10, 30);

    final testSwipe = Swipe(
      id: 'test-id-123',
      userId: 'user-123',
      gift: testGift,
      action: SwipeAction.like,
      createdAt: testDateTime,
    );

    test('Swipe should create with all properties', () {
      expect(testSwipe.id, 'test-id-123');
      expect(testSwipe.userId, 'user-123');
      expect(testSwipe.gift, testGift);
      expect(testSwipe.action, SwipeAction.like);
      expect(testSwipe.createdAt, testDateTime);
    });

    test('SwipeAction enum should have correct values', () {
      expect(SwipeAction.like.name, 'like');
      expect(SwipeAction.pass.name, 'pass');
      expect(SwipeAction.values.length, 2);
    });

    test('Swipe should serialize to JSON correctly', () {
      final json = testSwipe.toJson();
      
      expect(json['id'], 'test-id-123');
      expect(json['user_id'], 'user-123');
      expect(json['gift'], isA<Map<String, dynamic>>());
      expect(json['action'], 'like');
      expect(json['created_at'], testDateTime.toIso8601String());
    });

    test('Swipe should deserialize from JSON correctly', () {
      final json = {
        'id': 'json-swipe-456',
        'user_id': 'user-456',
        'gift': {
          'name': 'JSON Gift',
          'pitch': 'From JSON',
          'price': '\$25',
          'onlineLink': null,
          'imageUrl': null,
        },
        'action': 'pass',
        'created_at': '2024-01-20T15:45:00.000Z',
      };

      final swipe = Swipe.fromJson(json);
      
      expect(swipe.id, 'json-swipe-456');
      expect(swipe.userId, 'user-456');
      expect(swipe.gift.name, 'JSON Gift');
      expect(swipe.action, SwipeAction.pass);
      expect(swipe.createdAt, DateTime.parse('2024-01-20T15:45:00.000Z'));
    });

    test('Swipe without ID should serialize correctly', () {
      final swipeWithoutId = Swipe(
        userId: 'user-789',
        gift: testGift,
        action: SwipeAction.like,
        createdAt: testDateTime,
      );

      final json = swipeWithoutId.toJson();
      
      expect(json.containsKey('id'), false);
      expect(json['user_id'], 'user-789');
    });

    test('Swipe copyWith should work correctly', () {
      final copiedSwipe = testSwipe.copyWith(
        action: SwipeAction.pass,
        userId: 'new-user-id',
      );
      
      expect(copiedSwipe.id, testSwipe.id); // unchanged
      expect(copiedSwipe.userId, 'new-user-id'); // changed
      expect(copiedSwipe.gift, testSwipe.gift); // unchanged
      expect(copiedSwipe.action, SwipeAction.pass); // changed
      expect(copiedSwipe.createdAt, testSwipe.createdAt); // unchanged
    });

    test('Swipe equality should work correctly', () {
      final swipe1 = Swipe(
        id: 'same-id',
        userId: 'user-1',
        gift: testGift,
        action: SwipeAction.like,
        createdAt: testDateTime,
      );

      final swipe2 = Swipe(
        id: 'same-id',
        userId: 'user-1',
        gift: testGift,
        action: SwipeAction.like,
        createdAt: testDateTime,
      );

      final swipe3 = Swipe(
        id: 'different-id',
        userId: 'user-1',
        gift: testGift,
        action: SwipeAction.like,
        createdAt: testDateTime,
      );

      expect(swipe1, equals(swipe2));
      expect(swipe1, isNot(equals(swipe3)));
    });

    test('Swipe hashCode should be consistent', () {
      final swipe1 = Swipe(
        id: 'hash-test',
        userId: 'user-1',
        gift: testGift,
        action: SwipeAction.like,
        createdAt: testDateTime,
      );

      final swipe2 = Swipe(
        id: 'hash-test',
        userId: 'user-1',
        gift: testGift,
        action: SwipeAction.like,
        createdAt: testDateTime,
      );

      expect(swipe1.hashCode, equals(swipe2.hashCode));
    });

    test('Swipe toString should contain key information', () {
      final swipeString = testSwipe.toString();
      
      expect(swipeString, contains('test-id-123'));
      expect(swipeString, contains('user-123'));
      expect(swipeString, contains('like'));
      expect(swipeString, contains('Test Gift'));
    });

    test('SwipeAction should parse correctly from string', () {
      expect(
        SwipeAction.values.firstWhere((e) => e.name == 'like'),
        SwipeAction.like,
      );
      expect(
        SwipeAction.values.firstWhere((e) => e.name == 'pass'),
        SwipeAction.pass,
      );
    });
  });
} 