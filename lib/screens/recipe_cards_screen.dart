import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/buttons.dart';
import '../widgets/empty_state.dart';
import '../widgets/recipe_card.dart';
import '../widgets/screen_header.dart';

/// The saved recipe library, two cards per row.
class RecipeCardsScreen extends StatelessWidget {
  const RecipeCardsScreen({
    super.key,
    required this.library,
    required this.onAddToBoard,
    required this.onOpenBoard,
    required this.onBack,
  });

  final List<Recipe> library;
  final void Function(Recipe recipe) onAddToBoard;
  final VoidCallback onOpenBoard;
  final VoidCallback onBack;

  void _openSheet(BuildContext context, Recipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.asset(
                      recipe.category.sprite,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SectionRule(label: 'INGREDIENTS'),
                const SizedBox(height: 12),
                Text(
                  recipe.ingredients.isEmpty
                      ? 'No ingredients saved.'
                      : recipe.ingredients.join(', '),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkAt(0.75),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: 'ADD TO BOARD',
                    icon: Icons.add_circle_outline,
                    tone: AppColors.accentDark,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      onAddToBoard(recipe);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'RECIPE CARDS',
            onBack: onBack,
            trailing: Text(
              '${library.length}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ),
          Expanded(
            child: library.isEmpty
                ? EmptyState(
                    assetPath: AppAssets.spriteVeggie,
                    title: 'NO RECIPE CARDS',
                    hint: 'Meals you save on the board land here.',
                    actionLabel: 'OPEN THE BOARD',
                    actionIcon: Icons.grid_view,
                    onAction: onOpenBoard,
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                    padding: const EdgeInsets.all(20),
                    children: <Widget>[
                      for (final Recipe r in library)
                        RecipeCard(
                          recipe: r,
                          onTap: () => _openSheet(context, r),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
