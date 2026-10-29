import '../entities/personaje_partida.dart';
import '../repositories/partida_repository.dart';

/// Regla de negocio: qué pasa con el progreso del usuario al terminar un combate.
/// No sabe nada de SQLite ni de la pantalla.
class FinalizarPartidaUseCase {
  final PartidaRepository _repo;
  final bool _guardarLocalmente;

  FinalizarPartidaUseCase(
    this._repo, {
    bool guardarLocalmente = true,
  }) : _guardarLocalmente = guardarLocalmente;

  static const int xpPorVictoria = 50;
  static const int xpPorDerrota = 10;
  static const int xpParaSubirNivel = 100;

  Future<void> ejecutar({
    required Partida partida,
    required bool gano,
  }) async {
    partida.estado = gano ? 'ganada' : 'perdida';
    if (partida.score <= 0 && partida.xpObtenida <= 0) {
      if (partida.enemigosDerrotados == 0 &&
          partida.rachaMaxima == 0 &&
          partida.rondasTemerarias == 0) {
        partida.score = gano ? 150 : 0;
        partida.xpObtenida = gano ? xpPorVictoria : xpPorDerrota;
      } else {
        final puntosEnemigos = partida.enemigosDerrotados * 100;
        final bonusRacha = partida.rachaMaxima >= 7
            ? 150
            : (partida.rachaMaxima >= 5 ? 50 : 0);
        final bonusVictoria = gano ? 150 : 0;
        final bonusTemerario = partida.rondasTemerarias * 200;
        partida.score =
            puntosEnemigos + bonusRacha + bonusVictoria + bonusTemerario;
        partida.xpObtenida = partida.score > 0
            ? (partida.score ~/ 10).clamp(5, 1000)
            : (gano ? xpPorVictoria : 0);
      }
    }

    // SIEMPRE llamar al repo. En modo local guarda en SQLite. En modo
    // remoto llama al Edge Function finalizar-partida (que además
    // actualiza progreso_usuario en Postgres).
    await _repo.guardarPartida(partida);

    if (!_guardarLocalmente) {
      // Modo remoto: el backend ya actualizó el progreso.
      return;
    }

    // Modo local: actualizar progreso manualmente en SQLite.
    final progreso = await _repo.obtenerProgreso(partida.idUsuario) ??
        ProgresoUsuario(idUsuario: partida.idUsuario);

    progreso.xpTotal += partida.xpObtenida;
    if (gano) {
      progreso.victorias += 1;
      progreso.questsCompletadas += 1;
    } else {
      progreso.derrotas += 1;
    }
    progreso.partidasJugadas = progreso.victorias + progreso.derrotas;
    progreso.nivel = 1 + (progreso.xpTotal ~/ xpParaSubirNivel);

    await _repo.actualizarProgreso(progreso);
  }
}
