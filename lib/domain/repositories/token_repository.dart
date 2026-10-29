/// Puerto (interfaz) para el manejo persistente de tokens de autenticación
/// (como JWT y refresh tokens) devueltos por Supabase.
abstract class TokenRepository {
  /// Almacena de forma segura los tokens de acceso y refresco, junto con
  /// su tiempo de expiración (en segundos a partir de este momento).
  Future<void> guardarTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  });

  /// Recupera el token de acceso actual, si existe.
  Future<String?> obtenerAccessToken();

  /// Recupera el token de refresco actual, si existe.
  Future<String?> obtenerRefreshToken();

  /// Verifica si el token de acceso ha expirado, considerando
  /// un margen de seguridad (ej. 30 segundos).
  Future<bool> tokenExpirado();

  /// Borra todos los tokens almacenados (útil al cerrar sesión).
  Future<void> limpiarTokens();
}
