import 'package:uuid/uuid.dart';

import '../../../domain/entities/personaje_partida.dart';
import '../../../domain/repositories/partida_repository.dart';
import 'database_helper.dart';

class SqlitePartidaRepository implements PartidaRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();
  SqlitePartidaRepository(this._dbHelper);

  @override
  Future<void> guardarPartida(Partida partida) async {
    final db = await _dbHelper.database;
    await db.insert('partida', {
      'id_partida': partida.idPartida,
      'id_usuario': partida.idUsuario,
      'id_quest': partida.idQuest,
      'estado': partida.estado,
      'encuentro_actual': partida.encuentroActual,
      'score': partida.score,
      'xp_obtenida': partida.xpObtenida,
      'tiempo_segundos': partida.tiempoSegundos,
      'resultado': partida.estado,
      'finished_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<ProgresoUsuario?> obtenerProgreso(String idUsuario) async {
    final db = await _dbHelper.database;
    final filas = await db.query(
      'progreso_usuario',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
    );
    if (filas.isEmpty) return null;
    final r = filas.first;
    final partidasJugadas = (r['partidas_jugadas'] as int? ?? 0) > 0
        ? r['partidas_jugadas'] as int? ?? 0
        : ((r['victorias'] as int? ?? 0) + (r['derrotas'] as int? ?? 0));

    return ProgresoUsuario(
      idUsuario: idUsuario,
      nivel: r['nivel'] as int? ?? 1,
      xpTotal: r['xp_total'] as int? ?? 0,
      questsCompletadas: r['quests_completadas'] as int? ?? 0,
      victorias: r['victorias'] as int? ?? 0,
      derrotas: r['derrotas'] as int? ?? 0,
      partidasJugadas: partidasJugadas,
    );
  }

  @override
  Future<void> actualizarProgreso(ProgresoUsuario progreso) async {
    final db = await _dbHelper.database;
    final filasAfectadas = await db.update(
      'progreso_usuario',
      {
        'nivel': progreso.nivel,
        'xp_total': progreso.xpTotal,
        'quests_completadas': progreso.questsCompletadas,
        'victorias': progreso.victorias,
        'derrotas': progreso.derrotas,
        'partidas_jugadas': progreso.partidasJugadas,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id_usuario = ?',
      whereArgs: [progreso.idUsuario],
    );

    if (filasAfectadas == 0) {
      // No existía fila de progreso para este usuario (caso raro); se crea.
      await db.insert('progreso_usuario', {
        'id_progreso': _uuid.v4(),
        'id_usuario': progreso.idUsuario,
        'nivel': progreso.nivel,
        'xp_total': progreso.xpTotal,
        'quests_completadas': progreso.questsCompletadas,
        'victorias': progreso.victorias,
        'derrotas': progreso.derrotas,
        'partidas_jugadas': progreso.partidasJugadas,
      });
    }
  }
}
