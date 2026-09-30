import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/balance_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/stat_card.dart';

/// Week summary. Reached when the board is full, when FINISH WEEK is
/// tapped, or when the board is left alone long enough.
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.filled,
    required this.total,
    required this.balancePct,
    required this.recipeCount,
    required this.repeatsAvoided,
    required this.shares,
    required this.onPlanAgain,
    required this.onShopping,
    required this.onMenu,
  });

  final int filled;
  final int total;
  final int balancePct;
  final int recipeCount;
  final int repeatsAvoided;
  final List<double> shares;
  final VoidCallback onPlanAgain;
  final VoidCallback onShopping;
  final VoidCallback onMenu;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.resultIntroMs),
    );
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.filled >= widget.total && widget.balancePct >= 70) {
      return 'WEEK COMPLETE!';
    }
    if (widget.filled >= AppConfig.finishThreshold) {
      return 'ALMOST THERE!';
    }
    return 'WEEK UNFINISHED';
  }

  Widget _staggered({
    required double begin,
    required double end,
    required Widget child,
  }) {
    final Animation<double> curved = CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.10),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showStats = widget.filled > 0 && widget.balancePct > 0;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0x4DF2CC8F), Color(0xF2FFF8F1)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppConfig.headerTopPad,
              left: AppConfig.screenGutter,
              right: AppConfig.screenGutter,
              bottom: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(child: _summary(showStats)),
                ),
                const SizedBox(height: 16),
                Text(
                  'PLAN AGAIN TO RESHUFFLE THE WEEK',
                  style: AppTheme.eyebrow(
                    size: 11,
                    spacing: 1.6,
                    weight: FontWeight.w600,
                    color: AppColors.inkAt(0.45),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'PLAN AGAIN',
                  icon: Icons.refresh,
                  onTap: widget.onPlanAgain,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SecondaryButton(
                        label: 'SHOPPING LIST',
                        icon: Icons.checklist,
                        onTap: widget.onShopping,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SecondaryButton(
                        label: 'MENU',
                        icon: Icons.home_outlined,
                        onTap: widget.onMenu,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summary(bool showStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _staggered(
          begin: 0.0,
          end: 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                AppAssets.spriteNotebook,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3.0,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: AppColors.inkAt(0.12)),
              const SizedBox(height: 12),
              Text(
                '${widget.filled} of ${widget.total} slots  '
                '${widget.repeatsAvoided} repeats avoided',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkAt(0.65),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (showStats)
          _staggered(
            begin: 0.20,
            end: 0.80,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: StatCard(
                    value: '${widget.filled}',
                    label: 'slots',
                    valueColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    value: '${widget.balancePct}',
                    label: 'balance %',
                    valueColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    value: '${widget.recipeCount}',
                    label: 'recipes',
                    valueColor: AppColors.sandDark,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        _staggered(
          begin: 0.30,
          end: 0.90,
          child: BalanceBar(
            veggie: widget.shares[0],
            protein: widget.shares[1],
            grain: widget.shares[2],
            height: 10,
            showLegend: true,
          ),
        ),
      ],
    );
  }
}
