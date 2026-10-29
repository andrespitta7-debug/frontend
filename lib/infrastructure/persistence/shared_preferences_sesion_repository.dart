import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/sesion_repository.dart';

class SharedPreferencesSesionRepository implements SesionRepository {
  static const _idUsuarioActivoKey = 'id_usuario_activo';

  final SharedPreferences _preferences;

  SharedPreferencesSesionRepository(this._preferences);

  @override
  Future<void> guardarSesion(String idUsuario) async {
    await _preferences.setString(_idUsuarioActivoKey, idUsuario);
  }

  @override
  Future<String?> obtenerIdUsuarioActivo() async {
    return _preferences.getString(_idUsuarioActivoKey);
  }

  @override
  Future<void> cerrarSesion() async {
    await _preferences.remove(_idUsuarioActivoKey);
  }
}
