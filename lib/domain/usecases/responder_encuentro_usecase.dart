import '../entities/opcion_encuentro.dart';

enum ResultadoTurno { critico, acierto, fallo }

class ResultadoCombate {
  final ResultadoTurno resultado;
  final int danoAlEnemigo;
  final int danoAlJugador;

  const ResultadoCombate({
    required this.resultado,
    required this.danoAlEnemigo,
    required this.danoAlJugador,
  });
}

/// Caso de uso: NO sabe nada de Flutter, ni de SQLite, ni de widgets.
/// Solo recibe la opción elegida y devuelve el resultado del turno.
/// Esto es lo que en un examen o sustentación pueden explicar como
/// "la lógica de negocio está aislada de la interfaz y de los datos".
class ResponderEncuentroUseCase {
  static const int danoBaseCritico = 25;
  static const int danoBaseAcierto = 12;
  static const int danoBaseContraataque = 15;
  static const int bonoJefe = 10;

  ResultadoCombate ejecutar(
    OpcionEncuentro opcionElegida, {
    bool esJefe = false,
  }) {
    final bonoPorJefe = esJefe ? bonoJefe : 0;

    switch (opcionElegida.calidad) {
      case 2:
        return ResultadoCombate(
          resultado: ResultadoTurno.critico,
          danoAlEnemigo: danoBaseCritico + bonoPorJefe,
          danoAlJugador: 0,
        );
      case 1:
        return ResultadoCombate(
          resultado: ResultadoTurno.acierto,
          danoAlEnemigo: danoBaseAcierto + (bonoPorJefe ~/ 2),
          danoAlJugador: 0,
        );
      default:
        return ResultadoCombate(
          resultado: ResultadoTurno.fallo,
          danoAlEnemigo: 0,
          danoAlJugador: danoBaseContraataque + bonoPorJefe,
        );
    }
  }
}
