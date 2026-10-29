/// Cada encuentro tiene 4 opciones (A-D).
/// `calidad` define qué tan buena es la respuesta:
///   2 = correcta y más completa (crítico)
///   1 = correcta pero más débil (daño normal)
///   0 = incorrecta (el enemigo contraataca)
class OpcionEncuentro {
  final String idOpcion; // UUID
  final String idEncuentro;
  final String letra; // A, B, C, D
  final String texto;
  final int calidad; // 0, 1 o 2

  const OpcionEncuentro({
    required this.idOpcion,
    required this.idEncuentro,
    required this.letra,
    required this.texto,
    required this.calidad,
  });
}
