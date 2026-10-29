import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/usuario.dart';
import 'api_exception.dart';

/// Datos del progreso del jugador devueltos por la API.
class ProgresoApi {
  final int nivel;
  final int xpTotal;
  final int questsCompletadas;
  final int victorias;
  final int derrotas;
  final int partidasJugadas;

  const ProgresoApi({
    required this.nivel,
    required this.xpTotal,
    required this.questsCompletadas,
    required this.victorias,
    required this.derrotas,
    required this.partidasJugadas,
  });

  factory ProgresoApi.fromJson(Map<String, dynamic> json) {
    return ProgresoApi(
      nivel: json['nivel'] as int? ?? 1,
      xpTotal: json['xp_total'] as int? ?? 0,
      questsCompletadas: json['quests_completadas'] as int? ?? 0,
      victorias: json['victorias'] as int? ?? 0,
      derrotas: json['derrotas'] as int? ?? 0,
      partidasJugadas: json['partidas_jugadas'] as int? ?? 0,
    );
  }
}

/// Resultado exitoso de autenticación (registro o login).
class AuthApiResult {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final Usuario usuario;
  final ProgresoApi progreso;

  const AuthApiResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.usuario,
    required this.progreso,
  });

  factory AuthApiResult.fromJson(Map<String, dynamic> json) {
    final usuarioMap = json['usuario'] as Map<String, dynamic>? ?? {};
    final progresoMap = json['progreso'] as Map<String, dynamic>? ?? {};

    return AuthApiResult(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: json['expires_in'] as int? ?? 0,
      usuario: Usuario(
        idUsuario: usuarioMap['id'] as String? ?? '',
        email: usuarioMap['email'] as String? ?? '',
        nombreUsuario: usuarioMap['nombre_usuario'] as String? ?? '',
        nombre: usuarioMap['nombre'] as String? ?? '',
        apellido: usuarioMap['apellido'] as String? ?? '',
      ),
      progreso: ProgresoApi.fromJson(progresoMap),
    );
  }
}

/// Cliente HTTP para comunicarse con las Edge Functions de autenticación en Supabase.
class AuthApiClient {
  final String baseUrl;
  final String anonKey;
  final http.Client _client;

  AuthApiClient({
    required this.baseUrl,
    required this.anonKey,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  /// Registra un nuevo usuario en la Edge Function `register`.
  Future<AuthApiResult> registrar({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String nombreUsuario,
  }) async {
    return _post(
      '/functions/v1/register',
      {
        'email': email,
        'password': password,
        'nombre': nombre,
        'apellido': apellido,
        'nombre_usuario': nombreUsuario,
      },
    );
  }

  /// Inicia sesión de un usuario existente en la Edge Function `login`.
  Future<AuthApiResult> login({
    required String email,
    required String password,
  }) async {
    return _post(
      '/functions/v1/login',
      {
        'email': email,
        'password': password,
      },
    );
  }

  /// Obtiene los datos del usuario autenticado actual llamando a la Edge Function `obtener-usuario-actual`.
  Future<Usuario> obtenerUsuarioActual(String accessToken) async {
    final urlLimpia = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$urlLimpia/functions/v1/obtener-usuario-actual');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'apikey': anonKey,
    };

    final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode({}),
      );
    } catch (_) {
      throw const ApiException(
        'No se pudo conectar al servidor, revisa tu conexión.',
      );
    }

    final statusCode = response.statusCode;

    if (statusCode == 200) {
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final usuarioMap = data['usuario'] as Map<String, dynamic>? ?? {};
        return Usuario(
          idUsuario: usuarioMap['id'] as String? ?? '',
          email: usuarioMap['email'] as String? ?? '',
          nombreUsuario: usuarioMap['nombre_usuario'] as String? ?? '',
          nombre: usuarioMap['nombre'] as String? ?? '',
          apellido: usuarioMap['apellido'] as String? ?? '',
        );
      } catch (_) {
        throw ApiException(
          'Error al procesar la respuesta del servidor.',
          statusCode: statusCode,
        );
      }
    }

    if (statusCode == 401) {
      throw const ApiException(
        'Tu sesión expiró, vuelve a iniciar sesión.',
        statusCode: 401,
      );
    }

    if (statusCode >= 500) {
      throw ApiException(
        'Error del servidor, intenta de nuevo.',
        statusCode: statusCode,
      );
    }

    String mensaje = 'Error en la solicitud.';
    try {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (data['error'] is String) {
        mensaje = data['error'] as String;
      }
    } catch (_) {}
    throw ApiException(mensaje, statusCode: statusCode);
  }

  Future<AuthApiResult> _post(String endpoint, Map<String, dynamic> body) async {
    final urlLimpia = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$urlLimpia$endpoint');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $anonKey',
    };

    final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      throw const ApiException(
        'No se pudo conectar al servidor, revisa tu conexión.',
      );
    }

    final statusCode = response.statusCode;

    // 4. Éxito: 200 OK o 201 Created
    if (statusCode == 200 || statusCode == 201) {
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return AuthApiResult.fromJson(data);
      } catch (_) {
        throw ApiException(
          'Error al procesar la respuesta del servidor.',
          statusCode: statusCode,
        );
      }
    }

    // 5. Errores de cliente conocidos: 400, 401, 405, 409
    if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 405 ||
        statusCode == 409) {
      String mensaje = 'Error en la solicitud.';
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (data['error'] is String) {
          mensaje = data['error'] as String;
        }
      } catch (_) {
        // En caso de que el cuerpo no sea JSON válido
      }
      throw ApiException(mensaje, statusCode: statusCode);
    }

    // 6. Errores del servidor: >= 500
    if (statusCode >= 500) {
      throw ApiException(
        'Error del servidor, intenta de nuevo.',
        statusCode: statusCode,
      );
    }

    // Otros códigos no esperados
    throw ApiException(
      'Error inesperado del servidor.',
      statusCode: statusCode,
    );
  }
}
