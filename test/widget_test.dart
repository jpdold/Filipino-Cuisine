import 'package:filipino_cuisine_plus/app.dart';
import 'package:filipino_cuisine_plus/features/favorites/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('home screen lists seed recipes and navigates to detail', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const FilipinoCuisinePlusApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kain na!'), findsOneWidget);
    expect(find.text('Filipino Favorites'), findsOneWidget);
    expect(find.text('Chicken Adobo'), findsWidgets);

    await tester.tap(find.text('Chicken Adobo').first);
    await tester.pumpAndSettle();

    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Method'), findsOneWidget);
    expect(find.text('Add all'), findsOneWidget);
  });

  testWidgets('bottom navigation reaches every tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const FilipinoCuisinePlusApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('No favorites yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shopping_basket_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Your list is empty'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('Explore'), findsWidgets);
  });
}
