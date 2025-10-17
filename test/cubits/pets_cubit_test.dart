import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_finder_app/features/pets/data/models/pet_model.dart';
import 'package:pet_finder_app/features/pets/data/repositories/pet_repository.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/pets_cubit.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/pets_state.dart';

import '../datasources/mock_pet_remote_data_source.dart';

void main() {
  late MockPetRemoteDataSource mockRemote;
  late PetRepository repository;
  late PetsCubit cubit;

  setUp(() {
    mockRemote = MockPetRemoteDataSource();
    repository = PetRepository(mockRemote);
    cubit = PetsCubit(repository);
  });

  final pet1 = PetModel(id: '1', name: 'A', imageUrl: 'u1');
  final pet2 = PetModel(id: '2', name: 'B', imageUrl: 'u2');

  blocTest<PetsCubit, PetsState>(
    'emits [Loading, Loaded] when loadPets succeeds',
    build: () {
      when(() => mockRemote.getAllPets()).thenAnswer((_) async => [pet1, pet2]);
      return cubit;
    },
    act: (c) => c.loadPets(),
    expect: () => [isA<PetsLoading>(), isA<PetsLoaded>()],
    verify: (_) => verify(() => mockRemote.getAllPets()).called(1),
  );

  blocTest<PetsCubit, PetsState>(
    'emits [Loading, Loaded] when search succeeds',
    build: () {
      when(() => mockRemote.searchPets('q')).thenAnswer((_) async => [pet1]);
      return cubit;
    },
    act: (c) => c.search('q'),
    expect: () => [isA<PetsLoading>(), isA<PetsLoaded>()],
    verify: (_) => verify(() => mockRemote.searchPets('q')).called(1),
  );

  test('addFavorite updates local status', () async {
    when(() => mockRemote.getAllPets()).thenAnswer((_) async => [pet1]);
    when(() => mockRemote.addToFavorites('1')).thenAnswer((_) async => 111);

    await cubit.loadPets();
    expect((cubit.state as PetsLoaded).pets.first.isFavorite, isFalse);

    await cubit.addFavorite('1');
    // local update sets isFavorite true
    expect((cubit.state as PetsLoaded).pets.first.isFavorite, isTrue);
  });

  test(
    'removeFavorite updates local status and calls remote remove if favoriteId exists',
    () async {
      // create pet with favoriteId
      final petWithFav = PetModel(
        id: '10',
        name: 'X',
        imageUrl: 'u',
        favoriteId: 55,
        isFavorite: true,
      );
      when(() => mockRemote.getAllPets()).thenAnswer((_) async => [petWithFav]);
      when(
        () => mockRemote.removeFavorite(55),
      ).thenAnswer((_) async => Future.value());

      await cubit.loadPets();
      expect((cubit.state as PetsLoaded).pets.first.isFavorite, isTrue);

      await cubit.removeFavorite('10');
      expect((cubit.state as PetsLoaded).pets.first.isFavorite, isFalse);
      verify(() => mockRemote.removeFavorite(55)).called(1);
    },
  );
}
