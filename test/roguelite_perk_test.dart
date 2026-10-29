import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/domain/entities/encuentro.dart';
import 'package:sysquest_app/domain/entities/opcion_encuentro.dart';
import 'package:sysquest_app/domain/entities/personaje_partida.dart';
import 'package:sysquest_app/domain/entities/quest.dart';
import 'package:sysquest_app/domain/entities/quest_completa.dart';
import 'package:sysquest_app/domain/entities/roguelite_perk.dart';
import 'package:sysquest_app/domain/entities/wildcard.dart';
import 'package:sysquest_app/domain/repositories/partida_repository.dart';
import 'package:sysquest_app/domain/repositories/quest_generator_repository.dart';
import 'package:sysquest_app/domain/repositories/quest_repository.dart';
import 'package:sysquest_app/domain/usecases/finalizar_partida_usecase.dart';
import 'package:sysquest_app/domain/usecases/generar_encuentros_extra_usecase.dart';
import 'package:sysquest_app/domain/usecases/responder_encuentro_usecase.dart';
import 'package:sysquest_app/presentation/screens/combate/combate_controller.dart';

class _FakeQuestRepo implements QuestRepository {
  final List<Encuentro> encuentros;
  _FakeQuestRepo(this.encuentros);
  @override
  Future<List<Encuentro>> obtenerEncuentros(String idQuest) async => encuentros;
  @override
  Future<Quest?> obtenerQuestPorId(String idQuest) async => null;
  @override
  Future<void> guardarQuest(Quest quest) async {}
  @override
  Future<void> guardarQuestCompleta(QuestCompleta quest) async {}
}

class _FakePartidaRepo implements PartidaRepository {
  @override
  Future<void> guardarPartida(Partida partida) async {}
  @override
  Future<ProgresoUsuario?> obtenerProgreso(String idUsuario) async => null;
  @override
  Future<void> actualizarProgreso(ProgresoUsuario progreso) async {}
}

class _FakeQuestGenRepo implements QuestGeneratorRepository {
  @override
  Future<QuestCompleta> generarQuest(String tema) async => throw UnimplementedError();
  @override
  Future<List<Encuentro>> generarEncuentrosExtra({
    required String idQuest,
    required String tema,
    required String categoria,
    required String dificultad,
    required int ultimoNumero,
  }) async => [];
}

void main() {
  group('RoguelitePerk', () {
    test('allPerks contiene los 5 perks requeridos', () {
      final ids = RoguelitePerk.allPerks.map((p) => p.id).toList();
      expect(ids, contains('crimson_edge'));
      expect(ids, contains('academic_vampirism'));
      expect(ids, contains('compile_frenzy'));
      expect(ids, contains('alchemical_refill'));
      expect(ids, contains('dwarven_armor'));
    });

    test('seleccionarPerk actualiza armaEquipada y aplica recarga alquímica', () async {
      final encuentro = Encuentro(
        idEncuentro: 'e1',
        idQuest: 'q1',
        numero: 1,
        pregunta: '¿Pregunta?',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 100,
        opciones: const [
          OpcionEncuentro(idOpcion: 'o1', idEncuentro: 'e1', letra: 'A', texto: 'A', calidad: 2),
          OpcionEncuentro(idOpcion: 'o2', idEncuentro: 'e1', letra: 'B', texto: 'B', calidad: 1),
          OpcionEncuentro(idOpcion: 'o3', idEncuentro: 'e1', letra: 'C', texto: 'C', calidad: 0),
          OpcionEncuentro(idOpcion: 'o4', idEncuentro: 'e1', letra: 'D', texto: 'D', calidad: 0),
        ],
      );

      final controller = CombateController(
        _FakeQuestRepo([encuentro]),
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(_FakePartidaRepo()),
        GenerarEncuentrosExtraUseCase(_FakeQuestGenRepo()),
        duracionPausaTurno: Duration.zero,
      );

      await controller.cargarQuest(
        'q1',
        'u1',
        questTitle: 'Castillo de Código',
        resolvedTopic: 'Estructuras de Datos',
      );

      expect(controller.armaEquipada, 'weapon_knight_sword.png');

      // Seleccionar Filo Carmesí
      final crimsonPerk = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'crimson_edge');
      controller.seleccionarPerk(crimsonPerk);

      expect(controller.armaEquipada, 'weapon_red_gem_sword.png');
      expect(controller.activePerks.length, 1);

      // Seleccionar Recarga Alquímica
      final refillPerk = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'alchemical_refill');
      final pistasIniciales = controller.wildcards[TipoWildcard.pista] ?? 0;
      controller.seleccionarPerk(refillPerk);

      expect(controller.wildcards[TipoWildcard.pista], pistasIniciales + 1);
    });

    test('Dwarven Armor reduce 40% el daño recibido al fallar', () async {
      final encuentro = Encuentro(
        idEncuentro: 'e1',
        idQuest: 'q1',
        numero: 1,
        pregunta: '¿Pregunta?',
        dificultad: 'facil',
        tipoEncuentro: 'normal',
        vidaEnemigo: 100,
        opciones: const [
          OpcionEncuentro(idOpcion: 'o3', idEncuentro: 'e1', letra: 'C', texto: 'C', calidad: 0),
        ],
      );

      final controller = CombateController(
        _FakeQuestRepo([encuentro]),
        ResponderEncuentroUseCase(),
        FinalizarPartidaUseCase(_FakePartidaRepo()),
        GenerarEncuentrosExtraUseCase(_FakeQuestGenRepo()),
        duracionPausaTurno: Duration.zero,
      );

      await controller.cargarQuest('q1', 'u1');

      // Equipar Armadura Enana
      final armorPerk = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'dwarven_armor');
      controller.seleccionarPerk(armorPerk);

      // Fallo estándar causa 15 daño. 15 * 0.40 = 6 mitigado -> 9 daño recibido.
      // 100 - 9 = 91 HP restante.
      await controller.elegirOpcion(encuentro.opciones.first);

      expect(controller.vidaJugador, 91);
    });
  });
}
