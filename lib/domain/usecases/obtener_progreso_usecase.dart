import '../entities/personaje_partida.dart';
import '../repositories/partida_repository.dart';

class ObtenerProgresoUseCase {
  final PartidaRepository _repo;
  ObtenerProgresoUseCase(this._repo);

  Future<ProgresoUsuario> ejecutar(String idUsuario) async {
    return await _repo.obtenerProgreso(idUsuario) ?? ProgresoUsuario(idUsuario: idUsuario);
  }
}
