class PetModel {
  final String id; // image_id أو breed id
  final String name;
  final String? origin;
  final String? imageUrl;
  final int? favoriteId; // ✅ المعرف الحقيقي للمفضلة من API
  final bool isFavorite; // ✅ خاصية جديدة
  PetModel({
    required this.id,
    required this.name,
    this.origin,
    this.imageUrl,
    this.favoriteId,
    this.isFavorite = false, // القيمة الافتراضية false
  });

  factory PetModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PetModel(
        id: '0',
        name: 'Unknown',
        origin: '',
        imageUrl: _defaultImage,
        isFavorite: false,
      );
    }

    try {
      // ✅ في حالة breeds أو search
      if (json.containsKey('name')) {
        final imageData = json['image'];
        final imageUrl = (imageData is Map && imageData['url'] != null)
            ? imageData['url'] as String
            : _defaultImage;

        return PetModel(
          id: json['id']?.toString() ?? '',
          name: json['name'] ?? 'Unknown',
          origin: json['origin'] ?? '',
          imageUrl: imageUrl,
        );
      }

      // ✅ في حالة favorites
      if (json.containsKey('image_id')) {
        final imageId = json['image_id']?.toString() ?? '';
        final imageData = json['image'];
        String finalImageUrl = _defaultImage;

        if (imageData is Map && imageData['url'] != null) {
          finalImageUrl = imageData['url'];
        } else if (imageId.isNotEmpty) {
          finalImageUrl = 'https://cdn2.thecatapi.com/images/$imageId.jpg';
        }

        return PetModel(
          id: imageId,
          name: json['image_id'] ?? 'Favorite Cat 😺',
          origin: '',
          imageUrl: finalImageUrl,
          favoriteId: json['id'], // ✅ نخزن favoriteId من API
        );
      }

      // fallback
      return PetModel(
        id: '0',
        name: 'Unknown',
        origin: '',
        imageUrl: _defaultImage,
      );
    } catch (e) {
      return PetModel(
        id: '0',
        name: 'Error Cat 😿',
        origin: '',
        imageUrl: _defaultImage,
      );
    }
  }

  static const _defaultImage =
      'https://cdn-icons-png.flaticon.com/512/616/616408.png';

  PetModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? favoriteId,
    bool? isFavorite,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      favoriteId: favoriteId ?? this.favoriteId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
