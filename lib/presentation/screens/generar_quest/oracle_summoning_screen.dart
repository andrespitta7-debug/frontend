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
/// barra segmentada retro y retroalimentación de reintentos con backoff.
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
  Timer? _timerRotativo;
  Timer? _timerProgreso;
  int _indiceMensaje = 0;
  int _bloquesProgreso = 1;
  bool _haNavegado = false;

  static const List<String> _mensajesOraculo = [
    'Invocando al Oráculo...',
    'Consultando los astros...',
    'Descifrando runas binarias...',
    'Canalizando flujo de datos...',
    'Alineando constelaciones de silicio...',
    'Forjando los desafíos del calabozo...',
    'Extrayendo sabiduría ancestral...',
    'Equilibrando monstruos y código...',
  ];

  @override
  void initState() {
    super.initState();
    _iniciarTimerRotativo();
    _iniciarTimerProgreso();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ejecutarInvocacion();
    });
  }

  void _iniciarTimerRotativo() {
    _timerRotativo?.cancel();
    _timerRotativo =
        Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted) {
        setState(() {
          _indiceMensaje =
              (_indiceMensaje + 1) % _mensajesOraculo.length;
        });
      }
    });
  }

  void _iniciarTimerProgreso() {
    _timerProgreso?.cancel();
    _timerProgreso =
        Timer.periodic(const Duration(milliseconds: 280), (_) {
      if (mounted) {
        setState(() {
          _bloquesProgreso = (_bloquesProgreso % 10) + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerRotativo?.cancel();
    _timerProgreso?.cancel();
    super.dispose();
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
    final mensajeActual = _mensajesOraculo[_indiceMensaje];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _cancelar();
        }
      },
      child: Scaffold(
        backgroundColor: SysQuestColors.dungeonVoid,
        body: SafeArea(
          child: DungeonMenuBackdrop(
            isDoorOpen: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ValueListenableBuilder<QuestRetryState>(
                    valueListenable: widget.retryController,
                    builder: (context, retryState, _) {
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

                            // Mensaje rotativo cada 600ms
                            SizedBox(
                              height: 32,
                              child: Center(
                                child: Text(
                                  mensajeActual,
                                  textAlign: TextAlign.center,
                                  style: SysQuestTypography.caption.copyWith(
                                    color: SysQuestColors.parchmentText,
                                    fontSize: 8.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Barra de progreso segmentada (10 bloques)
                            _buildBarraProgresoSegmentada(),

                            // Retroalimentación de reintento con backoff exponencial
                            if (retryState.secondsUntilNextRetry > 0) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: SysQuestColors.gold
                                      .withValues(alpha: 0.12),
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

                            const SizedBox(height: 24),

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
        border: Border.all(color: SysQuestColors.borderBlack, width: 2),
      ),
      child: Row(
        children: List.generate(10, (index) {
          final bool activo = index < _bloquesProgreso;
          return Expanded(
            child: Container(
              height: 12,
              margin: EdgeInsets.only(right: index < 9 ? 3.0 : 0.0),
              decoration: BoxDecoration(
                color: activo
                    ? SysQuestColors.manaCyan
                    : SysQuestColors.stonePanel.withValues(alpha: 0.35),
                border: Border.all(
                  color: activo
                      ? SysQuestColors.manaCyan
                      : SysQuestColors.borderBlack,
                  width: 1,
                ),
                boxShadow: activo
                    ? [
                        BoxShadow(
                          color: SysQuestColors.manaCyan
                              .withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

