import 'package:uuid/uuid.dart';

import '../../../domain/entities/usuario.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/password_hasher.dart';
import 'database_helper.dart';

class SqliteAuthRepository implements AuthRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();
  SqliteAuthRepository(this._dbHelper);

  @override
  Future<Usuario?> obtenerPorId(String idUsuario) async {
    final db = await _dbHelper.database;
    final filas = await db.query(
      'usuario',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
    );
    if (filas.isEmpty) return null;
    final r = filas.first;
    return Usuario(
      idUsuario: r['id_usuario'] as String,
      email: r['email'] as String,
      nombreUsuario: r['nombre_usuario'] as String,
      nombre: r['nombre'] as String? ?? '',
      apellido: r['apellido'] as String? ?? '',
    );
  }

  @override
  Future<bool> existeEmail(String email) async {
    final db = await _dbHelper.database;
    final filas = await db.query(
      'usuario',
      where: 'lower(email) = ?',
      whereArgs: [email.toLowerCase()],
    );
    return filas.isNotEmpty;
  }

  @override
  Future<bool> existeNombreUsuario(String nombreUsuario) async {
    final db = await _dbHelper.database;
    final filas = await db.query(
      'usuario',
      where: 'nombre_usuario = ?',
      whereArgs: [nombreUsuario],
    );
    return filas.isNotEmpty;
  }

  @override
  Future<bool> existeNombreUsuarioExcepto(
    String nombreUsuario,
    String idUsuario,
  ) async {
    final db = await _dbHelper.database;
    final filas = await db.query(
      'usuario',
      where: 'nombre_usuario = ? AND id_usuario != ?',
      whereArgs: [nombreUsuario, idUsuario],
    );
    return filas.isNotEmpty;
  }

  @override
  Future<void> actualizar(Usuario usuario) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      '''
      UPDATE usuario
      SET nombre = ?, apellido = ?, nombre_usuario = ?,
          updated_at = CURRENT_TIMESTAMP
      WHERE id_usuario = ?
      ''',
      [
        usuario.nombre,
        usuario.apellido,
        usuario.nombreUsuario,
        usuario.idUsuario,
      ],
    );
  }

  @override
  Future<Usuario> registrar({
    required String email,
    required String nombreUsuario,
    required String nombre,
    required String apellido,
    required String passwordPlano,
  }) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final passwordHash = PasswordHasher.hash(passwordPlano);

    await db.transaction((txn) async {
      await txn.insert('usuario', {
        'id_usuario': id,
        'email': email,
        'nombre_usuario': nombreUsuario,
        'password_hash': passwordHash,
        'nombre': nombre,
        'apellido': apellido,
      });

      await txn.insert('progreso_usuario', {
        'id_progreso': _uuid.v4(),
        'id_usuario': id,
      });
    });

    return Usuario(
      idUsuario: id,
      email: email,
      nombreUsuario: nombreUsuario,
      nombre: nombre,
      apellido: apellido,
    );
  }

  @override
  Future<Usuario?> autenticar(String emailOUsuario, String passwordPlano) async {
    final db = await _dbHelper.database;
    final passwordHash = PasswordHasher.hash(passwordPlano);
    final valor = emailOUsuario.trim().toLowerCase();
    final filas = await db.query(
      'usuario',
      where: '(lower(email) = ? OR lower(nombre_usuario) = ?) AND password_hash = ?',
      whereArgs: [valor, valor, passwordHash],
    );
    if (filas.isEmpty) return null;
    final r = filas.first;
    return Usuario(
      idUsuario: r['id_usuario'] as String,
      email: r['email'] as String,
      nombreUsuario: r['nombre_usuario'] as String,
      nombre: r['nombre'] as String? ?? '',
      apellido: r['apellido'] as String? ?? '',
    );
  }

  @override
  Future<void> cambiarPassword(String idUsuario, String nuevoPasswordPlano) async {
    final db = await _dbHelper.database;
    final nuevoHash = PasswordHasher.hash(nuevoPasswordPlano);
    await db.rawUpdate(
      '''
      UPDATE usuario
      SET password_hash = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id_usuario = ?
      ''',
      [nuevoHash, idUsuario],
    );
  }

  @override
  Future<void> eliminarCuenta(String idUsuario) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'personaje',
        where: 'id_usuario = ?',
        whereArgs: [idUsuario],
      );
      await txn.delete(
        'progreso_usuario',
        where: 'id_usuario = ?',
        whereArgs: [idUsuario],
      );
      await txn.delete(
        'partida',
        where: 'id_usuario = ?',
        whereArgs: [idUsuario],
      );
      await txn.delete(
        'usuario',
        where: 'id_usuario = ?',
        whereArgs: [idUsuario],
      );
    });
  }
}
