import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/encuentro.dart';
import '../../../domain/entities/opcion_encuentro.dart';
import '../../../domain/usecases/responder_encuentro_usecase.dart';
import '../../../domain/entities/quest_completa.dart';
import '../../../domain/entities/wildcard.dart';
import '../../../domain/entities/visual_scene.dart';
import '../../theme/app_theme.dart';
import '../generar/generar_quest_screen.dart';
import '../progreso/progreso_screen.dart';
import '../../widgets/battle_fighter.dart';
import '../../widgets/battle_stage.dart';
import '../../widgets/enemy_damage_wrapper.dart';
import 'combate_controller.dart';
import '../../core/design_system/sysquest_theme.dart';
import '../../core/design_system/widgets/pixel_icon.dart';
import '../../core/design_system/widgets/retro_panel_box.dart';
import '../../core/design_system/widgets/retro_pixel_button.dart';

class CombateScreen extends StatefulWidget {
  final String idQuest;
  final String idUsuario;
  final String? categoriaQuest;
  final QuestCompleta? questCompleta;

  const CombateScreen({
    super.key,
    required this.idQuest,
    required this.idUsuario,
    this.categoriaQuest,
    this.questCompleta,
  });

  @override
  State<CombateScreen> createState() => _CombateScreenState();
}

