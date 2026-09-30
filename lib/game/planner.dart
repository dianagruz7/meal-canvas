import 'dart:math' as math;

import 'models.dart';
import 'seed_recipes.dart';

/// Outcome of one auto-fill pass.
class FillResult {
  const FillResult({required this.placements, required this.repeatsAvoided});

  /// Slot / recipe pairs, in the order they should animate in.
  final List<MapEntry<Slot, Recipe>> placements;
  final int repeatsAvoided;
}

class Planner {
  const Planner._();

  static const double targetVeggie = 0.40;
  static const double targetProtein = 0.35;
  static const double targetGrain = 0.25;

  /// Greedy auto-fill: prefers recipes that are not already placed within
  /// two days of the slot and that pull the category mix towards the target.
  static FillResult fillWeek({
    required WeekPlan plan,
    required List<Recipe> library,
    required MealCategory? filter,
    required bool avoidRepeats,
  }) {
    final List<Recipe> pool = library.isEmpty
        ? buildSeedRecipes()
        : List<Recipe>.of(library);
    final List<Recipe> filtered = filter == null
        ? pool
        : pool.where((Recipe r) => r.category == filter).toList();
    final List<Recipe> candidates = filtered.isEmpty ? pool : filtered;
    if (candidates.isEmpty) {
      return const FillResult(
        placements: <MapEntry<Slot, Recipe>>[],
        repeatsAvoided: 0,
      );
    }

    final List<MapEntry<Slot, Recipe>> placements = <MapEntry<Slot, Recipe>>[];
    int repeatsAvoided = 0;
    int cursor = 0;

    final List<Slot> empties = plan.slots.where((Slot s) => s.isEmpty).toList()
      ..sort((Slot a, Slot b) {
        final int byDay = a.dayIndex.compareTo(b.dayIndex);
        return byDay != 0 ? byDay : a.slotIndex.compareTo(b.slotIndex);
      });

    for (final Slot slot in empties) {
      Recipe? picked;
      double bestScore = -1000000;

      for (int i = 0; i < candidates.length; i++) {
        final Recipe candidate = candidates[(cursor + i) % candidates.length];
        final bool nearby = _usedNearby(
          plan,
          placements,
          slot.dayIndex,
          candidate,
        );
        if (nearby && avoidRepeats) {
          repeatsAvoided++;
          continue;
        }
        final double score = _balanceScore(plan, placements, candidate);
        if (score > bestScore) {
          bestScore = score;
          picked = candidate;
        }
      }

      picked ??= candidates[cursor % candidates.length];
      cursor++;
      placements.add(MapEntry<Slot, Recipe>(slot, picked));
    }

    return FillResult(placements: placements, repeatsAvoided: repeatsAvoided);
  }

  static bool _usedNearby(
    WeekPlan plan,
    List<MapEntry<Slot, Recipe>> pending,
    int dayIndex,
    Recipe candidate,
  ) {
    for (final Slot s in plan.slots) {
      if (s.recipe?.id == candidate.id && (s.dayIndex - dayIndex).abs() <= 2) {
        return true;
      }
    }
    for (final MapEntry<Slot, Recipe> entry in pending) {
      if (entry.value.id == candidate.id &&
          (entry.key.dayIndex - dayIndex).abs() <= 2) {
        return true;
      }
    }
    return false;
  }

  static double _balanceScore(
    WeekPlan plan,
    List<MapEntry<Slot, Recipe>> pending,
    Recipe candidate,
  ) {
    final Map<MealCategory, int> counts = <MealCategory, int>{
      for (final MealCategory c in MealCategory.values) c: 0,
    };
    for (final Recipe r in plan.placedRecipes) {
      counts[r.category] = (counts[r.category] ?? 0) + 1;
    }
    for (final MapEntry<Slot, Recipe> entry in pending) {
      counts[entry.value.category] = (counts[entry.value.category] ?? 0) + 1;
    }
    counts[candidate.category] = (counts[candidate.category] ?? 0) + 1;

    final int total = counts.values.fold<int>(0, (int a, int b) => a + b);
    if (total == 0) {
      return 0;
    }
    final double deviation =
        (counts[MealCategory.veggie]! / total - targetVeggie).abs() +
        (counts[MealCategory.protein]! / total - targetProtein).abs() +
        (counts[MealCategory.grain]! / total - targetGrain).abs();
    return -deviation;
  }

  /// Share of each category among the filled slots: veggie, protein, grain.
  static List<double> shares(WeekPlan plan) {
    final List<Recipe> placed = plan.placedRecipes;
    if (placed.isEmpty) {
      return <double>[0, 0, 0];
    }
    int veggie = 0;
    int protein = 0;
    int grain = 0;
    for (final Recipe r in placed) {
      switch (r.category) {
        case MealCategory.veggie:
          veggie++;
        case MealCategory.protein:
          protein++;
        case MealCategory.grain:
          grain++;
        case MealCategory.other:
          break;
      }
    }
    final int total = placed.length;
    return <double>[veggie / total, protein / total, grain / total];
  }

  /// 100 minus the total deviation from the target mix, clamped to 0..100.
  static int balancePct(WeekPlan plan) {
    if (plan.filled == 0) {
      return 0;
    }
    final List<double> s = shares(plan);
    final double deviation =
        (s[0] - targetVeggie).abs() +
        (s[1] - targetProtein).abs() +
        (s[2] - targetGrain).abs();
    final double pct = 100 - deviation * 100;
    return math.max(0, math.min(100, pct.round()));
  }
}
