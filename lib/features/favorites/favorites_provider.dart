import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../recipes/domain/recipe.dart';
import '../recipes/presentation/recipe_providers.dart';

/// Provided at app start so favorites and the shopping list persist locally.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) =>
      throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

class FavoritesNotifier extends Notifier<Set<String>> {
  static const _key = 'favorites';

  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  bool isFavorite(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_key, next.toList());
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

final favoriteRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final ids = ref.watch(favoritesProvider);
  return ref
      .watch(allRecipesProvider)
      .whenData(
        (all) => all.where((r) => ids.contains(r.id)).toList(growable: false),
      );
});
