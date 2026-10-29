class Usuario {
  final String idUsuario; // UUID
  final String email;
  final String nombreUsuario;
  final String nombre;
  final String apellido;

  const Usuario({
    required this.idUsuario,
    required this.email,
    required this.nombreUsuario,
    required this.nombre,
    required this.apellido,
  });
}
