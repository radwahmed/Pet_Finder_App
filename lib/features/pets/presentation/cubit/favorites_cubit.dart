import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/pet_repository.dart';
import '../../data/models/pet_model.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final PetRepository repository;

  FavoritesCubit(this.repository) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: $e'));
    }
  }

  Future<int?> addFavorite(String imageId) async {
    try {
      final favoriteId = await repository.addToFavorites(imageId);
      await loadFavorites();
      return favoriteId;
    } catch (e) {
      emit(FavoritesError('Failed to add favorite: $e'));
      return null;
    }
  }

  Future<void> removeFavorite(int favoriteId) async {
    try {
      await repository.removeFavorite(favoriteId);
      await loadFavorites();
    } catch (e) {
      emit(FavoritesError('Failed to remove favorite: $e'));
    }
  }

  bool isFavorite(String imageId) {
    if (state is FavoritesLoaded) {
      return (state as FavoritesLoaded).favorites.any((p) => p.id == imageId);
    }
    return false;
  }
}
