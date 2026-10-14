import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/empty_state.dart';
import 'shopping_list_provider.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(shoppingListProvider);
    final notifier = ref.read(shoppingListProvider.notifier);

    final grouped = <String, List<ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.recipeName, () => []).add(item);
    }
    final checkedCount = items.where((i) => i.checked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          if (items.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (v) => v == 'checked'
                  ? notifier.clearChecked()
                  : notifier.clearAll(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'checked',
                  enabled: checkedCount > 0,
                  child: Text('Remove checked ($checkedCount)'),
                ),
                const PopupMenuItem(value: 'all', child: Text('Clear list')),
              ],
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              emoji: '🛒',
              title: 'Your list is empty',
              message:
                  'Open a recipe and tap "Add all" to add its ingredients.',
              action: FilledButton(
                onPressed: () => context.go('/explore'),
                child: const Text('Find a recipe'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                    child: Text(entry.key, style: theme.textTheme.titleLarge),
                  ),
                  Card(
                    child: Column(
                      children: [
                        for (final item in entry.value)
                          Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: theme.colorScheme.error,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: theme.colorScheme.onError,
                              ),
                            ),
                            onDismissed: (_) => notifier.remove(item.id),
                            child: CheckboxListTile(
                              value: item.checked,
                              onChanged: (_) => notifier.toggle(item.id),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                item.name,
                                style: item.checked
                                    ? TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      )
                                    : null,
                              ),
                              secondary: Text(
                                item.quantity,
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
