import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/transitions/retro_page_route.dart';
import '../../core/design_system/widgets/dungeon_menu_backdrop.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';
import '../../core/design_system/widgets/retro_text_field.dart';
import '../../widgets/dialogo_alerta.dart';
import '../combate/combate_screen.dart';
import '../generar_quest/generar_quest_controller.dart';

class GenerarQuestScreen extends StatefulWidget {
  final String idUsuario;

  const GenerarQuestScreen({super.key, required this.idUsuario});

  @override
  State<GenerarQuestScreen> createState() => _GenerarQuestScreenState();
}

class _GenerarQuestScreenState extends State<GenerarQuestScreen> {
  final _temaController = TextEditingController();
  String? _errorTema;
  Timer? _timerRotativo;
  int _indiceMensaje = 0;

  static const List<String> _mensajesCarga = [
    'Invocando al Oráculo...',
    'Compilando la mazmorra...',
    'Forjando encuentros técnicos...',
    'Consultando los pergaminos...',
    'Equilibrando monstruos y desafíos...',
  ];

  @override
  void initState() {
    super.initState();
    _iniciarTimerRotativo();
  }

  void _iniciarTimerRotativo() {
    _timerRotativo?.cancel();
    _timerRotativo = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (mounted) {
        setState(() {
          _indiceMensaje = (_indiceMensaje + 1) % _mensajesCarga.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerRotativo?.cancel();
    _temaController.dispose();
    super.dispose();
  }

  Future<void> _generarQuest() async {
    final tema = _temaController.text.trim();
    if (tema.length < 3 || tema.length > 100) {
      setState(() {
        _errorTema = 'El tema debe tener entre 3 y 100 caracteres.';
      });
      return;
    }

    setState(() {
      _errorTema = null;
    });

    final controller = context.read<GenerarQuestController>();
    await controller.generar(tema);

    if (!mounted) return;
    final quest = controller.questGenerada;

    if (controller.estado == GenerarQuestEstado.exito && quest != null) {
      Navigator.pushReplacement(
        context,
        buildRetroRoute(
          CombateScreen(
            idQuest: quest.quest.idQuest,
            idUsuario: widget.idUsuario,
            categoriaQuest: quest.quest.categoria,
            questCompleta: quest,
          ),
        ),
      );
    } else if (controller.estado == GenerarQuestEstado.error &&
        controller.mensajeError != null) {
      DialogoAlertaSysQuest.mostrar(
        context,
        titulo: 'AVISO DE QUEST',
        mensaje: controller.mensajeError!,
        colorPrimario: SysQuestColors.gold,
        textoBoton:
            controller.puedeUsarFallback ? 'JUGAR QUEST CURADA' : 'ENTENDIDO',
        onAceptar: controller.puedeUsarFallback ? _jugarQuestRespaldo : null,
        textoBotonSecundario:
            controller.puedeUsarFallback ? 'REINTENTAR IA' : null,
        onSecundario: controller.puedeUsarFallback ? _generarQuest : null,
      );
    }
  }

  void _jugarQuestRespaldo() {
    final controller = context.read<GenerarQuestController>();
    final idSemilla = controller.questSemillaAleatoria();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.pushReplacement(
      context,
      buildRetroRoute(
        CombateScreen(
          idQuest: idSemilla,
          idUsuario: widget.idUsuario,
          categoriaQuest: 'libre',
          questCompleta: null,
        ),
      ),
    );
  }

  void _cancelarGeneracion() {
    context.read<GenerarQuestController>().cancelar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SysQuestColors.dungeonVoid,
      body: SafeArea(
        child: DungeonMenuBackdrop(
          isDoorOpen: false,
          child: Consumer<GenerarQuestController>(
            builder: (context, controller, _) {
              final generando =
                  controller.estado == GenerarQuestEstado.generando;

              if (generando) {
                return _buildVistaGenerando();
              }

              return _buildVistaFormulario(controller);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVistaGenerando() {
    final mensajeActual = _mensajesCarga[_indiceMensaje];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: RetroPanelBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: SysQuestColors.dungeonVoid,
                      border: Border.all(
                        color: SysQuestColors.gold,
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: SysQuestColors.shadowBlack,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/sprites/frames/wizzard_m_idle_anim_f0.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.auto_awesome,
                        color: SysQuestColors.gold,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'GENERANDO QUEST',
                  textAlign: TextAlign.center,
                  style: SysQuestTypography.h2.copyWith(
                    color: SysQuestColors.gold,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    mensajeActual,
                    key: ValueKey<String>(mensajeActual),
                    textAlign: TextAlign.center,
                    style: SysQuestTypography.caption.copyWith(
                      color: SysQuestColors.manaCyan,
                      fontSize: 9,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                RetroPixelButton(
                  text: 'CANCELAR',
                  color: SysQuestColors.lifeRed,
                  textColor: SysQuestColors.parchmentText,
                  onPressed: _cancelarGeneracion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVistaFormulario(GenerarQuestController controller) {
    final error = _errorTema ?? controller.mensajeError;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: SysQuestColors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              RetroPanelBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'FORJAR NUEVA QUEST',
                      style: SysQuestTypography.h2.copyWith(
                        color: SysQuestColors.gold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El Oráculo de IA construirá una aventura según tu tema.',
                      style: SysQuestTypography.caption.copyWith(
                        color: SysQuestColors.parchmentText
                            .withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    RetroTextField(
                      controller: _temaController,
                      labelText: 'TEMA DE INGENIERÍA',
                      hintText: 'Ej. Recursividad, Grafos, SQL...',
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _generarQuest(),
                      prefixIcon: const Icon(Icons.code),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              SysQuestColors.lifeRed.withValues(alpha: 0.15),
                          border: Border.all(
                            color: SysQuestColors.lifeRed,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          error,
                          style: SysQuestTypography.caption.copyWith(
                            color: SysQuestColors.lifeRed,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    RetroPixelButton(
                      text: 'FORJAR QUEST',
                      color: SysQuestColors.gold,
                      textColor: SysQuestColors.dungeonVoid,
                      leadingSpriteFile: 'weapon_knight_sword.png',
                      onPressed: _generarQuest,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
