import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/transitions/retro_page_route.dart';
import '../../core/design_system/widgets/dungeon_menu_backdrop.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';
import '../../core/design_system/widgets/retro_text_field.dart';
import '../combate/combate_screen.dart';
import '../generar_quest/generar_quest_controller.dart';
import '../generar_quest/oracle_summoning_screen.dart';
import '../generar_quest/quest_retry_controller.dart';

class GenerarQuestScreen extends StatefulWidget {
  final String idUsuario;

  const GenerarQuestScreen({super.key, required this.idUsuario});

  @override
  State<GenerarQuestScreen> createState() => _GenerarQuestScreenState();
}

class _GenerarQuestScreenState extends State<GenerarQuestScreen> {
  final _temaController = TextEditingController();
  late final QuestGenerationRetryController _retryController;
  String? _errorTema;

  @override
  void initState() {
    super.initState();
    _retryController = QuestGenerationRetryController();
  }

  @override
  void dispose() {
    _retryController.dispose();
    _temaController.dispose();
    super.dispose();
  }

  void _generarQuest() {
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
    _retryController.reiniciar();

    Navigator.push(
      context,
      buildRetroRoute(
        OracleSummoningScreen(
          retryController: _retryController,
          controller: controller,
          tema: tema,
          idUsuario: widget.idUsuario,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SysQuestColors.dungeonVoid,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DungeonMenuBackdrop(
              isDoorOpen: false,
            ),
          ),
          Positioned.fill(
            child: Consumer<GenerarQuestController>(
              builder: (context, controller, _) {
                return _buildVistaFormulario(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVistaFormulario(GenerarQuestController controller) {
    final error = _errorTema ?? controller.mensajeError;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: topPadding + 16,
          bottom: 24,
          left: 20,
          right: 20,
        ),
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
                      if (controller.puedeUsarFallback) ...[
                        const SizedBox(height: 10),
                        RetroPixelButton(
                          text: 'MAZMORRA DE PRÁCTICA (MODO LOCAL)',
                          color: SysQuestColors.stonePanel,
                          textColor: SysQuestColors.gold,
                          onPressed: _jugarQuestRespaldo,
                        ),
                      ],
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
