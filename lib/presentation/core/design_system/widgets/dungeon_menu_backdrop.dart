import 'package:flutter/material.dart';
import '../sysquest_theme.dart';

/// Fondo de menú retro estilo mazmorra de 16 bits.
/// Cuenta con pared (Y=76 a 140), suelo repetido (Y>=140), puerta central interactiva,
/// degradado de legibilidad y soporte para inyectar actores/sprites animados.
class DungeonMenuBackdrop extends StatelessWidget {
  final bool isDoorOpen;
  final Widget? centerStageActors;
  final Widget? child;

  const DungeonMenuBackdrop({
    super.key,
    this.isDoorOpen = false,
    this.centerStageActors,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final doorAsset =
        isDoorOpen ? 'doors_leaf_open.png' : 'doors_leaf_closed.png';

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fondo base dungeonVoid
          Container(
            color: SysQuestColors.dungeonVoid,
          ),

          // 2. Pared superior de la mazmorra (Y=76 a 140)
          Positioned(
            top: 76,
            left: 0,
            right: 0,
            height: 64,
            child: Image.asset(
              'assets/sprites/frames/wall_mid.png',
              scale: 0.25,
              repeat: ImageRepeat.repeatX,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

          // 3. Suelo de baldosas de piedra (a partir de Y=140)
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/sprites/frames/floor_1.png',
              scale: 0.25,
              repeat: ImageRepeat.repeat,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

          // 4. Puerta central superior en la pared
          Positioned(
            top: 68,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/sprites/frames/$doorAsset',
                scale: 0.25,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 5. Actores animados en el escenario (opcional)
          if (centerStageActors != null)
            Positioned(
              top: 104,
              left: 0,
              right: 0,
              child: Center(
                child: centerStageActors!,
              ),
            ),

          // 6. Degradado oscuro inferior para legibilidad de textos y botones
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.94),
                  ],
                  stops: const [0.25, 0.88],
                ),
              ),
            ),
          ),

          // 7. Contenido en primer plano (UI, menús, botones)
          if (child != null)
            Positioned.fill(
              child: child!,
            ),
        ],
      ),
    );
  }
}

