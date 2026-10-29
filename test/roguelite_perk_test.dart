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
  group('RoguelitePerk - Catálogo de 15 Perks', () {
    test('allPerks contiene exactamente los 15 perks requeridos divididos en 3 categorías', () {
      expect(RoguelitePerk.allPerks.length, 15);

      final armas = RoguelitePerk.allPerks.where((p) => p.category == PerkCategory.weapon).toList();
      final armaduras = RoguelitePerk.allPerks.where((p) => p.category == PerkCategory.armor).toList();
      final reliquias = RoguelitePerk.allPerks.where((p) => p.category == PerkCategory.relic).toList();

      expect(armas.length, 6);
      expect(armaduras.length, 4);
      expect(reliquias.length, 5);

      // Armas
      expect(armas.map((p) => p.id), containsAll([
        'iron_sword',
        'knight_broadsword',
        'swift_katana',
        'vampire_rapier',
        'boss_cleaver',
        'golden_excalibur',
      ]));

      // Armaduras
      expect(armaduras.map((p) => p.id), containsAll([
        'paladin_helm',
        'dwarven_plate',
        'elven_cloak',
        'archmage_robe',
      ]));

      // Reliquias
      expect(reliquias.map((p) => p.id), containsAll([
        'troll_blood',
        'titan_vitality',
        'oracle_essence',
        'berserker_brew',
        'greed_coin',
      ]));
    });

    test('verificación de propiedades de sinergia y sprites de héroe', () {
      final excalibur = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'golden_excalibur');
      expect(excalibur.isEvolution, isTrue);

      final paladin = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'paladin_helm');
      expect(paladin.heroPrefixOverride, 'knight_f');

      final dwarf = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'dwarven_plate');
      expect(dwarf.heroPrefixOverride, 'dwarf_m');

      final elf = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'elven_cloak');
      expect(elf.heroPrefixOverride, 'elf_m');

      final archmage = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'archmage_robe');
      expect(archmage.heroPrefixOverride, 'wizzard_m');
    });

    test('seleccionarPerk actualiza heroePrefijoActual, armaEquipada y comodines', () async {
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

      expect(controller.armaEquipada, 'weapon_regular_sword.png');
      expect(controller.heroePrefijoActual, 'knight_m');

      // 1. Equipar Katana
      final katana = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'swift_katana');
      controller.seleccionarPerk(katana);
      expect(controller.armaEquipada, 'weapon_katana.png');

      // 2. Equipar Armadura de Paladín (cambia aspecto a knight_f)
      final paladin = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'paladin_helm');
      controller.seleccionarPerk(paladin);
      expect(controller.heroePrefijoActual, 'knight_f');

      // 3. Seleccionar Esencia del Oráculo (+1 pista y +1 50/50)
      final pistasAntes = controller.wildcards[TipoWildcard.pista] ?? 0;
      final ccAntes = controller.wildcards[TipoWildcard.cincuentaCincuenta] ?? 0;
      final oracle = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'oracle_essence');
      controller.seleccionarPerk(oracle);
      expect(controller.wildcards[TipoWildcard.pista], pistasAntes + 1);
      expect(controller.wildcards[TipoWildcard.cincuentaCincuenta], ccAntes + 1);

      // 4. Seleccionar Elixir de Titán (+25 vida max y curación)
      final titan = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'titan_vitality');
      controller.seleccionarPerk(titan);
      expect(controller.vidaJugadorMax, 125);
    });

    test('Coraza Rúnica Enana reduce 45% el daño al fallar', () async {
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

      final dwarf = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'dwarven_plate');
      controller.seleccionarPerk(dwarf);

      // Daño estándar de contraataque = 15.
      // 15 * 0.45 = 6.75 -> round = 7 mitigado.
      // 15 - 7 = 8 recibido -> 100 - 8 = 92 HP restante.
      await controller.elegirOpcion(encuentro.opciones.first);
      expect(controller.vidaJugador, 92);
    });

    test('Manto Élfico permite esquivar contraataque con randomDodgeCheck', () async {
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

      final elf = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'elven_cloak');
      controller.seleccionarPerk(elf);
      controller.randomDodgeCheck = () => true;

      // Fallo pero esquiva el contraataque
      await controller.elegirOpcion(encuentro.opciones.first);
      expect(controller.vidaJugador, 100);
    });

    test('Brebaje Berserker duplica daño cuando vida < 50%', () async {
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

      final berserker = RoguelitePerk.allPerks.firstWhere((p) => p.id == 'berserker_brew');
      controller.seleccionarPerk(berserker);

      // Reducir vida por debajo del 50%
      controller.vidaJugador = 40;

      // Daño calidad 2 base = 25. Berserker x2 = 50.
      // Vida enemigo: 100 - 50 = 50.
      await controller.elegirOpcion(encuentro.opciones.first);
      expect(controller.vidaEnemigo, 50);
    });
  });
}
