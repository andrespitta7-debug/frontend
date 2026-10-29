import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sysquest_app/domain/entities/personaje_partida.dart';
import 'package:sysquest_app/domain/repositories/token_repository.dart';
import 'package:sysquest_app/infrastructure/api/api_exception.dart';
import 'package:sysquest_app/infrastructure/api/http_partida_repository.dart';

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

  final partidaEjemplo = Partida(
    idPartida: 'partida-uuid-1',
    idUsuario: 'user-uuid-1',
    idQuest: '00000000-0000-0000-0000-000000000001',
    estado: 'ganada',
    encuentroActual: 2,
    score: 150,
    xpObtenida: 50,
    tiempoSegundos: 45,
    vidaJugador: 80,
    enemigosDerrotados: 3,
  );

  group('HttpPartidaRepository', () {
    test('guardarPartida exitoso llama al endpoint con headers y body correctos', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('$baseUrl/functions/v1/finalizar-partida'),
        );
        expect(request.headers['Content-Type'], equals('application/json'));
        expect(
          request.headers['Authorization'],
          equals('Bearer $accessToken'),
        );
        expect(request.headers['apikey'], equals(anonKey));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['id_partida'], equals('partida-uuid-1'));
        expect(body['id_quest'], equals('00000000-0000-0000-0000-000000000001'));
        expect(body['estado'], equals('ganada'));
        expect(body['encuentro_actual'], equals(2));
        expect(body['enemigos_derrotados'], equals(3));
        expect(body['racha_maxima'], equals(0));
        expect(body['rondas_temerarias'], equals(0));
        expect(body.containsKey('score'), isFalse);
        expect(body.containsKey('xp_obtenida'), isFalse);
        expect(body['tiempo_segundos'], equals(45));
        expect(body['vida_jugador_actual'], equals(80));
        expect(body['vida_enemigo_actual'], isNull);

        return http.Response(jsonEncode({'ok': true}), 200);
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      await expectLater(
        repo.guardarPartida(partidaEjemplo),
        completes,
      );
    });

    test('guardarPartida exitoso con resumen actualiza score y xpObtenida en memoria', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': true,
            'resumen': {
              'score_total': 450,
              'puntos_enemigos': 300,
              'bonus_racha': 50,
              'bonus_victoria': 100,
              'xp_obtenida': 45,
              'enemigos_derrotados': 3,
              'racha_maxima': 5,
              'dificultad': 'facil',
            },
          }),
          200,
        );
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      final p = Partida(
        idPartida: 'partida-test',
        idUsuario: 'user-test',
        idQuest: 'quest-test',
        rachaMaxima: 5,
        enemigosDerrotados: 3,
      );

      await repo.guardarPartida(p);
      expect(p.score, equals(450));
      expect(p.xpObtenida, equals(45));
    });

    test('guardarPartida sin token en TokenRepository lanza ApiException 401', () async {
      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: FakeTokenRepository(token: null),
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(
        () => repo.guardarPartida(partidaEjemplo),
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

    test('guardarPartida con 401 lanza ApiException de sesión expirada', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'ok': false, 'codigo': 'NO_AUTORIZADO'}),
          401,
        );
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.guardarPartida(partidaEjemplo),
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

    test('guardarPartida con 500 lanza ApiException de error de servidor', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'ok': false, 'codigo': 'ERROR_PERSISTENCIA'}),
          500,
        );
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.guardarPartida(partidaEjemplo),
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

    test('guardarPartida con 400 extrae el mensaje de error o detalle', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'INPUT_INVALIDO',
            'detalle': 'El campo id_quest es obligatorio.',
          }),
          400,
        );
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.guardarPartida(partidaEjemplo),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.mensaje,
                'mensaje',
                contains('El campo id_quest es obligatorio.'),
              )
              .having((e) => e.statusCode, 'statusCode', equals(400)),
        ),
      );
    });

    test('guardarPartida con error de red lanza ApiException', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Error de conexión');
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.guardarPartida(partidaEjemplo),
        throwsA(
          isA<ApiException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains('No se pudo conectar al servidor, revisa tu conexión.'),
          ),
        ),
      );
    });

    test('obtenerProgreso exitoso devuelve ProgresoUsuario con campos correctos', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('$baseUrl/functions/v1/obtener-progreso'),
        );
        expect(request.headers['Content-Type'], equals('application/json'));
        expect(
          request.headers['Authorization'],
          equals('Bearer $accessToken'),
        );
        expect(request.headers['apikey'], equals(anonKey));

        return http.Response(
          jsonEncode({
            'ok': true,
            'progreso': {
              'nivel': 3,
              'xp_total': 250,
              'quests_completadas': 4,
              'victorias': 5,
              'derrotas': 1,
              'partidas_jugadas': 6,
            },
          }),
          200,
        );
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      final progreso = await repo.obtenerProgreso('user-uuid-1');

      expect(progreso, isNotNull);
      expect(progreso!.idUsuario, equals('user-uuid-1'));
      expect(progreso.nivel, equals(3));
      expect(progreso.xpTotal, equals(250));
      expect(progreso.questsCompletadas, equals(4));
      expect(progreso.victorias, equals(5));
      expect(progreso.derrotas, equals(1));
      expect(progreso.partidasJugadas, equals(6));
    });

    test('obtenerProgreso con 404 devuelve null', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'PROGRESO_NO_ENCONTRADO',
          }),
          404,
        );
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      final progreso = await repo.obtenerProgreso('user-inexistente');
      expect(progreso, isNull);
    });

    test('obtenerProgreso sin token lanza ApiException 401', () async {
      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: FakeTokenRepository(token: null),
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(
        () => repo.obtenerProgreso('user-uuid-1'),
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

    test('obtenerProgreso con 500 lanza ApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'ERROR_INTERNO',
          }),
          500,
        );
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.obtenerProgreso('user-uuid-1'),
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

    test('obtenerProgreso con error de red lanza ApiException', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Error de red');
      });

      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
        httpClient: mockClient,
      );

      expect(
        () => repo.obtenerProgreso('user-uuid-1'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains('No se pudo conectar al servidor, revisa tu conexión.'),
          ),
        ),
      );
    });

    test('actualizarProgreso lanza UnimplementedError', () {
      final repo = HttpPartidaRepository(
        baseUrl: baseUrl,
        anonKey: anonKey,
        tokenRepository: fakeTokenRepo,
      );

      expect(
        () => repo.actualizarProgreso(ProgresoUsuario(idUsuario: 'user-1')),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
