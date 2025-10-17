import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/pets_cubit.dart';
import '../cubit/favorites_cubit.dart';
import '../../widgets/pet_card.dart';
import '../../data/repositories/pet_repository.dart';
import '../../data/datasources/pet_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesCubit = FavoritesCubit(
      PetRepository(PetRemoteDataSource(DioClient())),
    )..loadFavorites();
    final petsCubit = PetsCubit(
      PetRepository(PetRemoteDataSource(DioClient())),
    );
    return BlocProvider.value(
      value: favoritesCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Favorites 😺'),
          backgroundColor: Colors.white,
        ),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return const Center(child: Text('No favorites yet.'));
              }
              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final pet = state.favorites[index];
                  return PetCard(
                    pet: pet,
                    isFavoriteCard: true,
                    petsCubit: petsCubit,
                    favoritesCubit: favoritesCubit,
                    isInFavoritesScreen: true,
                    // ✅ وضع خاص للمفضلة
                  );
                },
              );
            } else if (state is FavoritesError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Loading favorites...'));
          },
        ),
      ),
    );
  }
}
