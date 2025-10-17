import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_finder_app/features/pets/data/models/pet_model.dart';
import 'package:pet_finder_app/features/pets/data/repositories/pet_repository.dart';

import '../datasources/mock_pet_remote_data_source.dart';

void main() {
  late MockPetRemoteDataSource mockRemote;
  late PetRepository repository;

  setUp(() {
    mockRemote = MockPetRemoteDataSource();
    repository = PetRepository(mockRemote);
  });

  final samplePet = PetModel(id: '1', name: 'Cat 1', imageUrl: 'url1');

  test('getAllPets returns list from remote', () async {
    when(() => mockRemote.getAllPets()).thenAnswer((_) async => [samplePet]);

    final result = await repository.getAllPets();

    expect(result, isA<List<PetModel>>());
    expect(result.length, 1);
    verify(() => mockRemote.getAllPets()).called(1);
  });

  test('searchPets calls remote with query', () async {
    when(
      () => mockRemote.searchPets('abc'),
    ).thenAnswer((_) async => [samplePet]);

    final result = await repository.searchPets('abc');

    expect(result, isNotEmpty);
    verify(() => mockRemote.searchPets('abc')).called(1);
  });

  test('addToFavorites delegates to remote and returns id', () async {
    when(() => mockRemote.addToFavorites('img1')).thenAnswer((_) async => 999);

    final id = await repository.addToFavorites('img1');

    expect(id, 999);
    verify(() => mockRemote.addToFavorites('img1')).called(1);
  });

  test('getFavorites delegates to remote', () async {
    when(() => mockRemote.getFavorites()).thenAnswer((_) async => [samplePet]);

    final favs = await repository.getFavorites();

    expect(favs, isA<List<PetModel>>());
    verify(() => mockRemote.getFavorites()).called(1);
  });

  test('removeFavorite delegates to remote', () async {
    when(
      () => mockRemote.removeFavorite(123),
    ).thenAnswer((_) async => Future.value());

    await repository.removeFavorite(123);

    verify(() => mockRemote.removeFavorite(123)).called(1);
  });
}
