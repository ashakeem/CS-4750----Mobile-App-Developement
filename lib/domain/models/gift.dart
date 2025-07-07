class Gift {
  final String name;
  final String pitch;
  final String price;
  final String? onlineLink;
  final String? imageUrl;

  const Gift({
    required this.name,
    required this.pitch,
    required this.price,
    this.onlineLink,
    this.imageUrl,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      name: json['name'] as String,
      pitch: json['pitch'] as String,
      price: json['price'] as String,
      onlineLink: json['onlineLink'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pitch': pitch,
      'price': price,
      'onlineLink': onlineLink,
      'imageUrl': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gift &&
        other.name == name &&
        other.pitch == pitch &&
        other.price == price &&
        other.onlineLink == onlineLink &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(name, pitch, price, onlineLink, imageUrl);
  }

  @override
  String toString() {
    return 'Gift(name: $name, pitch: $pitch, price: $price, onlineLink: $onlineLink, imageUrl: $imageUrl)';
  }
} 