import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sysquest_app/infrastructure/api/api_exception.dart';
import 'package:sysquest_app/infrastructure/api/auth_api_client.dart';

void main() {
  const baseUrl = 'https://jctulgfdweeurqbmugot.supabase.co';
  const anonKey = 'test-anon-key';

  final sampleResponseJson = jsonEncode({
    'ok': true,
    'access_token': 'jwt_access_token_123',
    'refresh_token': 'jwt_refresh_token_456',
    'expires_in': 3600,
    'usuario': {
      'id': 'uuid-123',
      'email': 'estudiante@udec.edu.co',
      'nombre_usuario': 'estudiante_dev',
      'nombre': 'Estudiante',
      'apellido': 'Udec',
    },
    'progreso': {
      'nivel': 1,
      'xp_total': 0,
      'quests_completadas': 0,
      'victorias': 0,
      'derrotas': 0,
      'partidas_jugadas': 0,
    },
  });

  group('AuthApiClient - registrar', () {
    test('registrar exitoso (mock devuelve 201 con JWT)', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('$baseUrl/functions/v1/register'),
        );
        expect(request.headers['Content-Type'], equals('application/json'));
        expect(
          request.headers['Authorization'],
          equals('Bearer $anonKey'),
        );

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], equals('estudiante@udec.edu.co'));
        expect(body['password'], equals('Password123'));
        expect(body['nombre'], equals('Estudiante'));
        expect(body['apellido'], equals('Udec'));
        expect(body['nombre_usuario'], equals('estudiante_dev'));

        return http.Response(sampleResponseJson, 201);
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      final result = await client.registrar(
        email: 'estudiante@udec.edu.co',
        password: 'Password123',
        nombre: 'Estudiante',
        apellido: 'Udec',
        nombreUsuario: 'estudiante_dev',
      );

      expect(result.accessToken, equals('jwt_access_token_123'));
      expect(result.refreshToken, equals('jwt_refresh_token_456'));
      expect(result.expiresIn, equals(3600));
      expect(result.usuario.idUsuario, equals('uuid-123'));
      expect(result.usuario.email, equals('estudiante@udec.edu.co'));
      expect(result.usuario.nombreUsuario, equals('estudiante_dev'));
      expect(result.usuario.nombre, equals('Estudiante'));
      expect(result.usuario.apellido, equals('Udec'));
      expect(result.progreso.nivel, equals(1));
      expect(result.progreso.xpTotal, equals(0));
    });

    test('registrar con email duplicado (mock devuelve 409 con error)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'error': 'El correo ya está registrado.',
          }),
          409,
        );
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      expect(
        () => client.registrar(
          email: 'duplicado@udec.edu.co',
          password: 'Password123',
          nombre: 'Estudiante',
          apellido: 'Udec',
          nombreUsuario: 'estudiante_dev',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.mensaje, 'mensaje', 'El correo ya está registrado.')
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });
  });

  group('AuthApiClient - login', () {
    test('login exitoso (mock devuelve 200 con JWT)', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.toString(), equals('$baseUrl/functions/v1/login'));
        expect(request.headers['Content-Type'], equals('application/json'));
        expect(
          request.headers['Authorization'],
          equals('Bearer $anonKey'),
        );

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], equals('estudiante@udec.edu.co'));
        expect(body['password'], equals('Password123'));

        return http.Response(sampleResponseJson, 200);
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      final result = await client.login(
        email: 'estudiante@udec.edu.co',
        password: 'Password123',
      );

      expect(result.accessToken, equals('jwt_access_token_123'));
      expect(result.refreshToken, equals('jwt_refresh_token_456'));
      expect(result.expiresIn, equals(3600));
      expect(result.usuario.idUsuario, equals('uuid-123'));
      expect(result.usuario.email, equals('estudiante@udec.edu.co'));
      expect(result.usuario.nombreUsuario, equals('estudiante_dev'));
      expect(result.progreso.nivel, equals(1));
    });

    test('login con credenciales incorrectas (mock devuelve 401)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'error': 'Correo o contraseña incorrectos.',
          }),
          401,
        );
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      expect(
        () => client.login(
          email: 'wrong@udec.edu.co',
          password: 'WrongPassword123',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.mensaje, 'mensaje', 'Correo o contraseña incorrectos.')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('error de red (mock lanza excepción)', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Fallo de conexión');
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      expect(
        () => client.login(
          email: 'test@udec.edu.co',
          password: 'Password123',
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.mensaje,
            'mensaje',
            'No se pudo conectar al servidor, revisa tu conexión.',
          ),
        ),
      );
    });

    test('error del servidor >= 500 (mock devuelve 500)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'error': 'Error interno',
          }),
          500,
        );
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      expect(
        () => client.login(
          email: 'test@udec.edu.co',
          password: 'Password123',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.mensaje, 'mensaje', 'Error del servidor, intenta de nuevo.')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('AuthApiClient - obtenerUsuarioActual', () {
    test('obtenerUsuarioActual exitoso (mock devuelve 200 con usuario)', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('$baseUrl/functions/v1/obtener-usuario-actual'),
        );
        expect(request.headers['Content-Type'], equals('application/json'));
        expect(
          request.headers['Authorization'],
          equals('Bearer jwt_test_123'),
        );
        expect(request.headers['apikey'], equals(anonKey));

        return http.Response(
          jsonEncode({
            'ok': true,
            'usuario': {
              'id': 'uuid-123',
              'email': 'estudiante@udec.edu.co',
              'nombre_usuario': 'estudiante_dev',
              'nombre': 'Estudiante',
              'apellido': 'Udec',
            },
          }),
          200,
        );
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      final usuario = await client.obtenerUsuarioActual('jwt_test_123');

      expect(usuario.idUsuario, equals('uuid-123'));
      expect(usuario.email, equals('estudiante@udec.edu.co'));
      expect(usuario.nombreUsuario, equals('estudiante_dev'));
      expect(usuario.nombre, equals('Estudiante'));
      expect(usuario.apellido, equals('Udec'));
    });

    test('obtenerUsuarioActual con token inválido/expirado (mock devuelve 401)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'codigo': 'NO_AUTORIZADO',
          }),
          401,
        );
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      expect(
        () => client.obtenerUsuarioActual('jwt_invalido'),
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

    test('obtenerUsuarioActual con error del servidor >= 500', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'ok': false, 'codigo': 'ERROR_INTERNO'}),
          500,
        );
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      expect(
        () => client.obtenerUsuarioActual('jwt_test_123'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.mensaje, 'mensaje', 'Error del servidor, intenta de nuevo.')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('obtenerUsuarioActual con error de red', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Fallo de conexión');
      });

      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: mockClient,
      );

      expect(
        () => client.obtenerUsuarioActual('jwt_test_123'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.mensaje,
            'mensaje',
            'No se pudo conectar al servidor, revisa tu conexión.',
          ),
        ),
      );
    });
  });
}
