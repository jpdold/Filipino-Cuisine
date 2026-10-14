import 'package:filipino_cuisine_plus/features/recipes/data/local_recipe_repository.dart';
import 'package:filipino_cuisine_plus/features/recipes/domain/recipe.dart';
import 'package:filipino_cuisine_plus/features/recipes/presentation/recipe_providers.dart';
import 'package:flutter_test/flutter_test.dart';

const _sample = '''
{
  "recipes": [
    {
      "id": "adobo", "name": "Chicken Adobo", "localName": "Adobong Manok",
      "cuisine": "filipino", "category": "main", "difficulty": "easy",
      "description": "Braised chicken.", "prepMinutes": 10, "cookMinutes": 40, "servings": 4,
      "ingredients": [{"name": "Chicken", "quantity": "1 kg"}, {"name": "Soy sauce", "quantity": "1/2 cup"}],
      "steps": ["Marinate.", "Simmer."], "tags": ["classic"], "emoji": "🍗"
    },
    {
      "id": "ramen", "name": "Shoyu Ramen", "cuisine": "japanese", "category": "soup", "difficulty": "hard",
      "description": "Noodle soup.", "prepMinutes": 30, "cookMinutes": 120, "servings": 2,
      "ingredients": [{"name": "Noodles", "quantity": "2 portions"}], "steps": ["Cook."]
    }
  ]
}
''';

void main() {
  group('Recipe parsing', () {
    test('parses all fields and computes total time', () {
      final recipes = LocalRecipeRepository.parseRecipes(_sample);
      expect(recipes, hasLength(2));
      final adobo = recipes.first;
      expect(adobo.cuisine, Cuisine.filipino);
      expect(adobo.category, MealCategory.main);
      expect(adobo.difficulty, Difficulty.easy);
      expect(adobo.totalMinutes, 50);
      expect(adobo.ingredients.length, 2);
      expect(adobo.tags, ['classic']);
    });

    test(
      'falls back to name, empty tags and default emoji when optional fields are missing',
      () {
        final ramen = LocalRecipeRepository.parseRecipes(_sample).last;
        expect(ramen.localName, 'Shoyu Ramen');
        expect(ramen.tags, isEmpty);
        expect(ramen.emoji, '🍽️');
      },
    );

    test('round-trips through toJson', () {
      final recipes = LocalRecipeRepository.parseRecipes(_sample);
      for (final r in recipes) {
        final copy = Recipe.fromJson(r.toJson());
        expect(copy.toJson(), r.toJson());
      }
    });
  });

  group('Recipe.matches', () {
    final recipe = LocalRecipeRepository.parseRecipes(_sample).first;

    test(
      'matches name, local name, cuisine, tag and ingredient case-insensitively',
      () {
        expect(recipe.matches('ADOBO'), isTrue);
        expect(recipe.matches('manok'), isTrue);
        expect(recipe.matches('filipino'), isTrue);
        expect(recipe.matches('classic'), isTrue);
        expect(recipe.matches('soy'), isTrue);
        expect(recipe.matches('ramen'), isFalse);
      },
    );

    test('empty query matches everything', () {
      expect(recipe.matches('   '), isTrue);
    });
  });

  group('RecipeFilter', () {
    final recipes = LocalRecipeRepository.parseRecipes(_sample);

    test('empty filter returns everything', () {
      expect(const RecipeFilter().apply(recipes), hasLength(2));
      expect(const RecipeFilter().isEmpty, isTrue);
    });

    test('filters by cuisine, category and difficulty', () {
      expect(
        const RecipeFilter(cuisine: Cuisine.japanese).apply(recipes).single.id,
        'ramen',
      );
      expect(
        const RecipeFilter(
          category: MealCategory.main,
        ).apply(recipes).single.id,
        'adobo',
      );
      expect(
        const RecipeFilter(
          difficulty: Difficulty.hard,
        ).apply(recipes).single.id,
        'ramen',
      );
      expect(
        const RecipeFilter(
          cuisine: Cuisine.japanese,
          difficulty: Difficulty.easy,
        ).apply(recipes),
        isEmpty,
      );
    });

    test('copyWith can clear a field', () {
      final f = const RecipeFilter(
        cuisine: Cuisine.thai,
      ).copyWith(cuisine: () => null);
      expect(f.cuisine, isNull);
      expect(f.isEmpty, isTrue);
    });
  });
}
