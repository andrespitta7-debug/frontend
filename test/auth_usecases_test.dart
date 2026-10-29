import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/domain/entities/usuario.dart';
import 'package:sysquest_app/domain/repositories/auth_repository.dart';
import 'package:sysquest_app/domain/repositories/sesion_repository.dart';
import 'package:sysquest_app/domain/usecases/auth_usecases.dart';
import 'package:sysquest_app/domain/usecases/password_hasher.dart';

class FakeAuthRepository implements AuthRepository {
  final List<Usuario> usuarios = [];
  final Map<String, String> hashes = {};
  String? ultimoEmailConsultado;

  @override
  Future<Usuario?> obtenerPorId(String idUsuario) async {
    for (final usuario in usuarios) {
      if (usuario.idUsuario == idUsuario) return usuario;
    }
    return null;
  }

  @override
  Future<bool> existeEmail(String email) async {
    ultimoEmailConsultado = email;
    return usuarios.any((usuario) => usuario.email == email);
  }

  @override
  Future<bool> existeNombreUsuario(String nombreUsuario) async {
    return usuarios.any((usuario) => usuario.nombreUsuario == nombreUsuario);
  }

  @override
  Future<bool> existeNombreUsuarioExcepto(
    String nombreUsuario,
    String idUsuario,
  ) async {
    return usuarios.any(
      (usuario) =>
          usuario.nombreUsuario == nombreUsuario &&
          usuario.idUsuario != idUsuario,
    );
  }

  @override
  Future<void> actualizar(Usuario usuario) async {
    final indice = usuarios.indexWhere(
      (existente) => existente.idUsuario == usuario.idUsuario,
    );
    if (indice >= 0) usuarios[indice] = usuario;
  }

  @override
  Future<Usuario> registrar({
    required String email,
    required String nombreUsuario,
    required String nombre,
    required String apellido,
    required String passwordPlano,
  }) async {
    final usuario = Usuario(
      idUsuario: 'usuario-${usuarios.length + 1}',
      email: email,
      nombreUsuario: nombreUsuario,
      nombre: nombre,
      apellido: apellido,
    );
    usuarios.add(usuario);
    hashes[usuario.idUsuario] = PasswordHasher.hash(passwordPlano);
    return usuario;
  }

  @override
  Future<Usuario?> autenticar(String email, String passwordPlano) async {
    final hash = PasswordHasher.hash(passwordPlano);
    for (final usuario in usuarios) {
      if (usuario.email == email && hashes[usuario.idUsuario] == hash) {
        ultimoEmailConsultado = email;
        return usuario;
      }
    }
    ultimoEmailConsultado = email;
    return null;
  }

  @override
  Future<void> cambiarPassword(String idUsuario, String nuevoPasswordPlano) async {
    hashes[idUsuario] = PasswordHasher.hash(nuevoPasswordPlano);
  }

  @override
  Future<void> eliminarCuenta(String idUsuario) async {
    usuarios.removeWhere((u) => u.idUsuario == idUsuario);
    hashes.remove(idUsuario);
  }
}

class FakeSesionRepository implements SesionRepository {
  String? idUsuarioActivo;
  int sesionesGuardadas = 0;
  int sesionesCerradas = 0;

  @override
  Future<void> guardarSesion(String idUsuario) async {
    idUsuarioActivo = idUsuario;
    sesionesGuardadas++;
  }

  @override
  Future<String?> obtenerIdUsuarioActivo() async => idUsuarioActivo;

  @override
  Future<void> cerrarSesion() async {
    idUsuarioActivo = null;
    sesionesCerradas++;
  }
}

Usuario usuarioBase({
  String id = 'usuario-existente',
  String email = 'ana@example.com',
  String nombreUsuario = 'ana_01',
}) {
  return Usuario(
    idUsuario: id,
    email: email,
    nombreUsuario: nombreUsuario,
    nombre: 'Ana',
    apellido: 'Gomez',
  );
}

