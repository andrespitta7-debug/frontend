import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/domain/entities/encuentro.dart';
import 'package:sysquest_app/domain/entities/opcion_encuentro.dart';
import 'package:sysquest_app/domain/entities/quest.dart';
import 'package:sysquest_app/domain/entities/quest_completa.dart';
import 'package:sysquest_app/domain/repositories/quest_generator_repository.dart';
import 'package:sysquest_app/domain/repositories/quest_repository.dart';
import 'package:sysquest_app/domain/usecases/generar_quest_usecase.dart';
import 'package:sysquest_app/presentation/screens/generar_quest/generar_quest_controller.dart';
import 'package:sysquest_app/infrastructure/api/api_exception.dart';

class FakeQuestGeneratorRepository implements QuestGeneratorRepository {
  FakeQuestGeneratorRepository(this.questCompleta);

  final QuestCompleta questCompleta;

  @override
  Future<QuestCompleta> generarQuest(String tema) async => questCompleta;

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

QuestCompleta crearQuest({required String titulo}) {
  const questId = 'quest-controller-test';
  final encuentros = List.generate(3, (indice) {
    final numero = indice + 1;
    final encuentroId = 'enc-controller-$numero';
    final opciones = [
      OpcionEncuentro(
        idOpcion: 'op-$numero-a',
        idEncuentro: encuentroId,
        letra: 'A',
        texto: 'Respuesta principal',
        calidad: 2,
      ),
      OpcionEncuentro(
        idOpcion: 'op-$numero-b',
        idEncuentro: encuentroId,
        letra: 'B',
        texto: 'Respuesta parcial',
        calidad: 1,
      ),
      OpcionEncuentro(
        idOpcion: 'op-$numero-c',
        idEncuentro: encuentroId,
        letra: 'C',
        texto: 'Respuesta incorrecta',
        calidad: 0,
      ),
      OpcionEncuentro(
        idOpcion: 'op-$numero-d',
        idEncuentro: encuentroId,
        letra: 'D',
        texto: 'Otra respuesta incorrecta',
        calidad: 0,
      ),
    ];

    return Encuentro(
      idEncuentro: encuentroId,
      idQuest: questId,
      numero: numero,
      pregunta: 'Pregunta de prueba $numero',
      dificultad: numero == 1
          ? 'facil'
          : numero == 2
              ? 'medio'
              : 'dificil',
      tipoEncuentro: numero == 3 ? 'jefe' : 'normal',
      vidaEnemigo: 30,
      opciones: opciones,
    );
  });

  return QuestCompleta(
    quest: Quest(
      idQuest: questId,
      titulo: titulo,
      tema: 'tema de prueba',
      categoria: 'libre',
      dificultad: 'facil',
      descripcion: 'Descripción de prueba',
      fuenteGeneracion: 'ia',
    ),
    encuentros: encuentros,
  );
}

void main() {
  group('GenerarQuestController', () {
    test('transiciona de generando a exito con un generador falso', () async {
      final repo = FakeQuestRepository();
      final quest = crearQuest(titulo: 'Quest válida');
      final controller = GenerarQuestController(
        GenerarQuestUseCase(FakeQuestGeneratorRepository(quest), repo),
      );
      final estados = <GenerarQuestEstado>[];
      controller.addListener(() => estados.add(controller.estado));

      await controller.generar('tema válido');

      expect(estados, [GenerarQuestEstado.generando, GenerarQuestEstado.exito]);
      expect(controller.questGenerada, same(quest));
      expect(repo.questGuardada, same(quest));
      expect(controller.mensajeError, isNull);
      controller.dispose();
    });

    test('transiciona de generando a error y conserva el mensaje', () async {
      final repo = FakeQuestRepository();
      final controller = GenerarQuestController(
        GenerarQuestUseCase(
          FakeQuestGeneratorRepository(crearQuest(titulo: '   ')),
          repo,
        ),
      );
      final estados = <GenerarQuestEstado>[];
      controller.addListener(() => estados.add(controller.estado));

      await controller.generar('tema válido');

      expect(estados, [GenerarQuestEstado.generando, GenerarQuestEstado.error]);
      expect(controller.questGenerada, isNull);
      expect(
        controller.mensajeError,
        'El título de la quest no puede estar vacío.',
      );
      expect(repo.questGuardada, isNull);
      controller.dispose();
    });

    test(
        'captura ApiException temporal (IA_TIMEOUT) y marca esErrorReintentable como true',
        () async {
      final repo = FakeQuestRepository();
      final controller = GenerarQuestController(
        GenerarQuestUseCase(
          _ThrowingQuestGeneratorRepository(
            const ApiException(
              'La IA tardó demasiado en responder. Intenta de nuevo o prueba con un tema más específico.',
              statusCode: 504,
              codigo: 'IA_TIMEOUT',
            ),
          ),
          repo,
        ),
      );

      await controller.generar('tema válido');

      expect(controller.estado, GenerarQuestEstado.error);
      expect(
        controller.mensajeError,
        'La IA tardó demasiado en responder. Intenta de nuevo o prueba con un tema más específico.',
      );
      expect(controller.codigoError, 'IA_TIMEOUT');
      expect(controller.esErrorReintentable, isTrue);
      controller.dispose();
    });

    test(
        'captura ApiException no reintentable (IA_JSON_INVALIDO) y marca esErrorReintentable como false',
        () async {
      final repo = FakeQuestRepository();
      final controller = GenerarQuestController(
        GenerarQuestUseCase(
          _ThrowingQuestGeneratorRepository(
            const ApiException(
              'La IA generó una respuesta con formato inválido. Intenta de nuevo.',
              statusCode: 502,
              codigo: 'IA_JSON_INVALIDO',
            ),
          ),
          repo,
        ),
      );

      await controller.generar('tema válido');

      expect(controller.estado, GenerarQuestEstado.error);
      expect(
        controller.mensajeError,
        'La IA generó una respuesta con formato inválido. Intenta de nuevo.',
      );
      expect(controller.codigoError, 'IA_JSON_INVALIDO');
      expect(controller.esErrorReintentable, isFalse);
      expect(controller.puedeUsarFallback, isTrue);
      controller.dispose();
    });

    test('puedeUsarFallback es true con IA_ y false sin IA_', () async {
      final repo = FakeQuestRepository();
      final controller = GenerarQuestController(
        GenerarQuestUseCase(
          _ThrowingQuestGeneratorRepository(
            const ApiException('Error',
                statusCode: 500, codigo: 'ERROR_PERSISTENCIA'),
          ),
          repo,
        ),
      );

      await controller.generar('tema válido');
      expect(controller.puedeUsarFallback, isFalse);

      controller.dispose();
    });

    test(
        'questSemillaAleatoria devuelve uno de los 3 UUIDs de semilla válidos',
        () {
      final repo = FakeQuestRepository();
      final controller = GenerarQuestController(
        GenerarQuestUseCase(
            FakeQuestGeneratorRepository(crearQuest(titulo: 'T')), repo),
      );

      const validas = {
        '00000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000003',
      };

      for (var i = 0; i < 20; i++) {
        final semilla = controller.questSemillaAleatoria();
        expect(validas.contains(semilla), isTrue);
      }

      controller.dispose();
    });

    test('cancelar() reinicia el estado a inicial e invalida la peticion',
        () async {
      final generator =
          FakeQuestGeneratorRepository(crearQuest(titulo: 'Quest Test'));
      final localRepo = FakeQuestRepository();
      final useCase = GenerarQuestUseCase(generator, localRepo);
      final controller = GenerarQuestController(useCase);

      controller.estado = GenerarQuestEstado.generando;
      controller.cancelar();

      expect(controller.estado, equals(GenerarQuestEstado.inicial));
      expect(controller.mensajeError, isNull);
      expect(controller.codigoError, isNull);

      controller.dispose();
    });
  });
}

class _ThrowingQuestGeneratorRepository implements QuestGeneratorRepository {
  final Object error;

  _ThrowingQuestGeneratorRepository(this.error);

  @override
  Future<QuestCompleta> generarQuest(String tema) async => throw error;

  @override
  Future<List<Encuentro>> generarEncuentrosExtra({
    required String idQuest,
    required String tema,
    required String categoria,
    required String dificultad,
    required int ultimoNumero,
  }) async =>
      throw error;
}
