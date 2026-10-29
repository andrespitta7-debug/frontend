import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sysquest_app/domain/entities/quest.dart';
import 'package:sysquest_app/domain/entities/quest_completa.dart';
import 'package:sysquest_app/domain/repositories/token_repository.dart';
import 'package:sysquest_app/infrastructure/api/api_exception.dart';
import 'package:sysquest_app/infrastructure/api/http_quest_repository.dart';

class FakeTokenRepository implements TokenRepository {
  String? token;

  FakeTokenRepository({this.token = 'test-jwt-token'});

  @override
  Future<String?> obtenerAccessToken() async => token;

  @override
  Future<void> guardarTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {}

  @override
  Future<String?> obtenerRefreshToken() async => null;

  @override
  Future<bool> tokenExpirado() async => false;

  @override
  Future<void> limpiarTokens() async {}
}

void main() {
  const baseUrl = 'https://jctulgfdweeurqbmugot.supabase.co';
  const anonKey = 'test-anon-key';
  const accessToken = 'test-jwt-token';
  final fakeTokenRepo = FakeTokenRepository(token: accessToken);

  final sampleSuccessJson = jsonEncode({
    'ok': true,
    'quest': {
      'id': '00000000-0000-0000-0000-000000000001',
      'titulo': 'Quest de Programación Básica',
      'tema': 'Variables, condicionales y funciones',
      'categoria': 'debug',
      'dificultad': 'facil',
      'descripcion': 'Repasa conceptos básicos de programación con ejemplos simples.',
      'fuente_generacion': 'DOCENTE',
      'version': 1,
      'encuentros': [
        {
          'id': '00000000-0000-0000-0000-000000000101',
          'numero': 1,
          'tipo_encuentro': 'normal',
          'dificultad': 'facil',
          'vida_enemigo': 30,
          'enemigo': 'Bug del Alcance',
          'pregunta': '¿Para qué sirve una variable en un programa?',
          'codigo': null,
          'opciones': [
            {
              'id': 'op-1',
              'letra': 'A',
              'texto': 'Para guardar un valor para usarlo después',
              'calidad': 2,
              'explicacion': null,
            },
            {
              'id': 'op-2',
              'letra': 'B',
              'texto': 'Para hacer que el programa se detenga',
              'calidad': 0,
              'explicacion': null,
            },
            {
              'id': 'op-3',
              'letra': 'C',
              'texto': 'Para crear una imagen en pantalla',
              'calidad': 0,
              'explicacion': null,
            },
            {
              'id': 'op-4',
              'letra': 'D',
              'texto': 'Para borrar información del programa',
              'calidad': 1,
              'explicacion': null,
            },
          ],
        },
        {
          'id': '00000000-0000-0000-0000-000000000102',
          'numero': 2,
          'tipo_encuentro': 'normal',
          'dificultad': 'medio',
          'vida_enemigo': 40,
          'enemigo': 'Guardián del If',
          'pregunta': '¿Qué hace una condicional if en programación?',
          'codigo': null,
          'opciones': [
            {
              'id': 'op-5',
              'letra': 'A',
              'texto': 'Evalúa una condición y decide qué hacer según el resultado',
              'calidad': 2,
              'explicacion': null,
            },
            {
              'id': 'op-6',
              'letra': 'B',
              'texto': 'Guarda un valor en memoria',
              'calidad': 1,
              'explicacion': null,
            },
            {
              'id': 'op-7',
              'letra': 'C',
              'texto': 'Crea una nueva ventana del sistema',
              'calidad': 0,
              'explicacion': null,
            },
            {
              'id': 'op-8',
              'letra': 'D',
              'texto': 'Borra el código del programa',
              'calidad': 0,
              'explicacion': null,
            },
          ],
        },
        {
          'id': '00000000-0000-0000-0000-000000000103',
          'numero': 3,
          'tipo_encuentro': 'jefe',
          'dificultad': 'dificil',
          'vida_enemigo': 70,
          'enemigo': 'Dragón de la Recursión',
          'pregunta': '¿Qué es una función en programación?',
          'codigo': null,
          'opciones': [
            {
              'id': 'op-9',
              'letra': 'A',
              'texto': 'Un bloque de instrucciones reutilizable para realizar una tarea',
              'calidad': 2,
              'explicacion': null,
            },
            {
              'id': 'op-10',
              'letra': 'B',
              'texto': 'Un tipo de dato que solo guarda números',
              'calidad': 0,
              'explicacion': null,
            },
            {
              'id': 'op-11',
              'letra': 'C',
              'texto': 'Una base de datos pequeña',
              'calidad': 0,
              'explicacion': null,
            },
            {
              'id': 'op-12',
              'letra': 'D',
              'texto': 'Una pantalla de inicio del programa',
              'calidad': 1,
              'explicacion': null,
            },
          ],
        },
      ],
    },
  });

  group('HttpQuestRepository', () {
    test('obtenerQuestPorId exitoso devuelve Quest con campos correctos', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('$baseUrl/functions/v1/obtener-quest-completa'),
        );
        expect(request.headers['Content-Type'], equals('application/json'));
        expect(
          request.headers['Authorization'],
          equals('Bearer $accessToken'),
        );
        expect(request.headers['apikey'], equals(anonKey));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['id_quest'], equals('00000000-0000-0000-0000-000000000001'));

        return http.Response(sampleSuccessJson, 200);
      });

      final repo = HttpQuestRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      final quest = await repo.obtenerQuestPorId('00000000-0000-0000-0000-000000000001');

      expect(quest, isNotNull);
      expect(quest!.idQuest, equals('00000000-0000-0000-0000-000000000001'));
      expect(quest.titulo, equals('Quest de Programación Básica'));
      expect(quest.tema, equals('Variables, condicionales y funciones'));
      expect(quest.categoria, equals('debug'));
      expect(quest.dificultad, equals('facil'));
      expect(quest.descripcion, contains('Repasa conceptos básicos'));
      expect(quest.fuenteGeneracion, equals('docente'));
    });

    test('obtenerQuestPorId con 404 devuelve null', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'QUEST_NO_ENCONTRADA',
          }),
          404,
        );
      });

      final repo = HttpQuestRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      final quest = await repo.obtenerQuestPorId('uuid-inexistente');
      expect(quest, isNull);
    });

    test('obtenerEncuentros exitoso devuelve 3 encuentros con 4 opciones cada uno', () async {
      final mockClient = MockClient((request) async {
        return http.Response(sampleSuccessJson, 200);
      });

      final repo = HttpQuestRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      final encuentros = await repo.obtenerEncuentros('00000000-0000-0000-0000-000000000001');

      expect(encuentros.length, equals(3));

      // Primer encuentro
      final enc1 = encuentros[0];
      expect(enc1.idEncuentro, equals('00000000-0000-0000-0000-000000000101'));
      expect(enc1.numero, equals(1));
      expect(enc1.tipoEncuentro, equals('normal'));
      expect(enc1.esJefe, isFalse);
      expect(enc1.vidaEnemigo, equals(30));
      expect(enc1.pregunta, equals('¿Para qué sirve una variable en un programa?'));
      expect(enc1.opciones.length, equals(4));
      expect(enc1.opciones[0].letra, equals('A'));
      expect(enc1.opciones[0].calidad, equals(2));
      expect(enc1.opciones[3].letra, equals('D'));
      expect(enc1.opciones[3].calidad, equals(1));

      // Tercer encuentro (jefe)
      final enc3 = encuentros[2];
      expect(enc3.idEncuentro, equals('00000000-0000-0000-0000-000000000103'));
      expect(enc3.numero, equals(3));
      expect(enc3.tipoEncuentro, equals('jefe'));
      expect(enc3.esJefe, isTrue);
      expect(enc3.vidaEnemigo, equals(70));
      expect(enc3.opciones.length, equals(4));
    });

    test('obtenerEncuentros con 404 devuelve lista vacía', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'QUEST_NO_ENCONTRADA',
          }),
          404,
        );
      });

      final repo = HttpQuestRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      final encuentros = await repo.obtenerEncuentros('uuid-inexistente');
      expect(encuentros, isEmpty);
    });

    test('obtenerEncuentros sin token lanza ApiException 401', () async {
      final repo = HttpQuestRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: FakeTokenRepository(token: null),
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(
        () => repo.obtenerEncuentros('00000000-0000-0000-0000-000000000001'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains('Tu sesión expiró, vuelve a iniciar sesión.'),
              )
              .having((e) => e.statusCode, 'statusCode', equals(401)),
        ),
      );
    });

    test('obtenerEncuentros con 500 lanza ApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'ERROR_INTERNO',
          }),
          500,
        );
      });

      final repo = HttpQuestRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.obtenerEncuentros('00000000-0000-0000-0000-000000000001'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains('Error del servidor, intenta de nuevo.'),
              )
              .having((e) => e.statusCode, 'statusCode', equals(500)),
        ),
      );
    });

    test('guardarQuest y guardarQuestCompleta lanzan UnimplementedError', () {
      final repo = HttpQuestRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
      );

      const quest = Quest(
        idQuest: 'q1',
        titulo: 'T',
        tema: 'Te',
        categoria: 'debug',
        dificultad: 'facil',
        descripcion: 'D',
        fuenteGeneracion: 'manual',
      );

      expect(
        () => repo.guardarQuest(quest),
        throwsA(isA<UnimplementedError>()),
      );

      expect(
        () => repo.guardarQuestCompleta(QuestCompleta(quest: quest, encuentros: [])),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
