import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_finder_app/features/pets/data/models/pet_model.dart';
import 'package:pet_finder_app/features/pets/data/repositories/pet_repository.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/favorites_cubit.dart';
import '../datasources/mock_pet_remote_data_source.dart';

void main() {
  late MockPetRemoteDataSource mockRemote;
  late PetRepository repository;
  late FavoritesCubit cubit;

  setUp(() {
    mockRemote = MockPetRemoteDataSource();
    repository = PetRepository(mockRemote);
    cubit = FavoritesCubit(repository);
  });

  final favPet = PetModel(id: 'fav1', name: 'Fav', imageUrl: 'u');

  blocTest<FavoritesCubit, FavoritesState>(
    'loadFavorites emits Loading then Loaded',
    build: () {
      when(() => mockRemote.getFavorites()).thenAnswer((_) async => [favPet]);
      return cubit;
    },
    act: (c) => c.loadFavorites(),
    expect: () => [isA<FavoritesLoading>(), isA<FavoritesLoaded>()],
    verify: (_) => verify(() => mockRemote.getFavorites()).called(1),
  );

  test('addFavorite calls repository and reloads', () async {
    when(() => mockRemote.addToFavorites('img')).thenAnswer((_) async => 77);
    when(() => mockRemote.getFavorites()).thenAnswer((_) async => [favPet]);

    final id = await cubit.addFavorite('img');
    expect(id, 77);
    // loadFavorites should have been called internally
    verify(() => mockRemote.getFavorites()).called(greaterThanOrEqualTo(1));
  });

  test('removeFavorite calls repository and reloads', () async {
    when(
      () => mockRemote.removeFavorite(77),
    ).thenAnswer((_) async => Future.value());
    when(() => mockRemote.getFavorites()).thenAnswer((_) async => []);

    await cubit.removeFavorite(77);
    verify(() => mockRemote.removeFavorite(77)).called(1);
    verify(() => mockRemote.getFavorites()).called(greaterThanOrEqualTo(1));
  });
}
