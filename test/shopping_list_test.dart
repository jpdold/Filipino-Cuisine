import 'package:filipino_cuisine_plus/features/favorites/favorites_provider.dart';
import 'package:filipino_cuisine_plus/features/recipes/domain/recipe.dart';
import 'package:filipino_cuisine_plus/features/shopping_list/shopping_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _recipe = Recipe(
  id: 'adobo',
  name: 'Chicken Adobo',
  localName: 'Adobong Manok',
  cuisine: Cuisine.filipino,
  category: MealCategory.main,
  difficulty: Difficulty.easy,
  description: '',
  prepMinutes: 10,
  cookMinutes: 40,
  servings: 4,
  ingredients: [
    Ingredient(name: 'Chicken', quantity: '1 kg'),
    Ingredient(name: 'Soy sauce', quantity: '1/2 cup'),
  ],
  steps: ['Cook.'],
  tags: [],
  emoji: '🍗',
);

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('favorites toggle on and off and persist', () async {
    final c = await _container();
    final notifier = c.read(favoritesProvider.notifier);

    await notifier.toggle('adobo');
    expect(c.read(favoritesProvider), {'adobo'});

    await notifier.toggle('adobo');
    expect(c.read(favoritesProvider), isEmpty);

    await notifier.toggle('ramen');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorites'), ['ramen']);
  });

  test('addRecipe adds each ingredient once', () async {
    final c = await _container();
    final notifier = c.read(shoppingListProvider.notifier);

    expect(await notifier.addRecipe(_recipe), 2);
    expect(await notifier.addRecipe(_recipe), 0);
    expect(c.read(shoppingListProvider), hasLength(2));
    expect(c.read(shoppingListProvider).first.recipeName, 'Chicken Adobo');
  });

  test('toggle, remove and clear operate on items', () async {
    final c = await _container();
    final notifier = c.read(shoppingListProvider.notifier);
    await notifier.addRecipe(_recipe);
    final first = c.read(shoppingListProvider).first;

    await notifier.toggle(first.id);
    expect(c.read(shoppingListProvider).first.checked, isTrue);

    await notifier.clearChecked();
    expect(c.read(shoppingListProvider), hasLength(1));

    await notifier.remove(c.read(shoppingListProvider).single.id);
    expect(c.read(shoppingListProvider), isEmpty);
  });

  test('shopping list survives a restart', () async {
    final c = await _container();
    await c.read(shoppingListProvider.notifier).addRecipe(_recipe);

    final prefs = await SharedPreferences.getInstance();
    final restarted = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(restarted.dispose);
    expect(restarted.read(shoppingListProvider), hasLength(2));
  });
}
