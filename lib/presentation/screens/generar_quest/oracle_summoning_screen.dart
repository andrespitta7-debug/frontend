import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/quest_completa.dart';
import '../../../infrastructure/api/api_exception.dart';
import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/transitions/retro_page_route.dart';
import '../../core/design_system/widgets/dungeon_menu_backdrop.dart';
import '../../core/design_system/widgets/pixel_icon.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';
import '../combate/combate_screen.dart';
import 'generar_quest_controller.dart';
import 'quest_retry_controller.dart';

/// Pantalla inmersiva de invocación del Oráculo de IA con animación,
/// barra segmentada retro, consejos estilo Minecraft/Terraria rotativos cada 7s,
/// y estados intuitivos de apertura de portal y reintentos.
class OracleSummoningScreen extends StatefulWidget {
  final QuestGenerationRetryController retryController;
  final GenerarQuestController? controller;
  final String tema;
  final String idUsuario;

  const OracleSummoningScreen({
    super.key,
    required this.retryController,
    this.controller,
    required this.tema,
    required this.idUsuario,
  });

  @override
  State<OracleSummoningScreen> createState() => _OracleSummoningScreenState();
}

class _OracleSummoningScreenState extends State<OracleSummoningScreen> {
  Timer? _timerProgreso;
  Timer? _timerConsejos;
  int _bloquesProgreso = 1;
  int _indiceConsejo = 0;
  bool _haNavegado = false;

  static const List<String> _consejosJuego = [
    'Tip: Las respuestas críticas hacen +10 de daño adicional y desestabilizan a los jefes.',
    'Tip: Cada 3 enemigos derrotados recargas comodines y recibes mejoras estilo roguelite.',
    'Tip: La Armadura Enana mitiga un 40% del daño en contraataques cuando fallas.',
    'Tip: Lee con calma: las opciones más extensas no siempre son las respuestas correctas.',
    'Tip: El Vampirismo Académico absorbe salud del enemigo con cada acierto.',
    'Tip: Mantener tu racha multiplica exponencialmente el daño de tu arma y el puntaje.',
    'Tip: Retirarte con botín tras abatir a un jefe asegura tus puntos de experiencia.',
  ];

