import 'package:flutter/material.dart';

import '../theme.dart';

/// Three-part bar showing how the week splits across veggie / protein / grain.
class BalanceBar extends StatelessWidget {
  const BalanceBar({
    super.key,
    required this.veggie,
    required this.protein,
    required this.grain,
    this.height = 6,
    this.showLegend = false,
  });

  final double veggie;
  final double protein;
  final double grain;
  final double height;
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    final double sum = veggie + protein + grain;
    final bool hasData = sum > 0.001;
    final int v = hasData ? (veggie / sum * 1000).round() : 1;
    final int p = hasData ? (protein / sum * 1000).round() : 1;
    final int g = hasData ? (grain / sum * 1000).round() : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: hasData
                ? Row(
                    children: <Widget>[
                      Expanded(
                        flex: v < 1 ? 1 : v,
                        child: Container(color: AppColors.accent),
                      ),
                      Expanded(
                        flex: p < 1 ? 1 : p,
                        child: Container(color: AppColors.primary),
                      ),
                      Expanded(
                        flex: g < 1 ? 1 : g,
                        child: Container(color: AppColors.sand),
                      ),
                    ],
                  )
                : Container(color: AppColors.inkAt(0.10)),
          ),
        ),
        if (showLegend) ...<Widget>[
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _legend('VEGGIE', AppColors.accent),
              const SizedBox(width: 14),
              _legend('PROTEIN', AppColors.primary),
              const SizedBox(width: 14),
              _legend('GRAIN', AppColors.sandDark),
            ],
          ),
        ],
      ],
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.eyebrow(
            size: 9,
            spacing: 1.4,
            weight: FontWeight.w600,
            color: AppColors.inkAt(0.55),
          ),
        ),
      ],
    );
  }
}
