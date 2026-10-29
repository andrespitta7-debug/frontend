import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/encuentro.dart';
import '../../../domain/entities/opcion_encuentro.dart';
import '../../../domain/entities/personaje_partida.dart';
import '../../../domain/repositories/quest_repository.dart';
import '../../../domain/usecases/finalizar_partida_usecase.dart';
import '../../../domain/usecases/generar_encuentros_extra_usecase.dart';
import '../../../domain/usecases/responder_encuentro_usecase.dart';
import '../../../domain/entities/wildcard.dart';
import '../../../domain/entities/visual_scene.dart';

class OpcionEvento {
  final String etiqueta;
  final String codigoAccion; // 'estudiar_codice', 'destruir_codice', 'mercader_curar', 'mercader_poder', 'fuente_canalizar', 'ignorar'
  const OpcionEvento({required this.etiqueta, required this.codigoAccion});
}

class EventoDecision {
  final String titulo;
  final String descripcion;
  final String iconoEmoji;
  final List<OpcionEvento> opciones;
  const EventoDecision({
    required this.titulo,
    required this.descripcion,
    required this.iconoEmoji,
    required this.opciones,
  });
}

class CombateController extends ChangeNotifier {
  final QuestRepository _questRepository;
  final ResponderEncuentroUseCase _responderUseCase;
  final FinalizarPartidaUseCase _finalizarUseCase;
  final GenerarEncuentrosExtraUseCase _generarExtraUseCase;
  final Duration duracionPausaTurno;
  final _uuid = const Uuid();
  bool _disposed = false;
  Timer? _timerPausaTurno;
  Completer<void>? _completerPausaTurno;

  CombateController(
    this._questRepository,
    this._responderUseCase,
    this._finalizarUseCase,
    this._generarExtraUseCase, {
    this.duracionPausaTurno = const Duration(milliseconds: 700),
  });

  List<Encuentro> _encuentros = [];
  List<Encuentro> _preguntasExtra = [];
  int _indiceActual = 0;
  Encuentro? _preguntaActiva;
  Map<String, dynamic>? _poolNarrativo;
  int _poolNarrativoSemilla = 0;
  String _temaQuest = '';
  String _categoriaQuest = '';
  String _dificultadQuest = 'facil';
  late Partida _partida;

  int vidaJugador = 100;
  int vidaEnemigo = 30;
  String? mensajeUltimoTurno;
  String? mensajeNarrativoActual;
  int _score = 0;
  int _enemigosDerrotados = 0;
  int _ronda = 1;
  int _rachaActual = 0;
  int _rachaMaxima = 0;
  bool _modoTemerarioActivo = false;
  int _rondasTemerariasSuperadas = 0;
  EventoDecision? _eventoActivo;
  GameEvent? eventoActualVisual;

  int get score => _score;
  int get enemigosDerrotados => _enemigosDerrotados;
  int get ronda => _ronda;
  int get rachaActual => _rachaActual;
  int get rachaMaxima => _rachaMaxima;
  bool get modoTemerarioActivo => _modoTemerarioActivo;
  int get rondasTemerariasSuperadas => _rondasTemerariasSuperadas;
  int get bonusPorTemerario => _rondasTemerariasSuperadas * 200;
  bool get esperandoDecisionRonda => encuentroSuperado;
  EventoDecision? get eventoActivo => _eventoActivo;
  bool get esFinDeRonda => _enemigosDerrotados > 0 && _enemigosDerrotados % 3 == 0;
  String get temaQuest => _temaQuest;
  String get categoriaQuest => _categoriaQuest;
  String get dificultadQuest => _dificultadQuest;

  bool get ganoCombate => jugadorGano;
  int get puntosPorEnemigos => _enemigosDerrotados * 100;
  int get bonusPorRacha => _rachaMaxima >= 7 ? 150 : (_rachaMaxima >= 5 ? 50 : 0);
  int get bonusPorVictoria => ganoCombate ? 150 : 0;
  int get scoreFinalMostrado => _partida.score > 0 ? _partida.score : _score;
  int get xpFinalMostrada => _partida.xpObtenida;

