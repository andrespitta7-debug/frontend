import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/infrastructure/api/api_exception.dart';
import 'package:sysquest_app/presentation/screens/generar_quest/quest_retry_controller.dart';

void main() {
  group('QuestGenerationRetryController', () {
    late QuestGenerationRetryController controller;

    setUp(() {
      controller = QuestGenerationRetryController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('éxito devuelve el resultado en el primer intento', () async {
      int llamadas = 0;
      final resultado = await controller.generarQuestConReintentos<String>(
        executeUseCase: () async {
          llamadas++;
          return 'quest-exitosa';
        },
      );

      expect(resultado, 'quest-exitosa');
      expect(llamadas, 1);
      expect(controller.value.attempt, 1);
      expect(controller.value.isGenerating, isFalse);
      expect(controller.value.secondsUntilNextRetry, 0);
    });

    test('reintenta ante error de IA_NO_DISPONIBLE y tiene éxito en el segundo intento', () async {
      int llamadas = 0;
      final estados = <int>[];
      controller.addListener(() {
        if (controller.value.secondsUntilNextRetry > 0) {
          estados.add(controller.value.secondsUntilNextRetry);
        }
      });

      final resultado = await controller.generarQuestConReintentos<String>(
        executeUseCase: () async {
          llamadas++;
          if (llamadas == 1) {
            throw const ApiException(
              'Servicio saturado',
              codigo: 'IA_NO_DISPONIBLE',
              statusCode: 429,
            );
          }
          return 'exito-reintento';
        },
      );

      expect(resultado, 'exito-reintento');
      expect(llamadas, 2);
      expect(estados.isNotEmpty, isTrue);
      // Intento 1 backoff: 2^1 = 2 segundos
      expect(estados.first, 2);
    });

    test('cancelarInvocacion detiene el ciclo de reintentos y devuelve null', () async {
      Future<String?>? invocacion;

      invocacion = controller.generarQuestConReintentos<String>(
        executeUseCase: () async {
          throw const ApiException(
            'IA ocupada',
            codigo: 'IA_TIMEOUT',
            statusCode: 504,
          );
        },
      );

      // Esperar brevemente a que entre en backoff
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.value.secondsUntilNextRetry, greaterThan(0));

      // Cancelar
      controller.cancelarInvocacion();

      final resultado = await invocacion;
      expect(resultado, isNull);
      expect(controller.isCancelled, isTrue);
      expect(controller.value.isCancelled, isTrue);
      expect(controller.value.secondsUntilNextRetry, 0);
    });

    test('lanza excepción ante un error no relacionado con IA', () async {
      expect(
        () => controller.generarQuestConReintentos<String>(
          executeUseCase: () async {
            throw const FormatException('Error de formato fatal');
          },
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

