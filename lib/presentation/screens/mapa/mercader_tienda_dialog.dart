import 'package:flutter/material.dart';
import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';
import '../../../domain/entities/wildcard.dart';

/// Diálogo interactivo 16-bit retro para la Tienda del Mercader del Overworld 2D
class MercaderTiendaDialog extends StatefulWidget {
  final int scoreDisponible;
  final Map<TipoWildcard, int> inventarioActual;
  final Function(TipoWildcard tipo, int costo) onComprar;

  const MercaderTiendaDialog({
    super.key,
    required this.scoreDisponible,
    required this.inventarioActual,
    required this.onComprar,
  });

  static Future<void> mostrar(
    BuildContext context, {
    required int scoreDisponible,
    required Map<TipoWildcard, int> inventarioActual,
    required Function(TipoWildcard tipo, int costo) onComprar,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => MercaderTiendaDialog(
        scoreDisponible: scoreDisponible,
        inventarioActual: inventarioActual,
        onComprar: onComprar,
      ),
    );
  }

  @override
  State<MercaderTiendaDialog> createState() => _MercaderTiendaDialogState();
}

class _MercaderTiendaDialogState extends State<MercaderTiendaDialog> {
  late int _score;
  late Map<TipoWildcard, int> _inventario;

  @override
  void initState() {
    super.initState();
    _score = widget.scoreDisponible;
    _inventario = Map.from(widget.inventarioActual);
  }

  void _intentarComprar(TipoWildcard tipo, int costo, String nombre) {
    if (_score < costo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Oro insuficiente para comprar $nombre!',
            style: SysQuestTypography.caption.copyWith(
              color: SysQuestColors.parchmentText,
            ),
          ),
          backgroundColor: SysQuestColors.lifeRed,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _score -= costo;
      _inventario[tipo] = (_inventario[tipo] ?? 0) + 1;
    });

    widget.onComprar(tipo, costo);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Compraste 1x $nombre por $costo pts!',
          style: SysQuestTypography.caption.copyWith(
            color: SysQuestColors.dungeonVoid,
          ),
        ),
        backgroundColor: SysQuestColors.gold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: RetroPanelBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera Mercader
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: SysQuestColors.dungeonVoid,
                      border: Border.all(
                        color: SysQuestColors.gold,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/sprites/frames/wizzard_m_idle_anim_f0.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.storefront,
                        color: SysQuestColors.gold,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TIENDA DEL MERCADER',
                          style: SysQuestTypography.h3.copyWith(
                            color: SysQuestColors.gold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mejoras tácticas para tu run.',
                          style: SysQuestTypography.caption.copyWith(
                            color: SysQuestColors.parchmentText
                                .withValues(alpha: 0.8),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: SysQuestColors.parchmentText,
                      size: 20,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),

              // Balance de oro / score
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: SysQuestColors.dungeonVoid,
                  border: Border.all(
                    color: SysQuestColors.stoneHighlight,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ORO / PUNTOS:',
                      style: SysQuestTypography.caption.copyWith(
                        color: SysQuestColors.gold,
                        fontSize: 9,
                      ),
                    ),
                    Text(
                      '$_score PTS',
                      style: SysQuestTypography.caption.copyWith(
                        color: SysQuestColors.gold,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Lista de Artículos
              _ArticuloMercader(
                spriteAsset: 'assets/sprites/frames/skull.png',
                nombre: 'Pergamino de Pistas',
                descripcion: 'Revela la explicación teórica de la pregunta.',
                costo: 100,
                cantidad: _inventario[TipoWildcard.pista] ?? 0,
                onComprar: () => _intentarComprar(
                  TipoWildcard.pista,
                  100,
                  'Pergamino de Pistas',
                ),
              ),
              const SizedBox(height: 8),
              _ArticuloMercader(
                spriteAsset: 'assets/sprites/frames/weapon_waraxe.png',
                nombre: 'Filo Crítico (Golpe Doble)',
                descripcion: 'Duplica tu daño en el siguiente acierto.',
                costo: 150,
                cantidad: _inventario[TipoWildcard.golpeDoble] ?? 0,
                onComprar: () => _intentarComprar(
                  TipoWildcard.golpeDoble,
                  150,
                  'Filo Crítico',
                ),
              ),
              const SizedBox(height: 8),
              _ArticuloMercader(
                spriteAsset: 'assets/sprites/frames/flask_big_green.png',
                nombre: 'Poción Vampírica',
                descripcion: 'Restaura vida equivalente al daño infligido.',
                costo: 200,
                cantidad: _inventario[TipoWildcard.roboDeVida] ?? 0,
                onComprar: () => _intentarComprar(
                  TipoWildcard.roboDeVida,
                  200,
                  'Poción Vampírica',
                ),
              ),
              const SizedBox(height: 8),
              _ArticuloMercader(
                spriteAsset: 'assets/sprites/frames/weapon_knife.png',
                nombre: 'Orbe 50/50',
                descripcion: 'Descarta 2 opciones incorrectas.',
                costo: 120,
                cantidad: _inventario[TipoWildcard.cincuentaCincuenta] ?? 0,
                onComprar: () => _intentarComprar(
                  TipoWildcard.cincuentaCincuenta,
                  120,
                  'Orbe 50/50',
                ),
              ),
              const SizedBox(height: 16),

              // Botón Volver
              RetroPixelButton(
                text: 'REGRESAR AL MAPA',
                color: SysQuestColors.manaCyan,
                textColor: SysQuestColors.dungeonVoid,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticuloMercader extends StatelessWidget {
  final String spriteAsset;
  final String nombre;
  final String descripcion;
  final int costo;
  final int cantidad;
  final VoidCallback onComprar;

  const _ArticuloMercader({
    required this.spriteAsset,
    required this.nombre,
    required this.descripcion,
    required this.costo,
    required this.cantidad,
    required this.onComprar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SysQuestColors.dungeonVoid,
        border: Border.all(
          color: SysQuestColors.stoneHighlight,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: SysQuestColors.stonePanel,
              border: Border.all(color: SysQuestColors.borderBlack, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              spriteAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) => const Icon(
                Icons.auto_awesome,
                color: SysQuestColors.gold,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nombre,
                        style: SysQuestTypography.body.copyWith(
                          fontSize: 8,
                          color: SysQuestColors.parchmentText,
                        ),
                      ),
                    ),
                    Text(
                      'x$cantidad',
                      style: SysQuestTypography.caption.copyWith(
                        color: SysQuestColors.manaCyan,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: SysQuestTypography.caption.copyWith(
                    color: SysQuestColors.parchmentText.withValues(alpha: 0.75),
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RetroPixelButton(
            text: '$costo',
            height: 32,
            width: 78,
            color: SysQuestColors.gold,
            textColor: SysQuestColors.dungeonVoid,
            onPressed: onComprar,
          ),
        ],
      ),
    );
  }
}
