import 'package:flutter_test/flutter_test.dart';

import 'package:sysquest_app/domain/entities/encuentro.dart';
import 'package:sysquest_app/domain/entities/opcion_encuentro.dart';
import 'package:sysquest_app/domain/entities/personaje_partida.dart';
import 'package:sysquest_app/domain/entities/quest.dart';
import 'package:sysquest_app/domain/entities/quest_completa.dart';
import 'package:sysquest_app/domain/repositories/partida_repository.dart';
import 'package:sysquest_app/domain/repositories/quest_repository.dart';
import 'package:sysquest_app/domain/usecases/finalizar_partida_usecase.dart';
import 'package:sysquest_app/domain/usecases/responder_encuentro_usecase.dart';
import 'package:sysquest_app/domain/repositories/quest_generator_repository.dart';
import 'package:sysquest_app/domain/usecases/generar_encuentros_extra_usecase.dart';
import 'package:sysquest_app/domain/entities/wildcard.dart';
import 'package:sysquest_app/presentation/screens/combate/combate_controller.dart';

class FakeQuestRepository implements QuestRepository {
  final List<Encuentro> encuentros;
  FakeQuestRepository(this.encuentros);

  @override
  Future<List<Encuentro>> obtenerEncuentros(String idQuest) async => encuentros;

  @override
  Future<Quest?> obtenerQuestPorId(String idQuest) async => null;

  @override
  Future<void> guardarQuest(Quest quest) async {}

  @override
  Future<void> guardarQuestCompleta(QuestCompleta quest) async {}
}

class FakePartidaRepository implements PartidaRepository {
  Partida? ultimaPartidaGuardada;

  @override
  Future<void> guardarPartida(Partida partida) async {
    ultimaPartidaGuardada = partida;
  }

  @override
  Future<ProgresoUsuario?> obtenerProgreso(String idUsuario) async => null;

  @override
  Future<void> actualizarProgreso(ProgresoUsuario progreso) async {}
}

class FakeQuestGeneratorRepository implements QuestGeneratorRepository {
  String? ultimoTema;
  String? ultimaCategoria;
  String? ultimaDificultad;
  int? ultimoNumero;

  @override
  Future<QuestCompleta> generarQuest(String tema) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Encuentro>> generarEncuentrosExtra({
    required String idQuest,
    required String tema,
    required String categoria,
    required String dificultad,
    required int ultimoNumero,
  }) async {
    ultimoTema = tema;
    ultimaCategoria = categoria;
    ultimaDificultad = dificultad;
    this.ultimoNumero = ultimoNumero;
    return [];
  }
}