  double get multiplicadorRacha {
    if (_rachaActual >= 7) return 1.75;
    if (_rachaActual >= 5) return 1.5;
    if (_rachaActual >= 3) return 1.25;
    return 1.0;
  }

  final Map<TipoWildcard, int> _wildcards = {};
  final Set<String> _opcionesOcultas = {};
  bool _golpeDobleActivo = false;
  bool _roboDeVidaActivo = false;
  String? _pistaActiva;

  Map<TipoWildcard, int> get wildcards => Map.unmodifiable(_wildcards);
  Set<String> get opcionesOcultas => Set.unmodifiable(_opcionesOcultas);
  bool get golpeDobleActivo => _golpeDobleActivo;
  bool get roboDeVidaActivo => _roboDeVidaActivo;
  String? get pistaActiva => _pistaActiva;

  final List<String> _historialNarrativo = [];
  List<String> get historialNarrativo => List.unmodifiable(_historialNarrativo);
  ResultadoCombate? resultadoUltimoTurno;
  bool cargando = true;
  bool encuentroSuperado = false; // se venció al enemigo actual, pero faltan más
  bool combateTerminado = false; // se acabó TODA la quest (ganada, perdida o retirada)
  bool jugadorGano = false;
  bool guardandoResultado = false;
  bool turnoEnProceso = false;
  bool enPausa = false;
  bool _generandoExtra = false;

