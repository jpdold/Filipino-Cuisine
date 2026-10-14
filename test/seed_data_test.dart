import 'dart:io';

import 'package:filipino_cuisine_plus/features/recipes/data/local_recipe_repository.dart';
import 'package:filipino_cuisine_plus/features/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the bundled seed data so a bad edit to recipes.json fails CI.
void main() {
  final raw = File('assets/data/recipes.json').readAsStringSync();
  final recipes = LocalRecipeRepository.parseRecipes(raw);

  test('seed data parses and has unique ids', () {
    expect(recipes, isNotEmpty);
    expect(recipes.map((r) => r.id).toSet().length, recipes.length);
  });

  test('every recipe is complete', () {
    for (final r in recipes) {
      expect(r.ingredients, isNotEmpty, reason: r.id);
      expect(r.steps, isNotEmpty, reason: r.id);
      expect(r.description, isNotEmpty, reason: r.id);
      expect(r.servings, greaterThan(0), reason: r.id);
    }
  });

  test('includes Filipino and international cuisines', () {
    final cuisines = recipes.map((r) => r.cuisine).toSet();
    expect(cuisines, contains(Cuisine.filipino));
    expect(cuisines.length, greaterThan(1));
  });
}
