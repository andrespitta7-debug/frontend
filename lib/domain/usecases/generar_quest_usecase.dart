import '../entities/encuentro.dart';
import '../entities/opcion_encuentro.dart';
import '../entities/quest_completa.dart';
import '../repositories/quest_generator_repository.dart';
import '../repositories/quest_repository.dart';

class QuestInvalidaException implements Exception {
  final String mensaje;

  QuestInvalidaException(this.mensaje);

  @override
  String toString() => 'QuestInvalidaException: $mensaje';
}

class GenerarQuestUseCase {
  static const _categoriasValidas = {
    'debug',
    'database',
    'algorithm',
    'network',
    'architecture',
    'cyber',
    'libre',
  };
  static const _dificultadesValidas = {'facil', 'medio', 'dificil'};

  final QuestGeneratorRepository _generador;
  final QuestRepository _repo;
  final bool _guardarLocalmente;

  GenerarQuestUseCase(
    this._generador,
    this._repo, {
    bool guardarLocalmente = true,
  }) : _guardarLocalmente = guardarLocalmente;

  Future<QuestCompleta> ejecutar(String tema) async {
    final temaNormalizado = tema.trim();
    if (temaNormalizado.length < 3 || temaNormalizado.length > 100) {
      throw QuestInvalidaException(
        'El tema debe tener entre 3 y 100 caracteres sin espacios sobrantes.',
      );
    }

    final questCompleta = await _generador.generarQuest(temaNormalizado);
    _validarQuest(questCompleta);

    if (_guardarLocalmente) {
      await _repo.guardarQuestCompleta(questCompleta);
    }

    return questCompleta;
  }

  void _validarQuest(QuestCompleta questCompleta) {
    final quest = questCompleta.quest;
    if (quest.titulo.trim().isEmpty) {
      throw QuestInvalidaException(
        'El título de la quest no puede estar vacío.',
      );
    }
    final fuente = quest.fuenteGeneracion.trim().toLowerCase();
    if (fuente != 'ia' && fuente != 'fallback') {
      throw QuestInvalidaException('La fuente de generación debe ser ia.');
    }
    if (!_categoriasValidas.contains(quest.categoria)) {
      throw QuestInvalidaException(
        'La categoría de la quest no es válida: ${quest.categoria}.',
      );
    }
    if (!_dificultadesValidas.contains(quest.dificultad)) {
      throw QuestInvalidaException(
        'La dificultad de la quest no es válida: ${quest.dificultad}.',
      );
    }

    final encuentros = questCompleta.encuentros;
    if (encuentros.length != 3) {
      throw QuestInvalidaException(
        'La quest debe tener exactamente 3 encuentros.',
      );
    }

    final idsEncuentros = <String>{};
    final idsOpciones = <String>{};
    for (var indice = 0; indice < encuentros.length; indice++) {
      _validarEncuentro(
        encuentros[indice],
        indice,
        quest.idQuest,
        idsEncuentros,
        idsOpciones,
      );
    }
  }

  void _validarEncuentro(
    Encuentro encuentro,
    int indice,
    String idQuest,
    Set<String> idsEncuentros,
    Set<String> idsOpciones,
  ) {
    if (encuentro.idQuest != idQuest) {
      throw QuestInvalidaException(
        'Cada encuentro debe pertenecer a la quest generada.',
      );
    }
    if (!idsEncuentros.add(encuentro.idEncuentro)) {
      throw QuestInvalidaException('Los idEncuentro no se pueden repetir.');
    }

    final numeroEsperado = indice + 1;
    if (encuentro.numero != numeroEsperado) {
      throw QuestInvalidaException(
        'Los encuentros deben estar numerados 1, 2 y 3 en orden.',
      );
    }

    final esUltimo = indice == 2;
    if (esUltimo && encuentro.tipoEncuentro != 'jefe') {
      throw QuestInvalidaException('El último encuentro debe ser jefe.');
    }
    if (!esUltimo && encuentro.tipoEncuentro == 'jefe') {
      throw QuestInvalidaException('Solo el último encuentro puede ser jefe.');
    }
    if (encuentro.pregunta.trim().isEmpty) {
      throw QuestInvalidaException(
        'La pregunta de un encuentro no puede estar vacía.',
      );
    }
    if (!_dificultadesValidas.contains(encuentro.dificultad)) {
      throw QuestInvalidaException(
        'La dificultad del encuentro no es válida: ${encuentro.dificultad}.',
      );
    }
    if (encuentro.vidaEnemigo <= 0) {
      throw QuestInvalidaException(
        'La vida del enemigo debe ser mayor que cero.',
      );
    }
    if (encuentro.opciones.length != 4) {
      throw QuestInvalidaException(
        'Cada encuentro debe tener exactamente 4 opciones.',
      );
    }

    _validarOpciones(encuentro.opciones, encuentro.idEncuentro, idsOpciones);
  }

  void _validarOpciones(
    List<OpcionEncuentro> opciones,
    String idEncuentro,
    Set<String> idsOpciones,
  ) {
    const letrasEsperadas = {'A', 'B', 'C', 'D'};
    final letras = <String>{};
    var cantidadCriticas = 0;
    var cantidadIncorrectas = 0;

    for (final opcion in opciones) {
      if (opcion.idEncuentro != idEncuentro) {
        throw QuestInvalidaException(
          'Cada opción debe pertenecer a su encuentro.',
        );
      }
      if (!idsOpciones.add(opcion.idOpcion)) {
        throw QuestInvalidaException('Los idOpcion no se pueden repetir.');
      }
      if (!letrasEsperadas.contains(opcion.letra) ||
          !letras.add(opcion.letra)) {
        throw QuestInvalidaException(
          'Las opciones deben tener las letras A, B, C y D sin repetir.',
        );
      }
      if (opcion.texto.trim().isEmpty) {
        throw QuestInvalidaException(
          'El texto de una opción no puede estar vacío.',
        );
      }
      if (opcion.calidad < 0 || opcion.calidad > 2) {
        throw QuestInvalidaException('La calidad debe ser 0, 1 o 2.');
      }
      if (opcion.calidad == 2) cantidadCriticas++;
      if (opcion.calidad == 0) cantidadIncorrectas++;
    }

    if (letras.length != letrasEsperadas.length) {
      throw QuestInvalidaException(
        'Las opciones deben contener exactamente las letras A, B, C y D.',
      );
    }
    if (cantidadCriticas != 1) {
      throw QuestInvalidaException(
        'Cada encuentro debe tener exactamente una opción con calidad 2.',
      );
    }
    if (cantidadIncorrectas == 0) {
      throw QuestInvalidaException(
        'Cada encuentro debe tener al menos una opción con calidad 0.',
      );
    }
  }
}
