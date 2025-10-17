import 'package:pet_finder_app/features/pets/presentation/cubit/favorites_cubit.dart';

import '../network/dio_client.dart';
import '../../features/pets/data/datasources/pet_remote_data_source.dart';
import '../../features/pets/data/repositories/pet_repository.dart';
import '../../features/pets/presentation/cubit/pets_cubit.dart';

class AppDependencies {
  static late DioClient dioClient;
  static late PetRemoteDataSource petRemoteDataSource;
  static late PetRepository petRepository;

  static void init() {
    // Initialize Dio
    dioClient = DioClient();

    // Initialize Data Source
    petRemoteDataSource = PetRemoteDataSource(dioClient);

    // Initialize Repository
    petRepository = PetRepository(petRemoteDataSource);
  }

  static PetsCubit getPetsCubit() => PetsCubit(petRepository);

  static FavoritesCubit getFavoritesCubit() => FavoritesCubit(petRepository);
}
