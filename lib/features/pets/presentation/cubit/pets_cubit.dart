import 'package:flutter_bloc/flutter_bloc.dart';
import 'pets_state.dart';
import '../../data/repositories/pet_repository.dart';
import '../../data/models/pet_model.dart'; // ← لو مش موجود ضيفيه

class PetsCubit extends Cubit<PetsState> {
  final PetRepository repository;

  PetsCubit(this.repository) : super(PetsInitial());

  List<PetModel> _pets = [];

  Future<void> loadPets() async {
    emit(PetsLoading());
    try {
      final pets = await repository.getAllPets();
      _pets = pets;
      emit(PetsLoaded(_pets));
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }

  Future<void> search(String query) async {
    emit(PetsLoading());
    try {
      final pets = await repository.searchPets(query);
      _pets = pets;
      emit(PetsLoaded(_pets));
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }

  Future<void> addFavorite(String imageId) async {
    try {
      await repository.addToFavorites(imageId);
      _updateLocalFavoriteStatus(imageId, true);
    } catch (e) {
      emit(PetsError('Failed to add favorite: $e'));
    }
  }

  Future<void> removeFavorite(String imageId) async {
    try {
      final pet = _pets.where((p) => p.id == imageId).isNotEmpty
          ? _pets.firstWhere((p) => p.id == imageId)
          : null;

      if (pet != null && pet.favoriteId != null) {
        await repository.removeFavorite(pet.favoriteId!);
      }

      _updateLocalFavoriteStatus(imageId, false);
    } catch (e) {
      emit(PetsError('Failed to remove favorite: $e'));
    }
  }

  void _updateLocalFavoriteStatus(String imageId, bool isFav) {
    final index = _pets.indexWhere((p) => p.id == imageId);
    if (index != -1) {
      _pets[index] = _pets[index].copyWith(isFavorite: isFav);
      emit(PetsLoaded(List.from(_pets)));
    }
  }
}
