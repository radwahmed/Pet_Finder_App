import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder_app/features/pets/presentation/cubit/pets_cubit.dart';
import '../data/models/pet_model.dart';
import '../presentation/cubit/favorites_cubit.dart';

class PetCard extends StatefulWidget {
  final PetModel pet;
  final bool isFavoriteCard;
  final FavoritesCubit? favoritesCubit;
  final PetsCubit? petsCubit;
  final bool isInFavoritesScreen;

  const PetCard({
    super.key,
    required this.pet,
    this.isFavoriteCard = false,
    this.favoritesCubit,
    this.petsCubit,
    this.isInFavoritesScreen = false,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  bool isFavorite = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavoriteCard;
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final favoritesCubit = widget.favoritesCubit;
      final petsCubit = widget.petsCubit ?? context.read<PetsCubit>();

      if (widget.isInFavoritesScreen) {
        final favoriteId = int.tryParse(
          widget.pet.favoriteId?.toString() ?? '',
        );
        if (favoriteId != null && favoritesCubit != null) {
          await favoritesCubit.removeFavorite(favoriteId);
          await favoritesCubit.loadFavorites();
          petsCubit.removeFavorite(widget.pet.id);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.pet.name} removed from favorites 💔'),
              backgroundColor: Colors.redAccent,
            ),
          );
          setState(() => isFavorite = false);
        }
        return;
      }

      if (!isFavorite) {
        await petsCubit.addFavorite(widget.pet.id);
        favoritesCubit?.loadFavorites();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.pet.name} added to favorites ❤️'),
              backgroundColor: Colors.teal,
            ),
          );
        }
      } else {
        final favoriteId = int.tryParse(
          widget.pet.favoriteId?.toString() ?? '',
        );
        if (favoriteId != null && favoritesCubit != null) {
          await favoritesCubit.removeFavorite(favoriteId);
          await favoritesCubit.loadFavorites();
        }
        petsCubit.removeFavorite(widget.pet.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.pet.name} removed from favorites 💔'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }

      if (mounted) setState(() => isFavorite = !isFavorite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🖼️ الصورة
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.pet.imageUrl ??
                    'https://via.placeholder.com/80x80.png?text=Pet',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 🧩 بديل عند فشل تحميل الصورة (يمنع الخطأ في التست)
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.pets, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // 🐾 النصوص (مغلفة بـ Expanded لتفادي Overflow)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pet.name.isNotEmpty ? widget.pet.name : 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            IconButton(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFF44BDB6),
                    ),
              onPressed: isLoading ? null : () => _toggleFavorite(context),
            ),
          ],
        ),
      ),
    );
  }
}
