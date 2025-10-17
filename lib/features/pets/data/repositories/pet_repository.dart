import '../datasources/pet_remote_data_source.dart';
import '../models/pet_model.dart';

class PetRepository {
  final PetRemoteDataSource remoteDataSource;

  PetRepository(this.remoteDataSource);

  Future<List<PetModel>> getAllPets() async {
    return await remoteDataSource.getAllPets();
  }

  Future<List<PetModel>> searchPets(String query) async {
    return await remoteDataSource.searchPets(query);
  }

  Future<int?> addToFavorites(String imageId) async {
    return await remoteDataSource.addToFavorites(imageId);
  }

  Future<List<PetModel>> getFavorites() => remoteDataSource.getFavorites();

  Future<void> removeFavorite(int favoriteId) =>
      remoteDataSource.removeFavorite(favoriteId);
}
