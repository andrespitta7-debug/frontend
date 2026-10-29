class Personaje {
  final String idPersonaje; // UUID
  final String idUsuario;
  final String nombre;
  final String genero; // "masculino" / "femenino"
  final String skin; // id del skin equipado

  const Personaje({
    required this.idPersonaje,
    required this.idUsuario,
    required this.nombre,
    required this.genero,
    required this.skin,
  });
}

class Partida {
  final String idPartida; // UUID
  final String idUsuario;
  final String idQuest;
  String estado; // "en_curso" / "ganada" / "perdida"
  int encuentroActual; // índice del encuentro en el que va
  int score;
  int xpObtenida;
  int tiempoSegundos;
  int vidaJugador; // vida actual del jugador durante la partida
  int enemigosDerrotados;
  int rachaMaxima;
  int rondasTemerarias;

  Partida({
    required this.idPartida,
    required this.idUsuario,
    required this.idQuest,
    this.estado = 'en_curso',
    this.encuentroActual = 0,
    this.score = 0,
    this.xpObtenida = 0,
    this.tiempoSegundos = 0,
    this.vidaJugador = 100,
    this.enemigosDerrotados = 0,
    this.rachaMaxima = 0,
    this.rondasTemerarias = 0,
  });
}

class ProgresoUsuario {
  final String idUsuario;
  int nivel;
  int xpTotal;
  int questsCompletadas;
  int victorias;
  int derrotas;
  int partidasJugadas;

  ProgresoUsuario({
    required this.idUsuario,
    this.nivel = 1,
    this.xpTotal = 0,
    this.questsCompletadas = 0,
    this.victorias = 0,
    this.derrotas = 0,
    this.partidasJugadas = 0,
  });
}
