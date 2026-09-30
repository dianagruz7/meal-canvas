import 'package:flutter/material.dart';

import '../theme.dart';
import 'buttons.dart';

/// Centred placeholder with an illustration, used wherever a list is empty.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.assetPath,
    required this.title,
    required this.hint,
    this.artSize = 88,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String assetPath;
  final String title;
  final String hint;
  final double artSize;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              assetPath,
              width: artSize,
              height: artSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.eyebrow(size: 13, spacing: 1.6),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.inkAt(0.55),
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: SecondaryButton(
                  label: actionLabel!,
                  icon: actionIcon ?? Icons.arrow_forward,
                  onTap: onAction!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
