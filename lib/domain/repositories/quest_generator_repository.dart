import '../entities/encuentro.dart';
import '../entities/quest_completa.dart';

/// Puerto para generar una quest completa a partir de un tema.
abstract class QuestGeneratorRepository {
  Future<QuestCompleta> generarQuest(String tema);

  Future<List<Encuentro>> generarEncuentrosExtra({
    required String idQuest,
    required String tema,
    required String categoria,
    required String dificultad,
    required int ultimoNumero,
  });
}
