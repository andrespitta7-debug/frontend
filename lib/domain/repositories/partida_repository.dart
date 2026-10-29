import '../entities/personaje_partida.dart';

abstract class PartidaRepository {
  Future<void> guardarPartida(Partida partida);
  Future<ProgresoUsuario?> obtenerProgreso(String idUsuario);
  Future<void> actualizarProgreso(ProgresoUsuario progreso);
}
