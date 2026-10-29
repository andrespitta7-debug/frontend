import 'encuentro.dart';
import 'quest.dart';

class QuestCompleta {
  final Quest quest;
  final List<Encuentro> encuentros;
  final Map<String, dynamic>? poolNarrativo;
  final List<Encuentro> preguntasExtra;
  final int semilla;
  final String idPartida;
  final String questTitle;
  final String resolvedTopic;

  QuestCompleta({
    required this.quest,
    required List<Encuentro> encuentros,
    this.poolNarrativo,
    List<Encuentro>? preguntasExtra,
    this.semilla = 0,
    this.idPartida = '',
    this.questTitle = 'Incursión en la Mazmorra',
    this.resolvedTopic = 'Conocimiento Arcano',
  })  : encuentros = List<Encuentro>.unmodifiable(encuentros),
        preguntasExtra = List<Encuentro>.unmodifiable(preguntasExtra ?? const []);
}
