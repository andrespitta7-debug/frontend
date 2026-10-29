enum TipoWildcard {
  cincuentaCincuenta,
  roboDeVida,
  golpeDoble,
  pista,
}

class Wildcard {
  final TipoWildcard tipo;
  final int cantidad;
  const Wildcard({required this.tipo, required this.cantidad});

  Wildcard conCantidad(int nuevaCantidad) =>
      Wildcard(tipo: tipo, cantidad: nuevaCantidad);

  String get nombre {
    switch (tipo) {
      case TipoWildcard.cincuentaCincuenta: return '50/50';
      case TipoWildcard.roboDeVida: return 'Robo de vida';
      case TipoWildcard.golpeDoble: return 'Golpe doble';
      case TipoWildcard.pista: return 'Pista';
    }
  }

  String get emoji {
    switch (tipo) {
      case TipoWildcard.cincuentaCincuenta: return '✂️';
      case TipoWildcard.roboDeVida: return '💚';
      case TipoWildcard.golpeDoble: return '⚔️';
      case TipoWildcard.pista: return '💡';
    }
  }

  String get descripcion {
    switch (tipo) {
      case TipoWildcard.cincuentaCincuenta: return 'Elimina 2 opciones incorrectas';
      case TipoWildcard.roboDeVida: return 'El proximo acierto te cura 10 HP';
      case TipoWildcard.golpeDoble: return 'El proximo acierto hace dano x2';
      case TipoWildcard.pista: return 'Revela una pista sobre la respuesta';
    }
  }
}
