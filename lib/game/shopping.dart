import 'models.dart';

class ShoppingBuilder {
  const ShoppingBuilder._();

  /// Collapses identical ingredients across the week into one line each,
  /// keeping how many meals asked for it.
  static List<ShoppingItem> build(WeekPlan plan) {
    final Map<String, int> counts = <String, int>{};
    final Map<String, MealCategory> categories = <String, MealCategory>{};

    for (final Recipe recipe in plan.placedRecipes) {
      for (final String raw in recipe.ingredients) {
        final String name = raw.trim().toLowerCase();
        if (name.isEmpty) {
          continue;
        }
        counts[name] = (counts[name] ?? 0) + 1;
        categories.putIfAbsent(name, () => recipe.category);
      }
    }

    final List<String> names = counts.keys.toList()..sort();
    return names
        .map(
          (String name) => ShoppingItem(
            name: name,
            count: counts[name] ?? 1,
            category: categories[name] ?? MealCategory.other,
          ),
        )
        .toList();
  }

  /// Merges a freshly built list with the ticks the user already made.
  static List<ShoppingItem> merge(
    List<ShoppingItem> fresh,
    List<ShoppingItem> previous,
  ) {
    final Map<String, bool> checkedByName = <String, bool>{
      for (final ShoppingItem item in previous) item.name: item.checked,
    };
    return fresh
        .map(
          (ShoppingItem item) =>
              item.copyWith(checked: checkedByName[item.name] ?? false),
        )
        .toList();
  }
}
