import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/buttons.dart';
import '../widgets/stat_card.dart';

/// Asymmetric editorial cover: eyebrow, two-line wordmark, hero art
/// pushed to the right, then the call to action low on the page.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.plannedCount,
    required this.recipeCount,
    required this.onStart,
    required this.onRecipes,
    required this.onShopping,
    required this.onSettings,
  });

  final int plannedCount;
  final int recipeCount;
  final VoidCallback onStart;
  final VoidCallback onRecipes;
  final VoidCallback onShopping;
  final VoidCallback onSettings;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.menuStaggerMs),
    );
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
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
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final bool hasStats = widget.plannedCount > 0 && widget.recipeCount > 0;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgMenu),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xDBFFF8F1),
                Color(0xEBF2EAD8),
                Color(0xF5FFF8F1),
              ],
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
                  _staggered(
                    begin: 0.0,
                    end: 0.30,
                    child: Text(
                      'WEEK 1 OFFLINE PLANNER',
                      style: AppTheme.eyebrow(
                        size: 10,
                        spacing: 2.6,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _staggered(
                    begin: 0.14,
                    end: 0.58,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'MEAL',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3.0,
                            height: 0.98,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'CANVAS',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3.0,
                            height: 0.98,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppColors.inkAt(0.12)),
                  const SizedBox(height: 14),
                  _staggered(
                    begin: 0.28,
                    end: 0.72,
                    child: SizedBox(
                      width: screenW * 0.70,
                      child: Text(
                        'Arrange seven days. Save recipes. Shop once.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: AppColors.inkAt(0.7),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _staggered(
                      begin: 0.34,
                      end: 0.86,
                      child: Align(
                        alignment: const Alignment(0.85, 0.0),
                        child: SizedBox(
                          width: 192,
                          height: 192,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Align(
                                alignment: const Alignment(-0.16, -0.16),
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: AppColors.sand.withValues(
                                      alpha: 0.28,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Image.asset(
                                AppAssets.spriteBowl,
                                width: 168,
                                height: 168,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (hasStats)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: StatCard(
                            value: '${widget.plannedCount}',
                            label: 'meals planned',
                            valueColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: '${widget.recipeCount}',
                            label: 'recipes',
                            valueColor: AppColors.accent,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'NO PLAN YET TAP START PLANNING',
                      style: AppTheme.eyebrow(
                        size: 11,
                        spacing: 1.6,
                        weight: FontWeight.w600,
                        color: AppColors.inkAt(0.45),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _staggered(
                    begin: 0.44,
                    end: 1.0,
                    child: PrimaryButton(
                      label: 'START PLANNING',
                      icon: Icons.edit_calendar,
                      onTap: widget.onStart,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SecondaryButton(
                          label: 'RECIPE CARDS',
                          icon: Icons.menu_book,
                          onTap: widget.onRecipes,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          label: 'SHOPPING LIST',
                          icon: Icons.checklist,
                          onTap: widget.onShopping,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: widget.onSettings,
                      icon: Icon(
                        Icons.settings,
                        size: 24,
                        color: AppColors.inkAt(0.5),
                      ),
                      label: Text(
                        'SETTINGS',
                        style: AppTheme.eyebrow(
                          size: 11,
                          spacing: 1.8,
                          weight: FontWeight.w600,
                          color: AppColors.inkAt(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
