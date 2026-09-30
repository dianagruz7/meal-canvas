import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../game/models.dart';
import '../theme.dart';

/// Board geometry. The frame (padding + border) is subtracted before the
/// cells are sized, so the grid can never push past its own container.
class BoardMetrics {
  const BoardMetrics({
    required this.cellW,
    required this.cellH,
    required this.boardW,
    required this.boardH,
    required this.cols,
  });

  final double cellW;
  final double cellH;
  final double boardW;
  final double boardH;
  final int cols;

  static const double frame = AppConfig.boardPad + AppConfig.boardBorder;

  factory BoardMetrics.fit({
    required double availableW,
    required double availableH,
    required int cols,
    int rows = AppConfig.days,
  }) {
    final double maxW = math.min(availableW, AppConfig.boardMaxWidth);
    final double innerW =
        maxW - 2 * frame - AppConfig.dayLabelW - cols * AppConfig.colGap;
    final double cellW = math.max(28.0, (innerW / cols).floorToDouble());

    final double innerH =
        availableH -
        2 * frame -
        AppConfig.columnHeaderH -
        6 -
        (rows - 1) * AppConfig.rowGap;
    final double fromHeight = math.max(20.0, (innerH / rows).floorToDouble());
    final double cellH = math.min(
      math.max(24.0, (cellW * 0.62).floorToDouble()),
      fromHeight,
    );

    final double boardW =
        cellW * cols +
        AppConfig.dayLabelW +
        cols * AppConfig.colGap +
        2 * frame;
    final double boardH =
        cellH * rows +
        (rows - 1) * AppConfig.rowGap +
        AppConfig.columnHeaderH +
        6 +
        2 * frame;

    return BoardMetrics(
      cellW: cellW,
      cellH: cellH,
      boardW: boardW,
      boardH: boardH,
      cols: cols,
    );
  }
}

class WeekBoard extends StatelessWidget {
  const WeekBoard({
    super.key,
    required this.plan,
    required this.metrics,
    required this.dayNames,
    required this.onSlotTap,
  });

  final WeekPlan plan;
  final BoardMetrics metrics;
  final List<String> dayNames;
  final void Function(int dayIndex, int slotIndex) onSlotTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: metrics.boardW,
      height: metrics.boardH,
      padding: const EdgeInsets.all(AppConfig.boardPad),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.inkAt(0.14),
          width: AppConfig.boardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: AppConfig.columnHeaderH,
            child: Row(
              children: <Widget>[
                const SizedBox(width: AppConfig.dayLabelW),
                for (int c = 0; c < metrics.cols; c++) ...<Widget>[
                  const SizedBox(width: AppConfig.colGap),
                  SizedBox(
                    width: metrics.cellW,
                    child: Text(
                      AppConfig.slotInitials[c],
                      textAlign: TextAlign.center,
                      style: AppTheme.eyebrow(
                        size: 9,
                        spacing: 1.6,
                        color: AppColors.inkAt(0.45),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          for (int d = 0; d < AppConfig.days; d++) ...<Widget>[
            if (d > 0) const SizedBox(height: AppConfig.rowGap),
            SizedBox(
              height: metrics.cellH,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: AppConfig.dayLabelW,
                    child: Text(
                      dayNames[d],
                      style: AppTheme.eyebrow(
                        size: 10,
                        spacing: 1.4,
                        color: AppColors.inkAt(0.55),
                      ),
                    ),
                  ),
                  for (int c = 0; c < metrics.cols; c++) ...<Widget>[
                    const SizedBox(width: AppConfig.colGap),
                    SlotCell(
                      recipe: plan.at(d, c).recipe,
                      width: metrics.cellW,
                      height: metrics.cellH,
                      onTap: () => onSlotTap(d, c),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SlotCell extends StatelessWidget {
  const SlotCell({
    super.key,
    required this.recipe,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final Recipe? recipe;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Recipe? r = recipe;
    final Color tone = r?.category.color ?? AppColors.ink;
    final double fontSize = height < 34 ? 9 : (height < 44 ? 10 : 11);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppConfig.cellInsertMs),
        curve: Curves.easeOutBack,
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: r == null
              ? Colors.white.withValues(alpha: 0.55)
              : tone.withValues(alpha: r.category.fillAlpha),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: r == null
                ? AppColors.inkAt(0.14)
                : tone.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: r == null
            ? Center(
                child: Icon(Icons.add, size: 18, color: AppColors.inkAt(0.35)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: tone,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Flexible(
                    child: Text(
                      r.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
