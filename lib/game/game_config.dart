/// Timing + geometry constants for MealCanvas.
class AppConfig {
  const AppConfig._();

  /// Splash duration. Exactly 8000ms — shorter values race the screenshot pass.
  static const int loaderDurationMs = 8000;

  /// If the board sees no input for this long, the week is wrapped up so a
  /// result frame always surfaces.
  static const int idleBackstopMs = 9000;

  static const int screenFadeMs = 260;
  static const int menuStaggerMs = 700;
  static const int loaderIntroMs = 1200;
  static const int resultIntroMs = 520;
  static const int cellInsertMs = 220;
  static const int autoFillStepMs = 60;

  static const int days = 7;
  static const int defaultMealsPerDay = 3;

  static const double headerTopPad = 44;
  static const double headerHeight = 72;
  static const double boardPad = 12;
  static const double boardBorder = 1;
  static const double colGap = 8;
  static const double rowGap = 8;
  static const double dayLabelW = 34;
  static const double columnHeaderH = 16;
  static const double boardMaxWidth = 380;
  static const double screenGutter = 24;

  /// Slots that must be filled before FINISH WEEK is offered.
  static const int finishThreshold = 15;

  static const List<String> dayNamesMonFirst = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];
  static const List<String> dayNamesSunFirst = <String>[
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];
  static const List<String> slotNames = <String>[
    'BREAKFAST',
    'LUNCH',
    'DINNER',
  ];
  static const List<String> slotInitials = <String>['B', 'L', 'D'];
}
