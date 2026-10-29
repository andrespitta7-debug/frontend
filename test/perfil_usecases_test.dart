import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/domain/entities/usuario.dart';
import 'package:sysquest_app/domain/repositories/auth_repository.dart';
import 'package:sysquest_app/domain/usecases/auth_usecases.dart';
import 'package:sysquest_app/domain/usecases/password_hasher.dart';
import 'package:sysquest_app/domain/usecases/perfil_usecases.dart';

class FakePerfilAuthRepository implements AuthRepository {
  FakePerfilAuthRepository({
    this.nombreUsuarioEnUso,
    this.passwordHashValido,
  });

  final String? nombreUsuarioEnUso;
  final String? passwordHashValido;
  Usuario? usuarioActualizado;
  bool consultoNombreExcepto = false;
  String? idUsuarioPasswordCambiado;
  String? nuevoHashGuardado;
  String? idUsuarioEliminado;

  @override
  Future<void> actualizar(Usuario usuario) async {
    usuarioActualizado = usuario;
  }

  @override
  Future<bool> existeNombreUsuarioExcepto(
    String nombreUsuario,
    String idUsuario,
  ) async {
    consultoNombreExcepto = true;
    return nombreUsuario == nombreUsuarioEnUso;
  }

  @override
  Future<Usuario?> obtenerPorId(String idUsuario) async => null;

  @override
  Future<bool> existeEmail(String email) async => false;

  @override
  Future<bool> existeNombreUsuario(String nombreUsuario) async => false;