class _CombateScreenState extends State<CombateScreen>
    with TickerProviderStateMixin {
  CombateController? _controller;
  ResultadoCombate? _resultadoMostrado;
  int? _danioEnemigoVisible;
  int? _danioJugadorVisible;
  int _danioEnemigoKey = 0;
  int _danioJugadorKey = 0;
  Timer? _ocultarDanioEnemigo;
  Timer? _ocultarDanioJugador;
  Timer? _hitFeedbackTimer;

  final GlobalKey<BattleFighterWidgetState> _playerFighterKey =
      GlobalKey<BattleFighterWidgetState>();
  final GlobalKey<BattleFighterWidgetState> _enemyFighterKey =
      GlobalKey<BattleFighterWidgetState>();
  bool _enemigoRecibioGolpe = false;
  bool _enemigoMuerto = false;

  late final AnimationController _temblorEnemigo;
  late final AnimationController _sacudidaPantalla;
  late final AnimationController _destelloCritico;
  double _sacudidaAmplitud = 8.0;

  @override
  void initState() {
    super.initState();
    _temblorEnemigo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _sacudidaPantalla = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _destelloCritico = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CombateController>();
      controller.addListener(_detectarCambioDeEstado);
      _controller = controller;
      controller.cargarQuest(
        widget.idQuest, 
        widget.idUsuario,
        poolNarrativo: widget.questCompleta?.poolNarrativo,
        preguntasExtra: widget.questCompleta?.preguntasExtra,
        semilla: widget.questCompleta?.semilla ?? 0,
        temaQuest: widget.questCompleta?.quest.tema ?? '',
        categoriaQuest: widget.categoriaQuest ?? widget.questCompleta?.quest.categoria ?? '',
        dificultadQuest: widget.questCompleta?.quest.dificultad ?? '',
      );
    });
  }

  void _detectarCambioDeEstado() {
    final controller = _controller;
    final resultado = controller?.resultadoUltimoTurno;
    if (controller == null || controller.cargando || resultado == null) return;
    if (identical(_resultadoMostrado, resultado)) return;
    _resultadoMostrado = resultado;

    final enemigoMurio = controller.vidaEnemigo <= 0;

    if (resultado.danoAlEnemigo > 0) {
      _sacudidaAmplitud = 4.0;
      _sacudidaPantalla.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) return;
        _mostrarDanioEnemigo(resultado.danoAlEnemigo);
        _temblorEnemigo.forward(from: 0);
        if (resultado.resultado == ResultadoTurno.critico) {
          _destelloCritico.forward(from: 0);
        }
      });

      // Embestida y tajo de espada del jugador con impacto a los 128ms
      _playerFighterKey.currentState?.playAttack(
        onImpactMoment: () {
          if (!mounted) return;
          setState(() {
            _enemigoRecibioGolpe = true;
            if (enemigoMurio) {
              _enemigoMuerto = true;
            }
          });

          _hitFeedbackTimer?.cancel();
          _hitFeedbackTimer = Timer(const Duration(milliseconds: 180), () {
            if (mounted) {
              setState(() {
                _enemigoRecibioGolpe = false;
              });
            }
          });
        },
      );
    }
    if (resultado.danoAlJugador > 0) {
      _sacudidaAmplitud = 8.0;
      _sacudidaPantalla.forward(from: 0);
      _mostrarDanioJugador(resultado.danoAlJugador);

      // Embestida del enemigo al contraatacar
      _enemyFighterKey.currentState?.playAttack(
        onImpactMoment: () {},
      );
    }
  }

  void _mostrarDanioEnemigo(int danio) {
    _ocultarDanioEnemigo?.cancel();
    if (mounted) {
      setState(() {
        _danioEnemigoVisible = danio;
        _danioEnemigoKey++;
      });
    }
    _ocultarDanioEnemigo = Timer(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => _danioEnemigoVisible = null);
    });
  }

  void _mostrarDanioJugador(int danio) {
    _ocultarDanioJugador?.cancel();
    if (mounted) {
      setState(() {
        _danioJugadorVisible = danio;
        _danioJugadorKey++;
      });
    }
    _ocultarDanioJugador = Timer(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => _danioJugadorVisible = null);
    });
  }

  @override
  void dispose() {
    _hitFeedbackTimer?.cancel();
    _ocultarDanioEnemigo?.cancel();
    _ocultarDanioJugador?.cancel();
    _controller?.removeListener(_detectarCambioDeEstado);
    _temblorEnemigo.dispose();
    _sacudidaPantalla.dispose();
    _destelloCritico.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final controller = _controller;
        if (controller == null || controller.combateTerminado) {
          Navigator.of(context).pop();
          return;
        }
        _mostrarMenuPausa(context);
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('SysQuest'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _mostrarMenuPausa(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.superficieNoche,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.doradoCritico.withValues(alpha: 0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.doradoCritico.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pause, color: AppTheme.doradoCritico, size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'PAUSA',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 9,
                          color: AppTheme.doradoCritico,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<CombateController>(
        builder: (context, controller, _) {
          if (controller.cargando) {
            return const Center(child: CircularProgressIndicator());
          }
          final encuentro = controller.encuentroActual;
          if (encuentro == null) {
            return const Center(
              child: Text('Aún no hay preguntas en esta quest.'),
            );
          }

          return AnimatedBuilder(
            animation: _sacudidaPantalla,
            builder: (context, child) {
              final desplazamiento =
                  math.sin(_sacudidaPantalla.value * math.pi * 12) * _sacudidaAmplitud;
              return Transform.translate(
                offset: Offset(desplazamiento, 0),
                child: child,
              );
            },
            child: _CombateContenido(
              controller: controller,
              turnoEnProceso: controller.turnoEnProceso,
              encuentro: encuentro,
              playerFighterKey: _playerFighterKey,
              enemyFighterKey: _enemyFighterKey,
              enemigoRecibioGolpe: _enemigoRecibioGolpe,
              enemigoMuerto: controller.vidaEnemigo <= 0 || _enemigoMuerto,
              categoria:
                  widget.categoriaQuest ??
                  (widget.idQuest == 'quest-001' ? 'debug' : null),
              danioEnemigo: _danioEnemigoVisible,
              danioEnemigoKey: _danioEnemigoKey,
              danioJugador: _danioJugadorVisible,
              danioJugadorKey: _danioJugadorKey,
              temblorEnemigo: _temblorEnemigo,
              destelloCritico: _destelloCritico,
              onElegirOpcion: controller.elegirOpcion,
              onContinuar: controller.continuarSiguienteEncuentro,
              onVolverAJugar: _volverAJugar,
              onCambiarTema: _jugarConOtroTema,
              onVerProgreso: _verProgreso,
              onDismissNarrativa: () {
                setState(() {
                  controller.mensajeNarrativoActual = null;
                });
                if (controller.encuentroSuperado) {
                  controller.continuarSiguienteEncuentro();
                }
              },
            ),
          );
        },
      ),
    ));
  }

  void _mostrarMenuPausa(BuildContext context) {
    final controller = _controller;
    if (controller == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.superficieNoche,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.doradoCritico, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.doradoCritico.withValues(alpha: 0.3),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PAUSA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 18,
                    color: AppTheme.doradoCritico,
                  ),
                ),
                const SizedBox(height: 20),
                _FilaStatPausa(
                  icono: Icons.star,
                  etiqueta: 'Score',
                  valor: '${controller.score}',
                ),
                const SizedBox(height: 10),
                _FilaStatPausa(
                  icono: Icons.flag,
                  etiqueta: 'Ronda',
                  valor: '${controller.ronda}',
                ),
                const SizedBox(height: 10),
                _FilaStatPausa(
                  icono: Icons.whatshot,
                  etiqueta: 'Enemigos derrotados',
                  valor: '${controller.enemigosDerrotados}',
                ),
                const SizedBox(height: 10),
                _FilaStatPausa(
                  icono: Icons.favorite,
                  etiqueta: 'Vida',
                  valor: '${controller.vidaJugador}/100',
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    controller.continuarCombate();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Continuar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.verdeVida,
                    foregroundColor: AppTheme.fondoNoche,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await controller.retirarse();
                    if (!mounted) return;
                    Navigator.of(this.context).pop();
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Retirarse de la run'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.rojoDanio,
                    side: const BorderSide(color: AppTheme.rojoDanio, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _volverAJugar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CombateScreen(idQuest: widget.idQuest, idUsuario: widget.idUsuario),
      ),
    );
  }

  void _jugarConOtroTema() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GenerarQuestScreen(idUsuario: widget.idUsuario),
      ),
    );
  }

  void _verProgreso() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProgresoScreen(idUsuario: widget.idUsuario),
      ),
    );
  }
}

