import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sysquest_app/domain/entities/usuario.dart';
import 'package:sysquest_app/domain/repositories/auth_repository.dart';
import 'package:sysquest_app/domain/repositories/token_repository.dart';
import 'package:sysquest_app/infrastructure/api/api_exception.dart';
import 'package:sysquest_app/infrastructure/api/auth_api_client.dart';
import 'package:sysquest_app/infrastructure/api/http_auth_repository.dart';

class FakeTokenRepository implements TokenRepository {
  bool guardarTokensLlamado = false;
  bool limpiarTokensLlamado = false;
  String? accessTokenGuardado;
  String? refreshTokenGuardado;
  int? expiresInGuardado;
  final bool lanzarError;

  FakeTokenRepository({
    this.lanzarError = false,
    this.accessTokenGuardado,
  });

  @override
  Future<void> guardarTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    if (lanzarError) throw Exception('Error simulado guardando tokens');
    guardarTokensLlamado = true;
    accessTokenGuardado = accessToken;
    refreshTokenGuardado = refreshToken;
    expiresInGuardado = expiresIn;
  }

  @override
  Future<String?> obtenerAccessToken() async => accessTokenGuardado;

  @override
  Future<String?> obtenerRefreshToken() async => refreshTokenGuardado;

  @override
  Future<bool> tokenExpirado() async => false;

  @override
  Future<void> limpiarTokens() async {
    limpiarTokensLlamado = true;
    accessTokenGuardado = null;
  }
}

