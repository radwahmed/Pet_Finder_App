import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/pet_model.dart';

class PetRemoteDataSource {
  final DioClient dioClient;

  PetRemoteDataSource(this.dioClient);

  Future<List<PetModel>> getAllPets() async {
    final Response response = await dioClient.get(ApiConstants.breeds);
    return (response.data as List)
        .map((json) => PetModel.fromJson(json))
        .toList();
  }

  Future<List<PetModel>> searchPets(String query) async {
    final Response response = await dioClient.get(
      ApiConstants.breedsSearch,
      queryParams: {ApiConstants.queryParam: query},
    );
    return (response.data as List)
        .map((json) => PetModel.fromJson(json))
        .toList();
  }

  Future<int?> addToFavorites(String imageId) async {
    try {
      final response = await dioClient.post(
        ApiConstants.favorites,
        data: {'image_id': imageId},
      );

      // ✅ API بيرجع {"message":"SUCCESS","id":123456}
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['id'] as int?;
      }
    } catch (e) {
      print('❌ Error adding favorite: $e');
    }
    return null;
  }

  Future<List<PetModel>> getFavorites() async {
    try {
      final response = await dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.favorites}',
        options: Options(
          headers: {ApiConstants.apiKeyHeader: ApiConstants.apiKey},
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        final safeData = data.whereType<Map<String, dynamic>>().toList();
        return safeData.map((json) => PetModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e, s) {
      print('❌ Error in getFavorites: $e');
      print(s);
      return [];
    }
  }

  Future<void> removeFavorite(int favoriteId) async {
    try {
      await dioClient.dio.delete(
        '${ApiConstants.baseUrl}${ApiConstants.favorites}/$favoriteId',
        options: Options(
          headers: {ApiConstants.apiKeyHeader: ApiConstants.apiKey},
        ),
      );
      print('✅ Removed favorite $favoriteId');
    } catch (e) {
      print('❌ Error removing favorite: $e');
      rethrow;
    }
  }
}
