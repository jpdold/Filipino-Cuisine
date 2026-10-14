import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../../../favorites/favorites_provider.dart';
import '../../../shopping_list/shopping_list_provider.dart';
import '../../domain/recipe.dart';
import '../recipe_providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(recipeByIdProvider(recipeId));

    return Scaffold(
      body: AsyncBody(
        value: recipe,
        builder: (r) {
          if (r == null) {
            return const EmptyState(
              emoji: '🤷',
              title: 'Recipe not found',
              message: 'This recipe may have been removed.',
            );
          }
          return _RecipeDetail(recipe: r);
        },
      ),
    );
  }
}

class _RecipeDetail extends ConsumerWidget {
  const _RecipeDetail({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFav = ref.watch(
      favoritesProvider.select((s) => s.contains(recipe.id)),
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: theme.colorScheme.surface,
          leading: _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            _CircleButton(
              icon: isFav
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFav ? AppColors.chili : null,
              onTap: () =>
                  ref.read(favoritesProvider.notifier).toggle(recipe.id),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: RecipeHero(recipe: recipe, height: 280, emojiSize: 110),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${recipe.cuisine.flag} ${recipe.cuisine.label} · ${recipe.category.label}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(recipe.name, style: theme.textTheme.headlineMedium),
                if (recipe.localName != recipe.name)
                  Text(
                    recipe.localName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(recipe.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Stat(
                      icon: Icons.schedule_rounded,
                      label: 'Prep',
                      value: '${recipe.prepMinutes} min',
                    ),
                    _Stat(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Cook',
                      value: '${recipe.cookMinutes} min',
                    ),
                    _Stat(
                      icon: Icons.people_alt_rounded,
                      label: 'Serves',
                      value: '${recipe.servings}',
                    ),
                    _Stat(
                      icon: Icons.signal_cellular_alt_rounded,
                      label: 'Level',
                      value: recipe.difficulty.label,
                    ),
                  ],
                ),
                if (recipe.tags.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in recipe.tags) Chip(label: Text(t)),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ingredients',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final added = await ref
                            .read(shoppingListProvider.notifier)
                            .addRecipe(recipe);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              added == 0
                                  ? 'Already on your shopping list'
                                  : 'Added $added item${added == 1 ? '' : 's'} to your shopping list',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 18,
                      ),
                      label: const Text('Add all'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        for (final ing in recipe.ingredients)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.circle,
                              size: 8,
                              color: AppColors.mango,
                            ),
                            title: Text(ing.name),
                            subtitle: ing.note != null ? Text(ing.note!) : null,
                            trailing: Text(
                              ing.quantity,
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Method', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                for (var i = 0; i < recipe.steps.length; i++)
                  _Step(number: i + 1, text: recipe.steps[i]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color ?? AppColors.ink, size: 22),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleSmall),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              '$number',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(text, style: theme.textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
