import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/token_repository.dart';
import 'api_exception.dart';
import 'auth_api_client.dart';

/// Implementación del puerto [AuthRepository] que se comunica con
/// el backend de Supabase mediante [AuthApiClient].
class HttpAuthRepository implements AuthRepository {
  final AuthApiClient _client;
  final TokenRepository _tokenRepo;

  HttpAuthRepository(this._client, this._tokenRepo);

  static const _mensajeNoImplementado =
      'Este método aún no está implementado en el backend. '
      'Se completará cuando exista el Edge Function correspondiente.';

  @override
  Future<Usuario> registrar({
    required String email,
    required String nombreUsuario,
    required String nombre,
    required String apellido,
    required String passwordPlano,
  }) async {
    final result = await _client.registrar(
      email: email,
      password: passwordPlano,
      nombre: nombre,
      apellido: apellido,
      nombreUsuario: nombreUsuario,
    );

    await _tokenRepo.guardarTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      expiresIn: result.expiresIn,
    );

    return result.usuario;
  }

  @override
  Future<Usuario?> autenticar(String email, String passwordPlano) async {
    try {
      final result = await _client.login(
        email: email,
        password: passwordPlano,
      );

      await _tokenRepo.guardarTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiresIn: result.expiresIn,
      );

      return result.usuario;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<Usuario?> obtenerPorId(String idUsuario) async {
    if (await _tokenRepo.tokenExpirado()) {
      await _tokenRepo.limpiarTokens();
      return null;
    }

    final accessToken = await _tokenRepo.obtenerAccessToken();
    if (accessToken == null) {
      return null;
    }

    try {
      return await _client.obtenerUsuarioActual(accessToken);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _tokenRepo.limpiarTokens();
        return null;
      }
      rethrow;
    } catch (_) {
      // Fallo de conectividad con Supabase no debe romper la carga inicial
      return null;
    }
  }

  @override
  Future<bool> existeEmail(String email) async {
    throw UnimplementedError(_mensajeNoImplementado);
  }

  @override
  Future<bool> existeNombreUsuario(String nombreUsuario) async {
    throw UnimplementedError(_mensajeNoImplementado);
  }

  @override
  Future<bool> existeNombreUsuarioExcepto(
    String nombreUsuario,
    String idUsuario,
  ) async {
    throw UnimplementedError(_mensajeNoImplementado);
  }

  @override
  Future<void> actualizar(Usuario usuario) async {
    throw UnimplementedError(_mensajeNoImplementado);
  }

  @override
  Future<void> cambiarPassword(String idUsuario, String nuevoPasswordPlano) async {
    throw UnimplementedError(_mensajeNoImplementado);
  }

  @override
  Future<void> eliminarCuenta(String idUsuario) async {
    throw UnimplementedError(_mensajeNoImplementado);
  }
}