  @override
  Future<Usuario> registrar({
    required String email,
    required String nombreUsuario,
    required String nombre,
    required String apellido,
    required String passwordPlano,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Usuario?> autenticar(String email, String passwordPlano) async {
    final hash = PasswordHasher.hash(passwordPlano);
    if (passwordHashValido != null && hash == passwordHashValido) {
      return usuarioInicial;
    }
    return null;
  }

  @override
  Future<void> cambiarPassword(String idUsuario, String nuevoPasswordPlano) async {
    idUsuarioPasswordCambiado = idUsuario;
    nuevoHashGuardado = PasswordHasher.hash(nuevoPasswordPlano);
  }

  @override
  Future<void> eliminarCuenta(String idUsuario) async {
    idUsuarioEliminado = idUsuario;
  }
}

const usuarioInicial = Usuario(
  idUsuario: 'usuario-1',
  email: 'ana@example.com',
  nombreUsuario: 'ana_01',
  nombre: 'Ana',
  apellido: 'Gomez',
);

Future<void> expectError({
  required String nombre,
  required String apellido,
  required String nombreUsuario,
  required String mensaje,
}) async {
  final useCase = ActualizarPerfilUseCase(FakePerfilAuthRepository());

  await expectLater(
    useCase.ejecutar(
      usuarioActual: usuarioInicial,
      nombre: nombre,
      apellido: apellido,
      nombreUsuario: nombreUsuario,
    ),
    throwsA(
      isA<RegistroInvalidoException>().having(
        (error) => error.mensaje,
        'mensaje',
        mensaje,
      ),
    ),
  );
}

void main() {
  group('ActualizarPerfilUseCase', () {
    test('actualiza nombre, apellido y nombre de usuario', () async {
      final repo = FakePerfilAuthRepository();
      final useCase = ActualizarPerfilUseCase(repo);

      final actualizado = await useCase.ejecutar(
        usuarioActual: usuarioInicial,
        nombre: '  Beatriz  ',
        apellido: '  Perez  ',
        nombreUsuario: 'beatriz_02',
      );

      expect(actualizado.idUsuario, usuarioInicial.idUsuario);
      expect(actualizado.email, usuarioInicial.email);
      expect(actualizado.nombre, 'Beatriz');
      expect(actualizado.apellido, 'Perez');
      expect(actualizado.nombreUsuario, 'beatriz_02');
      expect(repo.usuarioActualizado, same(actualizado));
    });

    test('rechaza nombre vacío o fuera de rango', () async {
      const mensaje =
          'El nombre es obligatorio y debe tener entre 2 y 50 caracteres.';
      await expectError(
        nombre: '',
        apellido: 'Gomez',
        nombreUsuario: 'ana_01',
        mensaje: mensaje,
      );
      await expectError(
        nombre: 'A',
        apellido: 'Gomez',
        nombreUsuario: 'ana_01',
        mensaje: mensaje,
      );
      await expectError(
        nombre: 'A' * 51,
        apellido: 'Gomez',
        nombreUsuario: 'ana_01',
        mensaje: mensaje,
      );
    });

    test('rechaza apellido vacío o fuera de rango', () async {
      const mensaje =
          'El apellido es obligatorio y debe tener entre 2 y 50 caracteres.';
      await expectError(
        nombre: 'Ana',
        apellido: '',
        nombreUsuario: 'ana_01',
        mensaje: mensaje,
      );
      await expectError(
        nombre: 'Ana',
        apellido: 'G',
        nombreUsuario: 'ana_01',
        mensaje: mensaje,
      );
      await expectError(
        nombre: 'Ana',
        apellido: 'G' * 51,
        nombreUsuario: 'ana_01',
        mensaje: mensaje,
      );
    });

    test(
      'rechaza nombre de usuario menor, mayor o con caracteres inválidos',
      () async {
        const mensaje =
            'El nombre de usuario debe tener entre 3 y 20 caracteres y solo puede contener letras, números y guion bajo.';
        await expectError(
          nombre: 'Ana',
          apellido: 'Gomez',
          nombreUsuario: 'ab',
          mensaje: mensaje,
        );
        await expectError(
          nombre: 'Ana',
          apellido: 'Gomez',
          nombreUsuario: 'a' * 21,
          mensaje: mensaje,
        );
        await expectError(
          nombre: 'Ana',
          apellido: 'Gomez',
          nombreUsuario: 'ana-01',
          mensaje: mensaje,
        );
      },
    );

    test('rechaza un nombre de usuario usado por otro usuario', () async {
      final repo = FakePerfilAuthRepository(nombreUsuarioEnUso: 'otro_01');
      final useCase = ActualizarPerfilUseCase(repo);

      await expectLater(
        useCase.ejecutar(
          usuarioActual: usuarioInicial,
          nombre: 'Ana',
          apellido: 'Gomez',
          nombreUsuario: 'otro_01',
        ),
        throwsA(
          isA<RegistroInvalidoException>().having(
            (error) => error.mensaje,
            'mensaje',
            'El nombre de usuario ya está registrado.',
          ),
        ),
      );
      expect(repo.usuarioActualizado, isNull);
    });

    test(
      'permite conservar el nombre de usuario actual sin consultar duplicado',
      () async {
        final repo = FakePerfilAuthRepository(nombreUsuarioEnUso: 'ana_01');
        final useCase = ActualizarPerfilUseCase(repo);

        final actualizado = await useCase.ejecutar(
          usuarioActual: usuarioInicial,
          nombre: 'Ana María',
          apellido: 'Gomez',
          nombreUsuario: 'ana_01',
        );

        expect(actualizado.nombre, 'Ana María');
        expect(actualizado.nombreUsuario, 'ana_01');
        expect(repo.consultoNombreExcepto, isFalse);
        expect(repo.usuarioActualizado, same(actualizado));
      },
    );

    test('no cambia el email del usuario', () async {
      final repo = FakePerfilAuthRepository();
      final useCase = ActualizarPerfilUseCase(repo);

      final actualizado = await useCase.ejecutar(
        usuarioActual: usuarioInicial,
        nombre: 'Ana Nueva',
        apellido: 'Gomez',
        nombreUsuario: 'ana_nueva',
      );

      expect(actualizado.email, 'ana@example.com');
      expect(repo.usuarioActualizado?.email, 'ana@example.com');
    });
  });

  group('CambiarPasswordUseCase', () {
    test('cambiar password válido', () async {
      final repo = FakePerfilAuthRepository(
        passwordHashValido: PasswordHasher.hash('Actual123'),
      );
      final useCase = CambiarPasswordUseCase(repo);

      await useCase.ejecutar(
        usuario: usuarioInicial,
        passwordActual: 'Actual123',
        passwordNueva: 'NuevaPass1',
        passwordConfirmacion: 'NuevaPass1',
      );

      expect(repo.idUsuarioPasswordCambiado, usuarioInicial.idUsuario);
      expect(repo.nuevoHashGuardado, PasswordHasher.hash('NuevaPass1'));
    });

    test('password actual incorrecta → error', () async {
      final repo = FakePerfilAuthRepository(
        passwordHashValido: PasswordHasher.hash('Correcta123'),
      );
      final useCase = CambiarPasswordUseCase(repo);

      await expectLater(
        useCase.ejecutar(
          usuario: usuarioInicial,
          passwordActual: 'Erronea123',
          passwordNueva: 'NuevaPass1',
          passwordConfirmacion: 'NuevaPass1',
        ),
        throwsA(
          isA<RegistroInvalidoException>().having(
            (error) => error.mensaje,
            'mensaje',
            'La contraseña actual es incorrecta.',
          ),
        ),
      );
      expect(repo.nuevoHashGuardado, isNull);
    });

    test(
      'nueva password no cumple reglas (menos de 8, sin número, sin letra) → error',
      () async {
        final repo = FakePerfilAuthRepository(
          passwordHashValido: PasswordHasher.hash('Actual123'),
        );
        final useCase = CambiarPasswordUseCase(repo);

        final casosInvalidos = [
          'Abc1', // menos de 8
          'Abcdefgh', // sin número
          '12345678', // sin letra
        ];

        for (final pass in casosInvalidos) {
          await expectLater(
            useCase.ejecutar(
              usuario: usuarioInicial,
              passwordActual: 'Actual123',
              passwordNueva: pass,
              passwordConfirmacion: pass,
            ),
            throwsA(
              isA<RegistroInvalidoException>().having(
                (error) => error.mensaje,
                'mensaje',
                'La contraseña debe tener al menos 8 caracteres, una letra y un número.',
              ),
            ),
          );
        }
        expect(repo.nuevoHashGuardado, isNull);
      },
    );

    test('confirmación no coincide → error', () async {
      final repo = FakePerfilAuthRepository(
        passwordHashValido: PasswordHasher.hash('Actual123'),
      );
      final useCase = CambiarPasswordUseCase(repo);

      await expectLater(
        useCase.ejecutar(
          usuario: usuarioInicial,
          passwordActual: 'Actual123',
          passwordNueva: 'NuevaPass1',
          passwordConfirmacion: 'DistintaPass2',
        ),
        throwsA(
          isA<RegistroInvalidoException>().having(
            (error) => error.mensaje,
            'mensaje',
            'Las contraseñas no coinciden.',
          ),
        ),
      );
      expect(repo.nuevoHashGuardado, isNull);
    });

    test('nueva igual a la actual → error', () async {
      final repo = FakePerfilAuthRepository(
        passwordHashValido: PasswordHasher.hash('Actual123'),
      );
      final useCase = CambiarPasswordUseCase(repo);

      await expectLater(
        useCase.ejecutar(
          usuario: usuarioInicial,
          passwordActual: 'Actual123',
          passwordNueva: 'Actual123',
          passwordConfirmacion: 'Actual123',
        ),
        throwsA(
          isA<RegistroInvalidoException>().having(
            (error) => error.mensaje,
            'mensaje',
            'La nueva contraseña no puede ser igual a la actual.',
          ),
        ),
      );
      expect(repo.nuevoHashGuardado, isNull);
    });
  });

  group('EliminarCuentaUseCase', () {
    test('eliminación válida', () async {
      final repo = FakePerfilAuthRepository(
        passwordHashValido: PasswordHasher.hash('MiPassword123'),
      );
      final useCase = EliminarCuentaUseCase(repo);

      await useCase.ejecutar(
        usuario: usuarioInicial,
        passwordActual: 'MiPassword123',
      );

      expect(repo.idUsuarioEliminado, usuarioInicial.idUsuario);
    });

    test('contraseña incorrecta → error', () async {
      final repo = FakePerfilAuthRepository(
        passwordHashValido: PasswordHasher.hash('Correcta123'),
      );
      final useCase = EliminarCuentaUseCase(repo);

      await expectLater(
        useCase.ejecutar(
          usuario: usuarioInicial,
          passwordActual: 'Incorrecta123',
        ),
        throwsA(
          isA<RegistroInvalidoException>().having(
            (error) => error.mensaje,
            'mensaje',
            'La contraseña es incorrecta.',
          ),
        ),
      );
      expect(repo.idUsuarioEliminado, isNull);
    });
  });
}
