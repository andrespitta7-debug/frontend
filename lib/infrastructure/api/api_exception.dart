/// Excepción base para errores en llamadas a la API HTTP.
class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;
  final String? codigo;

  const ApiException(this.mensaje, {this.statusCode, this.codigo});

  @override
  String toString() => mensaje;
}
