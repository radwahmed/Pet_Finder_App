import 'package:flutter_test/flutter_test.dart';
import 'package:pet_finder_app/features/pets/data/models/pet_model.dart';

void main() {
  group('PetModel.fromJson', () {
    test('parses breed JSON with image correctly', () {
      final json = {
        "id": "abys",
        "name": "Abyssinian",
        "origin": "Ethiopia",
        "image": {"url": "https://example.com/abys.jpg"},
      };

      final pet = PetModel.fromJson(json);

      expect(pet.id, 'abys');
      expect(pet.name, 'Abyssinian');
      expect(pet.origin, 'Ethiopia');
      expect(pet.imageUrl, 'https://example.com/abys.jpg');
      expect(pet.favoriteId, isNull);
      expect(pet.isFavorite, isFalse);
    });

    test('parses favorite JSON correctly (with image map)', () {
      final json = {
        "id": 1234,
        "image_id": "abcd",
        "image": {"url": "https://example.com/abcd.jpg"},
      };

      final pet = PetModel.fromJson(json);

      expect(pet.id, 'abcd');
      expect(pet.favoriteId, 1234);
      expect(pet.imageUrl, 'https://example.com/abcd.jpg');
    });

    test(
      'parses favorite JSON without image map (builds url from image_id)',
      () {
        final json = {"id": 4321, "image_id": "wxyz"};

        final pet = PetModel.fromJson(json);

        expect(pet.id, 'wxyz');
        expect(pet.favoriteId, 4321);
        expect(pet.imageUrl, 'https://cdn2.thecatapi.com/images/wxyz.jpg');
      },
    );

    test('handles null json gracefully', () {
      final pet = PetModel.fromJson(null);

      expect(pet.id, isNotNull);
      expect(pet.name, isNotEmpty);
      expect(pet.imageUrl, isNotNull);
    });
  });
}
