import 'package:flutter/material.dart';
import '../sysquest_theme.dart';
import 'pixel_icon.dart';

/// Presets de escenarios para fondos de menú retro.
enum ScenePreset {
  /// Entrada a la mazmorra de noche con tono azul frío, puerta cerrada, fuentes y estandartes azules.
  loginGate,

  /// Taberna/gremio cálido con puerta abierta, escaleras de descenso, estandartes dorados, cofre y aventureros.
  guildHall,

  /// Biblioteca/archivo místico esmeralda con columnas, estandartes verdes, pociones y la sabia arcana.
  arcaneCodex,

  /// Armería real de forja cálida con estandartes rojos, cajas de suministros y exhibición de armas legendarias.
  heroArmory,
}

/// Fondo de menú retro estilo mazmorra de 16 bits evolucionado con soporte para [ScenePreset].
/// Cuenta con pared (Y=76 a 140), suelo repetido (Y>=140), puerta con marco completo,
/// accesorios temáticos, degradado de legibilidad y soporte para inyectar actores/sprites animados.
class DungeonMenuBackdrop extends StatelessWidget {
  final ScenePreset preset;
  final bool? isDoorOpen;
  final Widget? centerStageActors;
  final Widget? child;

  const DungeonMenuBackdrop({
    super.key,
    this.preset = ScenePreset.guildHall,
    this.isDoorOpen,
    this.centerStageActors,
    this.child,
  });

  ColorFilter _getColorFilter() {
    switch (preset) {
      case ScenePreset.loginGate:
        return const ColorFilter.mode(Color(0xFFB8C8FF), BlendMode.modulate);
      case ScenePreset.guildHall:
        return const ColorFilter.mode(Color(0xFFFFE8D0), BlendMode.modulate);
      case ScenePreset.arcaneCodex:
        return const ColorFilter.mode(Color(0xFFC8FFE0), BlendMode.modulate);
      case ScenePreset.heroArmory:
        return const ColorFilter.mode(Color(0xFFFFD6C8), BlendMode.modulate);
    }
  }

  bool get _effectiveDoorOpen {
    if (isDoorOpen != null) return isDoorOpen!;
    switch (preset) {
      case ScenePreset.loginGate:
      case ScenePreset.heroArmory:
        return false;
      case ScenePreset.guildHall:
      case ScenePreset.arcaneCodex:
        return true;
    }
  }

