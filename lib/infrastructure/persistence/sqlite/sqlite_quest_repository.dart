import '../../../domain/entities/encuentro.dart';
import '../../../domain/entities/opcion_encuentro.dart';
import '../../../domain/entities/quest.dart';
import '../../../domain/entities/quest_completa.dart';
import '../../../domain/repositories/quest_repository.dart';
import 'database_helper.dart';

/// Este es el ADAPTADOR: implementa el puerto QuestRepository usando SQLite.
/// Si un día lo cambian por Supabase, crean SupabaseQuestRepository
/// que implemente lo mismo, y en main.dart cambian una sola línea.
class SqliteQuestRepository implements QuestRepository {
  final DatabaseHelper _dbHelper;
  SqliteQuestRepository(this._dbHelper);

  @override
  Future<Quest?> obtenerQuestPorId(String idQuest) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'quest',
      where: 'id_quest = ?',
      whereArgs: [idQuest],
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Quest(
      idQuest: r['id_quest'] as String,
      titulo: r['titulo'] as String,
      tema: r['tema'] as String? ?? '',
      categoria: r['categoria'] as String? ?? '',
      dificultad: r['dificultad'] as String? ?? 'facil',
      descripcion: r['descripcion'] as String? ?? '',
      fuenteGeneracion: r['fuente_generacion'] as String? ?? 'manual',
    );
  }

  @override
  Future<List<Encuentro>> obtenerEncuentros(String idQuest) async {
    final db = await _dbHelper.database;
    final filas = await db.query(
      'encuentro',
      where: 'id_quest = ?',
      whereArgs: [idQuest],
      orderBy: 'numero ASC',
    );

    final List<Encuentro> encuentros = [];
    for (final fila in filas) {
      final idEncuentro = fila['id_encuentro'] as String;
      final filasOpciones = await db.query(
        'opcion_encuentro',
        where: 'id_encuentro = ?',
        whereArgs: [idEncuentro],
        orderBy: 'letra ASC',
      );

      final opciones = filasOpciones
          .map(
            (o) => OpcionEncuentro(
              idOpcion: o['id_opcion'] as String,
              idEncuentro: o['id_encuentro'] as String,
              letra: o['letra'] as String,
              texto: o['texto'] as String,
              calidad: o['calidad'] as int,
            ),
          )
          .toList();

      encuentros.add(
        Encuentro(
          idEncuentro: idEncuentro,
          idQuest: fila['id_quest'] as String,
          numero: fila['numero'] as int,
          pregunta: fila['pregunta'] as String,
          dificultad: fila['dificultad'] as String? ?? 'facil',
          tipoEncuentro: fila['tipo_encuentro'] as String? ?? 'normal',
          vidaEnemigo: fila['vida_enemigo'] as int? ?? 50,
          opciones: opciones,
        ),
      );
    }
    return encuentros;
  }

  @override
  Future<void> guardarQuest(Quest quest) async {
    final db = await _dbHelper.database;
    await db.insert('quest', {
      'id_quest': quest.idQuest,
      'titulo': quest.titulo,
      'tema': quest.tema,
      'categoria': quest.categoria,
      'dificultad': quest.dificultad,
      'descripcion': quest.descripcion,
      'fuente_generacion': quest.fuenteGeneracion,
    });
  }

  @override
  Future<void> guardarQuestCompleta(QuestCompleta questCompleta) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('quest', {
        'id_quest': questCompleta.quest.idQuest,
        'titulo': questCompleta.quest.titulo,
        'tema': questCompleta.quest.tema,
        'categoria': questCompleta.quest.categoria,
        'dificultad': questCompleta.quest.dificultad,
        'descripcion': questCompleta.quest.descripcion,
        'fuente_generacion': questCompleta.quest.fuenteGeneracion,
      });

      for (final encuentro in questCompleta.encuentros) {
        await txn.insert('encuentro', {
          'id_encuentro': encuentro.idEncuentro,
          'id_quest': encuentro.idQuest,
          'numero': encuentro.numero,
          'pregunta': encuentro.pregunta,
          'dificultad': encuentro.dificultad,
          'tipo_encuentro': encuentro.tipoEncuentro,
          'vida_enemigo': encuentro.vidaEnemigo,
        });

        for (final opcion in encuentro.opciones) {
          await txn.insert('opcion_encuentro', {
            'id_opcion': opcion.idOpcion,
            'id_encuentro': opcion.idEncuentro,
            'letra': opcion.letra,
            'texto': opcion.texto,
            'calidad': opcion.calidad,
          });
        }
      }
    });
  }
}
