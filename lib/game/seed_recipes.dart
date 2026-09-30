import 'models.dart';

/// Twelve built-in meals so the board is never empty on a first run.
/// Always returns a fresh growable list, never a const literal.
List<Recipe> buildSeedRecipes() {
  return List<Recipe>.of(<Recipe>[
    const Recipe(
      id: 'seed-01',
      name: 'Tomato and basil pasta',
      category: MealCategory.veggie,
      ingredients: <String>[
        'pasta',
        'tomatoes',
        'basil',
        'olive oil',
        'garlic',
      ],
    ),
    const Recipe(
      id: 'seed-02',
      name: 'Roasted veg tray',
      category: MealCategory.veggie,
      ingredients: <String>['carrots', 'peppers', 'onion', 'olive oil'],
    ),
    const Recipe(
      id: 'seed-03',
      name: 'Lentil soup',
      category: MealCategory.veggie,
      ingredients: <String>['lentils', 'onion', 'carrots', 'garlic'],
    ),
    const Recipe(
      id: 'seed-04',
      name: 'Garden salad bowl',
      category: MealCategory.veggie,
      ingredients: <String>['lettuce', 'cucumber', 'tomatoes', 'olive oil'],
    ),
    const Recipe(
      id: 'seed-05',
      name: 'Herb roast chicken',
      category: MealCategory.protein,
      ingredients: <String>['chicken', 'thyme', 'garlic', 'olive oil'],
    ),
    const Recipe(
      id: 'seed-06',
      name: 'Baked salmon',
      category: MealCategory.protein,
      ingredients: <String>['salmon', 'lemon', 'dill', 'olive oil'],
    ),
    const Recipe(
      id: 'seed-07',
      name: 'Bean chili',
      category: MealCategory.protein,
      ingredients: <String>['beans', 'tomatoes', 'onion', 'paprika'],
    ),
    const Recipe(
      id: 'seed-08',
      name: 'Egg and spinach skillet',
      category: MealCategory.protein,
      ingredients: <String>['eggs', 'spinach', 'butter', 'onion'],
    ),
    const Recipe(
      id: 'seed-09',
      name: 'Oat porridge',
      category: MealCategory.grain,
      ingredients: <String>['oats', 'milk', 'honey', 'cinnamon'],
    ),
    const Recipe(
      id: 'seed-10',
      name: 'Rice and mushroom bowl',
      category: MealCategory.grain,
      ingredients: <String>['rice', 'mushrooms', 'garlic', 'butter'],
    ),
    const Recipe(
      id: 'seed-11',
      name: 'Flatbread wraps',
      category: MealCategory.grain,
      ingredients: <String>['flatbread', 'yoghurt', 'cucumber', 'lettuce'],
    ),
    const Recipe(
      id: 'seed-12',
      name: 'Barley stew',
      category: MealCategory.grain,
      ingredients: <String>['barley', 'carrots', 'onion', 'thyme'],
    ),
  ]);
}
