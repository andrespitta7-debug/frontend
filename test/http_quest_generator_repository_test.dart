import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sysquest_app/domain/repositories/token_repository.dart';
import 'package:sysquest_app/infrastructure/api/api_exception.dart';
import 'package:sysquest_app/infrastructure/api/http_quest_generator_repository.dart';

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
    'fuente': 'AI',
    'proveedor_ia': 'groq',
    'quest': {
      'id': 'quest-uuid-1',
      'titulo': 'El Abismo de la Recursión',
      'tema': 'recursión',
      'categoria': 'debug',
      'dificultad': 'facil',
      'descripcion': 'Depura las funciones antes de que la pila colapse.',
      'fuente_generacion': 'AI',
      'version': 1,
      'encuentros': [
        {
          'id': 'enc-uuid-1',
          'numero': 1,
          'tipo_encuentro': 'normal',
          'dificultad': 'facil',
          'vida_enemigo': 25,
          'enemigo': 'Goblin del Caso Base',
          'pregunta': '¿Cuál es el error en la función factorial?',
          'codigo': 'int f(int n) { return n * f(n-1); }',
          'opciones': [
            {
              'id': 'op-uuid-1',
              'letra': 'A',
              'texto': 'Falta caso base',
              'calidad': 2,
              'explicacion': 'Sin caso base la llamada es infinita',
            },
            {
              'id': 'op-uuid-2',
              'letra': 'B',
              'texto': 'Usar bucle for',
              'calidad': 1,
              'explicacion': 'Funciona pero no explica la recursión',
            },
            {
              'id': 'op-uuid-3',
              'letra': 'C',
              'texto': 'Cambiar tipo a double',
              'calidad': 0,
              'explicacion': 'Incorrecto',
            },
            {
              'id': 'op-uuid-4',
              'letra': 'D',
              'texto': 'Falta return',
              'calidad': 0,
              'explicacion': 'Ya tiene return',
            },
          ],
        },
        {
          'id': 'enc-uuid-2',
          'numero': 2,
          'tipo_encuentro': 'normal',
          'dificultad': 'facil',
          'vida_enemigo': 25,
          'enemigo': 'Slime de Pila',
          'pregunta': '¿Por qué la suma nunca termina?',
          'codigo': null,
          'opciones': [
            {
              'id': 'op-uuid-5',
              'letra': 'A',
              'texto': 'Llamada recursiva se aleja del caso base',
              'calidad': 2,
              'explicacion': 'Debe decrementar hacia cero',
            },
            {
              'id': 'op-uuid-6',
              'letra': 'B',
              'texto': 'Limitar con if',
              'calidad': 1,
              'explicacion': 'Evita el crash pero da resultado erróneo',
            },
            {
              'id': 'op-uuid-7',
              'letra': 'C',
              'texto': 'Caso base en 1',
              'calidad': 0,
              'explicacion': 'Incorrecto',
            },
            {
              'id': 'op-uuid-8',
              'letra': 'D',
              'texto': 'Multiplicar en vez de sumar',
              'calidad': 0,
              'explicacion': 'Incorrecto',
            },
          ],
        },
        {
          'id': 'enc-uuid-3',
          'numero': 3,
          'tipo_encuentro': 'jefe',
          'dificultad': 'facil',
          'vida_enemigo': 70,
          'enemigo': 'Dragón Fibonacci',
          'pregunta': '¿Cómo acelerar el cálculo exponencial?',
          'codigo': null,
          'opciones': [
            {
              'id': 'op-uuid-9',
              'letra': 'A',
              'texto': 'Memoización o iteración',
              'calidad': 2,
              'explicacion': 'Reduce de exponencial a lineal',
            },
            {
              'id': 'op-uuid-10',
              'letra': 'B',
              'texto': 'Limitar a n pequeños',
              'calidad': 1,
              'explicacion': 'Esquiva el problema',
            },
            {
              'id': 'op-uuid-11',
              'letra': 'C',
              'texto': 'Falta caso base',
              'calidad': 0,
              'explicacion': 'Sí tiene caso base',
            },
            {
              'id': 'op-uuid-12',
              'letra': 'D',
              'texto': 'Usar double',
              'calidad': 0,
              'explicacion': 'No influye en la complejidad',
            },
          ],
        },
      ],
    },
    'pool_narrativo': {
      'inicio': ['Empieza la aventura en el bosque.', 'Caminas por la cueva.'],
      'victoria': ['¡Ganaste!'],
    },
    'preguntas_extra': [
      {
        'id': 'enc-extra-1',
        'numero': 4,
        'tipo_encuentro': 'normal',
        'dificultad': 'facil',
        'vida_enemigo': 20,
        'enemigo': 'Esqueleto',
        'pregunta': '¿Pregunta extra?',
        'codigo': null,
        'opciones': [
          {
            'id': 'op-ex-1',
            'letra': 'A',
            'texto': 'Sí',
            'calidad': 2,
            'explicacion': null,
          },
        ],
      }
    ],
    'semilla': 12345,
    'id_partida': 'partida-test',
  });

  group('HttpQuestGeneratorRepository', () {
    test('generarQuest exitoso construye QuestCompleta correctamente', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('$baseUrl/functions/v1/generar-quest-completa'),
        );
        expect(request.headers['Content-Type'], equals('application/json'));
        expect(
          request.headers['Authorization'],
          equals('Bearer $accessToken'),
        );
        expect(request.headers['apikey'], equals(anonKey));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['tema'], equals('recursión'));
        expect(body['categoria'], equals('libre'));
        expect(body['dificultad'], equals('facil'));

        return http.Response(sampleSuccessJson, 201);
      });

      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      final resultado = await repo.generarQuest('recursión');

      expect(resultado.quest.idQuest, equals('quest-uuid-1'));
      expect(resultado.quest.titulo, equals('El Abismo de la Recursión'));
      expect(resultado.quest.tema, equals('recursión'));
      expect(resultado.quest.categoria, equals('debug'));
      expect(resultado.quest.dificultad, equals('facil'));
      expect(resultado.quest.descripcion, contains('Depura las funciones'));
      // Verificación clave: fuenteGeneracion en minúscula para el dominio
      expect(resultado.quest.fuenteGeneracion, equals('ia'));

      expect(resultado.encuentros.length, equals(3));

      // Primer encuentro
      final enc1 = resultado.encuentros[0];
      expect(enc1.idEncuentro, equals('enc-uuid-1'));
      expect(enc1.idQuest, equals('quest-uuid-1'));
      expect(enc1.numero, equals(1));
      expect(enc1.tipoEncuentro, equals('normal'));
      expect(enc1.esJefe, isFalse);
      expect(enc1.vidaEnemigo, equals(25));
      expect(enc1.opciones.length, equals(4));
      expect(enc1.opciones[0].idOpcion, equals('op-uuid-1'));
      expect(enc1.opciones[0].letra, equals('A'));
      expect(enc1.opciones[0].calidad, equals(2));

      // Tercer encuentro (jefe)
      final enc3 = resultado.encuentros[2];
      expect(enc3.idEncuentro, equals('enc-uuid-3'));
      expect(enc3.numero, equals(3));
      expect(enc3.tipoEncuentro, equals('jefe'));
      expect(enc3.esJefe, isTrue);
      expect(enc3.vidaEnemigo, equals(70));
      expect(enc3.opciones.length, equals(4));

      // Verificación de los nuevos campos
      expect(resultado.poolNarrativo, isNotNull);
      expect((resultado.poolNarrativo!['inicio'] as List).length, equals(2));
      expect(resultado.preguntasExtra.length, equals(1));
      expect(resultado.preguntasExtra[0].pregunta, equals('¿Pregunta extra?'));
      expect(resultado.semilla, equals(12345));
      expect(resultado.idPartida, equals('partida-test'));
    });

    test('generarQuest sin token en TokenRepository lanza ApiException 401', () async {
      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: FakeTokenRepository(token: null),
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(
        () => repo.generarQuest('recursión'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains('Tu sesión expiró. Vuelve a iniciar sesión.'),
              )
              .having((e) => e.statusCode, 'statusCode', equals(401)),
        ),
      );
    });

    test('generarQuest con 401 lanza ApiException de sesión expirada', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'ok': false, 'codigo': 'NO_AUTORIZADO'}),
          401,
        );
      });

      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.generarQuest('recursión'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains('Tu sesión expiró. Vuelve a iniciar sesión.'),
              )
              .having((e) => e.statusCode, 'statusCode', equals(401)),
        ),
      );
    });

    test(
        'generarQuest con 502 e IA_NO_DISPONIBLE lanza ApiException específico',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'IA_NO_DISPONIBLE',
            'usar_fallback': true,
          }),
          502,
        );
      });

      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.generarQuest('recursión'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains(
                    'El servicio de IA no está disponible en este momento. Espera un minuto y vuelve a intentar.'),
              )
              .having((e) => e.statusCode, 'statusCode', equals(502))
              .having((e) => e.codigo, 'codigo', equals('IA_NO_DISPONIBLE')),
        ),
      );
    });

    test('generarQuest con error de red lanza ApiException', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Network failure');
      });

      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.generarQuest('recursión'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains(
                'No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.'),
          ),
        ),
      );
    });

    test('generarQuest con 400 extrae el campo detalle', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'INPUT_INVALIDO',
            'detalle': 'tema debe tener entre 3 y 100 caracteres.',
          }),
          400,
        );
      });

      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.generarQuest('ab'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains('tema debe tener entre 3 y 100 caracteres.'),
              )
              .having((e) => e.statusCode, 'statusCode', equals(400)),
        ),
      );
    });

    test('generarQuest con 504 e IA_TIMEOUT lanza mensaje de timeout', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'IA_TIMEOUT',
            'usar_fallback': true,
          }),
          504,
        );
      });

      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.generarQuest('recursión'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains(
                    'La IA tardó demasiado en responder. Intenta de nuevo o prueba con un tema más específico.'),
              )
              .having((e) => e.statusCode, 'statusCode', equals(504))
              .having((e) => e.codigo, 'codigo', equals('IA_TIMEOUT')),
        ),
      );
    });

    test('generarQuest con 500 y ERROR_PERSISTENCIA lanza mensaje mapeado',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'ERROR_PERSISTENCIA',
            'detalle': 'DB error',
          }),
          500,
        );
      });

      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.generarQuest('recursión'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains('Hubo un problema al guardar la quest. Intenta de nuevo.'),
              )
              .having((e) => e.codigo, 'codigo', equals('ERROR_PERSISTENCIA')),
        ),
      );
    });

    test('generarQuest con 502 e IA_JSON_INVALIDO lanza mensaje mapeado',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'IA_JSON_INVALIDO',
          }),
          502,
        );
      });

      final repo = HttpQuestGeneratorRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.generarQuest('recursión'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains(
                    'La IA generó una respuesta con formato inválido. Intenta de nuevo.'),
              )
              .having((e) => e.codigo, 'codigo', equals('IA_JSON_INVALIDO')),
        ),
      );
    });
  });
}
