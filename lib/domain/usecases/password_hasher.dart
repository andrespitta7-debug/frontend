import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Vive en domain porque es una regla ("cómo se protege una contraseña"),
/// no un detalle de SQLite ni de Supabase. Ambos adaptadores la reutilizan igual.
class PasswordHasher {
  static String hash(String passwordPlano) {
    final bytes = utf8.encode(passwordPlano);
    return sha256.convert(bytes).toString();
  }
}
