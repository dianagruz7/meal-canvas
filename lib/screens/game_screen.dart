import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/models.dart';
import '../game/planner.dart';
import '../theme.dart';
import '../widgets/balance_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/screen_header.dart';
import '../widgets/week_board.dart';

/// The week board: seven days by two or three slots, plus the controls
/// that fill, clear, shop from and finish the week.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.plan,
    required this.filledCount,
    required this.settings,
    required this.onSlotTap,
    required this.onFill,
    required this.onBuildList,
    required this.onClear,
    required this.onFinish,
    required this.onBack,
    required this.onInteract,
  });

  final WeekPlan plan;

  /// Mirrors plan.filled so a rebuild can tell the count actually moved.
  final int filledCount;
  final AppSettings settings;
  final void Function(int dayIndex, int slotIndex) onSlotTap;
  final void Function(MealCategory? filter) onFill;
  final VoidCallback onBuildList;
  final VoidCallback onClear;
  final void Function(String reason) onFinish;
  final VoidCallback onBack;

  /// Re-arms the session backstop owned by the app shell.
  final VoidCallback onInteract;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  MealCategory? _filter;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 1.0,
      upperBound: 1.12,
    );
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filledCount != widget.filledCount) {
      _pulse.forward().then((void _) {
        if (mounted) {
          _pulse.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _touch(VoidCallback action) {
    widget.onInteract();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final WeekPlan plan = widget.plan;
    final int cols = widget.settings.mealsPerDay;
    final List<double> shares = Planner.shares(plan);
    final bool canFinish = plan.filled >= AppConfig.finishThreshold;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'THE WEEK',
            onBack: () => _touch(widget.onBack),
            trailing: ScaleTransition(
              scale: _pulse,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${plan.filled}/${plan.total}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFeatures: AppTheme.tabular,
                    ),
                  ),
                  Text(
                    'SLOTS',
                    style: AppTheme.eyebrow(
                      size: 9,
                      spacing: 1.6,
                      weight: FontWeight.w600,
                      color: AppColors.inkAt(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.bgBoard),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: AppColors.paper.withValues(alpha: 0.90),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    final BoardMetrics metrics = BoardMetrics.fit(
                      availableW: c.maxWidth,
                      availableH: c.maxHeight - 46,
                      cols: cols,
                    );
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: WeekBoard(
                              plan: plan,
                              metrics: metrics,
                              dayNames: widget.settings.dayNames,
                              onSlotTap: (int d, int s) =>
                                  _touch(() => widget.onSlotTap(d, s)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: metrics.boardW,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              BalanceBar(
                                veggie: shares[0],
                                protein: shares[1],
                                grain: shares[2],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                plan.filled == 0
                                    ? 'TAP A SLOT TO ADD A MEAL'
                                    : 'WEEK BALANCE',
                                style: AppTheme.eyebrow(
                                  size: 9,
                                  spacing: 2.0,
                                  weight: FontWeight.w600,
                                  color: AppColors.inkAt(0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          _controls(canFinish),
        ],
      ),
    );
  }

  Widget _controls(bool canFinish) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(top: BorderSide(color: AppColors.inkAt(0.12), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (canFinish) ...<Widget>[
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: 'FINISH WEEK',
                    icon: Icons.flag,
                    tone: AppColors.primary,
                    onTap: () => _touch(() => widget.onFinish('manual')),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                height: 40,
                child: Row(
                  children: <Widget>[
                    _chip('ALL', null),
                    const SizedBox(width: 8),
                    _chip('VEGGIE', MealCategory.veggie),
                    const SizedBox(width: 8),
                    _chip('PROTEIN', MealCategory.protein),
                    const SizedBox(width: 8),
                    _chip('GRAIN', MealCategory.grain),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'START AUTO-FILL',
                icon: Icons.auto_awesome,
                startColor: AppColors.accent,
                endColor: AppColors.accentDark,
                shadowColor: AppColors.accent,
                onTap: () => _touch(() => widget.onFill(_filter)),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: SecondaryButton(
                      label: 'BUILD LIST',
                      icon: Icons.checklist,
                      onTap: () => _touch(widget.onBuildList),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'CLEAR WEEK',
                      icon: Icons.restart_alt,
                      onTap: () => _touch(widget.onClear),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, MealCategory? category) {
    return Expanded(
      child: CategoryChip(
        label: label,
        active: _filter == category,
        color: category?.color ?? AppColors.ink,
        onTap: () {
          widget.onInteract();
          setState(() => _filter = category);
        },
      ),
    );
  }
}