Future<void> expectRegistroInvalido({
  required String mensajeEsperado,
  String email = 'ana@example.com',
  String nombreUsuario = 'ana_01',
  String nombre = 'Ana',
  String apellido = 'Gomez',
  String password = 'Seguro123',
}) async {
  final authRepo = FakeAuthRepository();
  final useCase = RegistrarUsuarioUseCase(authRepo);

  await expectLater(
    useCase.ejecutar(
      email: email,
      nombreUsuario: nombreUsuario,
      nombre: nombre,
      apellido: apellido,
      passwordPlano: password,
    ),
    throwsA(
      isA<RegistroInvalidoException>().having(
        (error) => error.mensaje,
        'mensaje',
        mensajeEsperado,
      ),
    ),
  );
}

void main() {
  group('RegistrarUsuarioUseCase', () {
    test(
      'registra, normaliza datos y guarda la sesión automáticamente',
      () async {
        final authRepo = FakeAuthRepository();
        final sesionRepo = FakeSesionRepository();
        final useCase = RegistrarUsuarioUseCase(authRepo, sesionRepo);

        final usuario = await useCase.ejecutar(
          email: '  ANA@EXAMPLE.COM ',
          nombreUsuario: 'ana_01',
          nombre: ' Ana ',
          apellido: ' Gomez ',
          passwordPlano: 'Seguro123',
        );

        expect(usuario.email, 'ana@example.com');
        expect(usuario.nombre, 'Ana');
        expect(usuario.apellido, 'Gomez');
        expect(sesionRepo.idUsuarioActivo, usuario.idUsuario);
        expect(sesionRepo.sesionesGuardadas, 1);
        expect(authRepo.ultimoEmailConsultado, 'ana@example.com');
      },
    );

    test('rechaza un correo inválido', () async {
      await expectRegistroInvalido(
        email: 'correo-invalido',
        mensajeEsperado: 'El correo electrónico no es válido.',
      );
    });

    test('rechaza nombre vacío o fuera de rango', () async {
      await expectRegistroInvalido(
        nombre: 'A',
        mensajeEsperado:
            'El nombre es obligatorio y debe tener entre 2 y 50 caracteres.',
      );
    });

    test('rechaza apellido vacío o fuera de rango', () async {
      await expectRegistroInvalido(
        apellido: 'A',
        mensajeEsperado:
            'El apellido es obligatorio y debe tener entre 2 y 50 caracteres.',
      );
    });

    test('rechaza nombre de usuario inválido', () async {
      await expectRegistroInvalido(
        nombreUsuario: 'ana usuario',
        mensajeEsperado:
            'El nombre de usuario debe tener entre 3 y 20 caracteres y solo puede contener letras, números y guion bajo.',
      );
    });

    test('rechaza contraseña demasiado corta', () async {
      await expectRegistroInvalido(
        password: 'Abc1234',
        mensajeEsperado:
            'La contraseña debe tener al menos 8 caracteres, una letra y un número.',
      );
    });

    test('rechaza contraseña sin letra', () async {
      await expectRegistroInvalido(
        password: '12345678',
        mensajeEsperado:
            'La contraseña debe tener al menos 8 caracteres, una letra y un número.',
      );
    });

    test('rechaza contraseña sin número', () async {
      await expectRegistroInvalido(
        password: 'abcdefgh',
        mensajeEsperado:
            'La contraseña debe tener al menos 8 caracteres, una letra y un número.',
      );
    });

    test('rechaza un correo duplicado con un mensaje distinto', () async {
      final authRepo = FakeAuthRepository()..usuarios.add(usuarioBase());
      final useCase = RegistrarUsuarioUseCase(authRepo);

      await expectLater(
        useCase.ejecutar(
          email: 'ana@example.com',
          nombreUsuario: 'otra_01',
          nombre: 'Otra',
          apellido: 'Persona',
          passwordPlano: 'Seguro123',
        ),
        throwsA(
          isA<RegistroInvalidoException>().having(
            (error) => error.mensaje,
            'mensaje',
            'El correo ya está registrado.',
          ),
        ),
      );
    });

    test('rechaza un usuario duplicado con un mensaje distinto', () async {
      final authRepo = FakeAuthRepository()..usuarios.add(usuarioBase());
      final useCase = RegistrarUsuarioUseCase(authRepo);

      await expectLater(
        useCase.ejecutar(
          email: 'otro@example.com',
          nombreUsuario: 'ana_01',
          nombre: 'Otra',
          apellido: 'Persona',
          passwordPlano: 'Seguro123',
        ),
        throwsA(
          isA<RegistroInvalidoException>().having(
            (error) => error.mensaje,
            'mensaje',
            'El nombre de usuario ya está registrado.',
          ),
        ),
      );
    });
  });

  group('IniciarSesionUseCase', () {
    test('normaliza el correo y guarda sesión por defecto', () async {
      final authRepo = FakeAuthRepository();
      final sesionRepo = FakeSesionRepository();
      final usuario = await RegistrarUsuarioUseCase(authRepo).ejecutar(
        email: 'ana@example.com',
        nombreUsuario: 'ana_01',
        nombre: 'Ana',
        apellido: 'Gomez',
        passwordPlano: 'Seguro123',
      );
      authRepo.hashes[usuario.idUsuario] = PasswordHasher.hash('Seguro123');
      final useCase = IniciarSesionUseCase(authRepo, sesionRepo);

      final resultado = await useCase.ejecutar(
        ' ANA@EXAMPLE.COM ',
        'Seguro123',
      );

      expect(resultado.idUsuario, usuario.idUsuario);
      expect(authRepo.ultimoEmailConsultado, 'ana@example.com');
      expect(sesionRepo.idUsuarioActivo, usuario.idUsuario);
    });

    test('no guarda sesión cuando mantenerSesion es false', () async {
      final authRepo = FakeAuthRepository();
      final usuario = await RegistrarUsuarioUseCase(authRepo).ejecutar(
        email: 'ana@example.com',
        nombreUsuario: 'ana_01',
        nombre: 'Ana',
        apellido: 'Gomez',
        passwordPlano: 'Seguro123',
      );
      authRepo.hashes[usuario.idUsuario] = PasswordHasher.hash('Seguro123');
      final sesionRepo = FakeSesionRepository();
      final useCase = IniciarSesionUseCase(authRepo, sesionRepo);

      await useCase.ejecutar(
        'ana@example.com',
        'Seguro123',
        mantenerSesion: false,
      );

      expect(sesionRepo.sesionesGuardadas, 0);
      expect(sesionRepo.idUsuarioActivo, isNull);
    });

    test('usa un mensaje genérico ante credenciales incorrectas', () async {
      final useCase = IniciarSesionUseCase(
        FakeAuthRepository(),
        FakeSesionRepository(),
      );

      await expectLater(
        useCase.ejecutar('nadie@example.com', 'Incorrecta1'),
        throwsA(
          isA<CredencialesInvalidasException>().having(
            (error) => error.mensaje,
            'mensaje',
            'Correo o contraseña incorrectos',
          ),
        ),
      );
    });
  });

  group('SesionUseCases', () {
    test('restaura la sesión cuando el usuario existe', () async {
      final authRepo = FakeAuthRepository()..usuarios.add(usuarioBase());
      final sesionRepo = FakeSesionRepository()
        ..idUsuarioActivo = 'usuario-existente';
      final useCase = RestaurarSesionUseCase(sesionRepo, authRepo);

      final usuario = await useCase.ejecutar();

      expect(usuario?.idUsuario, 'usuario-existente');
      expect(sesionRepo.sesionesCerradas, 0);
    });

    test('limpia la sesión si el usuario guardado ya no existe', () async {
      final sesionRepo = FakeSesionRepository()
        ..idUsuarioActivo = 'usuario-eliminado';
      final useCase = RestaurarSesionUseCase(sesionRepo, FakeAuthRepository());

      final usuario = await useCase.ejecutar();

      expect(usuario, isNull);
      expect(sesionRepo.idUsuarioActivo, isNull);
      expect(sesionRepo.sesionesCerradas, 1);
    });

    test('cierra la sesión', () async {
      final sesionRepo = FakeSesionRepository()..idUsuarioActivo = 'usuario-1';
      final useCase = CerrarSesionUseCase(sesionRepo);

      await useCase.ejecutar();

      expect(sesionRepo.idUsuarioActivo, isNull);
      expect(sesionRepo.sesionesCerradas, 1);
    });
  });
}
