import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:pet_finder_app/features/pets/data/datasources/pet_remote_data_source.dart';
import 'package:pet_finder_app/features/pets/data/repositories/pet_repository.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/pets_cubit.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/favorites_cubit.dart';
import 'package:pet_finder_app/core/network/dio_client.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/pets_state.dart';

// -------- MOCKS --------
class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {} // 👈 أضفنا ده

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio; // 👈 وهنا
  late PetRemoteDataSource dataSource;
  late PetRepository repository;
  late PetsCubit petsCubit;
  late FavoritesCubit favoritesCubit;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();

    // نخلي dioClient.dio يرجع mockDio بدل Dio الحقيقي
    when(() => mockDioClient.dio).thenReturn(mockDio);

    dataSource = PetRemoteDataSource(mockDioClient);
    repository = PetRepository(dataSource);
    petsCubit = PetsCubit(repository);
    favoritesCubit = FavoritesCubit(repository);
  });

  group('🐾 Integration Test: Pets & Favorites Flow', () {
    test('loadPets → loads data successfully', () async {
      final mockResponse = Response(
        data: [
          {
            'id': 'abys',
            'name': 'Abyssinian',
            'origin': 'Egypt',
            'image': {'url': 'https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg'},
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/breeds'),
      );

      when(
        () => mockDioClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer((_) async => mockResponse);

      await petsCubit.loadPets();

      expect(petsCubit.state, isA<PetsLoaded>());
      final state = petsCubit.state as PetsLoaded;
      expect(state.pets.first.name, 'Abyssinian');
    });

    test('search → returns search results', () async {
      final mockResponse = Response(
        data: [
          {
            'id': 'siam',
            'name': 'Siamese',
            'origin': 'Thailand',
            'image': {'url': 'https://cdn2.thecatapi.com/images/ai6Jps4sx.jpg'},
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/breeds/search'),
      );

      when(
        () => mockDioClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer((_) async => mockResponse);

      await petsCubit.search('siam');

      expect(petsCubit.state, isA<PetsLoaded>());
      final state = petsCubit.state as PetsLoaded;
      expect(state.pets.first.name, 'Siamese');
    });

    test('addFavorite → updates favorites', () async {
      final mockAddResponse = Response(
        data: {'message': 'SUCCESS', 'id': 123},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/favourites'),
      );

      when(
        () => mockDioClient.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => mockAddResponse);

      final id = await repository.addToFavorites('siam');
      expect(id, equals(123));
    });

    test('removeFavorite → calls delete successfully', () async {
      // mock Dio delete
      when(
        () => mockDio.delete(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/favourites/123'),
        ),
      );

      await repository.removeFavorite(123);

      verify(
        () => mockDio.delete(any(), options: any(named: 'options')),
      ).called(1);
    });
  });
}
