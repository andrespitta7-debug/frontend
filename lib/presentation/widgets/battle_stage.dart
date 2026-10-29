import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Datos de ambientación visual (color de piedra, estandarte y props de pared) por bioma.
class BiomeData {
  final ColorFilter? colorFilter;
  final String bannerSprite;
  final String? extraWallProp;

  const BiomeData({
    required this.colorFilter,
    required this.bannerSprite,
    this.extraWallProp,
  });

  factory BiomeData.fromIndex(int indice) {
    switch (indice) {
      case 0:
        return const BiomeData(
          colorFilter: null,
          bannerSprite: 'wall_banner_blue.png',
        );
      case 1:
        return const BiomeData(
          colorFilter: ColorFilter.mode(Color(0xFFB5FFCC), BlendMode.modulate),
          bannerSprite: 'wall_banner_green.png',
          extraWallProp: 'wall_goo.png',
        );
      case 2:
        return const BiomeData(
          colorFilter: ColorFilter.mode(Color(0xFFFFB3B3), BlendMode.modulate),
          bannerSprite: 'wall_banner_red.png',
          extraWallProp: 'wall_fountain_basin_red_anim_f0.png',
        );
      default:
        return const BiomeData(
          colorFilter: ColorFilter.mode(Color(0xFFB3E5FF), BlendMode.modulate),
          bannerSprite: 'wall_banner_yellow.png',
        );
    }
  }
}

/// Arena de combate 2.5D con tiles repetidos (pared y suelo), props pixel art,
/// soporte de desplazamiento horizontal para efecto de caminata y agujero en el techo.
class BattleStage extends StatelessWidget {
  final Widget playerActor;
  final Widget enemyActor;
  final double height;
  final double scrollOffset;
  final bool showCeilingHole;
  final bool isEnemyVisible;
  final double? playerCustomBottom;
  final double? playerCustomTop;
  final ColorFilter? biomeColorFilter;
  final String bannerSprite;
  final String? extraWallProp;

  const BattleStage({
    super.key,
    required this.playerActor,
    required this.enemyActor,
    this.height = 220.0,
    this.scrollOffset = 0.0,
    this.showCeilingHole = false,
    this.isEnemyVisible = true,
    this.playerCustomBottom,
    this.playerCustomTop,
    this.biomeColorFilter,
    this.bannerSprite = 'wall_banner_blue.png',
    this.extraWallProp,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMoving = scrollOffset > 0.0;
    final double offsetNorm = scrollOffset % 64.0;

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
              // 1 y 2. Fondo de piedra (pared y suelo) modulado por el bioma de la sala
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: biomeColorFilter ??
                      const ColorFilter.mode(Colors.white, BlendMode.modulate),
                  child: Stack(
                    children: [
                      // Pared superior con repetición horizontal y desplazamiento
                      Positioned(
                        top: 0,
                        left: -offsetNorm,
                        right: -64.0,
                        height: 48,
                        child: Image.asset(
                          'assets/sprites/frames/wall_mid.png',
                          scale: 0.25,
                          repeat: ImageRepeat.repeatX,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),

                      // Suelo de baldosas de piedra con repetición 2D y desplazamiento
                      Positioned(
                        top: 48,
                        left: -offsetNorm,
                        right: -64.0,
                        bottom: 0,
                        child: Image.asset(
                          'assets/sprites/frames/floor_1.png',
                          scale: 0.25,
                          repeat: ImageRepeat.repeat,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Agujero en el techo para la intro de caída del portal
              if (showCeilingHole)
                Positioned(
                  top: 0,
                  left: 42,
                  child: Image.asset(
                    'assets/sprites/frames/hole.png',
                    scale: 0.25,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),

              // 4. Props de referencia visual durante la carrera (isMoving)
              if (isMoving) ...[
                // Columnas sobre la pared desplazándose de derecha a izquierda
                Positioned(
                  top: 4,
                  left: ((220.0 - scrollOffset) % 360.0) - 20.0,
                  child: const _PixelPropImage(assetName: 'column_wall.png'),
                ),
                Positioned(
                  top: 4,
                  left: ((400.0 - scrollOffset) % 360.0) - 20.0,
                  child: const _PixelPropImage(assetName: 'column_wall.png'),
                ),
                // Estandarte del bioma pasando de derecha a izquierda
                Positioned(
                  top: 6,
                  left: ((310.0 - scrollOffset) % 360.0) - 20.0,
                  child: _PixelPropImage(assetName: bannerSprite),
                ),
                // Caja en el suelo desplazándose
                Positioned(
                  top: 52,
                  left: ((350.0 - scrollOffset) % 360.0) - 20.0,
                  child: const _PixelPropImage(assetName: 'crate.png'),
                ),
                if (extraWallProp != null)
                  Positioned(
                    top: 14,
                    left: ((130.0 - scrollOffset) % 360.0) - 20.0,
                    child: _PixelPropImage(assetName: extraWallProp!),
                  ),
              ],

              // 5. Props estáticos del escenario (combate activo o reposo)
              if (!isMoving && !showCeilingHole) ...[
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

                // Estandarte del bioma actual en la pared
                _PixelProp(
                  assetName: bannerSprite,
                  top: 6,
                  left: 74,
                ),

                // Prop extra del bioma actual (wall_goo en sala 2 o fuente en sala 3)
                if (extraWallProp != null)
                  _PixelProp(
                    assetName: extraWallProp!,
                    top: 22,
                    right: 74,
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
              ],

              // 6. Sombras de los luchadores en el suelo
              Positioned(
                bottom: 8,
                left: 40,
                child: Opacity(
                  opacity: (playerCustomTop == null || playerCustomTop! >= height - 90) ? 1.0 : 0.0,
                  child: const _ShadowOval(width: 56, height: 16),
                ),
              ),
              if (isEnemyVisible)
                const Positioned(
                  bottom: 8,
                  right: 40,
                  child: _ShadowOval(width: 56, height: 16),
                ),

              // 7. Actores (Jugador y Enemigo)
              Positioned(
                top: playerCustomTop,
                bottom: playerCustomBottom ?? (playerCustomTop == null ? 12 : null),
                left: 44,
                child: playerActor,
              ),
              if (isEnemyVisible)
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

/// Imagen de prop pixel art con filtro nearest-neighbor.
class _PixelPropImage extends StatelessWidget {
  final String assetName;
  final double scale;

  const _PixelPropImage({
    required this.assetName,
    this.scale = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/sprites/frames/$assetName',
      scale: scale,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
    final image = _PixelPropImage(assetName: assetName, scale: scale);

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
