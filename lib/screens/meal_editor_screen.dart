import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/buttons.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_header.dart';

/// Fills one slot of the board: name, category, ingredients, or a quick
/// pick from what has already been saved.
class MealEditorScreen extends StatefulWidget {
  const MealEditorScreen({
    super.key,
    required this.dayIndex,
    required this.slotIndex,
    required this.dayLabel,
    required this.initial,
    required this.library,
    required this.onSave,
    required this.onRemove,
    required this.onClose,
    required this.onInteract,
  });

  final int dayIndex;
  final int slotIndex;
  final String dayLabel;
  final Recipe? initial;
  final List<Recipe> library;
  final void Function(Recipe recipe) onSave;
  final VoidCallback onRemove;
  final VoidCallback onClose;

  /// Re-arms the session backstop while the user is still typing.
  final VoidCallback onInteract;

  @override
  State<MealEditorScreen> createState() => _MealEditorScreenState();
}

class _MealEditorScreenState extends State<MealEditorScreen> {
  late final TextEditingController _name;
  late final TextEditingController _ingredients;
  late MealCategory _category;
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _ingredients = TextEditingController(
      text: widget.initial?.ingredients.join(', ') ?? '',
    );
    _category = widget.initial?.category ?? MealCategory.veggie;
  }

  @override
  void dispose() {
    _name.dispose();
    _ingredients.dispose();
    super.dispose();
  }

  void _save() {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    final List<String> parts = _ingredients.text
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
    widget.onSave(
      Recipe(
        id:
            widget.initial?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        category: _category,
        ingredients: parts,
      ),
    );
  }

  void _pick(Recipe recipe) {
    setState(() {
      _name.text = recipe.name;
      _ingredients.text = recipe.ingredients.join(', ');
      _category = recipe.category;
      _nameError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Recipe> recent = widget.library.reversed.take(6).toList();
    final String slotName = AppConfig
        .slotNames[widget.slotIndex.clamp(0, AppConfig.slotNames.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.paper,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: '${widget.dayLabel}  $slotName',
            leadingIcon: Icons.close,
            onBack: widget.onClose,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              children: <Widget>[
                Text(
                  'MEAL NAME',
                  style: AppTheme.eyebrow(
                    size: 10,
                    spacing: 2.0,
                    color: AppColors.inkAt(0.5),
                  ),
                ),
                TextField(
                  controller: _name,
                  onChanged: (String _) {
                    widget.onInteract();
                    if (_nameError) {
                      setState(() => _nameError = false);
                    }
                  },
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tomato and basil pasta',
                    hintStyle: TextStyle(color: AppColors.inkAt(0.35)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: _nameError
                            ? AppColors.primary
                            : AppColors.inkAt(0.2),
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                if (_nameError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'ENTER A MEAL NAME',
                      style: AppTheme.eyebrow(
                        size: 11,
                        spacing: 1.2,
                        weight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                Text(
                  'CATEGORY',
                  style: AppTheme.eyebrow(
                    size: 10,
                    spacing: 2.0,
                    color: AppColors.inkAt(0.5),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    for (final MealCategory c
                        in MealCategory.values) ...<Widget>[
                      if (c != MealCategory.values.first)
                        const SizedBox(width: 8),
                      Expanded(
                        child: CategoryChip(
                          label: c.label,
                          active: _category == c,
                          color: c.color,
                          onTap: () => setState(() => _category = c),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'INGREDIENTS',
                  style: AppTheme.eyebrow(
                    size: 10,
                    spacing: 2.0,
                    color: AppColors.inkAt(0.5),
                  ),
                ),
                TextField(
                  controller: _ingredients,
                  maxLines: 4,
                  onChanged: (String _) => widget.onInteract(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: 'pasta, tomatoes, basil, olive oil',
                    hintStyle: TextStyle(color: AppColors.inkAt(0.35)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColors.inkAt(0.2),
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'SEPARATE WITH COMMAS',
                  style: AppTheme.eyebrow(
                    size: 10,
                    spacing: 1.6,
                    weight: FontWeight.w600,
                    color: AppColors.inkAt(0.45),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionRule(label: 'QUICK PICK'),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  SizedBox(
                    height: 190,
                    child: EmptyState(
                      assetPath: AppAssets.spriteVeggie,
                      artSize: 64,
                      title: 'NO SAVED RECIPES YET',
                      hint: 'Your first save appears here.',
                    ),
                  )
                else
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recent.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int i) {
                        final Recipe r = recent[i];
                        return GestureDetector(
                          onTap: () => _pick(r),
                          child: Container(
                            width: 120,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.inkAt(0.12),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              r.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                    PrimaryButton(
                      label: 'SAVE TO BOARD',
                      icon: Icons.check,
                      onTap: _save,
                    ),
                    if (widget.initial != null) ...<Widget>[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SecondaryButton(
                          label: 'REMOVE FROM SLOT',
                          icon: Icons.delete_outline,
                          tone: AppColors.primary,
                          onTap: widget.onRemove,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
