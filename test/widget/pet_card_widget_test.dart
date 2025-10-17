import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/favorites_cubit.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/pets_cubit.dart';
import 'package:pet_finder_app/features/pets/data/models/pet_model.dart';
import 'package:pet_finder_app/features/pets/widgets/pet_card.dart';
import 'package:mockito/annotations.dart';
import 'pet_card_widget_test.mocks.dart';

// ✅ توليد mocks تلقائيًا بـ build_runner
@GenerateMocks([FavoritesCubit, PetsCubit])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFavoritesCubit mockFavoritesCubit;
  late MockPetsCubit mockPetsCubit;
  late PetModel mockPet;

  setUp(() {
    mockFavoritesCubit = MockFavoritesCubit();
    mockPetsCubit = MockPetsCubit();

    mockPet = PetModel(
      id: '1',
      name: 'Luna',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/616/616408.png',
      isFavorite: true,
      favoriteId: 99,
    );
  });

  Widget createWidgetUnderTest({
    required bool isFavoriteCard,
    bool isInFavoritesScreen = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<FavoritesCubit>.value(value: mockFavoritesCubit),
            BlocProvider<PetsCubit>.value(value: mockPetsCubit),
          ],
          child: PetCard(
            pet: mockPet,
            isFavoriteCard: isFavoriteCard,
            favoritesCubit: mockFavoritesCubit,
            petsCubit: mockPetsCubit,
            isInFavoritesScreen: isInFavoritesScreen,
          ),
        ),
      ),
    );
  }

  group('🩷 PetCard Widget Tests', () {
    testWidgets('يعرض اسم الحيوان والصورة بشكل صحيح', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isFavoriteCard: false));

      expect(find.text('Luna'), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // ✅ ممكن تكون أكتر من صورة
    });

    testWidgets('يعرض أيقونة القلب الفارغ لما مش Favorite', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isFavoriteCard: false));
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('يعرض أيقونة القلب الممتلئ لما يكون Favorite', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isFavoriteCard: true));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('عند الضغط على القلب يستدعي addFavorite لما مش Favorite', (
      tester,
    ) async {
      when(
        mockPetsCubit.addFavorite('1'),
      ).thenAnswer((_) async => Future.value());
      when(
        mockFavoritesCubit.loadFavorites(),
      ).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createWidgetUnderTest(isFavoriteCard: false));

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      verify(mockPetsCubit.addFavorite('1')).called(1);
      verify(mockFavoritesCubit.loadFavorites()).called(1);
    });

    testWidgets('عند الضغط على القلب في صفحة المفضلة يستدعي removeFavorite', (
      tester,
    ) async {
      when(
        mockFavoritesCubit.removeFavorite(99),
      ).thenAnswer((_) async => Future.value());
      when(
        mockFavoritesCubit.loadFavorites(),
      ).thenAnswer((_) async => Future.value());
      when(
        mockPetsCubit.removeFavorite('1'),
      ).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        createWidgetUnderTest(isFavoriteCard: true, isInFavoritesScreen: true),
      );

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      verify(mockFavoritesCubit.removeFavorite(99)).called(1);
      verify(mockFavoritesCubit.loadFavorites()).called(1);
      verify(mockPetsCubit.removeFavorite('1')).called(1);
    });
  });
}