void main() {
  const baseUrl = 'https://jctulgfdweeurqbmugot.supabase.co';
  const anonKey = 'test-anon-key';

  final sampleResponseJson = jsonEncode({
    'ok': true,
    'access_token': 'jwt_token_123',
    'refresh_token': 'jwt_refresh_456',
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

  group('HttpAuthRepository', () {
    test('cumple con el contrato del puerto AuthRepository', () {
      final client = AuthApiClient(
        baseUrl: baseUrl,
        anonKey: anonKey,
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );
      final repo = HttpAuthRepository(client, FakeTokenRepository());

      expect(repo, isA<AuthRepository>());
    });

    group('registrar', () {
      test('devuelve Usuario y guarda tokens cuando el registro es exitoso', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.url.path, contains('/register'));
          return http.Response(sampleResponseJson, 201);
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final tokenRepo = FakeTokenRepository();
        final repo = HttpAuthRepository(client, tokenRepo);

        final usuario = await repo.registrar(
          email: 'estudiante@udec.edu.co',
          nombreUsuario: 'estudiante_dev',
          nombre: 'Estudiante',
          apellido: 'Udec',
          passwordPlano: 'Password123',
        );

        expect(usuario.idUsuario, equals('uuid-123'));
        expect(usuario.email, equals('estudiante@udec.edu.co'));
        expect(usuario.nombreUsuario, equals('estudiante_dev'));
        expect(usuario.nombre, equals('Estudiante'));
        expect(usuario.apellido, equals('Udec'));

        expect(tokenRepo.guardarTokensLlamado, isTrue);
        expect(tokenRepo.accessTokenGuardado, equals('jwt_token_123'));
        expect(tokenRepo.refreshTokenGuardado, equals('jwt_refresh_456'));
        expect(tokenRepo.expiresInGuardado, equals(3600));
      });

      test('propaga Exception si el guardado de tokens falla tras un registro HTTP exitoso', () async {
        final mockClient = MockClient((request) async {
          return http.Response(sampleResponseJson, 201);
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final tokenRepo = FakeTokenRepository(lanzarError: true);
        final repo = HttpAuthRepository(client, tokenRepo);

        expect(
          () => repo.registrar(
            email: 'estudiante@udec.edu.co',
            nombreUsuario: 'estudiante_dev',
            nombre: 'Estudiante',
            apellido: 'Udec',
            passwordPlano: 'Password123',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('propaga ApiException cuando el registro falla', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'ok': false, 'error': 'El correo ya está registrado.'}),
            409,
          );
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final repo = HttpAuthRepository(client, FakeTokenRepository());

        expect(
          () => repo.registrar(
            email: 'duplicado@udec.edu.co',
            nombreUsuario: 'estudiante_dev',
            nombre: 'Estudiante',
            apellido: 'Udec',
            passwordPlano: 'Password123',
          ),
          throwsA(
            isA<ApiException>()
                .having((e) => e.mensaje, 'mensaje', 'El correo ya está registrado.')
                .having((e) => e.statusCode, 'statusCode', 409),
          ),
        );
      });
    });

    group('autenticar', () {
      test('devuelve Usuario y guarda tokens cuando las credenciales son correctas', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.url.path, contains('/login'));
          return http.Response(sampleResponseJson, 200);
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final tokenRepo = FakeTokenRepository();
        final repo = HttpAuthRepository(client, tokenRepo);

        final usuario = await repo.autenticar(
          'estudiante@udec.edu.co',
          'Password123',
        );

        expect(usuario, isNotNull);
        expect(usuario!.idUsuario, equals('uuid-123'));
        expect(usuario.email, equals('estudiante@udec.edu.co'));

        expect(tokenRepo.guardarTokensLlamado, isTrue);
        expect(tokenRepo.accessTokenGuardado, equals('jwt_token_123'));
        expect(tokenRepo.refreshTokenGuardado, equals('jwt_refresh_456'));
        expect(tokenRepo.expiresInGuardado, equals(3600));
      });

      test('propaga Exception si el guardado de tokens falla tras un login HTTP exitoso', () async {
        final mockClient = MockClient((request) async {
          return http.Response(sampleResponseJson, 200);
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final tokenRepo = FakeTokenRepository(lanzarError: true);
        final repo = HttpAuthRepository(client, tokenRepo);

        expect(
          () => repo.autenticar('estudiante@udec.edu.co', 'Password123'),
          throwsA(isA<Exception>()),
        );
      });

      test('devuelve null cuando las credenciales son incorrectas (401)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'ok': false, 'error': 'Correo o contraseña incorrectos.'}),
            401,
          );
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final repo = HttpAuthRepository(client, FakeTokenRepository());

        final usuario = await repo.autenticar(
          'estudiante@udec.edu.co',
          'WrongPassword123',
        );

        expect(usuario, isNull);
      });

      test('propaga ApiException ante otros errores (ej. error 500)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'ok': false, 'error': 'Error interno'}),
            500,
          );
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final repo = HttpAuthRepository(client, FakeTokenRepository());

        expect(
          () => repo.autenticar('estudiante@udec.edu.co', 'Password123'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 500),
          ),
        );
      });
    });

    group('obtenerPorId', () {
      test('caso de éxito: llama a la API y devuelve el usuario', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.url.path, contains('/obtener-usuario-actual'));
          expect(
            request.headers['Authorization'],
            equals('Bearer valid_jwt_token'),
          );
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
        final tokenRepo = FakeTokenRepository(
          accessTokenGuardado: 'valid_jwt_token',
        );
        final repo = HttpAuthRepository(client, tokenRepo);

        final usuario = await repo.obtenerPorId('uuid-123');

        expect(usuario, isNotNull);
        expect(usuario!.idUsuario, equals('uuid-123'));
        expect(usuario.email, equals('estudiante@udec.edu.co'));
        expect(usuario.nombreUsuario, equals('estudiante_dev'));
        expect(usuario.nombre, equals('Estudiante'));
        expect(usuario.apellido, equals('Udec'));
      });

      test('caso sin token: devuelve null sin llamar a la API', () async {
        var apiLlamada = false;
        final mockClient = MockClient((request) async {
          apiLlamada = true;
          return http.Response('{}', 200);
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final tokenRepo = FakeTokenRepository(accessTokenGuardado: null);
        final repo = HttpAuthRepository(client, tokenRepo);

        final usuario = await repo.obtenerPorId('uuid-123');

        expect(usuario, isNull);
        expect(apiLlamada, isFalse);
      });

      test('caso API devuelve 401: devuelve null y limpia los tokens', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'ok': false, 'codigo': 'NO_AUTORIZADO'}),
            401,
          );
        });

        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: mockClient,
        );
        final tokenRepo = FakeTokenRepository(
          accessTokenGuardado: 'expired_jwt_token',
        );
        final repo = HttpAuthRepository(client, tokenRepo);

        final usuario = await repo.obtenerPorId('uuid-123');

        expect(usuario, isNull);
        expect(tokenRepo.limpiarTokensLlamado, isTrue);
      });
    });

    group('métodos aún no implementados en backend lanzan UnimplementedError', () {
      late HttpAuthRepository repo;

      setUp(() {
        final client = AuthApiClient(
          baseUrl: baseUrl,
          anonKey: anonKey,
          httpClient: MockClient((_) async => http.Response('{}', 200)),
        );
        repo = HttpAuthRepository(client, FakeTokenRepository());
      });

      test('existeEmail lanza UnimplementedError', () {
        expect(() => repo.existeEmail('test@udec.edu.co'), throwsUnimplementedError);
      });

      test('existeNombreUsuario lanza UnimplementedError', () {
        expect(() => repo.existeNombreUsuario('user'), throwsUnimplementedError);
      });

      test('existeNombreUsuarioExcepto lanza UnimplementedError', () {
        expect(
          () => repo.existeNombreUsuarioExcepto('user', 'uuid-123'),
          throwsUnimplementedError,
        );
      });

      test('actualizar lanza UnimplementedError', () {
        final usuario = Usuario(
          idUsuario: 'uuid-123',
          email: 'test@udec.edu.co',
          nombreUsuario: 'user',
          nombre: 'Test',
          apellido: 'User',
        );
        expect(() => repo.actualizar(usuario), throwsUnimplementedError);
      });

      test('cambiarPassword lanza UnimplementedError', () {
        expect(
          () => repo.cambiarPassword('uuid-123', 'newHash'),
          throwsUnimplementedError,
        );
      });

      test('eliminarCuenta lanza UnimplementedError', () {
        expect(() => repo.eliminarCuenta('uuid-123'), throwsUnimplementedError);
      });
    });
  });
}
