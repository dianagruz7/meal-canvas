import 'package:flutter/material.dart';

import '../assets.dart';
import '../theme.dart';

enum MealCategory { veggie, protein, grain, other }

extension MealCategoryX on MealCategory {
  String get label {
    switch (this) {
      case MealCategory.veggie:
        return 'VEGGIE';
      case MealCategory.protein:
        return 'PROTEIN';
      case MealCategory.grain:
        return 'GRAIN';
      case MealCategory.other:
        return 'OTHER';
    }
  }

  Color get color {
    switch (this) {
      case MealCategory.veggie:
        return AppColors.accent;
      case MealCategory.protein:
        return AppColors.primary;
      case MealCategory.grain:
        return AppColors.sand;
      case MealCategory.other:
        return AppColors.ink;
    }
  }

  /// Fill opacity of a filled board cell for this category.
  double get fillAlpha {
    switch (this) {
      case MealCategory.grain:
        return 0.34;
      case MealCategory.other:
        return 0.10;
      case MealCategory.veggie:
      case MealCategory.protein:
        return 0.22;
    }
  }

  String get sprite {
    switch (this) {
      case MealCategory.veggie:
        return AppAssets.spriteVeggie;
      case MealCategory.protein:
        return AppAssets.spriteProtein;
      case MealCategory.grain:
        return AppAssets.spriteGrain;
      case MealCategory.other:
        return AppAssets.spriteBowl;
    }
  }
}

@immutable
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.ingredients,
  });

  final String id;
  final String name;
  final MealCategory category;
  final List<String> ingredients;

  Recipe copyWith({
    String? name,
    MealCategory? category,
    List<String>? ingredients,
  }) {
    return Recipe(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      ingredients: List<String>.of(ingredients ?? this.ingredients),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'category': category.name,
    'ingredients': List<String>.of(ingredients),
  };

  static Recipe fromJson(Map<String, dynamic> json) {
    final Object? rawIngredients = json['ingredients'];
    return Recipe(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: MealCategory.values.firstWhere(
        (MealCategory c) => c.name == json['category'],
        orElse: () => MealCategory.other,
      ),
      ingredients: rawIngredients is List
          ? rawIngredients.map((Object? e) => e.toString()).toList()
          : <String>[],
    );
  }
}

class Slot {
  Slot({required this.dayIndex, required this.slotIndex, this.recipe});

  final int dayIndex;
  final int slotIndex;
  Recipe? recipe;

  bool get isEmpty => recipe == null;
}

class WeekPlan {
  WeekPlan(List<Slot>? slots) : slots = List<Slot>.of(slots ?? const <Slot>[]);

  factory WeekPlan.empty(int days, int mealsPerDay) {
    final List<Slot> built = <Slot>[];
    for (int d = 0; d < days; d++) {
      for (int s = 0; s < mealsPerDay; s++) {
        built.add(Slot(dayIndex: d, slotIndex: s));
      }
    }
    return WeekPlan(built);
  }

  final List<Slot> slots;

  int get total => slots.length;

  int get filled => slots.where((Slot s) => s.recipe != null).length;

  Slot at(int dayIndex, int slotIndex) => slots.firstWhere(
    (Slot s) => s.dayIndex == dayIndex && s.slotIndex == slotIndex,
    orElse: () => Slot(dayIndex: dayIndex, slotIndex: slotIndex),
  );

  List<Recipe> get placedRecipes => slots
      .where((Slot s) => s.recipe != null)
      .map((Slot s) => s.recipe!)
      .toList();

  void clear() {
    for (final Slot s in slots) {
      s.recipe = null;
    }
  }

  /// Resizes the board when the meals-per-day setting changes, keeping
  /// whatever already fits.
  WeekPlan resized(int days, int mealsPerDay) {
    final WeekPlan next = WeekPlan.empty(days, mealsPerDay);
    for (final Slot s in next.slots) {
      final Slot old = at(s.dayIndex, s.slotIndex);
      s.recipe = old.recipe;
    }
    return next;
  }
}

@immutable
class AppSettings {
  const AppSettings({
    this.weekStartsMonday = true,
    this.mealsPerDay = 3,
    this.avoidRepeats = true,
  });

  final bool weekStartsMonday;
  final int mealsPerDay;
  final bool avoidRepeats;

  List<String> get dayNames => weekStartsMonday
      ? AppConfigDayNames.monFirst
      : AppConfigDayNames.sunFirst;

  AppSettings copyWith({
    bool? weekStartsMonday,
    int? mealsPerDay,
    bool? avoidRepeats,
  }) {
    return AppSettings(
      weekStartsMonday: weekStartsMonday ?? this.weekStartsMonday,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      avoidRepeats: avoidRepeats ?? this.avoidRepeats,
    );
  }
}

/// Kept separate so models.dart does not depend on game_config.dart.
class AppConfigDayNames {
  const AppConfigDayNames._();

  static const List<String> monFirst = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];
  static const List<String> sunFirst = <String>[
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];
}

/// One aggregated line of the shopping list.
@immutable
class ShoppingItem {
  const ShoppingItem({
    required this.name,
    required this.count,
    required this.category,
    this.checked = false,
  });

  final String name;
  final int count;
  final MealCategory category;
  final bool checked;

  ShoppingItem copyWith({bool? checked}) => ShoppingItem(
    name: name,
    count: count,
    category: category,
    checked: checked ?? this.checked,
  );
}