  Future<void> _solicitarMasEncuentros() async {
    if (_generandoExtra) return;
    _generandoExtra = true;

    try {
      int ultimoNumero = 0;
      if (_encuentros.isNotEmpty) {
        ultimoNumero = _encuentros.map((e) => e.numero).reduce((a, b) => a > b ? a : b);
      }
      if (_preguntasExtra.isNotEmpty) {
        final maxExtra = _preguntasExtra.map((e) => e.numero).reduce((a, b) => a > b ? a : b);
        if (maxExtra > ultimoNumero) ultimoNumero = maxExtra;
      }

      // Necesitamos el tema, categoria, dificultad del quest. Lo sacamos del primer encuentro o partida
      // Asumiremos que tenemos esta info en los encuentros actuales.
      final primerEncuentro = _encuentros.first;
      
      final nuevosEncuentros = await _generarExtraUseCase.ejecutar(
        idQuest: primerEncuentro.idQuest,
        tema: _temaQuest,
        categoria: _categoriaQuest,
        dificultad: _dificultadQuest,
        ultimoNumero: ultimoNumero,
      );

      if (!_disposed) {
        _preguntasExtra.addAll(nuevosEncuentros);
      }
    } catch (e) {
      debugPrint('Error solicitando más encuentros: $e');
    } finally {
      if (!_disposed) _generandoExtra = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timerPausaTurno?.cancel();
    if (_completerPausaTurno != null && !_completerPausaTurno!.isCompleted) {
      _completerPausaTurno!.complete();
    }
    super.dispose();
  }

  /// Retorna el encuentro actual combinando los metadatos del enemigo en turno
  /// con la pregunta activa (sea la original o una extra tras fallar).
  Encuentro? get encuentroActual {
    if (_encuentros.isEmpty || _indiceActual >= _encuentros.length) return null;
    final enemigo = _encuentros[_indiceActual];
    final pregunta = _preguntaActiva ?? enemigo;

    if (identical(enemigo, pregunta)) {
      return enemigo;
    }

    return Encuentro(
      idEncuentro: pregunta.idEncuentro,
      idQuest: enemigo.idQuest,
      numero: enemigo.numero,
      pregunta: pregunta.pregunta,
      dificultad: enemigo.dificultad,
      tipoEncuentro: enemigo.tipoEncuentro,
      vidaEnemigo: enemigo.vidaEnemigo,
      enemigo: enemigo.enemigo,
      opciones: pregunta.opciones,
    );
  }

  /// Cantidad de preguntas extra restantes en cola.
  int get preguntasExtraRestantes => _preguntasExtra.length;

  /// Partida actual.
  Partida get partida => _partida;

  /// Semilla para RNG narrativo.
  int get poolNarrativoSemilla => _poolNarrativoSemilla;

  /// Consume y remueve el primer fragmento disponible de una categoría del pool narrativo.
  String? _consumirFragmentoNarrativo(String categoria) {
    if (_poolNarrativo == null) return null;
    final lista = _poolNarrativo![categoria];
    if (lista is List && lista.isNotEmpty) {
      final fragmento = lista.removeAt(0);
      return fragmento.toString();
    }
    return null;
  }

  void _setMensajeNarrativo(String? mensaje) {
    mensajeNarrativoActual = mensaje;
    if (mensaje != null) {
      _historialNarrativo.insert(0, mensaje);
    }
  }

  void _agregarNarrativa(String mensaje) {
    _historialNarrativo.insert(0, mensaje);
  }

  Future<void> cargarQuest(
    String idQuest,
    String idUsuario, {
    Map<String, dynamic>? poolNarrativo,
    List<Encuentro>? preguntasExtra,
    int semilla = 0,
    String temaQuest = '',
    String categoriaQuest = '',
    String dificultadQuest = '',
  }) async {
    cargando = true;
    combateTerminado = false;
    encuentroSuperado = false;
    enPausa = false;
    resultadoUltimoTurno = null;
    mensajeUltimoTurno = null;
    vidaJugador = 100;
    _score = 0;
    _enemigosDerrotados = 0;
    _ronda = 1;
    _rachaActual = 0;
    _rachaMaxima = 0;
    _modoTemerarioActivo = false;
    _rondasTemerariasSuperadas = 0;
    _eventoActivo = null;
    eventoActualVisual = null;
    _historialNarrativo.clear();
    turnoEnProceso = false;

    _wildcards.clear();
    for (final tipo in TipoWildcard.values) {
      _wildcards[tipo] = 1;
    }
    _opcionesOcultas.clear();
    _golpeDobleActivo = false;
    _roboDeVidaActivo = false;
    _pistaActiva = null;
    _poolNarrativo = poolNarrativo != null ? Map<String, dynamic>.from(poolNarrativo) : null;
    _preguntasExtra = preguntasExtra != null ? List<Encuentro>.from(preguntasExtra) : [];
    notifyListeners();

    final encuentrosCargados = await _questRepository.obtenerEncuentros(idQuest);

    final todosNormales = encuentrosCargados.where((e) => !e.esJefe).toList();
    final jefes = encuentrosCargados.where((e) => e.esJefe).toList();

    List<Encuentro> normales;
    // Si la quest incluye preguntas extra (números > 3) en la misma lista y no se pasaron aparte
    if (_preguntasExtra.isEmpty && todosNormales.any((e) => e.numero > 3)) {
      normales = todosNormales.where((e) => e.numero <= 3).toList()..shuffle();
      _preguntasExtra = todosNormales.where((e) => e.numero > 3).toList();
    } else {
      normales = todosNormales..shuffle();
    }

    _encuentros = [...normales, ...jefes];
    _indiceActual = 0;

    if (poolNarrativo != null) {
      _poolNarrativo = poolNarrativo;
    }
    if (preguntasExtra != null && preguntasExtra.isNotEmpty) {
      _preguntasExtra = List<Encuentro>.from(preguntasExtra);
    }
    _poolNarrativoSemilla = semilla;

    _temaQuest = (temaQuest.trim().length >= 3)
        ? temaQuest.trim()
        : 'Aventura General';
    _categoriaQuest = categoriaQuest.trim().isNotEmpty
        ? categoriaQuest.trim()
        : 'libre';
    _dificultadQuest = dificultadQuest.trim().isNotEmpty
        ? dificultadQuest.trim()
        : 'facil';

    if (_encuentros.isNotEmpty) {
      vidaEnemigo = _encuentros.first.vidaEnemigo;
      _preguntaActiva = _encuentros.first;
    }

    _partida = Partida(
      idPartida: _uuid.v4(),
      idUsuario: idUsuario,
      idQuest: idQuest,
    );

    _setMensajeNarrativo(_consumirFragmentoNarrativo('intro'));
    cargando = false;
    notifyListeners();
  }

  Future<void> elegirOpcion(OpcionEncuentro opcion) async {
    if (combateTerminado || encuentroSuperado || turnoEnProceso || enPausa) return;

    turnoEnProceso = true;
    notifyListeners();

    final enemigoActual = _encuentros[_indiceActual];
    final resultado = _responderUseCase.ejecutar(
      opcion,
      esJefe: enemigoActual.esJefe,
    );
    resultadoUltimoTurno = resultado;

    final rachaPrevia = _rachaActual;
    final esAciertoOCritico = resultado.resultado == ResultadoTurno.acierto ||
        resultado.resultado == ResultadoTurno.critico;

    if (esAciertoOCritico) {
      _rachaActual += 1;
      if (_rachaActual > _rachaMaxima) _rachaMaxima = _rachaActual;

      // Bonus de score por hitos de racha
      if (_rachaActual == 5) {
        _score += 50;
      } else if (_rachaActual == 7) {
        _score += 100;
      }
    } else {
      _rachaActual = 0;
    }

    final aplicaGolpeDoble = _golpeDobleActivo;
    final aplicaRoboDeVida = _roboDeVidaActivo;

    var danioAlEnemigoFinal = resultado.danoAlEnemigo;
    // Multiplicador de racha (solo afecta daño positivo al enemigo)
    if (esAciertoOCritico && resultado.danoAlEnemigo > 0) {
      danioAlEnemigoFinal = (danioAlEnemigoFinal * multiplicadorRacha).round();
    }
    // Modo temerario: +30% de daño al enemigo en aciertos/críticos
    if (esAciertoOCritico && danioAlEnemigoFinal > 0 && _modoTemerarioActivo) {
      danioAlEnemigoFinal = (danioAlEnemigoFinal * 1.3).round();
    }
    // Multiplicador de golpe doble (wildcard)
    if (aplicaGolpeDoble && resultado.danoAlEnemigo > 0) {
      danioAlEnemigoFinal *= 2;
    }

    final danioAlJugadorFinal = resultado.danoAlJugador +
        (_modoTemerarioActivo && resultado.danoAlJugador > 0 ? 5 : 0);

    vidaEnemigo = (vidaEnemigo - danioAlEnemigoFinal).clamp(0, 999);
    vidaJugador = (vidaJugador - danioAlJugadorFinal).clamp(0, 999);

    if (aplicaRoboDeVida && esAciertoOCritico) {
      vidaJugador = (vidaJugador + 10).clamp(0, 100);
    }

    final nombreEnemigo = (encuentroActual?.enemigo?.isNotEmpty == true) ? encuentroActual!.enemigo! : 'El enemigo';

    if (resultado.resultado == ResultadoTurno.critico) {
      _agregarNarrativa('[CRITICO] 💥 ¡Golpe crítico a $nombreEnemigo! Le causas -$danioAlEnemigoFinal HP.');
    } else if (resultado.resultado == ResultadoTurno.acierto) {
      _agregarNarrativa('[ACIERTO] ⚔️ Atacas a $nombreEnemigo y le causas -$danioAlEnemigoFinal HP.');
    }

    if (aplicaRoboDeVida && esAciertoOCritico) {
      _agregarNarrativa('[COMODIN] 💚 ¡Poción Vampirica activada! Recuperas +10 HP (Vida: $vidaJugador/100).');
    }

    if (_rachaActual == 5) {
      _agregarNarrativa('[RACHA] 🔥 ¡Racha Imparable (x5)! Daño x1.5 y +50 pts de bonus.');
    } else if (_rachaActual == 7) {
      _agregarNarrativa('[RACHA] 🔥 ¡RACHA LEGENDARIA (x7)! Daño x1.75 y +100 pts de bonus.');
    }

    if (resultado.resultado == ResultadoTurno.fallo) {
      _agregarNarrativa('[CONTRAATAQUE] 🩸 Fallaste. $nombreEnemigo contraataca con furia y te quita -$danioAlJugadorFinal HP.');
      if (rachaPrevia >= 3) {
        _agregarNarrativa('[CONTRAATAQUE] 💔 ¡Perdiste tu racha de $rachaPrevia aciertos!');
      }
    }

    switch (resultado.resultado) {
      case ResultadoTurno.critico:
        mensajeUltimoTurno = '¡Golpe crítico! -$danioAlEnemigoFinal HP al enemigo';
        if (_rachaActual >= 7) {
          mensajeUltimoTurno = '$mensajeUltimoTurno | 🔥 ¡RACHA LEGENDARIA!';
        } else if (_rachaActual >= 5) {
          mensajeUltimoTurno = '$mensajeUltimoTurno | 🔥 ¡Racha imparable!';
        } else if (_rachaActual >= 3) {
          mensajeUltimoTurno = '$mensajeUltimoTurno | 🔥 Racha x$_rachaActual';
        }
        _score += 125;
        break;
      case ResultadoTurno.acierto:
        mensajeUltimoTurno = 'Correcto. -$danioAlEnemigoFinal HP al enemigo';
        if (_rachaActual >= 7) {
          mensajeUltimoTurno = '$mensajeUltimoTurno | 🔥 ¡RACHA LEGENDARIA!';
        } else if (_rachaActual >= 5) {
          mensajeUltimoTurno = '$mensajeUltimoTurno | 🔥 ¡Racha imparable!';
        } else if (_rachaActual >= 3) {
          mensajeUltimoTurno = '$mensajeUltimoTurno | 🔥 Racha x$_rachaActual';
        }
        _score += 100;
        break;
      case ResultadoTurno.fallo:
        mensajeUltimoTurno = 'Incorrecto. El enemigo contraataca: -$danioAlJugadorFinal HP';
        break;
    }

    // Si el enemigo sigue vivo y el jugador también, toca nueva pregunta.
    if (vidaEnemigo > 0 && vidaJugador > 0) {
      _avanzarPregunta();
    }

    if (vidaJugador <= 0) {
      combateTerminado = true;
      jugadorGano = false;
      _setMensajeNarrativo(_consumirFragmentoNarrativo('muerte'));
      _finalizarPartida(gano: false);
    } else if (vidaEnemigo <= 0) {
      _enemigosDerrotados += 1;
      if (_enemigosDerrotados % 3 == 0) {
        _ronda += 1;
        _score += 500;
        _otorgarWildcardAleatoria();
        if (_modoTemerarioActivo) {
          _rondasTemerariasSuperadas += 1;
          _score += 200;
          _agregarNarrativa('[RACHA] 💀 ¡Sobreviviste al Pacto Temerario! +200 pts extra.');
        }
      }
      final hayMasEncuentros = _indiceActual + 1 < _encuentros.length;
      if (hayMasEncuentros) {
        encuentroSuperado = true;
        if (_enemigosDerrotados % 3 != 0) {
          final caso = _enemigosDerrotados % 3;
          if (caso == 1) {
            eventoActualVisual = const GameEvent(
              eventId: 'evt_codice_arcano',
              visualScene: VisualScene(
                biomeTag: 'dungeon_crypt',
                visualTag: 'trap_triggered',
                animationMode: 'pulse',
                screenEffect: 'subtle_glitch',
                tintHex: '#4A90E2',
              ),
              narrative: NarrativeData(
                title: '🏺 Códice Arcano',
                storyText:
                    'Encuentras un antiguo códice brillante entre los restos del enemigo.',
                educationalHint:
                    'Analizar código antiguo con cuidado evita trampas de concurrencia.',
              ),
              choices: [
                EventChoice(
                  id: 'estudiar_codice',
                  label:
                      '📖 Estudiar códice (-10 HP | +1 Comodín y +100 pts)',
                  consequenceType: 'gamble_resource',
                ),
                EventChoice(
                  id: 'destruir_codice',
                  label: '🛡️ Purificar energía (+15 HP seguros)',
                  consequenceType: 'safe_heal',
                ),
              ],
            );
            _eventoActivo = const EventoDecision(
              titulo: '🏺 Códice Arcano',
              descripcion:
                  'Encuentras un antiguo códice brillante entre los restos del enemigo.',
              iconoEmoji: '🏺',
              opciones: [
                OpcionEvento(
                  etiqueta:
                      '📖 Estudiar códice (-10 HP | +1 Comodín y +100 pts)',
                  codigoAccion: 'estudiar_codice',
                ),
                OpcionEvento(
                  etiqueta: '🛡️ Purificar energía (+15 HP seguros)',
                  codigoAccion: 'destruir_codice',
                ),
              ],
            );
          } else {
            eventoActualVisual = const GameEvent(
              eventId: 'evt_mercader_abismo',
              visualScene: VisualScene(
                biomeTag: 'abyss_market',
                visualTag: 'npc_mentor',
                animationMode: 'float',
                screenEffect: 'mist',
                tintHex: '#9B51E0',
              ),
              narrative: NarrativeData(
                title: '🧙‍♂️ Mercader del Abismo',
                storyText:
                    'Un mercader encapuchado emerge de las sombras ofreciendo un trato.',
                educationalHint:
                    'Equilibrar riesgo y recompensa es clave en sistemas distribuidos.',
              ),
              choices: [
                EventChoice(
                  id: 'mercader_poder',
                  label:
                      '⚡ Pacto de Poder (-15 HP | +1 Golpe Doble y +150 pts)',
                  consequenceType: 'buff_damage',
                ),
                EventChoice(
                  id: 'mercader_curar',
                  label: '💚 Elixir Menor (+20 HP sin costo)',
                  consequenceType: 'free_heal',
                ),
              ],
            );
            _eventoActivo = const EventoDecision(
              titulo: '🧙‍♂️ Mercader del Abismo',
              descripcion:
                  'Un mercader encapuchado emerge de las sombras ofreciendo un trato.',
              iconoEmoji: '🧙‍♂️',
              opciones: [
                OpcionEvento(
                  etiqueta:
                      '⚡ Pacto de Poder (-15 HP | +1 Golpe Doble y +150 pts)',
                  codigoAccion: 'mercader_poder',
                ),
                OpcionEvento(
                  etiqueta: '💚 Elixir Menor (+20 HP sin costo)',
                  codigoAccion: 'mercader_curar',
                ),
              ],
            );
          }
        } else {
          _eventoActivo = null;
          eventoActualVisual = null;
        }
        _avanzarSiguienteEnemigo();
      } else {
        combateTerminado = true;
        jugadorGano = true;
        _setMensajeNarrativo(_consumirFragmentoNarrativo('ronda_completada'));
        _finalizarPartida(gano: true);
      }
    }

    notifyListeners();

    // Resetear wildcards
    _golpeDobleActivo = false;
    _roboDeVidaActivo = false;
    _pistaActiva = null;
    _opcionesOcultas.clear();

    // Pausa dramática para que el jugador vea el resultado del turno
    if (duracionPausaTurno > Duration.zero) {
      final completer = Completer<void>();
      _completerPausaTurno = completer;
      _timerPausaTurno = Timer(duracionPausaTurno, () {
        if (!_disposed) {
          turnoEnProceso = false;
          notifyListeners();
        }
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future;
    } else {
      if (!_disposed) {
        turnoEnProceso = false;
        notifyListeners();
      }
    }
  }

  /// Cambia la pregunta activa a la siguiente del pool.
  /// Si el pool se está agotando, solicita más al backend.
  void _avanzarPregunta() {
    if (_preguntasExtra.isEmpty) {
      // No hay preguntas disponibles todavía. Solicitar más y dejar
      // la pregunta actual como fallback hasta que lleguen.
      if (!_generandoExtra) {
        _solicitarMasEncuentros();
      }
      return;
    }

    _preguntaActiva = _preguntasExtra.removeAt(0);

    // Si quedan pocas, pedir más en background para no bloquear.
    if (_preguntasExtra.length <= 3 && !_generandoExtra) {
      _solicitarMasEncuentros();
    }
  }

  /// Avanza automáticamente al siguiente enemigo en cola y consume narrativa de transición.
  void _avanzarSiguienteEnemigo() {
    if (_indiceActual + 1 >= _encuentros.length) return;
    _indiceActual++;
    final nuevoEnemigo = _encuentros[_indiceActual];
    vidaEnemigo = nuevoEnemigo.vidaEnemigo;
    _preguntaActiva = nuevoEnemigo;
    mensajeUltimoTurno = null;

    final proximoEsJefe = nuevoEnemigo.esJefe;
    _setMensajeNarrativo(proximoEsJefe
        ? (_consumirFragmentoNarrativo('jefe_avistado') ??
            _consumirFragmentoNarrativo('entre_combates'))
        : _consumirFragmentoNarrativo('entre_combates'));

    // Solicitar más preguntas en background si quedan 3 o menos
    if (_preguntasExtra.length <= 3 && !_generandoExtra) {
      _solicitarMasEncuentros();
    }
  }

  /// Desbloquea la transición de ronda permitiendo elegir Descanso Seguro o Pacto Temerario.
  void continuarSiguienteRonda({bool temerario = false}) {
    _eventoActivo = null;
    eventoActualVisual = null;
    if (temerario) {
      _modoTemerarioActivo = true;
      if (vidaJugador > 25) {
        vidaJugador = (vidaJugador - 10).clamp(1, 100);
      }
      _agregarNarrativa('[CRITICO] 💀 ¡Pacto Temerario aceptado! Daño +30%, Recompensa +200 pts, Enemigos +5 daño.');
    } else {
      _modoTemerarioActivo = false;
      vidaJugador = (vidaJugador + 25).clamp(0, 100);
      _agregarNarrativa('[COMODIN] 🛡️ Descansaste en la hoguera: recuperas +25 HP (Vida: $vidaJugador/100).');
    }

    if (encuentroSuperado) {
      encuentroSuperado = false;
      mensajeUltimoTurno = null;
      notifyListeners();
      return;
    }
    if (_indiceActual + 1 < _encuentros.length) {
      _avanzarSiguienteEnemigo();
      notifyListeners();
    }
  }

  /// Desbloquea la transición entre encuentros (mantiene compatibilidad anterior).
  void continuarSiguienteEncuentro() => continuarSiguienteRonda(temerario: false);

  /// Resuelve la opción elegida por el jugador en un evento de decisión entre combates.
  void resolverEventoDecision(String codigoAccion) {
    switch (codigoAccion) {
      case 'estudiar_codice':
        vidaJugador = (vidaJugador - 10).clamp(1, 100);
        _score += 100;
        _otorgarWildcardAleatoria();
        _agregarNarrativa(
            '[COMODIN] 📖 Estudiaste el Códice Arcano: -10 HP, +100 pts y obtuviste un comodín.');
        break;
      case 'destruir_codice':
        vidaJugador = (vidaJugador + 15).clamp(0, 100);
        _agregarNarrativa(
            '[COMODIN] 🛡️ Purificaste el Códice Arcano: recuperas +15 HP (Vida: $vidaJugador/100).');
        break;
      case 'mercader_poder':
        vidaJugador = (vidaJugador - 15).clamp(1, 100);
        _score += 150;
        _wildcards[TipoWildcard.golpeDoble] =
            (_wildcards[TipoWildcard.golpeDoble] ?? 0) + 1;
        _agregarNarrativa(
            '[CRITICO] ⚡ Aceptaste el Pacto del Mercader: -15 HP, +150 pts y +1 Golpe Doble.');
        break;
      case 'mercader_curar':
        vidaJugador = (vidaJugador + 20).clamp(0, 100);
        _agregarNarrativa(
            '[COMODIN] 💚 Bebiste el Elixir del Mercader: recuperas +20 HP (Vida: $vidaJugador/100).');
        break;
    }

    _eventoActivo = null;
    eventoActualVisual = null;
    if (encuentroSuperado) {
      encuentroSuperado = false;
      mensajeUltimoTurno = null;
      notifyListeners();
      return;
    }
    if (_indiceActual + 1 < _encuentros.length) {
      _avanzarSiguienteEnemigo();
    }
    notifyListeners();
  }

  /// Pausa el combate actual.
  void pausarCombate() {
    if (combateTerminado || cargando) return;
    enPausa = true;
    notifyListeners();
  }

  /// Reanuda el combate tras una pausa.
  void continuarCombate() {
    enPausa = false;
    notifyListeners();
  }

  /// El jugador decide retirarse voluntariamente.
  /// Marca la partida como perdida/abandonada, otorga 10 XP de derrota y guarda progreso.
  Future<void> retirarse() async {
    if (combateTerminado || cargando) return;
    enPausa = false;
    combateTerminado = true;
    jugadorGano = false;
    _setMensajeNarrativo(_consumirFragmentoNarrativo('retirada') ?? 'Te has retirado del combate.');
    await _finalizarPartida(gano: false);
  }

  Future<void> _finalizarPartida({required bool gano}) async {
    guardandoResultado = true;
    notifyListeners();
    _partida.encuentroActual = _indiceActual;
    _partida.enemigosDerrotados = _enemigosDerrotados;
    _partida.rachaMaxima = _rachaMaxima;
    _partida.rondasTemerarias = _rondasTemerariasSuperadas;
    // El servidor calculará el score y la XP. Aquí los ponemos en 0
    // solo como valores por defecto (el servidor los ignorará).
    _partida.score = 0;
    _partida.xpObtenida = 0;
    await _finalizarUseCase.ejecutar(partida: _partida, gano: gano);
    guardandoResultado = false;
    notifyListeners();
  }

  Future<void> usarWildcard(TipoWildcard tipo) async {
    if (combateTerminado || turnoEnProceso || enPausa) return;
    final cantidad = _wildcards[tipo] ?? 0;
    if (cantidad <= 0) return;

    switch (tipo) {
      case TipoWildcard.cincuentaCincuenta:
        _aplicarCincuentaCincuenta();
        _agregarNarrativa('[COMODIN] 🎯 Usaste 50/50: dos opciones falsas fueron descartadas.');
        break;
      case TipoWildcard.roboDeVida:
        _roboDeVidaActivo = true;
        _agregarNarrativa('[COMODIN] 🧪 Preparaste Poción Vampirica: tu próximo acierto curará +10 HP.');
        break;
      case TipoWildcard.golpeDoble:
        _golpeDobleActivo = true;
        _agregarNarrativa('[COMODIN] ⚡ Activaste Golpe Doble: tu próximo ataque hará el doble de daño.');
        break;
      case TipoWildcard.pista:
        _pistaActiva = _generarPistaLocal();
        _agregarNarrativa('[COMODIN] 💡 Consultaste al Oráculo para obtener una pista.');
        break;
    }

    _wildcards[tipo] = cantidad - 1;
    notifyListeners();
  }

  void _aplicarCincuentaCincuenta() {
    final pregunta = _preguntaActiva ?? _encuentros[_indiceActual];
    final incorrectas = pregunta.opciones.where((o) => o.calidad < 2).toList();
    incorrectas.shuffle();
    final aOcultar = incorrectas.take(2);
    _opcionesOcultas.clear();
    for (final op in aOcultar) {
      _opcionesOcultas.add(op.texto);
    }
  }

  String _generarPistaLocal() {
    final pregunta = _preguntaActiva ?? _encuentros[_indiceActual];
    return 'La respuesta correcta tiene aproximadamente ${_longitudRespuesta(pregunta)} caracteres.';
  }

  int _longitudRespuesta(Encuentro pregunta) {
    final correcta = pregunta.opciones.firstWhere((o) => o.calidad == 2);
    return correcta.texto.length;
  }

  void _otorgarWildcardAleatoria() {
    final tipos = TipoWildcard.values.toList()..shuffle();
    for (final tipo in tipos) {
      final actual = _wildcards[tipo] ?? 0;
      if (actual < 3) {
        _wildcards[tipo] = actual + 1;
        break;
      }
    }
  }
}
