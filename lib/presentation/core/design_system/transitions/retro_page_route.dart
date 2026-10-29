import 'package:flutter/material.dart';
import '../sysquest_theme.dart';

/// Calcula la opacidad escalonada en 5 niveles discretos: 0.0, 0.25, 0.50, 0.75 y 1.0.
double _calculateSteppedOpacity(double t) {
  if (t <= 0.0) return 0.0;
  if (t >= 1.0) return 1.0;
  // 5 escalones uniformes de opacidad de 16 bits
  return ((t * 4).floor() / 4.0).clamp(0.0, 1.0);
}

/// Construye una ruta con transición de fade escalonada (stepped opacity)
/// en 5 pasos discretos, evocando los juegos de 16 bits.
PageRouteBuilder<T> buildRetroRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 300),
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final opacity = _calculateSteppedOpacity(animation.value);
          return Container(
            color: SysQuestColors.dungeonVoid,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
      );
    },
  );
}

/// Clase equivalente a [buildRetroRoute] para usar como `RetroPageRoute(builder: ...)`.
class RetroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  RetroPageRoute({
    required this.page,
    super.settings,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final opacity = _calculateSteppedOpacity(animation.value);
                return Container(
                  color: SysQuestColors.dungeonVoid,
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                );
              },
            );
          },
        );
}

