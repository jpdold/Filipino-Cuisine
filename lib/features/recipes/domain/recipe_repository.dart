import 'recipe.dart';

/// Abstraction over where recipes come from.
///
/// The app ships with [LocalRecipeRepository] (bundled JSON). Swap in a
/// remote implementation (Supabase, Firebase, REST) without touching the UI.
abstract class RecipeRepository {
  Future<List<Recipe>> getAll();

  Future<Recipe?> getById(String id);
}
