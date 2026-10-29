import 'encuentro.dart';
import 'quest.dart';

class QuestCompleta {
  final Quest quest;
  final List<Encuentro> encuentros;
  final Map<String, dynamic>? poolNarrativo;
  final List<Encuentro> preguntasExtra;
  final int semilla;
  final String idPartida;

  QuestCompleta({
    required this.quest,
    required List<Encuentro> encuentros,
    this.poolNarrativo,
    List<Encuentro>? preguntasExtra,
    this.semilla = 0,
    this.idPartida = '',
  })  : encuentros = List<Encuentro>.unmodifiable(encuentros),
        preguntasExtra = List<Encuentro>.unmodifiable(preguntasExtra ?? const []);
}
