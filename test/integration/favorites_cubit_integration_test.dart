import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_finder_app/features/pets/data/models/pet_model.dart';
import 'package:pet_finder_app/features/pets/data/repositories/pet_repository.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/favorites_cubit.dart';

class MockPetRepository extends Mock implements PetRepository {}

void main() {
  late MockPetRepository mockRepo;
  late FavoritesCubit favoritesCubit;

  final fakeFavorites = [
    PetModel(
      id: 'abys',
      name: 'Abyssinian',
      imageUrl: 'https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg',
      favoriteId: 1,
    ),
    PetModel(
      id: 'siam',
      name: 'Siamese',
      imageUrl: 'https://cdn2.thecatapi.com/images/ai6Jps4sx.jpg',
      favoriteId: 2,
    ),
  ];

  setUp(() {
    mockRepo = MockPetRepository();
    favoritesCubit = FavoritesCubit(mockRepo);
  });

  tearDown(() {
    favoritesCubit.close();
  });

  group('🐾 FavoritesCubit Integration Tests', () {
    test('loadFavorites emits [Loading, Loaded] with data', () async {
      when(
        () => mockRepo.getFavorites(),
      ).thenAnswer((_) async => fakeFavorites);

      expectLater(
        favoritesCubit.stream,
        emitsInOrder([isA<FavoritesLoading>(), isA<FavoritesLoaded>()]),
      );

      await favoritesCubit.loadFavorites();

      final state = favoritesCubit.state;
      expect(state, isA<FavoritesLoaded>());
      expect((state as FavoritesLoaded).favorites.length, 2);
      expect(state.favorites.first.name, 'Abyssinian');
    });

    test('addFavorite emits Loaded after successful add', () async {
      when(() => mockRepo.addToFavorites(any())).thenAnswer((_) async => 3);
      when(
        () => mockRepo.getFavorites(),
      ).thenAnswer((_) async => fakeFavorites);

      await favoritesCubit.addFavorite('siam');

      expect(favoritesCubit.state, isA<FavoritesLoaded>());
      verify(() => mockRepo.addToFavorites('siam')).called(1);
      verify(() => mockRepo.getFavorites()).called(1);
    });

    test('removeFavorite emits Loaded after delete', () async {
      when(() => mockRepo.removeFavorite(any())).thenAnswer((_) async => {});
      when(
        () => mockRepo.getFavorites(),
      ).thenAnswer((_) async => [fakeFavorites.first]);

      await favoritesCubit.removeFavorite(2);

      expect(favoritesCubit.state, isA<FavoritesLoaded>());
      final state = favoritesCubit.state as FavoritesLoaded;
      expect(state.favorites.length, 1);
      expect(state.favorites.first.name, 'Abyssinian');
    });

    test('loadFavorites emits Error when repository throws', () async {
      when(() => mockRepo.getFavorites()).thenThrow(Exception('API Error'));

      expectLater(
        favoritesCubit.stream,
        emitsInOrder([isA<FavoritesLoading>(), isA<FavoritesError>()]),
      );

      await favoritesCubit.loadFavorites();

      expect(favoritesCubit.state, isA<FavoritesError>());
    });
  });
}
