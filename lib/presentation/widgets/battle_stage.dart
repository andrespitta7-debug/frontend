import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Arena de combate 2.5D con tiles repetidos (pared y suelo) y props pixel art.
class BattleStage extends StatelessWidget {
  final Widget playerActor;
  final Widget enemyActor;
  final double height;

  const BattleStage({
    super.key,
    required this.playerActor,
    required this.enemyActor,
    this.height = 220.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1828),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.doradoCritico.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Pared superior de la mazmorra con repetición horizontal
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 48,
                child: Image.asset(
                  'assets/sprites/frames/wall_mid.png',
                  scale: 0.25,
                  repeat: ImageRepeat.repeatX,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),

              // 2. Suelo de baldosas de piedra con repetición 2D
              Positioned(
                top: 48,
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

              // 3. Props del escenario
              // Puerta de la mazmorra en la pared central
              const _PixelProp(
                assetName: 'doors_leaf_closed.png',
                top: 4,
                left: 0,
                right: 0,
                alignment: Alignment.topCenter,
              ),

              // Columnas de piedra a los costados
              const _PixelProp(
                assetName: 'column.png',
                top: 6,
                left: 12,
              ),
              const _PixelProp(
                assetName: 'column.png',
                top: 6,
                right: 12,
              ),

              // Caja de suministros
              const _PixelProp(
                assetName: 'crate.png',
                top: 50,
                left: 18,
              ),

              // Calavera en el suelo
              const _PixelProp(
                assetName: 'skull.png',
                bottom: 6,
                left: 135,
                scale: 0.35,
              ),

              // 4. Sombras de los luchadores en el suelo
              const Positioned(
                bottom: 8,
                left: 48,
                child: _ShadowOval(width: 56, height: 16),
              ),
              const Positioned(
                bottom: 8,
                right: 48,
                child: _ShadowOval(width: 56, height: 16),
              ),

              // 5. Actores (Jugador y Enemigo)
              Positioned(
                bottom: 12,
                left: 44,
                child: playerActor,
              ),
              Positioned(
                bottom: 12,
                right: 44,
                child: enemyActor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Prop de pixel art colocado de forma absoluta en el escenario.
class _PixelProp extends StatelessWidget {
  final String assetName;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final AlignmentGeometry? alignment;
  final double scale;

  const _PixelProp({
    required this.assetName,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.alignment,
    this.scale = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/sprites/frames/$assetName',
      scale: scale,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );

    if (alignment != null) {
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Align(
          alignment: alignment!,
          child: image,
        ),
      );
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: image,
    );
  }
}

/// Sombra ovalada suave proyectada en el suelo de la arena.
class _ShadowOval extends StatelessWidget {
  final double width;
  final double height;

  const _ShadowOval({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.all(
          Radius.elliptical(width / 2, height / 2),
        ),
      ),
    );
  }
}
