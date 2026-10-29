import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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
import 'package:sysquest_app/presentation/screens/combate/combate_controller.dart';
import 'package:sysquest_app/presentation/screens/combate/combate_screen.dart';
import 'package:sysquest_app/presentation/theme/app_theme.dart';

class FakeQuestRepository implements QuestRepository {
  final encuentro = Encuentro(
    idEncuentro: 'enc-test',
    idQuest: 'quest-test',
    numero: 1,
    pregunta: 'Pregunta de prueba',
    dificultad: 'facil',
    tipoEncuentro: 'normal',
    vidaEnemigo: 100,
    opciones: const [
      OpcionEncuentro(
        idOpcion: 'op-critica',
        idEncuentro: 'enc-test',
        letra: 'A',
        texto: 'Respuesta crítica',
        calidad: 2,
      ),
      OpcionEncuentro(
        idOpcion: 'op-acierto',
        idEncuentro: 'enc-test',
        letra: 'B',
        texto: 'Respuesta correcta',
        calidad: 1,
      ),
      OpcionEncuentro(
        idOpcion: 'op-error',
        idEncuentro: 'enc-test',
        letra: 'C',
        texto: 'Respuesta incorrecta',
        calidad: 0,
      ),
      OpcionEncuentro(
        idOpcion: 'op-error-2',
        idEncuentro: 'enc-test',
        letra: 'D',
        texto: 'Otra respuesta incorrecta',
        calidad: 0,
      ),
    ],
  );

  @override
  Future<List<Encuentro>> obtenerEncuentros(String idQuest) async => [
    encuentro,
  ];

  @override
  Future<Quest?> obtenerQuestPorId(String idQuest) async => null;

  @override
  Future<void> guardarQuest(Quest quest) async {}

  @override
  Future<void> guardarQuestCompleta(QuestCompleta quest) async {}
}

class FakePartidaRepository implements PartidaRepository {
  @override
  Future<void> guardarPartida(Partida partida) async {}

  @override
  Future<ProgresoUsuario?> obtenerProgreso(String idUsuario) async => null;

  @override
  Future<void> actualizarProgreso(ProgresoUsuario progreso) async {}
}

class FakeQuestGeneratorRepository implements QuestGeneratorRepository {
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
    return [];
  }
}

void main() {
  testWidgets('muestra cada daño junto a la barra correspondiente', (
    tester,
  ) async {
    final controller = CombateController(
      FakeQuestRepository(),
      ResponderEncuentroUseCase(),
      FinalizarPartidaUseCase(FakePartidaRepository()),
      GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ChangeNotifierProvider.value(
          value: controller,
          child: const CombateScreen(
            idQuest: 'quest-test',
            idUsuario: 'usuario-test',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final barras = find.byType(LinearProgressIndicator);
    expect(barras, findsNWidgets(2));

    final opcionCritica = find.text('A  Respuesta crítica');
    await tester.ensureVisible(opcionCritica);
    await tester.pump();
    await tester.tap(opcionCritica);
    await tester.pump(const Duration(milliseconds: 100));
    final posicionBarraEnemigo = tester.getTopLeft(barras.at(0));
    final posicionDanioEnemigo = tester.getCenter(find.text('-25').first);
    expect(posicionDanioEnemigo.dy, lessThan(posicionBarraEnemigo.dy + 24));

    await tester.pump(const Duration(milliseconds: 900));
    final opcionIncorrrecta = find.text('C  Respuesta incorrecta');
    await tester.ensureVisible(opcionIncorrrecta);
    await tester.pump();
    await tester.tap(opcionIncorrrecta);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(barras.at(1));
    await tester.pump();
    final posicionBarraJugador = tester.getTopLeft(barras.at(1));
    final posicionDanioJugador = tester.getCenter(find.text('-15').first);
    expect(posicionDanioJugador.dy, lessThan(posicionBarraJugador.dy + 24));

    controller.dispose();
  });

  testWidgets('la barra de vida del enemigo se actualiza y baja visiblemente al recibir daño', (
    tester,
  ) async {
    final controller = CombateController(
      FakeQuestRepository(),
      ResponderEncuentroUseCase(),
      FinalizarPartidaUseCase(FakePartidaRepository()),
      GenerarEncuentrosExtraUseCase(FakeQuestGeneratorRepository()),
      duracionPausaTurno: Duration.zero,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ChangeNotifierProvider.value(
          value: controller,
          child: const CombateScreen(
            idQuest: 'quest-test',
            idUsuario: 'usuario-test',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final barraEnemigoInicial = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).first,
    );
    expect(barraEnemigoInicial.value, equals(1.0));

    final opcionCritica = find.text('A  Respuesta crítica');
    await tester.ensureVisible(opcionCritica);
    await tester.pump();
    await tester.tap(opcionCritica);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final barraEnemigoDanada = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).first,
    );
    expect(barraEnemigoDanada.value, equals(0.75));

    controller.dispose();
  });
}
