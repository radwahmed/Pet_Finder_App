import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder_app/core/di/dependency_injection.dart';
import 'package:pet_finder_app/core/network/dio_client.dart';
import 'package:pet_finder_app/features/pets/data/datasources/pet_remote_data_source.dart';
import 'package:pet_finder_app/features/pets/data/repositories/pet_repository.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/favorites_cubit.dart';
import 'package:pet_finder_app/features/pets/presentation/pages/favorites_page.dart';
import '../cubit/pets_cubit.dart';
import '../cubit/pets_state.dart';
import '../../widgets/pet_card.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final TextEditingController _searchController = TextEditingController();
  final favoritesCubit = FavoritesCubit(
    PetRepository(PetRemoteDataSource(DioClient())),
  )..loadFavorites();
  final petsCubit = PetsCubit(PetRepository(PetRemoteDataSource(DioClient())));

  void _onSearch() {
    final query = _searchController.text.trim();
    final cubit = context.read<PetsCubit>();

    if (query.isEmpty) {
      cubit.loadPets(); // لو فاضي رجّع كل الحيوانات
    } else {
      cubit.search(query); // ابحث بالكلمة اللي كتبها المستخدم
    }
  }

  @override
  void initState() {
    super.initState();
    // تحميل الحيوانات عند أول مرة
    context.read<PetsCubit>().loadPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 0,
              ),
              child: Row(
                children: [
                  Text(
                    'Find Your Forever Pet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'poppins',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Color(0xFF44BDB6)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                AppDependencies.getFavoritesCubit()
                                  ..loadFavorites(),
                            child: const FavoritesPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // مربع البحث
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _onSearch(),
                        onChanged: (value) {
                          // 👇 نفس المنطق بدون تعديل
                          if (value.isEmpty) {
                            context.read<PetsCubit>().loadPets();
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // زر الفلترة (Filter)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _onSearch, // نفس الوظيفة
                      icon: const Icon(Icons.send, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),

            // 🐱 Pet List
            Expanded(
              child: BlocBuilder<PetsCubit, PetsState>(
                builder: (context, state) {
                  if (state is PetsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PetsLoaded) {
                    if (state.pets.isEmpty) {
                      return const Center(child: Text('No pets found.'));
                    }
                    return ListView.builder(
                      itemCount: state.pets.length,
                      itemBuilder: (context, index) {
                        final pet = state.pets[index];
                        return PetCard(
                          pet: pet,
                          favoritesCubit: favoritesCubit,
                          petsCubit: petsCubit,
                        );
                      },
                    );
                  } else if (state is PetsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('Search for a pet!'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
