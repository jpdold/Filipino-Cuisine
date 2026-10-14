import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../../domain/recipe.dart';
import '../recipe_providers.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(recipeFilterProvider).query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(recipeFilterProvider);
    final notifier = ref.read(recipeFilterProvider.notifier);
    final results = ref.watch(filteredRecipesProvider);

    // Keep the text field in sync when the query is changed elsewhere (e.g. cleared).
    if (_controller.text != filter.query) {
      _controller.value = TextEditingValue(
        text: filter.query,
        selection: TextSelection.collapsed(offset: filter.query.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          if (!filter.isEmpty)
            TextButton.icon(
              onPressed: notifier.clear,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _controller,
              onChanged: notifier.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search recipes or ingredients',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => notifier.setQuery(''),
                      ),
              ),
            ),
          ),
          _FilterRow<Cuisine>(
            values: Cuisine.values,
            selected: filter.cuisine,
            label: (c) => '${c.flag} ${c.label}',
            onSelected: notifier.setCuisine,
          ),
          const SizedBox(height: 8),
          _FilterRow<MealCategory>(
            values: MealCategory.values,
            selected: filter.category,
            label: (c) => c.label,
            onSelected: notifier.setCategory,
          ),
          const SizedBox(height: 8),
          _FilterRow<Difficulty>(
            values: Difficulty.values,
            selected: filter.difficulty,
            label: (d) => d.label,
            onSelected: notifier.setDifficulty,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AsyncBody(
              value: results,
              builder: (recipes) {
                if (recipes.isEmpty) {
                  return EmptyState(
                    emoji: '🔍',
                    title: 'No recipes found',
                    message: 'Try a different search or clear the filters.',
                    action: FilledButton(
                      onPressed: notifier.clear,
                      child: const Text('Clear filters'),
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
          ),
        ],
      ),
    );
  }
}

class _FilterRow<T> extends StatelessWidget {
  const _FilterRow({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final void Function(T?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final v = values[i];
          final isSelected = v == selected;
          return FilterChip(
            label: Text(label(v)),
            selected: isSelected,
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : null,
            ),
            onSelected: (_) => onSelected(isSelected ? null : v),
          );
        },
      ),
    );
  }
}
