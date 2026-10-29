class Quest {
  final String idQuest; // UUID
  final String titulo;
  final String tema;
  final String categoria; // debug / database / algorithm / network / architecture / cyber / libre
  final String dificultad;
  final String descripcion;
  final String fuenteGeneracion; // "manual" o "ia"

  const Quest({
    required this.idQuest,
    required this.titulo,
    required this.tema,
    required this.categoria,
    required this.dificultad,
    required this.descripcion,
    required this.fuenteGeneracion,
  });
}
