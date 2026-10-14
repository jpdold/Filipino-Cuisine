import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_recipe_repository.dart';
import '../domain/recipe.dart';
import '../domain/recipe_repository.dart';

/// Override this in tests or when swapping to a remote backend.
final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => LocalRecipeRepository(),
);

final allRecipesProvider = FutureProvider<List<Recipe>>((ref) {
  return ref.watch(recipeRepositoryProvider).getAll();
});

final recipeByIdProvider = FutureProvider.family<Recipe?, String>((ref, id) {
  return ref.watch(recipeRepositoryProvider).getById(id);
});

/// Filters applied on the Explore screen.
class RecipeFilter {
  const RecipeFilter({
    this.query = '',
    this.cuisine,
    this.category,
    this.difficulty,
  });

  final String query;
  final Cuisine? cuisine;
  final MealCategory? category;
  final Difficulty? difficulty;

  bool get isEmpty =>
      query.isEmpty &&
      cuisine == null &&
      category == null &&
      difficulty == null;

  RecipeFilter copyWith({
    String? query,
    Cuisine? Function()? cuisine,
    MealCategory? Function()? category,
    Difficulty? Function()? difficulty,
  }) => RecipeFilter(
    query: query ?? this.query,
    cuisine: cuisine != null ? cuisine() : this.cuisine,
    category: category != null ? category() : this.category,
    difficulty: difficulty != null ? difficulty() : this.difficulty,
  );

  List<Recipe> apply(List<Recipe> recipes) => recipes
      .where((r) => r.matches(query))
      .where((r) => cuisine == null || r.cuisine == cuisine)
      .where((r) => category == null || r.category == category)
      .where((r) => difficulty == null || r.difficulty == difficulty)
      .toList(growable: false);
}

class RecipeFilterNotifier extends Notifier<RecipeFilter> {
  @override
  RecipeFilter build() => const RecipeFilter();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setCuisine(Cuisine? c) => state = state.copyWith(cuisine: () => c);
  void setCategory(MealCategory? c) =>
      state = state.copyWith(category: () => c);
  void setDifficulty(Difficulty? d) =>
      state = state.copyWith(difficulty: () => d);
  void clear() => state = const RecipeFilter();
}

final recipeFilterProvider =
    NotifierProvider<RecipeFilterNotifier, RecipeFilter>(
      RecipeFilterNotifier.new,
    );

final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final filter = ref.watch(recipeFilterProvider);
  return ref.watch(allRecipesProvider).whenData(filter.apply);
});

/// Recipes grouped by cuisine, for the home screen sections.
final recipesByCuisineProvider =
    Provider<AsyncValue<Map<Cuisine, List<Recipe>>>>((ref) {
      return ref.watch(allRecipesProvider).whenData((recipes) {
        final map = <Cuisine, List<Recipe>>{};
        for (final r in recipes) {
          map.putIfAbsent(r.cuisine, () => []).add(r);
        }
        return map;
      });
    });
