import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/infrastructure/persistence/secure_token_repository.dart';

class ThrowingSecureStorage extends FlutterSecureStorage {
  const ThrowingSecureStorage();

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    throw Exception('Fallo simulado al escribir');
  }
}

void main() {
  late FlutterSecureStorage storage;
  late SecureTokenRepository repository;

  setUp(() {
    // flutter_secure_storage provee este método para inicializar valores
    // en memoria para tests unitarios sin usar el MethodChannel.
    FlutterSecureStorage.setMockInitialValues({});
    
    storage = const FlutterSecureStorage();
    repository = SecureTokenRepository(storage);
  });

  group('SecureTokenRepository', () {
    test('guardarTokens() seguido de obtenerAccessToken() devuelve lo guardado', () async {
      await repository.guardarTokens(
        accessToken: 'mi_access_token',
        refreshToken: 'mi_refresh_token',
        expiresIn: 3600,
      );

      final access = await repository.obtenerAccessToken();
      final refresh = await repository.obtenerRefreshToken();

      expect(access, equals('mi_access_token'));
      expect(refresh, equals('mi_refresh_token'));
    });

    test('tokenExpirado() devuelve true si la fecha guardada ya pasó', () async {
      // Guardamos con expiración negativa (hace 10 segundos)
      await repository.guardarTokens(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresIn: -10,
      );

      final expirado = await repository.tokenExpirado();
      expect(expirado, isTrue);
    });

    test('tokenExpirado() devuelve false si la fecha guardada es futura', () async {
      // Guardamos con expiración lejana en el futuro (1 hora)
      await repository.guardarTokens(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresIn: 3600,
      );

      final expirado = await repository.tokenExpirado();
      expect(expirado, isFalse);
    });

    test('limpiarTokens() deja obtenerAccessToken() en null', () async {
      await repository.guardarTokens(
        accessToken: 'token_a_borrar',
        refreshToken: 'refresh_a_borrar',
        expiresIn: 3600,
      );

      await repository.limpiarTokens();

      final access = await repository.obtenerAccessToken();
      final refresh = await repository.obtenerRefreshToken();

      expect(access, isNull);
      expect(refresh, isNull);
    });

    test('tokenExpirado() devuelve true si no hay fecha guardada (null)', () async {
      // No guardamos nada, el repositorio debe tratarlo como expirado
      final expirado = await repository.tokenExpirado();
      expect(expirado, isTrue);
    });

    test('guardarTokens() propaga excepción si el storage falla', () async {
      final repoConFallo = SecureTokenRepository(const ThrowingSecureStorage());

      expect(
        () => repoConFallo.guardarTokens(
          accessToken: 'token',
          refreshToken: 'refresh',
          expiresIn: 3600,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
