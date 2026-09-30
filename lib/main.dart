import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'game/game_config.dart';
import 'game/models.dart';
import 'game/planner.dart';
import 'game/seed_recipes.dart';
import 'game/shopping.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/meal_editor_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/recipe_cards_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'theme.dart';

enum Screen { loader, menu, game, editor, recipes, shopping, result, settings }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the semantics tree built for the whole session. Flutter only
  // generates it once an accessibility service attaches, so screen-reader
  // and automation tooling otherwise sees a single empty view with no
  // labels at all — every button becomes invisible to text-based lookup.
  SemanticsBinding.instance.ensureSemantics();
  runApp(const MealCanvasApp());
}

class MealCanvasApp extends StatelessWidget {
  const MealCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Canvas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AppShell(),
    );
  }
}

/// Owns every piece of session state and swaps the screens.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Screen _screen = Screen.loader;

  late WeekPlan _plan;
  List<Recipe> _library = <Recipe>[];
  AppSettings _settings = const AppSettings();
  List<ShoppingItem> _shopping = <ShoppingItem>[];

  int _repeatsAvoided = 0;
  int _editorDay = 0;
  int _editorSlot = 0;

  Timer? _backstop;
  Timer? _autoFill;

  @override
  void initState() {
    super.initState();
    _plan = WeekPlan.empty(AppConfig.days, _settings.mealsPerDay);
  }

  @override
  void dispose() {
    _backstop?.cancel();
    _autoFill?.cancel();
    super.dispose();
  }

  // --- session backstop -----------------------------------------------------

  /// While a planning session is open, a quiet stretch wraps the week up so
  /// the summary is always reachable without further input.
  void _armBackstop() {
    _backstop?.cancel();
    _backstop = Timer(
      const Duration(milliseconds: AppConfig.idleBackstopMs),
      () {
        if (!mounted) {
          return;
        }
        if (_screen == Screen.game || _screen == Screen.editor) {
          _finishWeek('timeup');
        }
      },
    );
  }

  void _cancelBackstop() {
    _backstop?.cancel();
    _backstop = null;
  }

  // --- navigation -----------------------------------------------------------

  void _go(Screen next) {
    setState(() => _screen = next);
    if (next == Screen.game || next == Screen.editor) {
      _armBackstop();
    } else if (next == Screen.menu || next == Screen.result) {
      _cancelBackstop();
    }
  }

  void _startPlanning() {
    _autoFill?.cancel();
    _go(Screen.game);
  }

  void _finishWeek(String reason) {
    _autoFill?.cancel();
    _cancelBackstop();
    setState(() => _screen = Screen.result);
    debugPrint('MealCanvas: week finished ($reason)');
  }

  // --- board actions --------------------------------------------------------

  void _openSlot(int dayIndex, int slotIndex) {
    setState(() {
      _editorDay = dayIndex;
      _editorSlot = slotIndex;
    });
    _go(Screen.editor);
  }

  void _saveMeal(Recipe recipe) {
    setState(() {
      _plan.at(_editorDay, _editorSlot).recipe = recipe;
      final bool known = _library.any((Recipe r) => r.id == recipe.id);
      if (known) {
        _library = _library
            .map((Recipe r) => r.id == recipe.id ? recipe : r)
            .toList();
      } else {
        _library = <Recipe>[..._library, recipe];
      }
      _shopping = ShoppingBuilder.merge(
        ShoppingBuilder.build(_plan),
        _shopping,
      );
    });
    if (_plan.filled >= _plan.total) {
      _finishWeek('complete');
      return;
    }
    _go(Screen.game);
  }

  void _removeMeal() {
    setState(() {
      _plan.at(_editorDay, _editorSlot).recipe = null;
      _shopping = ShoppingBuilder.merge(
        ShoppingBuilder.build(_plan),
        _shopping,
      );
    });
    _go(Screen.game);
  }

  /// Auto-fills the empty slots one at a time so the board visibly grows.
  void _fillWeek(MealCategory? filter) {
    _autoFill?.cancel();
    final FillResult result = Planner.fillWeek(
      plan: _plan,
      library: _library,
      filter: filter,
      avoidRepeats: _settings.avoidRepeats,
    );
    if (result.placements.isEmpty) {
      return;
    }

    if (_library.isEmpty) {
      _library = buildSeedRecipes();
    }
    setState(() => _repeatsAvoided += result.repeatsAvoided);

    int index = 0;
    _autoFill = Timer.periodic(
      const Duration(milliseconds: AppConfig.autoFillStepMs),
      (Timer timer) {
        if (!mounted || index >= result.placements.length) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _shopping = ShoppingBuilder.merge(
                ShoppingBuilder.build(_plan),
                _shopping,
              );
            });
          }
          return;
        }
        final MapEntry<Slot, Recipe> entry = result.placements[index];
        index++;
        setState(() {
          _plan.at(entry.key.dayIndex, entry.key.slotIndex).recipe =
              entry.value;
        });
      },
    );
    _armBackstop();
  }

  void _addRecipeToBoard(Recipe recipe) {
    final Slot? free = _plan.slots.cast<Slot?>().firstWhere(
      (Slot? s) => s != null && s.isEmpty,
      orElse: () => null,
    );
    if (free == null) {
      return;
    }
    setState(() {
      free.recipe = recipe;
      _shopping = ShoppingBuilder.merge(
        ShoppingBuilder.build(_plan),
        _shopping,
      );
    });
    _go(Screen.game);
  }

  void _clearWeek() {
    _autoFill?.cancel();
    setState(() {
      _plan.clear();
      _shopping = <ShoppingItem>[];
    });
    _armBackstop();
  }

  void _buildShoppingList() {
    setState(() {
      _shopping = ShoppingBuilder.merge(
        ShoppingBuilder.build(_plan),
        _shopping,
      );
    });
    _go(Screen.shopping);
  }

  void _toggleItem(String name) {
    setState(() {
      _shopping = _shopping
          .map(
            (ShoppingItem item) => item.name == name
                ? item.copyWith(checked: !item.checked)
                : item,
          )
          .toList();
    });
  }

  void _clearChecked() {
    setState(() {
      _shopping = _shopping
          .where((ShoppingItem item) => !item.checked)
          .toList();
    });
  }

  void _planAgain() {
    _autoFill?.cancel();
    setState(() {
      _plan.clear();
      _shopping = <ShoppingItem>[];
      _repeatsAvoided = 0;
    });
    _go(Screen.game);
  }

  void _applySettings(AppSettings next) {
    setState(() {
      if (next.mealsPerDay != _settings.mealsPerDay) {
        _plan = _plan.resized(AppConfig.days, next.mealsPerDay);
      }
      _settings = next;
    });
  }

  void _clearAllData() {
    _autoFill?.cancel();
    setState(() {
      _plan = WeekPlan.empty(AppConfig.days, _settings.mealsPerDay);
      _library = <Recipe>[];
      _shopping = <ShoppingItem>[];
      _repeatsAvoided = 0;
    });
  }

  // --- build ----------------------------------------------------------------

  Widget _current() {
    switch (_screen) {
      case Screen.loader:
        return LoaderScreen(
          key: const ValueKey<String>('loader'),
          onDone: () => _go(Screen.menu),
        );

      case Screen.menu:
        return MenuScreen(
          key: const ValueKey<String>('menu'),
          plannedCount: _plan.filled,
          recipeCount: _library.length,
          onStart: _startPlanning,
          onRecipes: () => _go(Screen.recipes),
          onShopping: _buildShoppingList,
          onSettings: () => _go(Screen.settings),
        );

      case Screen.game:
        return GameScreen(
          key: const ValueKey<String>('game'),
          plan: _plan,
          filledCount: _plan.filled,
          settings: _settings,
          onSlotTap: _openSlot,
          onFill: _fillWeek,
          onBuildList: _buildShoppingList,
          onClear: _clearWeek,
          onFinish: _finishWeek,
          onBack: () => _go(Screen.menu),
          onInteract: _armBackstop,
        );

      case Screen.editor:
        return MealEditorScreen(
          key: const ValueKey<String>('editor'),
          dayIndex: _editorDay,
          slotIndex: _editorSlot,
          dayLabel: _settings.dayNames[_editorDay],
          initial: _plan.at(_editorDay, _editorSlot).recipe,
          library: _library,
          onSave: _saveMeal,
          onRemove: _removeMeal,
          onClose: () => _go(Screen.game),
          onInteract: _armBackstop,
        );

      case Screen.recipes:
        return RecipeCardsScreen(
          key: const ValueKey<String>('recipes'),
          library: _library,
          onAddToBoard: _addRecipeToBoard,
          onOpenBoard: _startPlanning,
          onBack: () => _go(Screen.menu),
        );

      case Screen.shopping:
        return ShoppingListScreen(
          key: const ValueKey<String>('shopping'),
          items: _shopping,
          onToggle: _toggleItem,
          onClearChecked: _clearChecked,
          onBuildList: _startPlanning,
          onBack: () => _go(Screen.menu),
        );

      case Screen.result:
        return GameOverScreen(
          key: const ValueKey<String>('result'),
          filled: _plan.filled,
          total: _plan.total,
          balancePct: Planner.balancePct(_plan),
          recipeCount: _library.length,
          repeatsAvoided: _repeatsAvoided,
          shares: Planner.shares(_plan),
          onPlanAgain: _planAgain,
          onShopping: _buildShoppingList,
          onMenu: () => _go(Screen.menu),
        );

      case Screen.settings:
        return SettingsScreen(
          key: const ValueKey<String>('settings'),
          settings: _settings,
          onChanged: _applySettings,
          onClearAll: _clearAllData,
          onBack: () => _go(Screen.menu),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent _) {
        if (_screen == Screen.game || _screen == Screen.editor) {
          _armBackstop();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: AppConfig.screenFadeMs),
        child: _current(),
      ),
    );
  }
}
