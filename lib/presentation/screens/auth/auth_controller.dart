import 'package:flutter/foundation.dart';

import '../../../domain/entities/usuario.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../infrastructure/api/api_exception.dart';

class AuthController extends ChangeNotifier {
  final RegistrarUsuarioUseCase _registrarUseCase;
  final IniciarSesionUseCase _iniciarSesionUseCase;

  AuthController(this._registrarUseCase, this._iniciarSesionUseCase);

  Usuario? usuarioActual;
  bool cargando = false;
  String? error;

  bool get sesionActiva => usuarioActual != null;

  Future<bool> registrar({
    required String email,
    required String nombreUsuario,
    required String nombre,
    required String apellido,
    required String password,
  }) async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      usuarioActual = await _registrarUseCase.ejecutar(
        email: email,
        nombreUsuario: nombreUsuario,
        nombre: nombre,
        apellido: apellido,
        passwordPlano: password,
      );
      return true;
    } on RegistroInvalidoException catch (e) {
      error = e.mensaje;
      return false;
    } on ApiException catch (e) {
      error = e.mensaje;
      return false;
    } catch (e) {
      error = 'Error al registrar.';
      return false;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> iniciarSesion(
    String email,
    String password, {
    bool mantenerSesion = true,
  }) async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      usuarioActual = await _iniciarSesionUseCase.ejecutar(
        email,
        password,
        mantenerSesion: mantenerSesion,
      );
      return true;
    } on CredencialesInvalidasException {
      error = 'Correo o contraseña incorrectos.';
      return false;
    } on ApiException catch (e) {
      error = e.mensaje;
      return false;
    } catch (_) {
      error = 'Ocurrió un error inesperado al iniciar sesión.';
      return false;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void cerrarSesion() {
    usuarioActual = null;
    notifyListeners();
  }
}
