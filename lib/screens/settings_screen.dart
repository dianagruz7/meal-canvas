import 'package:flutter/material.dart';

import '../game/models.dart';
import '../theme.dart';
import '../widgets/screen_header.dart';

/// Week shape and data controls.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onClearAll,
    required this.onBack,
  });

  final AppSettings settings;
  final void Function(AppSettings next) onChanged;
  final VoidCallback onClearAll;
  final VoidCallback onBack;

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.paper,
          title: const Text(
            'CLEAR ALL DATA',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: AppColors.ink,
            ),
          ),
          content: Text(
            'The board and every saved recipe card will be removed.',
            style: TextStyle(fontSize: 14, color: AppColors.inkAt(0.7)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('KEEP'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onClearAll();
              },
              child: const Text(
                'DELETE ALL',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
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
          ScreenHeader(title: 'SETTINGS', onBack: onBack),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: <Widget>[
                  _row(
                    'WEEK STARTS ON',
                    _segment(
                      options: const <String>['MON', 'SUN'],
                      selectedIndex: settings.weekStartsMonday ? 0 : 1,
                      onSelect: (int i) => onChanged(
                        settings.copyWith(weekStartsMonday: i == 0),
                      ),
                    ),
                  ),
                  _row(
                    'MEALS PER DAY',
                    _segment(
                      options: const <String>['2', '3'],
                      selectedIndex: settings.mealsPerDay == 2 ? 0 : 1,
                      onSelect: (int i) => onChanged(
                        settings.copyWith(mealsPerDay: i == 0 ? 2 : 3),
                      ),
                    ),
                  ),
                  _row(
                    'AVOID REPEATS',
                    Switch(
                      value: settings.avoidRepeats,
                      activeThumbColor: AppColors.accent,
                      onChanged: (bool v) =>
                          onChanged(settings.copyWith(avoidRepeats: v)),
                    ),
                  ),
                  InkWell(
                    onTap: () => _confirmClear(context),
                    child: Container(
                      height: 56,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.inkAt(0.08),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'CLEAR ALL DATA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'MEAL CANVAS  v1.0.0  WORKS OFFLINE',
                      style: AppTheme.eyebrow(
                        size: 10,
                        spacing: 2.0,
                        weight: FontWeight.w600,
                        color: AppColors.inkAt(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, Widget control) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.inkAt(0.08), width: 1),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.ink,
              ),
            ),
          ),
          control,
        ],
      ),
    );
  }

  Widget _segment({
    required List<String> options,
    required int selectedIndex,
    required void Function(int index) onSelect,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 52,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == selectedIndex
                    ? AppColors.accent.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: i == selectedIndex
                      ? AppColors.accent
                      : AppColors.inkAt(0.14),
                  width: 1,
                ),
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: i == selectedIndex
                      ? AppColors.ink
                      : AppColors.inkAt(0.6),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
