import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_body.dart';
import '../../core/widgets/recipe_card.dart';
import '../recipes/domain/recipe.dart';
import '../recipes/presentation/recipe_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final byCuisine = ref.watch(recipesByCuisineProvider);

    return Scaffold(
      body: SafeArea(
        child: AsyncBody(
          value: byCuisine,
          builder: (groups) {
            final filipino = groups[Cuisine.filipino] ?? const [];
            final international =
                groups.entries.where((e) => e.key != Cuisine.filipino).toList()
                  ..sort((a, b) => a.key.label.compareTo(b.key.label));

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kain na!', style: theme.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          'What are we cooking today?',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SearchBarButton(onTap: () => context.go('/explore')),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _CuisineStrip(
                    cuisines: groups.keys.toList()
                      ..sort((a, b) => a.index.compareTo(b.index)),
                  ),
                ),
                _SectionHeader(
                  title: 'Filipino Favorites',
                  subtitle: 'Lutong bahay, from adobo to halo-halo',
                  onSeeAll: () {
                    ref
                        .read(recipeFilterProvider.notifier)
                        .setCuisine(Cuisine.filipino);
                    context.go('/explore');
                  },
                ),
                SliverToBoxAdapter(child: _Carousel(recipes: filipino)),
                for (final entry in international) ...[
                  _SectionHeader(
                    title: '${entry.key.flag} ${entry.key.label}',
                    onSeeAll: () {
                      ref
                          .read(recipeFilterProvider.notifier)
                          .setCuisine(entry.key);
                      context.go('/explore');
                    },
                  ),
                  SliverToBoxAdapter(child: _Carousel(recipes: entry.value)),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchBarButton extends StatelessWidget {
  const _SearchBarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.inputDecorationTheme.fillColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                'Search recipes or ingredients',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CuisineStrip extends ConsumerWidget {
  const _CuisineStrip({required this.cuisines});

  final List<Cuisine> cuisines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cuisines.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = cuisines[i];
          return ActionChip(
            avatar: Text(c.flag),
            label: Text(c.label),
            onPressed: () {
              ref.read(recipeFilterProvider.notifier).setCuisine(c);
              context.go('/explore');
            },
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    required this.onSeeAll,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 12),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineSmall),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See all',
                style: TextStyle(color: AppColors.chili),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recipes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => RecipeCard(recipe: recipes[i], width: 190),
      ),
    );
  }
}
