import '../entities/encuentro.dart';
import '../repositories/quest_generator_repository.dart';

class GenerarEncuentrosExtraUseCase {
  final QuestGeneratorRepository _repository;

  GenerarEncuentrosExtraUseCase(this._repository);

  Future<List<Encuentro>> ejecutar({
    required String idQuest,
    required String tema,
    required String categoria,
    required String dificultad,
    required int ultimoNumero,
  }) {
    return _repository.generarEncuentrosExtra(
      idQuest: idQuest,
      tema: tema,
      categoria: categoria,
      dificultad: dificultad,
      ultimoNumero: ultimoNumero,
    );
  }
}
