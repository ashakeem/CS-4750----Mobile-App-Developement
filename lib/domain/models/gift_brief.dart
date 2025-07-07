class GiftBrief {
  final String occasion;
  final String relationship;
  final String ageRange;
  final List<String> interests;
  final String budget;

  const GiftBrief({
    required this.occasion,
    required this.relationship,
    required this.ageRange,
    required this.interests,
    required this.budget,
  });

  factory GiftBrief.fromJson(Map<String, dynamic> json) {
    return GiftBrief(
      occasion: json['occasion'] as String,
      relationship: json['relationship'] as String,
      ageRange: json['ageRange'] as String,
      interests: List<String>.from(json['interests'] as List),
      budget: json['budget'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'occasion': occasion,
      'relationship': relationship,
      'ageRange': ageRange,
      'interests': interests,
      'budget': budget,
    };
  }

  String toPrompt() {
    return '''
You are a gifting concierge. Given the following gift brief, return a JSON list of gift suggestions.

Occasion: $occasion
Relationship: $relationship
Age Range: $ageRange
Interests: ${interests.join(', ')}
Budget: $budget

Please return a JSON array of 8-10 gift suggestions with the following structure:
[
  {
    "name": "Gift Name",
    "pitch": "Why this gift is perfect for them",
    "price": "Price range or estimate",
    "onlineLink": "Where to buy (optional)"
  }
]

Focus on thoughtful, personalized gifts that match their interests and the occasion. Consider the budget and relationship when making suggestions.
''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GiftBrief &&
        other.occasion == occasion &&
        other.relationship == relationship &&
        other.ageRange == ageRange &&
        listEquals(other.interests, interests) &&
        other.budget == budget;
  }

  @override
  int get hashCode {
    return Object.hash(
      occasion,
      relationship,
      ageRange,
      interests,
      budget,
    );
  }
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
} 