class _CombateContenido extends StatelessWidget {
  final CombateController controller;
  final bool turnoEnProceso;
  final Encuentro encuentro;
  final GlobalKey<BattleFighterWidgetState> playerFighterKey;
  final GlobalKey<BattleFighterWidgetState> enemyFighterKey;
  final bool enemigoRecibioGolpe;
  final bool enemigoMuerto;
  final String? categoria;
  final int? danioEnemigo;
  final int danioEnemigoKey;
  final int? danioJugador;
  final int danioJugadorKey;
  final AnimationController temblorEnemigo;
  final AnimationController destelloCritico;
  final ValueChanged<OpcionEncuentro> onElegirOpcion;
  final VoidCallback onContinuar;
  final VoidCallback onVolverAJugar;
  final VoidCallback onCambiarTema;
  final VoidCallback onVerProgreso;
  final VoidCallback onDismissNarrativa;

  const _CombateContenido({
    required this.controller,
    required this.turnoEnProceso,
    required this.encuentro,
    required this.playerFighterKey,
    required this.enemyFighterKey,
    required this.enemigoRecibioGolpe,
    required this.enemigoMuerto,
    required this.categoria,
    required this.danioEnemigo,
    required this.danioEnemigoKey,
    required this.danioJugador,
    required this.danioJugadorKey,
    required this.temblorEnemigo,
    required this.destelloCritico,
    required this.onElegirOpcion,
    required this.onContinuar,
    required this.onVolverAJugar,
    required this.onCambiarTema,
    required this.onVerProgreso,
    required this.onDismissNarrativa,
  });