  @override
  void initState() {
    super.initState();
    _iniciarTimerProgreso();
    _iniciarTimerConsejos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ejecutarInvocacion();
    });
  }

  void _iniciarTimerProgreso() {
    _timerProgreso?.cancel();
    _timerProgreso = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _bloquesProgreso = (_bloquesProgreso % 10) + 1;
        });
      }
    });
  }

  void _iniciarTimerConsejos() {
    _timerConsejos?.cancel();
    _timerConsejos = Timer.periodic(const Duration(seconds: 7), (_) {
      if (mounted) {
        setState(() {
          _indiceConsejo = (_indiceConsejo + 1) % _consejosJuego.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerProgreso?.cancel();
    _timerConsejos?.cancel();
    super.dispose();
  }

  String _obtenerTextoEstado(QuestRetryState retryState) {
    if (retryState.secondsUntilNextRetry > 0) {
      return 'Estabilizando el portal dimensional (${retryState.secondsUntilNextRetry}s)...';
    }
    if (retryState.attempt > 1) {
      return 'Sintonizando frecuencia del Limbo...';
    }
    return 'Abriendo portal dimensional...';
  }

  Future<void> _ejecutarInvocacion() async {
    final generarController =
        widget.controller ?? context.read<GenerarQuestController>();

    try {
      final questCompleta =
          await widget.retryController.generarQuestConReintentos(
        executeUseCase: () async {
          await generarController.generar(widget.tema);
          if (generarController.estado == GenerarQuestEstado.error) {
            throw ApiException(
              generarController.mensajeError ??
                  'La IA no está disponible temporalmente.',
              codigo: generarController.codigoError ?? 'IA_NO_DISPONIBLE',
            );
          }
          return generarController.questGenerada;
        },
      );

      if (!mounted) return;

      if (questCompleta != null) {
        _navegarACombate(questCompleta);
      } else {
        _volver();
      }
    } catch (_) {
      if (!mounted) return;
      _volver();
    }
  }

  void _navegarACombate(QuestCompleta questCompleta) {
    if (_haNavegado || !mounted) return;
    _haNavegado = true;
    Navigator.pushReplacement(
      context,
      buildRetroRoute(
        CombateScreen(
          idQuest: questCompleta.quest.idQuest,
          idUsuario: widget.idUsuario,
          categoriaQuest: questCompleta.quest.categoria,
          questCompleta: questCompleta,
        ),
      ),
    );
  }

  void _volver() {
    if (_haNavegado || !mounted) return;
    _haNavegado = true;
    Navigator.of(context).pop();
  }

  void _cancelar() {
    widget.retryController.cancelarInvocacion();
    final generarController =
        widget.controller ?? context.read<GenerarQuestController>();
    generarController.cancelar();
    _volver();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _cancelar();
        }
      },
      child: Scaffold(
        backgroundColor: SysQuestColors.dungeonVoid,
        body: SizedBox.expand(
          child: DungeonMenuBackdrop(
            isDoorOpen: false,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: topPadding + 20,
                  bottom: 24,
                  left: 20,
                  right: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ValueListenableBuilder<QuestRetryState>(
                    valueListenable: widget.retryController,
                    builder: (context, retryState, _) {
                      final textoEstado = _obtenerTextoEstado(retryState);

                      return RetroPanelBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Sprite central del Nigromante
                            Center(
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: SysQuestColors.dungeonVoid,
                                  border: Border.all(
                                    color: SysQuestColors.manaCyan,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: SysQuestColors.shadowBlack,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const PixelIcon(
                                  fileName: 'necromancer_anim_f0.png',
                                  size: 48,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Título retro
                            Text(
                              'INVOCANDO AL ORÁCULO',
                              textAlign: TextAlign.center,
                              style: SysQuestTypography.h2.copyWith(
                                color: SysQuestColors.gold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Texto de estado intuitivo
                            SizedBox(
                              height: 32,
                              child: Center(
                                child: Text(
                                  textoEstado,
                                  textAlign: TextAlign.center,
                                  style: SysQuestTypography.caption.copyWith(
                                    color: SysQuestColors.manaCyan,
                                    fontSize: 8.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Barra de progreso segmentada (Timer 500ms)
                            _buildBarraProgresoSegmentada(),

                            // Retroalimentación de reintento si está esperando
                            if (retryState.secondsUntilNextRetry > 0) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: SysQuestColors.gold.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: SysQuestColors.gold,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'Flujo arcano denso (Intento #${retryState.attempt}). Reanudando en ${retryState.secondsUntilNextRetry}s...',
                                  textAlign: TextAlign.center,
                                  style: SysQuestTypography.caption.copyWith(
                                    color: SysQuestColors.gold,
                                    fontSize: 8,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Contenedor de consejos estilo Terraria / Minecraft rotativos cada 7s
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: SysQuestColors.dungeonVoid.withValues(alpha: 0.6),
                                border: Border.all(
                                  color: SysQuestColors.stoneHighlight,
                                  width: 1,
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                child: Text(
                                  _consejosJuego[_indiceConsejo],
                                  key: ValueKey<int>(_indiceConsejo),
                                  textAlign: TextAlign.center,
                                  style: SysQuestTypography.caption.copyWith(
                                    color: SysQuestColors.parchmentText,
                                    fontSize: 7.5,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Botón cancelar
                            RetroPixelButton(
                              text: 'CANCELAR',
                              color: SysQuestColors.lifeRed,
                              textColor: SysQuestColors.parchmentText,
                              onPressed: _cancelar,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarraProgresoSegmentada() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SysQuestColors.dungeonVoid,
        border: Border.all(
          color: SysQuestColors.stoneHighlight,
          width: 2,
        ),
      ),
      child: Row(
        children: List.generate(10, (index) {
          final lleno = index < _bloquesProgreso;
          return Expanded(
            child: Container(
              height: 14,
              margin: EdgeInsets.only(right: index < 9 ? 2.5 : 0),
              decoration: BoxDecoration(
                color: lleno ? SysQuestColors.gold : SysQuestColors.stonePanel,
                border: Border.all(
                  color: lleno ? SysQuestColors.manaCyan : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

