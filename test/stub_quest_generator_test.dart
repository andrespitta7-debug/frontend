import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/domain/entities/encuentro.dart';
import 'package:sysquest_app/domain/entities/quest.dart';
import 'package:sysquest_app/domain/entities/quest_completa.dart';
import 'package:sysquest_app/domain/repositories/quest_repository.dart';
import 'package:sysquest_app/domain/usecases/generar_quest_usecase.dart';
import 'package:sysquest_app/infrastructure/generation/stub_quest_generator.dart';

class FakeQuestRepository implements QuestRepository {
  QuestCompleta? questGuardada;

  @override
  Future<void> guardarQuestCompleta(QuestCompleta quest) async {
    questGuardada = quest;
  }

  @override
  Future<Quest?> obtenerQuestPorId(String idQuest) async => null;

  @override
  Future<List<Encuentro>> obtenerEncuentros(String idQuest) async => [];

  @override
  Future<void> guardarQuest(Quest quest) async {}
}

void main() {
  test('el stub genera una quest válida y el caso de uso la guarda', () async {
    const tema = 'recursión en programación';
    final repo = FakeQuestRepository();
    final useCase = GenerarQuestUseCase(StubQuestGenerator(), repo);

    final questCompleta = await useCase.ejecutar(tema);

    expect(questCompleta.quest.fuenteGeneracion, 'ia');
    expect(questCompleta.quest.categoria, 'libre');
    expect(questCompleta.quest.titulo, contains(tema));
    expect(questCompleta.quest.descripcion, contains(tema));
    expect(questCompleta.encuentros, hasLength(3));
    expect(questCompleta.encuentros.map((e) => e.numero), [1, 2, 3]);
    expect(questCompleta.encuentros.map((e) => e.tipoEncuentro), [
      'normal',
      'normal',
      'jefe',
    ]);
    expect(questCompleta.encuentros.map((e) => e.vidaEnemigo), [30, 40, 70]);
    expect(questCompleta.encuentros.map((e) => e.dificultad), [
      'facil',
      'medio',
      'dificil',
    ]);

    for (final encuentro in questCompleta.encuentros) {
      expect(encuentro.opciones, hasLength(4));
      expect(encuentro.opciones.map((o) => o.letra), ['A', 'B', 'C', 'D']);
      expect(encuentro.opciones.map((o) => o.calidad), [2, 1, 0, 0]);
      expect(
        encuentro.opciones.every(
          (opcion) => opcion.idEncuentro == encuentro.idEncuentro,
        ),
        isTrue,
      );
    }

    expect(repo.questGuardada, same(questCompleta));
  });
}