  void _mostrarConsolaCompleta(
    BuildContext context,
    List<String> historial,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 500),
          child: RetroPanelBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONSOLA DE EVENTOS',
                      style: SysQuestTypography.h3.copyWith(
                        color: SysQuestColors.gold,
                        fontSize: 10,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: SysQuestColors.parchmentText,
                        size: 18,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(color: SysQuestColors.stoneHighlight),
                Expanded(
                  child: _ConsolaNarrativa(historial: historial),
                ),
                const SizedBox(height: 10),
                RetroPixelButton(
                  text: 'CERRAR',
                  height: 36,
                  color: SysQuestColors.stonePanel,
                  textColor: SysQuestColors.parchmentText,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.mensajeNarrativoActual != null) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _PanelNarrativo(
              texto: controller.mensajeNarrativoActual!,
              onContinuar: onDismissNarrativa,
            ),
          ),
        ),
      );
    } else if (controller.encuentroSuperado) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: controller.eventoActivo != null && !controller.esFinDeRonda
                ? _EventoDecisionCard(
                    evento: controller.eventoActivo!,
                    visualScene: controller.eventoActualVisual?.visualScene,
                    vidaActual: controller.vidaJugador,
                    onSeleccionar: controller.resolverEventoDecision,
                  )
                : _RondaSuperada(
                    rondaActual: controller.ronda,
                    vidaActual: controller.vidaJugador,
                    onDescansoSeguro: () =>
                        controller.continuarSiguienteRonda(temerario: false),
                    onPactoTemerario: () =>
                        controller.continuarSiguienteRonda(temerario: true),
                    onRetirarseConBotin: () => controller.retirarse(),
                  ),
          ),
        ),
      );
    } else if (controller.combateTerminado) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _FinCombate(
            controller: controller,
            onVolverAJugar: onVolverAJugar,
            onCambiarTema: onCambiarTema,
            onVerProgreso: onVerProgreso,
          ),
        ),
      );
    }

    // COMBATE ACTIVO: ZERO-SCROLL ESTRICTO
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Arena de Combate (Altura fija 220px)
          SizedBox(
            height: 220,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: BattleStage(
                    playerActor: BattleFighterWidget(
                      key: playerFighterKey,
                      characterPrefix: 'knight_m',
                      weaponSprite: 'weapon_knight_sword.png',
                      isEnemy: false,
                    ),
                    enemyActor: EnemyDamageAndDeathWrapper(
                      isHit: enemigoRecibioGolpe,
                      isDead: enemigoMuerto,
                      child: BattleFighterWidget(
                        key: enemyFighterKey,
                        characterPrefix:
                            encuentro.esJefe ? 'big_demon' : 'goblin',
                        weaponSprite: encuentro.esJefe
                            ? 'weapon_cleaver.png'
                            : 'weapon_knife.png',
                        isEnemy: true,
                      ),
                    ),
                  ),
                ),

                // Arriba a la derecha: Barra de vida del enemigo (primero en árbol para barras.at(0))
                Positioned(
                  top: 8,
                  right: 8,
                  child: _BarraVidaEnemigoCompacta(
                    vida: controller.vidaEnemigo,
                    vidaMaxima: encuentro.vidaEnemigo,
                    danio: danioEnemigo,
                    danioKey: danioEnemigoKey,
                  ),
                ),

                // Arriba a la izquierda: Barra de vida del héroe (segundo en árbol para barras.at(1))
                Positioned(
                  top: 8,
                  left: 8,
                  child: _BarraVidaHeroeCompacta(
                    vida: controller.vidaJugador,
                    danio: danioJugador,
                    danioKey: danioJugadorKey,
                  ),
                ),

                // Badge Temerario si aplica
                if (controller.modoTemerarioActivo)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              SysQuestColors.dungeonVoid.withValues(alpha: 0.85),
                          border:
                              Border.all(color: SysQuestColors.lifeRed, width: 2),
                        ),
                        child: Text(
                          'TEMERARIO x2',
                          style: SysQuestTypography.caption.copyWith(
                            color: SysQuestColors.lifeRed,
                            fontSize: 7,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Ticker abajo (28px)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 28,
                  child: _TickerNarrativoArena(
                    ultimoMensaje: controller.historialNarrativo.isNotEmpty
                        ? controller.historialNarrativo.last
                        : 'El combate ha comenzado...',
                    onTap: () => _mostrarConsolaCompleta(
                      context,
                      controller.historialNarrativo,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Fila de Comodines (Altura fija 60px)
          SizedBox(
            height: 60,
            child: _FilaWildcardsZeroScroll(
              wildcards: controller.wildcards,
              pistaActiva: controller.pistaActiva,
              golpeDobleActivo: controller.golpeDobleActivo,
              roboDeVidaActivo: controller.roboDeVidaActivo,
              turnoEnProceso: turnoEnProceso,
              onUsarWildcard: controller.usarWildcard,
            ),
          ),

          // 3. Pregunta (Expanded flex: 4)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: RetroPanelBox(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.pistaActiva != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: SysQuestColors.dungeonVoid,
                              border: Border.all(
                                  color: SysQuestColors.gold, width: 1.5),
                            ),
                            child: Text(
                              'PISTA: ${controller.pistaActiva}',
                              style: SysQuestTypography.caption.copyWith(
                                color: SysQuestColors.gold,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        Text(
                          encuentro.pregunta,
                          style: SysQuestTypography.body.copyWith(
                            color: SysQuestColors.parchmentText,
                            fontSize: 10,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Opciones (Expanded flex: 6)
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
              child: Column(
                children: encuentro.opciones.map((opcion) {
                  final descartada =
                      controller.opcionesOcultas.contains(opcion.texto);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: descartada
                          ? const RetroPixelButton(
                              text: '--- DESCARTADA ---',
                              height: null,
                              enabled: false,
                              color: SysQuestColors.dungeonVoid,
                              textColor: SysQuestColors.disabledGray,
                            )
                          : RetroPixelButton(
                              text: '${opcion.letra}  ${opcion.texto}',
                              height: null,
                              enabled: !turnoEnProceso,
                              color: SysQuestColors.stonePanel,
                              textColor: SysQuestColors.parchmentText,
                              onPressed: turnoEnProceso
                                  ? null
                                  : () => onElegirOpcion(opcion),
                            ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraVidaHeroeCompacta extends StatelessWidget {
  final int vida;
  final int? danio;
  final int danioKey;

  const _BarraVidaHeroeCompacta({
    required this.vida,
    required this.danio,
    required this.danioKey,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: SysQuestColors.dungeonVoid.withValues(alpha: 0.85),
            border: Border.all(color: SysQuestColors.borderBlack, width: 2),
            boxShadow: const [
              BoxShadow(
                color: SysQuestColors.shadowBlack,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HÉROE $vida/100',
                style: SysQuestTypography.caption.copyWith(
                  color: AppTheme.verdeVida,
                  fontSize: 7,
                ),
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: LinearProgressIndicator(
                  value: (vida / 100).clamp(0.0, 1.0),
                  color: AppTheme.verdeVida,
                  backgroundColor: SysQuestColors.stonePanel,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        if (danio != null)
          Positioned(
            top: -8,
            right: 12,
            child: _NumeroDanio(
              key: ValueKey(danioKey),
              valor: danio!,
              color: SysQuestColors.lifeRed,
            ),
          ),
      ],
    );
  }
}

class _BarraVidaEnemigoCompacta extends StatelessWidget {
  final int vida;
  final int vidaMaxima;
  final int? danio;
  final int danioKey;

  const _BarraVidaEnemigoCompacta({
    required this.vida,
    required this.vidaMaxima,
    required this.danio,
    required this.danioKey,
  });

  @override
  Widget build(BuildContext context) {
    final maximo = vidaMaxima > 0 ? vidaMaxima : 100;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: SysQuestColors.dungeonVoid.withValues(alpha: 0.85),
            border: Border.all(color: SysQuestColors.borderBlack, width: 2),
            boxShadow: const [
              BoxShadow(
                color: SysQuestColors.shadowBlack,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ENEMIGO $vida/$maximo',
                style: SysQuestTypography.caption.copyWith(
                  color: SysQuestColors.lifeRed,
                  fontSize: 7,
                ),
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: LinearProgressIndicator(
                  value: (vida / maximo).clamp(0.0, 1.0),
                  color: SysQuestColors.lifeRed,
                  backgroundColor: SysQuestColors.stonePanel,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        if (danio != null)
          Positioned(
            top: -8,
            right: 12,
            child: _NumeroDanio(
              key: ValueKey(danioKey),
              valor: danio!,
              color: SysQuestColors.lifeRed,
            ),
          ),
      ],
    );
  }
}

class _TickerNarrativoArena extends StatelessWidget {
  final String ultimoMensaje;
  final VoidCallback onTap;

  const _TickerNarrativoArena({
    required this.ultimoMensaje,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          border: Border(
            top: BorderSide(
              color: SysQuestColors.stoneHighlight.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.terminal,
              color: SysQuestColors.gold,
              size: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ultimoMensaje,
                style: SysQuestTypography.caption.copyWith(
                  color: SysQuestColors.gold,
                  fontSize: 8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.unfold_more,
              color: SysQuestColors.gold,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaWildcardsZeroScroll extends StatelessWidget {
  final Map<TipoWildcard, int> wildcards;
  final String? pistaActiva;
  final bool golpeDobleActivo;
  final bool roboDeVidaActivo;
  final bool turnoEnProceso;
  final ValueChanged<TipoWildcard> onUsarWildcard;

  const _FilaWildcardsZeroScroll({
    required this.wildcards,
    required this.pistaActiva,
    required this.golpeDobleActivo,
    required this.roboDeVidaActivo,
    required this.turnoEnProceso,
    required this.onUsarWildcard,
  });

  String _spriteDeWildcard(TipoWildcard tipo) {
    switch (tipo) {
      case TipoWildcard.cincuentaCincuenta:
        return 'weapon_knife.png';
      case TipoWildcard.roboDeVida:
        return 'flask_big_green.png';
      case TipoWildcard.golpeDoble:
        return 'weapon_waraxe.png';
      case TipoWildcard.pista:
        return 'flask_big_yellow.png';
    }
  }

  bool _esActivo(TipoWildcard tipo) {
    if (tipo == TipoWildcard.pista) return pistaActiva != null;
    if (tipo == TipoWildcard.golpeDoble) return golpeDobleActivo;
    if (tipo == TipoWildcard.roboDeVida) return roboDeVidaActivo;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: TipoWildcard.values.map((tipo) {
          final cantidad = wildcards[tipo] ?? 0;
          final activo = _esActivo(tipo);
          final habilitado = cantidad > 0 && !turnoEnProceso;

          return _BotonComodinCuadrado(
            spriteFileName: _spriteDeWildcard(tipo),
            cantidad: cantidad,
            activo: activo,
            habilitado: habilitado,
            onPressed: () => onUsarWildcard(tipo),
          );
        }).toList(),
      ),
    );
  }
}

class _BotonComodinCuadrado extends StatelessWidget {
  final String spriteFileName;
  final int cantidad;
  final bool activo;
  final bool habilitado;
  final VoidCallback onPressed;

  const _BotonComodinCuadrado({
    required this.spriteFileName,
    required this.cantidad,
    required this.activo,
    required this.habilitado,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (activo) {
      borderColor = SysQuestColors.manaCyan;
    } else if (habilitado) {
      borderColor = SysQuestColors.stoneHighlight;
    } else {
      borderColor = SysQuestColors.borderBlack;
    }

    return GestureDetector(
      onTap: habilitado ? onPressed : null,
      child: Opacity(
        opacity: habilitado ? 1.0 : 0.45,
        child: Container(
          width: 52,
          height: 48,
          decoration: BoxDecoration(
            color: SysQuestColors.stonePanel,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: habilitado
                ? const [
                    BoxShadow(
                      color: SysQuestColors.shadowBlack,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelIcon(fileName: spriteFileName, size: 22),
              const SizedBox(height: 2),
              Text(
                'x$cantidad',
                style: SysQuestTypography.caption.copyWith(
                  fontSize: 7,
                  color: habilitado
                      ? (activo ? SysQuestColors.manaCyan : SysQuestColors.gold)
                      : SysQuestColors.disabledGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RondaSuperada extends StatelessWidget {
  final VoidCallback onDescansoSeguro;
  final VoidCallback onPactoTemerario;
  final VoidCallback onRetirarseConBotin;
  final int rondaActual;
  final int vidaActual;

  const _RondaSuperada({
    required this.onDescansoSeguro,
    required this.onPactoTemerario,
    required this.onRetirarseConBotin,
    required this.rondaActual,
    required this.vidaActual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.superficieNoche,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.doradoCritico, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.doradoCritico, size: 48),
          const SizedBox(height: 8),
          Text(
            '¡RONDA $rondaActual SUPERADA!',
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 12,
              color: AppTheme.doradoCritico,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Vida actual: $vidaActual/100 HP',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Elige tu destino para la siguiente ronda:',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: AppTheme.azulTexto,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.verdeVida,
                foregroundColor: AppTheme.fondoNoche,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onDescansoSeguro,
              child: const Text(
                '🛡️ Descanso Seguro (+25 HP)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.rojoDanio,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onPactoTemerario,
              child: const Text(
                '💀 Pacto Temerario (-10 HP | +30% Daño y +200 pts)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: onRetirarseConBotin,
              child: const Text(
                '💰 Retirarse con el botín actual',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpriteSceneViewer extends StatelessWidget {
  final VisualScene visualScene;

  const _SpriteSceneViewer({required this.visualScene});

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      final buffer = StringBuffer();
      if (clean.length == 6) {
        buffer.write('FF');
        buffer.write(clean);
      } else if (clean.length == 8) {
        buffer.write(clean);
      } else {
        return AppTheme.azulTexto;
      }
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppTheme.azulTexto;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _parseColor(visualScene.tintHex);

    // TODO: Integrar SpriteAnimationWidget de Flame aquí
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.fondoNoche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              visualScene.visualTag,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 11,
                color: borderColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Bioma: ${visualScene.biomeTag} | Efecto: ${visualScene.screenEffect}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventoDecisionCard extends StatelessWidget {
  final EventoDecision evento;
  final VisualScene? visualScene;
  final int vidaActual;
  final void Function(String) onSeleccionar;

  const _EventoDecisionCard({
    required this.evento,
    this.visualScene,
    required this.vidaActual,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.superficieNoche,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.azulTexto, width: 2),
      ),
      child: Column(
        children: [
          if (visualScene != null) _SpriteSceneViewer(visualScene: visualScene!),
          Text(
            evento.iconoEmoji,
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 8),
          Text(
            evento.titulo,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 11,
              color: AppTheme.azulTexto,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Vida actual: $vidaActual/100 HP',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            evento.descripcion,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          for (final opcion in evento.opciones) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.superficieElevada,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.azulTexto),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
                onPressed: () => onSeleccionar(opcion.codigoAccion),
                child: Text(
                  opcion.etiqueta,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _FinCombate extends StatelessWidget {
  final CombateController controller;
  final VoidCallback onVolverAJugar;
  final VoidCallback onCambiarTema;
  final VoidCallback onVerProgreso;

  const _FinCombate({
    required this.controller,
    required this.onVolverAJugar,
    required this.onCambiarTema,
    required this.onVerProgreso,
  });

  @override
  Widget build(BuildContext context) {
    final gano = controller.jugadorGano;
    final guardando = controller.guardandoResultado;

    return Column(
      children: [
        Icon(
          gano ? Icons.emoji_events : Icons.close,
          color: gano ? AppTheme.doradoCritico : AppTheme.rojoDanio,
          size: 72,
        ),
        const SizedBox(height: 12),
        Text(
          gano ? '¡Victoria!' : 'Derrota',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _ResumenPartidaCard(controller: controller),
        const SizedBox(height: 12),
        Text(
          guardando ? 'Guardando progreso...' : 'Progreso guardado',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (!guardando) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onVolverAJugar,
            child: const Text('Volver a jugar'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.verdeVida,
              foregroundColor: Colors.black,
            ),
            onPressed: onCambiarTema,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Volver a Jugar con otro tema'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onVerProgreso,
            child: const Text('Mi progreso'),
          ),
        ],
      ],
    );
  }
}

class _ResumenPartidaCard extends StatelessWidget {
  final CombateController controller;

  const _ResumenPartidaCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.superficieNoche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.superficieElevada, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'RESUMEN DE LA RUN',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 11,
                color: AppTheme.azulTexto,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _FilaResumen(
            etiqueta: '⚔️ Enemigos derrotados (${controller.enemigosDerrotados})',
            valor: '+${controller.puntosPorEnemigos} pts',
          ),
          const SizedBox(height: 8),
          _FilaResumen(
            etiqueta: '🔥 Racha máxima (x${controller.rachaMaxima})',
            valor: '+${controller.bonusPorRacha} pts',
          ),
          if (controller.ganoCombate) ...[
            const SizedBox(height: 8),
            _FilaResumen(
              etiqueta: '🏆 Bonus de Victoria',
              valor: '+${controller.bonusPorVictoria} pts',
            ),
          ],
          if (controller.rondasTemerariasSuperadas > 0) ...[
            const SizedBox(height: 8),
            _FilaResumen(
              etiqueta: '💀 Rondas temerarias (${controller.rondasTemerariasSuperadas})',
              valor: '+${controller.bonusPorTemerario} pts',
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⭐ SCORE TOTAL:',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 10,
                  color: AppTheme.doradoCritico,
                ),
              ),
              Text(
                '${controller.scoreFinalMostrado} pts',
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 10,
                  color: AppTheme.doradoCritico,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '✨ XP GANADA:',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 10,
                  color: AppTheme.verdeVida,
                ),
              ),
              Text(
                '+${controller.xpFinalMostrada} XP',
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 10,
                  color: AppTheme.verdeVida,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaResumen({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _NumeroDanio extends StatefulWidget {
  final int valor;
  final Color color;

  const _NumeroDanio({super.key, required this.valor, required this.color});

  @override
  State<_NumeroDanio> createState() => _NumeroDanioState();
}

class _NumeroDanioState extends State<_NumeroDanio> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacidad;
  late final Animation<double> _desplazamiento;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacidad = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15), 
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),          
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25), 
    ]).animate(_controller);

    _desplazamiento = Tween<double>(begin: 0.0, end: -40.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esCritico = widget.valor >= 25;
    final double fontSize = esCritico ? 32 : 24;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacidad.value,
        child: Transform.translate(
          offset: Offset(0, _desplazamiento.value),
          child: child,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            '-${widget.valor}',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: fontSize,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = Colors.black,
            ),
          ),
          Text(
            '-${widget.valor}',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: fontSize,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelNarrativo extends StatelessWidget {
  final String texto;
  final VoidCallback onContinuar;

  const _PanelNarrativo({
    required this.texto,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.superficieElevada,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.azulTexto.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.azulTexto.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.azulTexto, size: 48),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.azulTexto,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'NUEVO',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 8,
                color: AppTheme.fondoNoche,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppTheme.azulTexto,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: onContinuar,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.azulTexto,
              foregroundColor: AppTheme.fondoNoche,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsolaNarrativa extends StatefulWidget {
  final List<String> historial;
  const _ConsolaNarrativa({required this.historial});
  
  @override
  State<_ConsolaNarrativa> createState() => _ConsolaNarrativaState();
}

class _ConsolaNarrativaState extends State<_ConsolaNarrativa> {
  bool _expandida = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.superficieNoche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.superficieElevada, width: 2),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandida = !_expandida),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '> HISTORIAL DE LA RUN',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: AppTheme.azulTexto,
                    ),
                  ),
                  Icon(
                    _expandida ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.azulTexto,
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: _expandida ? 180 : 0,
              padding: _expandida
                  ? const EdgeInsets.fromLTRB(12, 0, 12, 12)
                  : EdgeInsets.zero,
              child: ListView.builder(
                itemCount: widget.historial.length,
                itemBuilder: (context, index) {
                  final estilo = _EstiloLineaNarrativa.parse(widget.historial[index]);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: estilo.colorFondo,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      border: Border(
                        left: BorderSide(
                          color: estilo.colorBorde,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      estilo.texto,
                      style: TextStyle(
                        fontSize: 12,
                        color: estilo.colorTexto,
                        fontStyle: estilo.fontStyle,
                        height: 1.4,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstiloLineaNarrativa {
  final String texto;
  final Color colorTexto;
  final Color colorBorde;
  final Color colorFondo;
  final FontStyle fontStyle;

  const _EstiloLineaNarrativa({
    required this.texto,
    required this.colorTexto,
    required this.colorBorde,
    required this.colorFondo,
    this.fontStyle = FontStyle.normal,
  });

  factory _EstiloLineaNarrativa.parse(String linea) {
    if (linea.startsWith('[CRITICO]')) {
      return _EstiloLineaNarrativa(
        texto: linea.substring('[CRITICO]'.length).trimLeft(),
        colorTexto: AppTheme.doradoCritico,
        colorBorde: AppTheme.doradoCritico,
        colorFondo: AppTheme.doradoCritico.withValues(alpha: 0.08),
      );
    } else if (linea.startsWith('[RACHA]')) {
      return _EstiloLineaNarrativa(
        texto: linea.substring('[RACHA]'.length).trimLeft(),
        colorTexto: AppTheme.doradoCritico,
        colorBorde: AppTheme.doradoCritico,
        colorFondo: AppTheme.doradoCritico.withValues(alpha: 0.08),
      );
    } else if (linea.startsWith('[ACIERTO]')) {
      return _EstiloLineaNarrativa(
        texto: linea.substring('[ACIERTO]'.length).trimLeft(),
        colorTexto: AppTheme.azulTexto,
        colorBorde: AppTheme.azulTexto,
        colorFondo: AppTheme.azulTexto.withValues(alpha: 0.08),
      );
    } else if (linea.startsWith('[CONTRAATAQUE]')) {
      return _EstiloLineaNarrativa(
        texto: linea.substring('[CONTRAATAQUE]'.length).trimLeft(),
        colorTexto: AppTheme.rojoDanio,
        colorBorde: AppTheme.rojoDanio,
        colorFondo: AppTheme.rojoDanio.withValues(alpha: 0.10),
      );
    } else if (linea.startsWith('[COMODIN]')) {
      return _EstiloLineaNarrativa(
        texto: linea.substring('[COMODIN]'.length).trimLeft(),
        colorTexto: AppTheme.verdeVida,
        colorBorde: AppTheme.verdeVida,
        colorFondo: AppTheme.verdeVida.withValues(alpha: 0.08),
      );
    } else {
      final texto = linea.startsWith('[HISTORIA]')
          ? linea.substring('[HISTORIA]'.length).trimLeft()
          : linea;
      return _EstiloLineaNarrativa(
        texto: texto,
        colorTexto: Colors.white70,
        colorBorde: Colors.white24,
        colorFondo: Colors.white.withValues(alpha: 0.03),
        fontStyle: FontStyle.italic,
      );
    }
  }
}

class _FilaStatPausa extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _FilaStatPausa({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.superficieElevada,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.azulTexto.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icono, color: AppTheme.azulTexto, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: AppTheme.azulTexto,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 12,
              color: AppTheme.doradoCritico,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicadorRacha extends StatefulWidget {
  final int racha;
  const _IndicadorRacha({required this.racha});

  @override
  State<_IndicadorRacha> createState() => _IndicadorRachaState();
}

class _IndicadorRachaState extends State<_IndicadorRacha>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  int _rachaAnterior = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _rachaAnterior = widget.racha;
    _controller.forward(from: 0).then((_) {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void didUpdateWidget(_IndicadorRacha oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.racha != _rachaAnterior) {
      _rachaAnterior = widget.racha;
      _controller.forward(from: 0).then((_) {
        if (mounted) _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.racha >= 7
        ? Colors.orange
        : (widget.racha >= 5 ? Colors.deepOrange : AppTheme.doradoCritico);

    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'RACHA x${widget.racha}',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
