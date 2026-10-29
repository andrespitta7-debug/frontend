import '../entities/encuentro.dart';
import '../entities/quest.dart';
import '../entities/quest_completa.dart';

/// Puerto: define QUÉ se puede hacer, no CÓMO.
/// El dominio y los casos de uso solo conocen esta interfaz.
/// Hoy la implementa SQLite; mañana podría implementarla Supabase
/// sin que este archivo, ni el caso de uso, ni la pantalla cambien.
abstract class QuestRepository {
  Future<Quest?> obtenerQuestPorId(String idQuest);

  /// Devuelve los encuentros de una quest, en orden, cada uno con sus opciones.
  Future<List<Encuentro>> obtenerEncuentros(String idQuest);

  Future<void> guardarQuest(Quest quest);

  Future<void> guardarQuestCompleta(QuestCompleta quest);
}
