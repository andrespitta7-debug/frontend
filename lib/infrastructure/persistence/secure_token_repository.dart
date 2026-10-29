import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/token_repository.dart';

/// Implementación de [TokenRepository] usando `flutter_secure_storage`
/// para almacenar los tokens de manera segura y cifrada en el dispositivo.
class SecureTokenRepository implements TokenRepository {
  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyExpiresAt = 'expires_at';

  SecureTokenRepository(this._storage);

  @override
  Future<void> guardarTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyExpiresAt, value: expiresAt.toIso8601String());
  }

  @override
  Future<String?> obtenerAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> obtenerRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> tokenExpirado() async {
    try {
      final dateStr = await _storage.read(key: _keyExpiresAt);
      if (dateStr == null) {
        return true; // Si no hay fecha, asumimos que está expirado/no existe
      }

      final expiresAt = DateTime.parse(dateStr);
      // Margen de 30 segundos: si expira en menos de 30s, lo consideramos expirado.
      final momentoLimite = DateTime.now().add(const Duration(seconds: 30));

      return expiresAt.isBefore(momentoLimite);
    } catch (e) {
      // Si falla el parseo o la lectura, mejor prevenir y forzar reautenticación
      return true;
    }
  }

  @override
  Future<void> limpiarTokens() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyExpiresAt);
    } catch (e) {
      // Ignorar errores en limpieza
    }
  }
}
