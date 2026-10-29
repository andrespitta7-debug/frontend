import 'opcion_encuentro.dart';

class Encuentro {
  final String idEncuentro; // UUID
  final String idQuest;
  final int numero; // orden dentro de la quest (1, 2, 3...)
  final String pregunta;
  final String dificultad;
  final String tipoEncuentro; // "normal" o "jefe"
  final int vidaEnemigo;
  final String? enemigo;
  final String? codigo;
  final List<OpcionEncuentro> opciones; // siempre 4

  const Encuentro({
    required this.idEncuentro,
    required this.idQuest,
    required this.numero,
    required this.pregunta,
    required this.dificultad,
    required this.tipoEncuentro,
    required this.vidaEnemigo,
    this.enemigo,
    this.codigo,
    required this.opciones,
  });

  bool get esJefe => tipoEncuentro == 'jefe';
}
