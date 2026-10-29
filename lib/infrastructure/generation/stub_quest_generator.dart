import 'package:uuid/uuid.dart';

import '../../domain/entities/encuentro.dart';
import '../../domain/entities/opcion_encuentro.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_completa.dart';
import '../../domain/repositories/quest_generator_repository.dart';

class StubQuestGenerator implements QuestGeneratorRepository {
  final Uuid _uuid;

  StubQuestGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  @override
  Future<QuestCompleta> generarQuest(String tema) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final questId = _uuid.v4();
    final temaNormalizado = tema.trim();
    final quest = Quest(
      idQuest: questId,
      titulo: 'Quest de $temaNormalizado',
      tema: temaNormalizado,
      categoria: 'libre',
      dificultad: 'facil',
      descripcion: 'Practica $temaNormalizado mediante combates por turnos.',
      fuenteGeneracion: 'ia',
    );

    final encuentros = <Encuentro>[
      _crearEncuentro(
        questId: questId,
        numero: 1,
        dificultad: 'facil',
        vidaEnemigo: 30,
        tema: temaNormalizado,
      ),
      _crearEncuentro(
        questId: questId,
        numero: 2,
        dificultad: 'medio',
        vidaEnemigo: 40,
        tema: temaNormalizado,
      ),
      _crearEncuentro(
        questId: questId,
        numero: 3,
        dificultad: 'dificil',
        vidaEnemigo: 70,
        tema: temaNormalizado,
        esJefe: true,
      ),
    ];

    return QuestCompleta(quest: quest, encuentros: encuentros);
  }

  Encuentro _crearEncuentro({
    required String questId,
    required int numero,
    required String dificultad,
    required int vidaEnemigo,
    required String tema,
    bool esJefe = false,
  }) {
    final encuentroId = _uuid.v4();
    final opciones = <OpcionEncuentro>[
      _crearOpcion(
        encuentroId: encuentroId,
        letra: 'A',
        texto: 'Aplicar correctamente $tema en el problema.',
        calidad: 2,
      ),
      _crearOpcion(
        encuentroId: encuentroId,
        letra: 'B',
        texto: 'Reconocer una idea relacionada con $tema.',
        calidad: 1,
      ),
      _crearOpcion(
        encuentroId: encuentroId,
        letra: 'C',
        texto: 'Ignorar por completo el concepto de $tema.',
        calidad: 0,
      ),
      _crearOpcion(
        encuentroId: encuentroId,
        letra: 'D',
        texto: 'Usar una respuesta que no corresponde a $tema.',
        calidad: 0,
      ),
    ];

    return Encuentro(
      idEncuentro: encuentroId,
      idQuest: questId,
      numero: numero,
      pregunta: '¿Cuál afirmación describe mejor $tema?',
      dificultad: dificultad,
      tipoEncuentro: esJefe ? 'jefe' : 'normal',
      vidaEnemigo: vidaEnemigo,
      opciones: opciones,
    );
  }

  OpcionEncuentro _crearOpcion({
    required String encuentroId,
    required String letra,
    required String texto,
    required int calidad,
  }) {
    return OpcionEncuentro(
      idOpcion: _uuid.v4(),
      idEncuentro: encuentroId,
      letra: letra,
      texto: texto,
      calidad: calidad,
    );
  }

  @override
  Future<List<Encuentro>> generarEncuentrosExtra({
    required String idQuest,
    required String tema,
    required String categoria,
    required String dificultad,
    required int ultimoNumero,
  }) async {
    // Stub simply returns empty for now
    return [];
  }
}
