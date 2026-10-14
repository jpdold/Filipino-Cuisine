import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../favorites/favorites_provider.dart';
import '../recipes/domain/recipe.dart';

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.recipeId,
    required this.recipeName,
    this.checked = false,
  });

  final String id;
  final String name;
  final String quantity;
  final String recipeId;
  final String recipeName;
  final bool checked;

  ShoppingItem copyWith({bool? checked}) => ShoppingItem(
    id: id,
    name: name,
    quantity: quantity,
    recipeId: recipeId,
    recipeName: recipeName,
    checked: checked ?? this.checked,
  );

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as String,
    recipeId: json['recipeId'] as String,
    recipeName: json['recipeName'] as String,
    checked: json['checked'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'recipeId': recipeId,
    'recipeName': recipeName,
    'checked': checked,
  };
}

class ShoppingListNotifier extends Notifier<List<ShoppingItem>> {
  static const _key = 'shopping_list';

  @override
  List<ShoppingItem> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List)
        .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _persist(List<ShoppingItem> items) async {
    state = items;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, jsonEncode(items.map((i) => i.toJson()).toList()));
  }

  /// Adds every ingredient of [recipe]. Skips ingredients already listed for it.
  Future<int> addRecipe(Recipe recipe) async {
    final existing = state.map((i) => i.id).toSet();
    final added = <ShoppingItem>[];
    for (final ing in recipe.ingredients) {
      final id = '${recipe.id}::${ing.name}';
      if (existing.contains(id)) continue;
      added.add(
        ShoppingItem(
          id: id,
          name: ing.name,
          quantity: ing.quantity,
          recipeId: recipe.id,
          recipeName: recipe.name,
        ),
      );
    }
    if (added.isNotEmpty) await _persist([...state, ...added]);
    return added.length;
  }

  Future<void> toggle(String id) => _persist([
    for (final i in state) i.id == id ? i.copyWith(checked: !i.checked) : i,
  ]);

  Future<void> remove(String id) =>
      _persist(state.where((i) => i.id != id).toList());

  Future<void> clearChecked() =>
      _persist(state.where((i) => !i.checked).toList());

  Future<void> clearAll() => _persist(const []);
}

final shoppingListProvider =
    NotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(
      ShoppingListNotifier.new,
    );
