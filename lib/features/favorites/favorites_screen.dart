import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_body.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/recipe_card.dart';
import 'favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: AsyncBody(
        value: favorites,
        builder: (recipes) {
          if (recipes.isEmpty) {
            return EmptyState(
              emoji: '❤️',
              title: 'No favorites yet',
              message: 'Tap the heart on any recipe to save it here.',
              action: FilledButton(
                onPressed: () => context.go('/explore'),
                child: const Text('Explore recipes'),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 232,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: recipes.length,
            itemBuilder: (_, i) => RecipeCard(recipe: recipes[i]),
          );
        },
      ),
    );
  }
}