  List<Widget> _buildSceneryElements() {
    final doorAsset =
        _effectiveDoorOpen ? 'doors_leaf_open.png' : 'doors_leaf_closed.png';

    switch (preset) {
      case ScenePreset.loginGate:
        return [
          // Puerta cerrada con marco completo
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 128,
                height: 96,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 0,
                      left: 32,
                      width: 64,
                      height: 32,
                      child: PixelIcon(
                        fileName: 'doors_frame_top.png',
                        width: 64,
                        height: 32,
                      ),
                    ),
                    const Positioned(
                      top: 32,
                      left: 0,
                      width: 32,
                      height: 64,
                      child: PixelIcon(
                        fileName: 'doors_frame_left.png',
                        width: 32,
                        height: 64,
                      ),
                    ),
                    Positioned(
                      top: 32,
                      left: 32,
                      width: 64,
                      height: 64,
                      child: PixelIcon(fileName: doorAsset, size: 64),
                    ),
                    const Positioned(
                      top: 32,
                      left: 96,
                      width: 32,
                      height: 64,
                      child: PixelIcon(
                        fileName: 'doors_frame_right.png',
                        width: 32,
                        height: 64,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Estandartes azules en el muro
          const Positioned(
            top: 80,
            left: 72,
            child: PixelIcon(fileName: 'wall_banner_blue.png', size: 32),
          ),
          const Positioned(
            top: 80,
            right: 72,
            child: PixelIcon(fileName: 'wall_banner_blue.png', size: 32),
          ),
          // Fuentes azules a los extremos
          const Positioned(
            top: 96,
            left: 24,
            child: PixelIcon(
              fileName: 'wall_fountain_basin_blue_anim_f0.png',
              size: 32,
            ),
          ),
          const Positioned(
            top: 96,
            right: 24,
            child: PixelIcon(
              fileName: 'wall_fountain_basin_blue_anim_f0.png',
              size: 32,
            ),
          ),
        ];

      case ScenePreset.guildHall:
        return [
          // Puerta abierta con marco completo
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 128,
                height: 96,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 0,
                      left: 32,
                      width: 64,
                      height: 32,
                      child: PixelIcon(
                        fileName: 'doors_frame_top.png',
                        width: 64,
                        height: 32,
                      ),
                    ),
                    const Positioned(
                      top: 32,
                      left: 0,
                      width: 32,
                      height: 64,
                      child: PixelIcon(
                        fileName: 'doors_frame_left.png',
                        width: 32,
                        height: 64,
                      ),
                    ),
                    Positioned(
                      top: 32,
                      left: 32,
                      width: 64,
                      height: 64,
                      child: PixelIcon(fileName: doorAsset, size: 64),
                    ),
                    const Positioned(
                      top: 32,
                      left: 96,
                      width: 32,
                      height: 64,
                      child: PixelIcon(
                        fileName: 'doors_frame_right.png',
                        width: 32,
                        height: 64,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Escaleras de descenso frente al portal abierto
          const Positioned(
            top: 136,
            left: 0,
            right: 0,
            child: Center(
              child: PixelIcon(
                fileName: 'floor_stairs.png',
                width: 64,
                height: 32,
              ),
            ),
          ),
          // Estandartes dorados en el muro
          const Positioned(
            top: 80,
            left: 48,
            child: PixelIcon(fileName: 'wall_banner_yellow.png', size: 32),
          ),
          const Positioned(
            top: 80,
            right: 48,
            child: PixelIcon(fileName: 'wall_banner_yellow.png', size: 32),
          ),
          // Cofre abierto a la derecha
          const Positioned(
            top: 130,
            right: 36,
            child: PixelIcon(fileName: 'chest_full_open_anim_f2.png', size: 34),
          ),
          // Caballero y mago a la izquierda
          const Positioned(
            top: 110,
            left: 28,
            child: PixelIcon(
              fileName: 'knight_m_idle_anim_f0.png',
              width: 32,
              height: 44,
            ),
          ),
          const Positioned(
            top: 110,
            left: 64,
            child: PixelIcon(
              fileName: 'wizzard_m_idle_anim_f0.png',
              width: 32,
              height: 44,
            ),
          ),
        ];

      case ScenePreset.arcaneCodex:
        return [
          // Portal central con marco
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 128,
                height: 96,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 0,
                      left: 32,
                      width: 64,
                      height: 32,
                      child: PixelIcon(
                        fileName: 'doors_frame_top.png',
                        width: 64,
                        height: 32,
                      ),
                    ),
                    const Positioned(
                      top: 32,
                      left: 0,
                      width: 32,
                      height: 64,
                      child: PixelIcon(
                        fileName: 'doors_frame_left.png',
                        width: 32,
                        height: 64,
                      ),
                    ),
                    Positioned(
                      top: 32,
                      left: 32,
                      width: 64,
                      height: 64,
                      child: PixelIcon(fileName: doorAsset, size: 64),
                    ),
                    const Positioned(
                      top: 32,
                      left: 96,
                      width: 32,
                      height: 64,
                      child: PixelIcon(
                        fileName: 'doors_frame_right.png',
                        width: 32,
                        height: 64,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Columnas a los lados del portal
          const Positioned(
            top: 56,
            left: 32,
            child: PixelIcon(
              fileName: 'column_wall.png',
              width: 28,
              height: 84,
            ),
          ),
          const Positioned(
            top: 56,
            right: 32,
            child: PixelIcon(
              fileName: 'column_wall.png',
              width: 28,
              height: 84,
            ),
          ),
          // Estandartes verdes
          const Positioned(
            top: 80,
            left: 76,
            child: PixelIcon(fileName: 'wall_banner_green.png', size: 32),
          ),
          const Positioned(
            top: 80,
            right: 76,
            child: PixelIcon(fileName: 'wall_banner_green.png', size: 32),
          ),
          // Pociones de sabiduría
          const Positioned(
            top: 132,
            left: 18,
            child: PixelIcon(fileName: 'flask_big_blue.png', size: 28),
          ),
          const Positioned(
            top: 132,
            right: 18,
            child: PixelIcon(fileName: 'flask_big_yellow.png', size: 28),
          ),
          // La sabia / nigromante en el centro
          const Positioned(
            top: 108,
            left: 0,
            right: 0,
            child: Center(
              child: PixelIcon(
                fileName: 'wizzard_f_idle_anim_f0.png',
                width: 32,
                height: 44,
              ),
            ),
          ),
        ];

      case ScenePreset.heroArmory:
        return [
          // Puerta central con marco
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 128,
                height: 96,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 0,
                      left: 32,
                      width: 64,
                      height: 32,
                      child: PixelIcon(
                        fileName: 'doors_frame_top.png',
                        width: 64,
                        height: 32,
                      ),
                    ),
                    const Positioned(
                      top: 32,
                      left: 0,
                      width: 32,
                      height: 64,
                      child: PixelIcon(
                        fileName: 'doors_frame_left.png',
                        width: 32,
                        height: 64,
                      ),
                    ),
                    Positioned(
                      top: 32,
                      left: 32,
                      width: 64,
                      height: 64,
                      child: PixelIcon(fileName: doorAsset, size: 64),
                    ),
                    const Positioned(
                      top: 32,
                      left: 96,
                      width: 32,
                      height: 64,
                      child: PixelIcon(
                        fileName: 'doors_frame_right.png',
                        width: 32,
                        height: 64,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Estandartes rojos en el muro
          const Positioned(
            top: 80,
            left: 36,
            child: PixelIcon(fileName: 'wall_banner_red.png', size: 32),
          ),
          const Positioned(
            top: 80,
            right: 36,
            child: PixelIcon(fileName: 'wall_banner_red.png', size: 32),
          ),
          // Cajas de suministros en el suelo
          const Positioned(
            top: 124,
            left: 24,
            child: PixelIcon(fileName: 'crate.png', width: 32, height: 40),
          ),
          const Positioned(
            top: 124,
            right: 24,
            child: PixelIcon(fileName: 'crate.png', width: 32, height: 40),
          ),
          // Exhibición de armas
          const Positioned(
            top: 78,
            left: 80,
            child: PixelIcon(fileName: 'weapon_double_axe.png', size: 30),
          ),
          const Positioned(
            top: 72,
            left: 0,
            right: 0,
            child: Center(
              child: PixelIcon(fileName: 'weapon_golden_sword.png', size: 36),
            ),
          ),
          const Positioned(
            top: 78,
            right: 80,
            child: PixelIcon(fileName: 'weapon_katana.png', size: 30),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fondo base dungeonVoid
          Container(
            color: SysQuestColors.dungeonVoid,
          ),

          // 2. Escenario con ColorFilter según el ScenePreset
          ColorFiltered(
            colorFilter: _getColorFilter(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Pared superior de la mazmorra (Y=76 a 140)
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

                // Suelo de baldosas de piedra (a partir de Y=140)
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

                // Elementos decorativos y puerta del preset
                ..._buildSceneryElements(),

                // Actores animados inyectados en el escenario (opcional)
                if (centerStageActors != null)
                  Positioned(
                    top: 104,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: centerStageActors!,
                    ),
                  ),
              ],
            ),
          ),

          // 3. Degradado oscuro inferior para legibilidad de textos y botones
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

          // 4. Contenido en primer plano (UI, menús, botones)
          if (child != null)
            Positioned.fill(
              child: child!,
            ),
        ],
      ),
    );
  }
}
