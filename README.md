# Filipino Cuisine Plus

A beautiful, user-friendly recipe app for Android and iOS. It celebrates Filipino cooking
first, from adobo to halo-halo, alongside a growing library of international dishes.

Built with [Flutter](https://flutter.dev) so one codebase ships to both platforms.

## Features (v1)

- **Home**: a warm landing page with Filipino favorites and sections per international cuisine.
- **Explore**: full-text search over names, local names, tags, and ingredients, with cuisine,
  category, and difficulty filters.
- **Recipe detail**: description, prep and cook times, servings, difficulty, ingredients with
  quantities and notes, and numbered method steps.
- **Favorites**: one-tap saving, persisted on the device.
- **Shopping list**: add every ingredient from a recipe, grouped by recipe, with check-off,
  swipe to remove, and bulk clear. Persisted on the device.
- Light and dark themes that follow the system setting.

## Getting started

Requires Flutter 3.35 or newer (Dart 3.9).

```bash
flutter pub get
flutter run            # pick a connected device or simulator
flutter test           # unit and widget tests
flutter analyze        # static analysis
```

## Architecture

The app follows a feature-first layout with a thin domain layer, so the data source can be
swapped without touching the UI.

```
lib/
  main.dart                      App bootstrap: SharedPreferences + ProviderScope
  app.dart                       MaterialApp.router with theme and routing
  core/
    theme/                       Brand palette and Material 3 theme (light + dark)
    router/                      go_router config with a bottom-nav shell
    widgets/                     RecipeCard, EmptyState, AsyncBody
  features/
    recipes/
      domain/                    Recipe model, enums, RecipeRepository interface
      data/                      LocalRecipeRepository (bundled JSON)
      presentation/              Riverpod providers, Explore and Detail screens
    home/                        Home screen
    favorites/                   Favorites state + screen
    shopping_list/               Shopping list state + screen
assets/data/recipes.json         Seed recipe content
test/                            Unit tests (model, filters, state) and widget tests
```

### Key choices

| Concern | Choice | Why |
| --- | --- | --- |
| State | [Riverpod](https://riverpod.dev) | Compile-safe, testable, no global singletons |
| Navigation | [go_router](https://pub.dev/packages/go_router) | Declarative routes, deep-link ready, stateful bottom tabs |
| Persistence | shared_preferences | Enough for favorites and a shopping list in v1 |
| Content | Bundled JSON behind `RecipeRepository` | Works offline on day one; swap in Supabase, Firebase, or a REST API later |
| Fonts | Playfair Display (headings) + Inter (body) via google_fonts | Editorial, food-magazine feel |

### Visual direction

The palette is drawn from Filipino ingredients:

| Token | Hex | Use |
| --- | --- | --- |
| Ube | `#5B3A8C` | Primary, headings, selected states |
| Mango | `#F2A93B` | Accents, bullets |
| Chili | `#D64541` | Favorites, destructive actions |
| Pandan | `#5A9E6F` | "Easy" difficulty, success |
| Coconut | `#FFF8F0` | Light background |

Recipes currently use an emoji on a per-cuisine gradient as the hero. Setting `imageUrl` on a
recipe swaps in a photo with no other changes.

## Adding recipes

Append an object to `assets/data/recipes.json`. The `seed_data_test` guards the file: every
recipe needs a unique `id`, at least one ingredient and step, and a description. Valid values
for `cuisine`, `category`, and `difficulty` are the enum names in
`lib/features/recipes/domain/recipe.dart`.

## Roadmap

- Real food photography and a cover image pipeline
- User accounts and cloud sync (Supabase)
- Meal planning and serving-size scaling
- Community recipe submissions
- Localization (Filipino, Spanish, Japanese)
