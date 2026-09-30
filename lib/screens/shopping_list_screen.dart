import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/buttons.dart';
import '../widgets/screen_header.dart';

/// Deduplicated shopping list grouped by category.
class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onClearChecked,
    required this.onBuildList,
    required this.onBack,
  });

  final List<ShoppingItem> items;
  final void Function(String name) onToggle;
  final VoidCallback onClearChecked;
  final VoidCallback onBuildList;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final int checked = items.where((ShoppingItem i) => i.checked).length;
    final int total = items.length;
    final double progress = total == 0 ? 0 : checked / total;

    final Map<MealCategory, List<ShoppingItem>> grouped =
        <MealCategory, List<ShoppingItem>>{};
    for (final ShoppingItem item in items) {
      grouped.putIfAbsent(item.category, () => <ShoppingItem>[]).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'SHOPPING LIST',
            onBack: onBack,
            trailing: Text(
              '$checked/$total',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            AppAssets.spriteBasket,
                            width: 88,
                            height: 88,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'NOTHING TO BUY YET',
                            style: AppTheme.eyebrow(size: 13, spacing: 1.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fill the week, then build the list.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkAt(0.55),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 200,
                            child: SecondaryButton(
                              label: 'BUILD LIST',
                              icon: Icons.checklist,
                              onTap: onBuildList,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    children: <Widget>[
                      for (final MealCategory category
                          in MealCategory.values) ...<Widget>[
                        if (grouped[category] != null) ...<Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: SectionRule(
                              label: category.label,
                              color: category.color.withValues(alpha: 0.4),
                            ),
                          ),
                          for (final ShoppingItem item in grouped[category]!)
                            _row(item),
                        ],
                      ],
                    ],
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.paper.withValues(alpha: 0.96),
              border: Border(
                top: BorderSide(color: AppColors.inkAt(0.12), width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.inkAt(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SecondaryButton(
                        label: 'CLEAR CHECKED',
                        icon: Icons.remove_done,
                        onTap: onClearChecked,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(ShoppingItem item) {
    return InkWell(
      onTap: () => onToggle(item.name),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.inkAt(0.08), width: 1),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              item.checked ? Icons.check_box : Icons.check_box_outline_blank,
              size: 24,
              color: AppColors.accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: item.checked ? AppColors.inkAt(0.4) : AppColors.ink,
                  decoration: item.checked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (item.count > 1)
              Text(
                'x${item.count}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFeatures: AppTheme.tabular,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
