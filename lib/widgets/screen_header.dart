import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../theme.dart';

/// Shared header bar. Keeps the 44dp status-bar inset on every screen.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.leadingIcon = Icons.arrow_back,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final IconData leadingIcon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: AppConfig.headerTopPad),
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(color: AppColors.inkAt(0.12), width: 1),
        ),
      ),
      child: SizedBox(
        height: AppConfig.headerHeight,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 56,
              child: onBack == null
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: onBack,
                      icon: Icon(leadingIcon, size: 24, color: AppColors.ink),
                    ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.4,
                  color: AppColors.ink,
                ),
              ),
            ),
            SizedBox(
              width: 72,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: trailing ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
