import 'gift.dart';

enum SwipeAction { like, pass }

class Swipe {
  final String? id;
  final String userId;
  final Gift gift;
  final SwipeAction action;
  final DateTime createdAt;

  const Swipe({
    this.id,
    required this.userId,
    required this.gift,
    required this.action,
    required this.createdAt,
  });

  factory Swipe.fromJson(Map<String, dynamic> json) {
    return Swipe(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      gift: Gift.fromJson(json['gift'] as Map<String, dynamic>),
      action: SwipeAction.values.firstWhere(
        (e) => e.name == json['action'],
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'gift': gift.toJson(),
      'action': action.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Swipe copyWith({
    String? id,
    String? userId,
    Gift? gift,
    SwipeAction? action,
    DateTime? createdAt,
  }) {
    return Swipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gift: gift ?? this.gift,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Swipe &&
        other.id == id &&
        other.userId == userId &&
        other.gift == gift &&
        other.action == action &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, gift, action, createdAt);
  }

  @override
  String toString() {
    return 'Swipe(id: $id, userId: $userId, gift: $gift, action: $action, createdAt: $createdAt)';
  }
} 