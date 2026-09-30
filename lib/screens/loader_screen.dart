import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/grain_painter.dart';

/// Branded splash. Dark linen against the cream menu that follows.
///
/// The hand-off is driven by a wall-clock Timer, not by the intro
/// animation, so a device with animations scaled down still waits.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _progress;
  Timer? _handoff;
  bool _armed = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.loaderIntroMs),
    );
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutBack));
    _progress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeInOut));
    _intro.forward();

    // The hand-off is armed only once a frame has actually been rasterised
    // and presented. Until that happens the platform launch window still
    // covers the app, and a timer started here spends its budget behind it:
    // on a loaded emulator the engine warm-up plus the first (grain-heavy)
    // raster ran longer than loaderDurationMs, so this screen was never once
    // on screen and the Menu was the first visible frame the capture pass
    // could grab.
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    // Fallback, in case frame timings never reach us: arm shortly after the
    // first build so the app still reaches the Menu.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      Timer(const Duration(milliseconds: 2500), _armHandoff);
    });
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    _armHandoff();
  }

  /// Starts the single hand-off timer. Safe to call more than once.
  void _armHandoff() {
    if (_armed || !mounted) {
      return;
    }
    _armed = true;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _handoff = Timer(
      const Duration(milliseconds: AppConfig.loaderDurationMs),
      () {
        if (mounted) {
          widget.onDone();
        }
      },
    );
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _handoff?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loaderTop,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.bgLoader),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xF22A2C3D),
                  Color(0xD93D405B),
                  Color(0xE64A3B36),
                ],
              ),
            ),
          ),
          const RepaintBoundary(
            child: CustomPaint(size: Size.infinite, painter: GrainPainter()),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 168,
                      height: 168,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.paper.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.sand.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Image.asset(
                        AppAssets.iconMain,
                        width: 132,
                        height: 132,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'MEAL CANVAS',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 6.0,
                        color: AppColors.paper,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(width: 64, height: 1, color: AppColors.primary),
                    const SizedBox(height: 14),
                    Text(
                      'PLAN THE WEEK 7 DAYS AT A TIME',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.4,
                        color: AppColors.sand.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 42),
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (BuildContext context, Widget? child) {
                        return Container(
                          width: 180,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.paper.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progress.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LOADING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.0,
                        color: AppColors.paper.withValues(alpha: 0.55),
                      ),
                    ),
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