void main() {
  final opcionCritica = OpcionEncuentro(
    idOpcion: 'op-1',
    idEncuentro: 'enc-1',
    letra: 'A',
    texto: 'Opcion optima',
    calidad: 2,
  );

  final encuentroNormal1 = Encuentro(
    idEncuentro: 'enc-1',
    idQuest: 'q-1',
    numero: 1,
    pregunta: 'Pregunta 1',
    dificultad: 'facil',
    tipoEncuentro: 'normal',
    vidaEnemigo: 50,
    opciones: [opcionCritica],
  );

  final encuentroJefe = Encuentro(
    idEncuentro: 'enc-jefe',
    idQuest: 'q-1',
    numero: 3,
    pregunta: 'Pregunta Jefe',
    dificultad: 'dificil',
    tipoEncuentro: 'jefe',
    vidaEnemigo: 80,
    opciones: [opcionCritica],
  );

  group('CombateController', () {
    test('elegirOpcion con turnoEnProceso=true no procesa el turno', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1, encuentroJefe]);
      final repoPartida = FakePartidaRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: const Duration(milliseconds: 10),
      );

      await controller.cargarQuest('q-1', 'u-1');
      expect(controller.vidaEnemigo, equals(50));

      // Simulamos turno en proceso activo
      controller.turnoEnProceso = true;

      await controller.elegirOpcion(opcionCritica);

      // No debe haberse procesado el turno ni reducido la vida del enemigo
      expect(controller.vidaEnemigo, equals(50));
      expect(controller.resultadoUltimoTurno, isNull);
    });

    test('elegirOpcion con turnoEnProceso=false procesa y vuelve a false tras el delay', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1, encuentroJefe]);
      final repoPartida = FakePartidaRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: const Duration(milliseconds: 30),
      );

      await controller.cargarQuest('q-1', 'u-1');
      expect(controller.turnoEnProceso, isFalse);

      final futureElegir = controller.elegirOpcion(opcionCritica);

      // Inmediatamente tras llamar, turnoEnProceso pasa a true
      expect(controller.turnoEnProceso, isTrue);

      await futureElegir;

      // Al completar el delay, vuelve a false
      expect(controller.turnoEnProceso, isFalse);
      expect(controller.resultadoUltimoTurno, isNotNull);
      expect(controller.vidaEnemigo, lessThan(50));
    });

    test('cargarQuest baraja solo los normales y deja el jefe al final', () async {
      final normalA = Encuentro(
        idEncuentro: 'norm-A',
        idQuest: 'q-1',
        numero: 1,
        pregunta: 'A',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 30,
        opciones: [opcionCritica],
      );
      final normalB = Encuentro(
        idEncuentro: 'norm-B',
        idQuest: 'q-1',
        numero: 2,
        pregunta: 'B',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 30,
        opciones: [opcionCritica],
      );
      final normalC = Encuentro(
        idEncuentro: 'norm-C',
        idQuest: 'q-1',
        numero: 3,
        pregunta: 'C',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 30,
        opciones: [opcionCritica],
      );

      final repoQuest = FakeQuestRepository([normalA, normalB, normalC, encuentroJefe]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
      );

      await controller.cargarQuest('q-1', 'u-1');

      // Avanzamos por todos los encuentros para verificar su orden
      final idsRecorridos = <String>[];
      final tiposRecorridos = <String>[];

      while (controller.encuentroActual != null) {
        idsRecorridos.add(controller.encuentroActual!.idEncuentro);
        tiposRecorridos.add(controller.encuentroActual!.tipoEncuentro);
        if (controller.encuentroActual!.esJefe) break;
        controller.continuarSiguienteEncuentro();
      }

      expect(idsRecorridos.length, equals(4));
      // El último debe ser siempre el jefe
      expect(tiposRecorridos.last, equals('jefe'));
      expect(idsRecorridos.last, equals('enc-jefe'));

      // Los primeros deben ser todos normales
      expect(tiposRecorridos.sublist(0, 3).every((tipo) => tipo == 'normal'), isTrue);
      expect(idsRecorridos.sublist(0, 3).toSet(), equals({'norm-A', 'norm-B', 'norm-C'}));
    });

    test('al fallar pregunta con calidad 0 carga pregunta extra para el mismo enemigo', () async {
      final opcionFalla = OpcionEncuentro(
        idOpcion: 'op-falla',
        idEncuentro: 'enc-1',
        letra: 'B',
        texto: 'Opcion incorrecta',
        calidad: 0,
      );
      final encuentroOriginal = Encuentro(
        idEncuentro: 'enc-1',
        idQuest: 'q-1',
        numero: 1,
        pregunta: 'Pregunta Inicial',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 50,
        opciones: [opcionFalla],
      );
      final preguntaExtra = Encuentro(
        idEncuentro: 'extra-1',
        idQuest: 'q-1',
        numero: 4,
        pregunta: 'Pregunta Extra 1',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 50,
        opciones: [opcionCritica],
      );

      final repoQuest = FakeQuestRepository([encuentroOriginal, encuentroJefe]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );

      await controller.cargarQuest(
        'q-1',
        'u-1',
        preguntasExtra: [preguntaExtra],
      );

      expect(controller.encuentroActual!.pregunta, equals('Pregunta Inicial'));
      final vidaJugadorInicial = controller.vidaJugador;

      // Jugador falla
      await controller.elegirOpcion(opcionFalla);

      // El enemigo contraatacó
      expect(controller.vidaJugador, lessThan(vidaJugadorInicial));
      // El mismo enemigo sigue vivo
      expect(controller.vidaEnemigo, equals(50));
      expect(controller.encuentroSuperado, isFalse);
      // La pregunta fue reemplazada por la pregunta extra
      expect(controller.encuentroActual!.pregunta, equals('Pregunta Extra 1'));
      expect(controller.encuentroActual!.numero, equals(1)); // Conserva número de enemigo
    });

    test('al derrotar a un enemigo avanza automaticamente al siguiente y consume narrativa', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1, encuentroJefe]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );

      final poolNarrativo = {
        'jefe_avistado': ['El jefe final aparece imponente en el horizonte.'],
      };

      await controller.cargarQuest(
        'q-1',
        'u-1',
        poolNarrativo: poolNarrativo,
      );

      expect(controller.encuentroActual!.tipoEncuentro, equals('normal'));
      expect(controller.vidaEnemigo, equals(50));

      // Asestamos dos golpes de 25 (calidad 2)
      await controller.elegirOpcion(opcionCritica);
      expect(controller.vidaEnemigo, equals(25));

      await controller.elegirOpcion(opcionCritica);

      // Enemigo derrotado -> transiciona al siguiente (el jefe)
      expect(controller.encuentroSuperado, isTrue);
      expect(controller.encuentroActual!.tipoEncuentro, equals('jefe'));
      expect(controller.vidaEnemigo, equals(80));
      expect(controller.mensajeNarrativoActual, equals('El jefe final aparece imponente en el horizonte.'));
      expect(controller.combateTerminado, isFalse);
    });

    test('pausarCombate, continuarCombate y retirarse funcionan correctamente', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1]);
      final repoPartida = FakePartidaRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );

      final poolNarrativo = {
        'retirada': ['Te retiras tácticamente para luchar otro día.'],
      };

      await controller.cargarQuest(
        'q-1',
        'u-1',
        poolNarrativo: poolNarrativo,
      );

      expect(controller.enPausa, isFalse);

      controller.pausarCombate();
      expect(controller.enPausa, isTrue);

      controller.continuarCombate();
      expect(controller.enPausa, isFalse);

      controller.pausarCombate();
      await controller.retirarse();

      expect(controller.enPausa, isFalse);
      expect(controller.combateTerminado, isTrue);
      expect(controller.jugadorGano, isFalse);
      expect(controller.mensajeNarrativoActual, equals('Te retiras tácticamente para luchar otro día.'));
    });
    test('usarWildcard reduce la cantidad en 1', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
      );
      await controller.cargarQuest('q-1', 'u-1');

      expect(controller.wildcards[TipoWildcard.roboDeVida], equals(1));
      await controller.usarWildcard(TipoWildcard.roboDeVida);
      expect(controller.wildcards[TipoWildcard.roboDeVida], equals(0));
      expect(controller.roboDeVidaActivo, isTrue);
    });

    test('usarWildcard con cantidad 0 no hace nada', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
      );
      await controller.cargarQuest('q-1', 'u-1');

      await controller.usarWildcard(TipoWildcard.roboDeVida);
      expect(controller.wildcards[TipoWildcard.roboDeVida], equals(0));
      // Try again
      await controller.usarWildcard(TipoWildcard.roboDeVida);
      expect(controller.wildcards[TipoWildcard.roboDeVida], equals(0)); // Still 0
    });

    test('50/50 oculta 2 opciones incorrectas', () async {
      final opcionMala1 = OpcionEncuentro(idOpcion: 'op-2', idEncuentro: 'enc-1', letra: 'B', texto: 'Mala 1', calidad: 0);
      final opcionMala2 = OpcionEncuentro(idOpcion: 'op-3', idEncuentro: 'enc-1', letra: 'C', texto: 'Mala 2', calidad: 0);
      final opcionMala3 = OpcionEncuentro(idOpcion: 'op-4', idEncuentro: 'enc-1', letra: 'D', texto: 'Mala 3', calidad: 1);
      final encuentro4Ops = Encuentro(
        idEncuentro: 'enc-1', idQuest: 'q-1', numero: 1, pregunta: 'P', dificultad: 'facil', tipoEncuentro: 'normal', vidaEnemigo: 50,
        opciones: [opcionCritica, opcionMala1, opcionMala2, opcionMala3],
      );

      final repoQuest = FakeQuestRepository([encuentro4Ops]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
      );
      await controller.cargarQuest('q-1', 'u-1');

      expect(controller.opcionesOcultas.isEmpty, isTrue);
      await controller.usarWildcard(TipoWildcard.cincuentaCincuenta);
      expect(controller.opcionesOcultas.length, equals(2));
      expect(controller.opcionesOcultas.contains(opcionCritica.texto), isFalse);
    });

    test('golpe doble hace daño x2 en el próximo acierto', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );
      await controller.cargarQuest('q-1', 'u-1');

      await controller.usarWildcard(TipoWildcard.golpeDoble);
      expect(controller.golpeDobleActivo, isTrue);

      await controller.elegirOpcion(opcionCritica);
      // Critico base es 25. x2 = 50. Enemigo inicial tiene 50. Debería quedar en 0.
      expect(controller.vidaEnemigo, equals(0));
      expect(controller.golpeDobleActivo, isFalse);
    });

    test('robo de vida cura 10 HP en el próximo acierto', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );
      await controller.cargarQuest('q-1', 'u-1');

      controller.vidaJugador = 50; // Set to 50 directly for test

      await controller.usarWildcard(TipoWildcard.roboDeVida);
      expect(controller.roboDeVidaActivo, isTrue);

      await controller.elegirOpcion(opcionCritica);
      expect(controller.vidaJugador, equals(60)); // 50 + 10
      expect(controller.roboDeVidaActivo, isFalse);
    });

    test('cada 3 enemigos derrotados se otorga 1 wildcard', () async {
      final e2 = Encuentro(
        idEncuentro: 'enc-2', idQuest: 'q-1', numero: 2, pregunta: 'P', dificultad: 'facil', tipoEncuentro: 'normal', vidaEnemigo: 50,
        opciones: [opcionCritica],
      );
      final e3 = Encuentro(
        idEncuentro: 'enc-3', idQuest: 'q-1', numero: 3, pregunta: 'P', dificultad: 'facil', tipoEncuentro: 'normal', vidaEnemigo: 50,
        opciones: [opcionCritica],
      );
      final repoQuest = FakeQuestRepository([encuentroNormal1, e2, e3]);
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(FakePartidaRepository()),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );
      await controller.cargarQuest('q-1', 'u-1');

      // Gastamos todos los wildcards para ver el incremento
      for (final tipo in TipoWildcard.values) {
        await controller.usarWildcard(tipo);
      }
      
      final totalAntes = TipoWildcard.values.map((t) => controller.wildcards[t]!).reduce((a, b) => a + b);
      expect(totalAntes, equals(0));

      // Derrotar 3 enemigos (cada uno tiene 50 HP, 2 criticos lo matan)
      for (int i = 0; i < 3; i++) {
        await controller.elegirOpcion(opcionCritica);
        await controller.elegirOpcion(opcionCritica);
        controller.continuarSiguienteEncuentro();
      }

      // Check wildcards
      final totalDespues = TipoWildcard.values.map((t) => controller.wildcards[t]!).reduce((a, b) => a + b);
      expect(totalDespues, equals(1)); // Se otorgó 1
    });

    test('al finalizar partida asigna enemigosDerrotados y delega score/XP al servidor', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1]);
      final repoPartida = FakePartidaRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );
      await controller.cargarQuest('q-1', 'u-1');

      // Caso 1: Retirarse sin derrotar enemigos asigna enemigosDerrotados = 0 y score = 0
      await controller.retirarse();
      expect(controller.partida.enemigosDerrotados, equals(0));
      expect(controller.partida.score, equals(0));
      expect(repoPartida.ultimaPartidaGuardada!.enemigosDerrotados, equals(0));

      // Caso 2: Derrotar al enemigo asigna enemigosDerrotados = 1, rachaMaxima y calcula score/XP coherente
      final controller2 = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );
      await controller2.cargarQuest('q-1', 'u-1');
      await controller2.elegirOpcion(opcionCritica);
      await controller2.elegirOpcion(opcionCritica);
      expect(controller2.partida.enemigosDerrotados, equals(1));
      expect(controller2.partida.rachaMaxima, equals(2));
      expect(controller2.rachaMaxima, equals(2));
      expect(controller2.puntosPorEnemigos, equals(100));
      expect(controller2.bonusPorRacha, equals(0));
      expect(controller2.bonusPorVictoria, equals(150));
      expect(controller2.partida.score, equals(250));
      expect(controller2.partida.xpObtenida, equals(25));
      expect(controller2.scoreFinalMostrado, equals(250));
      expect(controller2.xpFinalMostrada, equals(25));
      expect(repoPartida.ultimaPartidaGuardada!.enemigosDerrotados, equals(1));
      expect(repoPartida.ultimaPartidaGuardada!.rachaMaxima, equals(2));
    });

    test('sistema de racha: incrementa con aciertos/críticos, aplica multiplicador, bonos de score, convive con golpe doble y resetea con fallo', () async {
      final opcionAcierto = OpcionEncuentro(
        idOpcion: 'op-acierto',
        idEncuentro: 'enc-esponja',
        letra: 'B',
        texto: 'Acierto normal',
        calidad: 1,
      );
      final opcionFallo = OpcionEncuentro(
        idOpcion: 'op-fallo',
        idEncuentro: 'enc-esponja',
        letra: 'C',
        texto: 'Fallo',
        calidad: 0,
      );
      final enemigoEsponja = Encuentro(
        idEncuentro: 'enc-esponja',
        idQuest: 'q-racha',
        numero: 1,
        pregunta: 'Pregunta racha',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 1000,
        opciones: [opcionAcierto, opcionCritica, opcionFallo],
      );

      final repoQuest = FakeQuestRepository([enemigoEsponja]);
      final repoPartida = FakePartidaRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );
      await controller.cargarQuest('q-racha', 'u-1');

      expect(controller.rachaActual, equals(0));
      expect(controller.multiplicadorRacha, equals(1.0));

      // Turno 1: Crítico -> racha 1 (base 25 daño)
      await controller.elegirOpcion(opcionCritica);
      expect(controller.rachaActual, equals(1));
      expect(controller.multiplicadorRacha, equals(1.0));
      expect(controller.vidaEnemigo, equals(1000 - 25));

      // Turno 2: Acierto -> racha 2 (base 12 daño)
      await controller.elegirOpcion(opcionAcierto);
      expect(controller.rachaActual, equals(2));
      expect(controller.multiplicadorRacha, equals(1.0));
      expect(controller.vidaEnemigo, equals(975 - 12)); // 963

      // Turno 3: Acierto -> racha 3 (multiplicador 1.25x -> round(12 * 1.25) = 15 daño)
      await controller.elegirOpcion(opcionAcierto);
      expect(controller.rachaActual, equals(3));
      expect(controller.multiplicadorRacha, equals(1.25));
      expect(controller.vidaEnemigo, equals(963 - 15)); // 948

      // Turno 4: Acierto -> racha 4 (multiplicador 1.25x -> 15 daño)
      await controller.elegirOpcion(opcionAcierto);
      expect(controller.rachaActual, equals(4));
      expect(controller.multiplicadorRacha, equals(1.25));
      expect(controller.vidaEnemigo, equals(948 - 15)); // 933

      // Turno 5: Acierto -> racha 5 (multiplicador 1.5x -> round(12 * 1.5) = 18 daño)
      // Bonus score: al llegar a 5 suma +50 (+ 100 de acierto = +150)
      final scoreAntesDe5 = controller.score;
      await controller.elegirOpcion(opcionAcierto);
      expect(controller.rachaActual, equals(5));
      expect(controller.multiplicadorRacha, equals(1.5));
      expect(controller.vidaEnemigo, equals(933 - 18)); // 915
      expect(controller.score, equals(scoreAntesDe5 + 100 + 50));

      // Turno 6: Acierto -> racha 6 (multiplicador 1.5x -> 18 daño)
      await controller.elegirOpcion(opcionAcierto);
      expect(controller.rachaActual, equals(6));
      expect(controller.multiplicadorRacha, equals(1.5));
      expect(controller.vidaEnemigo, equals(915 - 18)); // 897

      // Turno 7: Acierto -> racha 7 (multiplicador 1.75x -> round(12 * 1.75) = 21 daño)
      // Bonus score: al llegar a 7 suma +100 (+ 100 de acierto = +200)
      final scoreAntesDe7 = controller.score;
      await controller.elegirOpcion(opcionAcierto);
      expect(controller.rachaActual, equals(7));
      expect(controller.multiplicadorRacha, equals(1.75));
      expect(controller.vidaEnemigo, equals(897 - 21)); // 876
      expect(controller.score, equals(scoreAntesDe7 + 100 + 100));

      // Fallo resetea racha a 0
      await controller.elegirOpcion(opcionFallo);
      expect(controller.rachaActual, equals(0));
      expect(controller.multiplicadorRacha, equals(1.0));

      // Convivencia racha y golpe doble:
      // Construir racha hasta 4, luego activar golpe doble y acertar para llegar a racha 5
      for (var i = 0; i < 4; i++) {
        await controller.elegirOpcion(opcionAcierto);
      }
      expect(controller.rachaActual, equals(4));
      await controller.usarWildcard(TipoWildcard.golpeDoble);
      final vidaAntesGolpeDoble = controller.vidaEnemigo;
      // Al acertar, racha pasa a 5 (mult 1.5x -> 12 * 1.5 = 18), y golpe doble duplica -> 18 * 2 = 36
      await controller.elegirOpcion(opcionAcierto);
      expect(controller.rachaActual, equals(5));
      expect(controller.vidaEnemigo, equals(vidaAntesGolpeDoble - 36));
    });

    test('consola narrativa registra eventos etiquetados de ataque, contraataque y comodines', () async {
      final opcionCritica = OpcionEncuentro(
        idOpcion: 'op-critica',
        idEncuentro: 'enc-log',
        letra: 'A',
        texto: 'Opción crítica',
        calidad: 2,
      );
      final opcionFallo = OpcionEncuentro(
        idOpcion: 'op-fallo',
        idEncuentro: 'enc-log',
        letra: 'B',
        texto: 'Opción fallo',
        calidad: 0,
      );
      final encuentroLog = Encuentro(
        idEncuentro: 'enc-log',
        idQuest: 'q-log',
        numero: 1,
        pregunta: 'Pregunta log',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 500,
        enemigo: 'Gólem de Código',
        opciones: [opcionCritica, opcionFallo],
      );

      final repoQuest = FakeQuestRepository([encuentroLog]);
      final repoPartida = FakePartidaRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );

      await controller.cargarQuest('q-log', 'u-1');

      // 1. Usar comodín
      await controller.usarWildcard(TipoWildcard.roboDeVida);
      expect(
        controller.historialNarrativo.any((l) => l.contains('[COMODIN]') && l.contains('Poción Vampirica')),
        isTrue,
      );

      // 2. Acertar (crítico) con comodín activo
      await controller.elegirOpcion(opcionCritica);
      expect(
        controller.historialNarrativo.any((l) => l.contains('[CRITICO]') && l.contains('Gólem de Código')),
        isTrue,
      );
      expect(
        controller.historialNarrativo.any((l) => l.contains('[COMODIN]') && l.contains('Poción Vampirica activada')),
        isTrue,
      );

      // 3. Fallar
      await controller.elegirOpcion(opcionFallo);
      expect(
        controller.historialNarrativo.any((l) => l.contains('[CONTRAATAQUE]') && l.contains('Gólem de Código contraataca')),
        isTrue,
      );
    });

    test('sistema riesgo/recompensa: descanso seguro cura +25 HP y pacto temerario aumenta daño +30%, riesgo +5 HP y suma rondasTemerarias', () async {
      final opcionCritica = OpcionEncuentro(
        idOpcion: 'op-critica',
        idEncuentro: 'enc-1',
        letra: 'A',
        texto: 'Crítico',
        calidad: 2,
      );
      final opcionAcierto = OpcionEncuentro(
        idOpcion: 'op-acierto',
        idEncuentro: 'enc-1',
        letra: 'B',
        texto: 'Acierto',
        calidad: 1,
      );
      final opcionFallo = OpcionEncuentro(
        idOpcion: 'op-fallo',
        idEncuentro: 'enc-1',
        letra: 'C',
        texto: 'Fallo',
        calidad: 0,
      );

      final encuentros = [
        Encuentro(
          idEncuentro: 'enc-1',
          idQuest: 'q-temerario',
          numero: 1,
          pregunta: 'Pregunta 1',
          dificultad: 'facil',
          tipoEncuentro: 'normal',
          vidaEnemigo: 25,
          enemigo: 'Enemigo 1',
          opciones: [opcionCritica, opcionAcierto, opcionFallo],
        ),
        Encuentro(
          idEncuentro: 'enc-2',
          idQuest: 'q-temerario',
          numero: 2,
          pregunta: 'Pregunta 2',
          dificultad: 'facil',
          tipoEncuentro: 'normal',
          vidaEnemigo: 25,
          enemigo: 'Enemigo 2',
          opciones: [opcionCritica, opcionAcierto, opcionFallo],
        ),
        Encuentro(
          idEncuentro: 'enc-3',
          idQuest: 'q-temerario',
          numero: 3,
          pregunta: 'Pregunta 3',
          dificultad: 'facil',
          tipoEncuentro: 'normal',
          vidaEnemigo: 25,
          enemigo: 'Enemigo 3',
          opciones: [opcionCritica, opcionAcierto, opcionFallo],
        ),
        Encuentro(
          idEncuentro: 'enc-4',
          idQuest: 'q-temerario',
          numero: 4,
          pregunta: 'Jefe',
          dificultad: 'dificil',
          tipoEncuentro: 'jefe',
          vidaEnemigo: 50,
          enemigo: 'Jefe Final',
          opciones: [opcionCritica, opcionAcierto, opcionFallo],
        ),
      ];

      final repoQuest = FakeQuestRepository(encuentros);
      final repoPartida = FakePartidaRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );

      await controller.cargarQuest('q-temerario', 'u-1');

      // 1. Reducir vida fallando en encuentro 1 (-15 HP -> 85 HP)
      await controller.elegirOpcion(opcionFallo);
      expect(controller.vidaJugador, equals(85));

      // Derrotar enemigo 1 (25 HP) con crítico (25 daño)
      await controller.elegirOpcion(opcionCritica);
      expect(controller.enemigosDerrotados, equals(1));
      expect(controller.encuentroSuperado, isTrue);

      // 2. Elegir Descanso Seguro tras superar encuentro 1:
      // Recupera +25 HP (85 + 25 = 100 max) y desactiva modo temerario
      controller.continuarSiguienteRonda(temerario: false);
      expect(controller.encuentroSuperado, isFalse);
      expect(controller.modoTemerarioActivo, isFalse);
      expect(controller.vidaJugador, equals(100));
      expect(
        controller.historialNarrativo.any((l) => l.contains('[COMODIN]') && l.contains('Descansaste en la hoguera')),
        isTrue,
      );

      // 3. Derrotar enemigo 2 (25 HP) con crítico
      await controller.elegirOpcion(opcionCritica);
      expect(controller.enemigosDerrotados, equals(2));
      expect(controller.encuentroSuperado, isTrue);

      // 4. Elegir Pacto Temerario tras superar encuentro 2:
      // Sacrifica 10 HP (100 -> 90) y activa modo temerario
      controller.continuarSiguienteRonda(temerario: true);
      expect(controller.encuentroSuperado, isFalse);
      expect(controller.modoTemerarioActivo, isTrue);
      expect(controller.vidaJugador, equals(90));
      expect(
        controller.historialNarrativo.any((l) => l.contains('[CRITICO]') && l.contains('Pacto Temerario aceptado')),
        isTrue,
      );

      // 5. Daño aumentado con racha x3 y modo temerario (+30%):
      // Acierto base = 12. Racha x3 (1.25x) = 15. Modo temerario (1.3x): round(15 * 1.3) = 20 daño.
      final vidaEnemigo3Antes = controller.vidaEnemigo; // 25 HP
      await controller.elegirOpcion(opcionAcierto);
      expect(vidaEnemigo3Antes - controller.vidaEnemigo, equals(20));
      expect(controller.vidaEnemigo, equals(5));

      // 6. Contraataque con +5 HP extra en fallo y reseteo de racha:
      // Fallo base = 15 daño. Con modo temerario: 15 + 5 = 20 daño.
      final vidaAntesFallo = controller.vidaJugador; // 90 HP
      await controller.elegirOpcion(opcionFallo);
      expect(controller.vidaJugador, equals(vidaAntesFallo - 20)); // 70 HP
      expect(controller.rachaActual, equals(0));

      // 7. Derrotar enemigo 3 (restaban 5 HP, acierto a racha 1 hace 16 daño):
      // Completa ronda 1 (_enemigosDerrotados % 3 == 0) en modo temerario
      final scoreAntesDeRonda = controller.score;
      await controller.elegirOpcion(opcionAcierto);
      expect(controller.enemigosDerrotados, equals(3));
      expect(controller.rondasTemerariasSuperadas, equals(1));
      expect(controller.bonusPorTemerario, equals(200));
      // Suma 100 (acierto) + 500 (ronda normal) + 200 (bono temerario)
      expect(controller.score, equals(scoreAntesDeRonda + 100 + 500 + 200));
      expect(
        controller.historialNarrativo.any((l) => l.contains('[RACHA]') && l.contains('¡Sobreviviste al Pacto Temerario!')),
        isTrue,
      );
    });

    test('eventos con decision: genera evento en encuentros intermedios y aplica efectos de estudiar_codice y mercader_poder', () async {
      final opcionCritica = OpcionEncuentro(
        idOpcion: 'op-critica',
        idEncuentro: 'enc-1',
        letra: 'A',
        texto: 'Crítico',
        calidad: 2,
      );
      final opcionAcierto = OpcionEncuentro(
        idOpcion: 'op-acierto',
        idEncuentro: 'enc-1',
        letra: 'B',
        texto: 'Acierto',
        calidad: 1,
      );
      final opcionFallo = OpcionEncuentro(
        idOpcion: 'op-fallo',
        idEncuentro: 'enc-1',
        letra: 'C',
        texto: 'Fallo',
        calidad: 0,
      );

      final encuentros = [
        Encuentro(
          idEncuentro: 'enc-1',
          idQuest: 'q-eventos',
          numero: 1,
          pregunta: 'Pregunta 1',
          dificultad: 'facil',
          tipoEncuentro: 'normal',
          vidaEnemigo: 25,
          enemigo: 'Enemigo 1',
          opciones: [opcionCritica, opcionAcierto, opcionFallo],
        ),
        Encuentro(
          idEncuentro: 'enc-2',
          idQuest: 'q-eventos',
          numero: 2,
          pregunta: 'Pregunta 2',
          dificultad: 'facil',
          tipoEncuentro: 'normal',
          vidaEnemigo: 25,
          enemigo: 'Enemigo 2',
          opciones: [opcionCritica, opcionAcierto, opcionFallo],
        ),
        Encuentro(
          idEncuentro: 'enc-3',
          idQuest: 'q-eventos',
          numero: 3,
          pregunta: 'Pregunta 3',
          dificultad: 'facil',
          tipoEncuentro: 'normal',
          vidaEnemigo: 25,
          enemigo: 'Enemigo 3',
          opciones: [opcionCritica, opcionAcierto, opcionFallo],
        ),
        Encuentro(
          idEncuentro: 'enc-4',
          idQuest: 'q-eventos',
          numero: 4,
          pregunta: 'Jefe',
          dificultad: 'dificil',
          tipoEncuentro: 'jefe',
          vidaEnemigo: 50,
          enemigo: 'Jefe',
          opciones: [opcionCritica, opcionAcierto, opcionFallo],
        ),
      ];

      final repoQuest = FakeQuestRepository(encuentros);
      final repoPartida = FakePartidaRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
        duracionPausaTurno: Duration.zero,
      );

      await controller.cargarQuest('q-eventos', 'u-1');

      // 1. Derrotar enemigo 1 (25 HP) con crítico (25 daño)
      await controller.elegirOpcion(opcionCritica);
      expect(controller.enemigosDerrotados, equals(1));
      expect(controller.encuentroSuperado, isTrue);
      expect(controller.esFinDeRonda, isFalse);

      // Debe generar evento de encuentro intermedio (Caso 1: Códice Arcano)
      expect(controller.eventoActivo, isNotNull);
      expect(controller.eventoActivo!.titulo, contains('Códice Arcano'));

      // Resolver con 'estudiar_codice': -10 HP, +100 score, +1 comodín
      final scoreAntesEvento = controller.score;
      final vidaAntesEvento = controller.vidaJugador;
      controller.resolverEventoDecision('estudiar_codice');

      expect(controller.eventoActivo, isNull);
      expect(controller.encuentroSuperado, isFalse);
      expect(controller.vidaJugador, equals(vidaAntesEvento - 10));
      expect(controller.score, equals(scoreAntesEvento + 100));
      expect(
        controller.historialNarrativo.any((l) =>
            l.contains('[COMODIN]') && l.contains('Estudiaste el Códice Arcano')),
        isTrue,
      );

      // Ahora estamos en el enemigo 2 (vidaEnemigo = 25)
      expect(controller.vidaEnemigo, equals(25));

      // 2. Derrotar enemigo 2 con crítico
      await controller.elegirOpcion(opcionCritica);
      expect(controller.enemigosDerrotados, equals(2));
      expect(controller.encuentroSuperado, isTrue);
      expect(controller.esFinDeRonda, isFalse);

      // Debe generar evento de encuentro intermedio (Caso 2: Mercader del Abismo)
      expect(controller.eventoActivo, isNotNull);
      expect(controller.eventoActivo!.titulo, contains('Mercader del Abismo'));

      // Resolver con 'mercader_poder': -15 HP, +150 score, +1 golpe doble
      final golpesDoblesAntes =
          controller.wildcards[TipoWildcard.golpeDoble] ?? 0;
      final scoreAntesMercader = controller.score;
      final vidaAntesMercader = controller.vidaJugador;
      controller.resolverEventoDecision('mercader_poder');

      expect(controller.eventoActivo, isNull);
      expect(controller.encuentroSuperado, isFalse);
      expect(controller.vidaJugador, equals(vidaAntesMercader - 15));
      expect(controller.score, equals(scoreAntesMercader + 150));
      expect(controller.wildcards[TipoWildcard.golpeDoble],
          equals(golpesDoblesAntes + 1));
      expect(
        controller.historialNarrativo.any((l) =>
            l.contains('[CRITICO]') &&
            l.contains('Aceptaste el Pacto del Mercader')),
        isTrue,
      );

      // 3. Derrotar enemigo 3 (completa ronda 1: enemigosDerrotados = 3)
      await controller.elegirOpcion(opcionCritica);
      expect(controller.enemigosDerrotados, equals(3));
      expect(controller.esFinDeRonda, isTrue);
      // Fin de ronda: no hay evento intermedio, se muestra el Altar de Ronda
      expect(controller.eventoActivo, isNull);
    });

    test('cargarQuest asigna valores de fallback cuando se pasan vacíos o tema < 3 chars', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1]);
      final repoPartida = FakePartidaRepository();
      final fakeGenerator = FakeQuestGeneratorRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(fakeGenerator),
        duracionPausaTurno: const Duration(milliseconds: 10),
      );

      // 1. Cargar con valores vacíos por defecto
      await controller.cargarQuest('q-1', 'u-1');
      expect(controller.temaQuest, equals('Aventura General'));
      expect(controller.categoriaQuest, equals('libre'));
      expect(controller.dificultadQuest, equals('facil'));

      // 2. Cargar con tema menor a 3 caracteres y espacios
      await controller.cargarQuest(
        'q-1',
        'u-1',
        temaQuest: '  ab  ',
        categoriaQuest: '   ',
        dificultadQuest: '   ',
      );
      expect(controller.temaQuest, equals('Aventura General'));
      expect(controller.categoriaQuest, equals('libre'));
      expect(controller.dificultadQuest, equals('facil'));

      // 3. Cargar con valores válidos explícitos
      await controller.cargarQuest(
        'q-1',
        'u-1',
        temaQuest: 'Bases de Datos',
        categoriaQuest: 'sql',
        dificultadQuest: 'medio',
      );
      expect(controller.temaQuest, equals('Bases de Datos'));
      expect(controller.categoriaQuest, equals('sql'));
      expect(controller.dificultadQuest, equals('medio'));
    });

    test('cargarQuest con fallbacks envía tema y categoría válidos al solicitar más encuentros', () async {
      final repoQuest = FakeQuestRepository([encuentroNormal1]);
      final repoPartida = FakePartidaRepository();
      final fakeGenerator = FakeQuestGeneratorRepository();
      final controller = CombateController(
        repoQuest,
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(repoPartida),
        GenerarEncuentrosExtraUseCase(fakeGenerator),
        duracionPausaTurno: const Duration(milliseconds: 10),
      );

      // Cargar quest sin tema ni categoría (ej. quest del sistema)
      await controller.cargarQuest('q-1', 'u-1');

      // Vencer al enemigo para agotar preguntas y disparar solicitud de más encuentros
      await controller.elegirOpcion(opcionCritica);

      // Debe haber llamado a generarEncuentrosExtra con los valores de fallback
      expect(fakeGenerator.ultimoTema, equals('Aventura General'));
      expect(fakeGenerator.ultimaCategoria, equals('libre'));
      expect(fakeGenerator.ultimaDificultad, equals('facil'));
    });
  });
}

