/// Core domain model for a recipe.
///
/// Recipes are immutable value objects. They are loaded from a data source
/// (bundled JSON today, a backend later) through [RecipeRepository].
library;

enum Cuisine {
  filipino('Filipino', '🇵🇭'),
  japanese('Japanese', '🇯🇵'),
  thai('Thai', '🇹🇭'),
  italian('Italian', '🇮🇹'),
  mexican('Mexican', '🇲🇽'),
  indian('Indian', '🇮🇳'),
  korean('Korean', '🇰🇷'),
  american('American', '🇺🇸'),
  french('French', '🇫🇷'),
  chinese('Chinese', '🇨🇳');

  const Cuisine(this.label, this.flag);

  final String label;
  final String flag;

  static Cuisine fromKey(String key) => Cuisine.values.firstWhere(
    (c) => c.name == key,
    orElse: () => Cuisine.filipino,
  );
}

enum MealCategory {
  breakfast('Breakfast'),
  appetizer('Appetizer'),
  soup('Soup'),
  main('Main Dish'),
  side('Side Dish'),
  noodles('Noodles & Rice'),
  dessert('Dessert'),
  drink('Drink'),
  snack('Snack');

  const MealCategory(this.label);

  final String label;

  static MealCategory fromKey(String key) => MealCategory.values.firstWhere(
    (c) => c.name == key,
    orElse: () => MealCategory.main,
  );
}

enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const Difficulty(this.label);

  final String label;

  static Difficulty fromKey(String key) => Difficulty.values.firstWhere(
    (d) => d.name == key,
    orElse: () => Difficulty.medium,
  );
}

class Ingredient {
  const Ingredient({required this.name, required this.quantity, this.note});

  final String name;
  final String quantity;
  final String? note;

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    name: json['name'] as String,
    quantity: json['quantity'] as String,
    note: json['note'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    if (note != null) 'note': note,
  };

  @override
  bool operator ==(Object other) =>
      other is Ingredient &&
      other.name == name &&
      other.quantity == quantity &&
      other.note == note;

  @override
  int get hashCode => Object.hash(name, quantity, note);
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.localName,
    required this.cuisine,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.tags,
    required this.emoji,
    this.imageUrl,
  });

  final String id;
  final String name;

  /// Name in the dish's native language, e.g. "Adobong Manok".
  final String localName;
  final Cuisine cuisine;
  final MealCategory category;
  final Difficulty difficulty;
  final String description;
  final int prepMinutes;
  final int cookMinutes;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final List<String> tags;

  /// Placeholder visual until real photography is added.
  final String emoji;
  final String? imageUrl;

  int get totalMinutes => prepMinutes + cookMinutes;

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    name: json['name'] as String,
    localName: json['localName'] as String? ?? json['name'] as String,
    cuisine: Cuisine.fromKey(json['cuisine'] as String),
    category: MealCategory.fromKey(json['category'] as String),
    difficulty: Difficulty.fromKey(json['difficulty'] as String),
    description: json['description'] as String,
    prepMinutes: json['prepMinutes'] as int,
    cookMinutes: json['cookMinutes'] as int,
    servings: json['servings'] as int,
    ingredients: (json['ingredients'] as List)
        .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
        .toList(),
    steps: (json['steps'] as List).cast<String>(),
    tags: (json['tags'] as List?)?.cast<String>() ?? const [],
    emoji: json['emoji'] as String? ?? '🍽️',
    imageUrl: json['imageUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'localName': localName,
    'cuisine': cuisine.name,
    'category': category.name,
    'difficulty': difficulty.name,
    'description': description,
    'prepMinutes': prepMinutes,
    'cookMinutes': cookMinutes,
    'servings': servings,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    'steps': steps,
    'tags': tags,
    'emoji': emoji,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };

  /// True when [query] matches the name, local name, tags, or ingredients.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        localName.toLowerCase().contains(q) ||
        cuisine.label.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q)) ||
        ingredients.any((i) => i.name.toLowerCase().contains(q));
  }

  @override
  bool operator ==(Object other) => other is Recipe && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
