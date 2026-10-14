import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/recipe.dart';
import '../domain/recipe_repository.dart';

/// Loads recipes from the bundled `assets/data/recipes.json` file.
class LocalRecipeRepository implements RecipeRepository {
  LocalRecipeRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/recipes.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  List<Recipe>? _cache;

  @override
  Future<List<Recipe>> getAll() async {
    if (_cache != null) return _cache!;
    // cache: false because we cache the parsed list ourselves, and a cached
    // bundle future can hang across test boundaries.
    final raw = await _bundle.loadString(assetPath, cache: false);
    _cache = parseRecipes(raw);
    return _cache!;
  }

  @override
  Future<Recipe?> getById(String id) async {
    final all = await getAll();
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Pure parsing helper, exposed for tests.
  static List<Recipe> parseRecipes(String raw) {
    final decoded = jsonDecode(raw);
    final list = decoded is Map<String, dynamic>
        ? decoded['recipes'] as List
        : decoded as List;
    return list
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
