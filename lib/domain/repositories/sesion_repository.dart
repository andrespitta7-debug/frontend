/// Puerto para conservar la sesión activa del usuario.
/// Solo se persiste el id del usuario; nunca una contraseña.
abstract class SesionRepository {
  Future<void> guardarSesion(String idUsuario);

  Future<String?> obtenerIdUsuarioActivo();

  Future<void> cerrarSesion();
}
