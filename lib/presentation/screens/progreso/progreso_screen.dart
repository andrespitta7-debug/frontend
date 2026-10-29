import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/transitions/retro_page_route.dart';
import '../../core/design_system/widgets/dungeon_menu_backdrop.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';
import '../combate/combate_screen.dart';
import '../generar/generar_quest_screen.dart';
import 'progreso_controller.dart';

class ProgresoScreen extends StatefulWidget {
  final String idUsuario;
  final bool enHub;

  const ProgresoScreen({
    super.key,
    required this.idUsuario,
    this.enHub = false,
  });

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgresoController>().cargar(widget.idUsuario);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    final content = Consumer<ProgresoController>(
      builder: (context, c, _) {
        if (c.cargando || c.progreso == null) {
          return Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'CONSULTANDO CRÓNICAS...',
                style: SysQuestTypography.caption.copyWith(
                  color: SysQuestColors.gold,
                ),
              ),
            ),
          );
        }
        final p = c.progreso!;
        final partidasJugadas = p.partidasJugadas;
        final tasaVictoria = partidasJugadas == 0
            ? 0
            : ((p.victorias / partidasJugadas) * 100).round();

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: (widget.enHub ? topPadding : 8) + 16,
            bottom: 32,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.enHub) ...[
                Text(
                  'CÓDICE DE PROGRESO',
                  style: SysQuestTypography.h2.copyWith(
                    color: SysQuestColors.gold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Historial de batallas y logros',
                  style: SysQuestTypography.caption.copyWith(
                    color: SysQuestColors.parchmentText.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
              RetroPanelBox(
                child: Column(
                  children: [
                    _StatCard(titulo: 'Nivel', valor: '${p.nivel}'),
                    _StatCard(titulo: 'XP total', valor: '${p.xpTotal}'),
                    _StatCard(
                      titulo: 'Quests completadas',
                      valor: '${p.questsCompletadas}',
                    ),
                    _StatCard(
                      titulo: 'Partidas jugadas',
                      valor: '$partidasJugadas',
                    ),
                    _StatCard(titulo: 'Victorias', valor: '${p.victorias}'),
                    _StatCard(titulo: 'Derrotas', valor: '${p.derrotas}'),
                    _StatCard(
                      titulo: 'Tasa de victoria',
                      valor: partidasJugadas == 0
                          ? 'Sin partidas aún'
                          : '$tasaVictoria%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              RetroPixelButton(
                text: 'NUEVA QUEST CON IA',
                color: SysQuestColors.manaCyan,
                textColor: SysQuestColors.dungeonVoid,
                leadingSpriteFile: 'chest_full_open_anim_f0.png',
                onPressed: () {
                  Navigator.push(
                    context,
                    buildRetroRoute(
                      GenerarQuestScreen(idUsuario: widget.idUsuario),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              RetroPixelButton(
                text: 'JUGAR OTRA QUEST',
                color: SysQuestColors.stoneHighlight,
                leadingSpriteFile: 'doors_leaf_open.png',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    buildRetroRoute(
                      CombateScreen(
                        idQuest: 'quest-001',
                        idUsuario: widget.idUsuario,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (widget.enHub) {
      return content;
    }

    return Scaffold(
      backgroundColor: SysQuestColors.dungeonVoid,
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        backgroundColor: SysQuestColors.stonePanel,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DungeonMenuBackdrop(
              isDoorOpen: false,
            ),
          ),
          Positioned.fill(
            child: content,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  const _StatCard({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SysQuestColors.dungeonVoid.withValues(alpha: 0.5),
        border: Border.all(color: SysQuestColors.stoneHighlight, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: SysQuestTypography.caption.copyWith(
              color: SysQuestColors.parchmentText,
            ),
          ),
          Text(
            valor,
            style: SysQuestTypography.body.copyWith(
              fontSize: 12,
              color: SysQuestColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
