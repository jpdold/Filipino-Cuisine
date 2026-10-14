import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/favorites/favorites_provider.dart';
import '../../features/recipes/domain/recipe.dart';
import '../theme/app_colors.dart';

/// Card used in grids and horizontal carousels.
class RecipeCard extends ConsumerWidget {
  const RecipeCard({super.key, required this.recipe, this.width});

  final Recipe recipe;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFav = ref.watch(
      favoritesProvider.select((s) => s.contains(recipe.id)),
    );

    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/recipe/${recipe.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  RecipeHero(recipe: recipe, height: 130),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteBubble(
                      isFavorite: isFav,
                      onTap: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(recipe.id),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: _Pill(
                      label: '${recipe.cuisine.flag} ${recipe.cuisine.label}',
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recipe.localName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.totalMinutes} min',
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: _difficultyColor(recipe.difficulty),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            recipe.difficulty.label,
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _difficultyColor(Difficulty d) => switch (d) {
  Difficulty.easy => AppColors.pandan,
  Difficulty.medium => AppColors.mango,
  Difficulty.hard => AppColors.chili,
};

/// Gradient hero with the dish emoji. Replaced by a photo when [Recipe.imageUrl] is set.
class RecipeHero extends StatelessWidget {
  const RecipeHero({
    super.key,
    required this.recipe,
    required this.height,
    this.emojiSize = 56,
  });

  final Recipe recipe;
  final double height;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    final colors = _gradientFor(recipe.cuisine);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: recipe.imageUrl != null
          ? Image.network(recipe.imageUrl!, fit: BoxFit.cover)
          : Center(
              child: Text(recipe.emoji, style: TextStyle(fontSize: emojiSize)),
            ),
    );
  }

  static List<Color> _gradientFor(Cuisine c) => switch (c) {
    Cuisine.filipino => const [AppColors.ube, Color(0xFF8B5FC2)],
    Cuisine.japanese => const [Color(0xFFB23A48), Color(0xFFE06B7A)],
    Cuisine.thai => const [Color(0xFF2E8B6E), Color(0xFF6BC4A1)],
    Cuisine.italian => const [Color(0xFF3F7D4F), Color(0xFFD96A4E)],
    Cuisine.mexican => const [Color(0xFFD9772B), Color(0xFFF2B85C)],
    Cuisine.indian => const [Color(0xFFC95A1E), Color(0xFFF2A93B)],
    Cuisine.korean => const [Color(0xFFA63A3A), Color(0xFFE07A5F)],
    Cuisine.american => const [Color(0xFF3B5B9E), Color(0xFF7FA3E0)],
    Cuisine.french => const [Color(0xFF4A5C8C), Color(0xFFB7C3E6)],
    Cuisine.chinese => const [Color(0xFFB8321F), Color(0xFFF0A040)],
  };
}

class _FavoriteBubble extends StatelessWidget {
  const _FavoriteBubble({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFavorite ? AppColors.chili : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
