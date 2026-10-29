import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';
import '../repositories/sesion_repository.dart';


class RegistroInvalidoException implements Exception {
  final String mensaje;
  RegistroInvalidoException(this.mensaje);
}

class CredencialesInvalidasException implements Exception {
  final String mensaje = 'Correo o contraseña incorrectos';
}

class RegistrarUsuarioUseCase {
  final AuthRepository _repo;
  final SesionRepository? _sesionRepo;

  RegistrarUsuarioUseCase(this._repo, [this._sesionRepo]);

  Future<Usuario> ejecutar({
    required String email,
    required String nombreUsuario,
    required String nombre,
    required String apellido,
    required String passwordPlano,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final nombreNormalizado = nombre.trim();
    final apellidoNormalizado = apellido.trim();
    final nombreUsuarioNormalizado = nombreUsuario.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(emailNormalizado)) {
      throw RegistroInvalidoException('El correo electrónico no es válido.');
    }
    if (nombreNormalizado.length < 2 || nombreNormalizado.length > 50) {
      throw RegistroInvalidoException(
        'El nombre es obligatorio y debe tener entre 2 y 50 caracteres.',
      );
    }
    if (apellidoNormalizado.length < 2 || apellidoNormalizado.length > 50) {
      throw RegistroInvalidoException(
        'El apellido es obligatorio y debe tener entre 2 y 50 caracteres.',
      );
    }
    if (nombreUsuarioNormalizado.length < 3 ||
        nombreUsuarioNormalizado.length > 20 ||
        !RegExp(r'^[A-Za-z0-9_]+$').hasMatch(nombreUsuarioNormalizado)) {
      throw RegistroInvalidoException(
        'El nombre de usuario debe tener entre 3 y 20 caracteres y solo puede contener letras, números y guion bajo.',
      );
    }
    if (passwordPlano.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(passwordPlano) ||
        !RegExp(r'[0-9]').hasMatch(passwordPlano)) {
      throw RegistroInvalidoException(
        'La contraseña debe tener al menos 8 caracteres, una letra y un número.',
      );
    }

    try {
      if (await _repo.existeEmail(emailNormalizado)) {
        throw RegistroInvalidoException('El correo ya está registrado.');
      }
      if (await _repo.existeNombreUsuario(nombreUsuarioNormalizado)) {
        throw RegistroInvalidoException(
          'El nombre de usuario ya está registrado.',
        );
      }
    } on UnimplementedError {
      // El backend HTTP actual no tiene estos endpoints implementados aún.
      // Permitimos que continúe y delegamos la validación de duplicados al backend.
    }

    final usuario = await _repo.registrar(
      email: emailNormalizado,
      nombreUsuario: nombreUsuarioNormalizado,
      nombre: nombreNormalizado,
      apellido: apellidoNormalizado,
      passwordPlano: passwordPlano,
    );
    await _sesionRepo?.guardarSesion(usuario.idUsuario);
    return usuario;
  }
}

class IniciarSesionUseCase {
  final AuthRepository _repo;
  final SesionRepository? _sesionRepo;

  IniciarSesionUseCase(this._repo, [this._sesionRepo]);

  Future<Usuario> ejecutar(
    String identificador,
    String passwordPlano, {
    bool mantenerSesion = true,
  }) async {
    final usuario = await _repo.autenticar(
      identificador.trim().toLowerCase(),
      passwordPlano,
    );
    if (usuario == null) throw CredencialesInvalidasException();
    if (mantenerSesion && _sesionRepo != null) {
      await _sesionRepo.guardarSesion(usuario.idUsuario);
    }
    return usuario;
  }
}

class RestaurarSesionUseCase {
  final SesionRepository _sesionRepo;
  final AuthRepository _authRepo;

  RestaurarSesionUseCase(this._sesionRepo, this._authRepo);

  Future<Usuario?> ejecutar() async {
    final idUsuario = await _sesionRepo.obtenerIdUsuarioActivo();
    if (idUsuario == null) return null;

    final usuario = await _authRepo.obtenerPorId(idUsuario);
    if (usuario == null) {
      await _sesionRepo.cerrarSesion();
      return null;
    }
    return usuario;
  }
}

class CerrarSesionUseCase {
  final SesionRepository _sesionRepo;

  CerrarSesionUseCase(this._sesionRepo);

  Future<void> ejecutar() => _sesionRepo.cerrarSesion();
}
