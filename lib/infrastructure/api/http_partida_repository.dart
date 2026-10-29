import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/personaje_partida.dart';
import '../../domain/repositories/partida_repository.dart';
import '../../domain/repositories/token_repository.dart';
import 'api_exception.dart';

/// Implementación HTTP de [PartidaRepository] que se comunica con las
/// Edge Functions `finalizar-partida` y `obtener-progreso` de Supabase.
class HttpPartidaRepository implements PartidaRepository {
  final String baseUrl;
  final String anonKey;
  final TokenRepository tokenRepository;
  final http.Client _client;

  HttpPartidaRepository({
    required this.baseUrl,
    required this.anonKey,
    required this.tokenRepository,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  @override
  Future<void> guardarPartida(Partida partida) async {
    final accessToken = await tokenRepository.obtenerAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        'Tu sesión expiró, vuelve a iniciar sesión.',
        statusCode: 401,
      );
    }

    final urlLimpia = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$urlLimpia/functions/v1/finalizar-partida');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'apikey': anonKey,
    };

    final body = {
      'id_partida': partida.idPartida,
      'id_quest': partida.idQuest,
      'estado': partida.estado,
      'encuentro_actual': partida.encuentroActual,
      'enemigos_derrotados': partida.enemigosDerrotados,
      'racha_maxima': partida.rachaMaxima,
      'rondas_temerarias': partida.rondasTemerarias,
      'tiempo_segundos': partida.tiempoSegundos,
      'vida_jugador_actual': partida.vidaJugador,
      'vida_enemigo_actual': null,
    };

    final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const ApiException(
        'No se pudo conectar al servidor, revisa tu conexión.',
      );
    }

    final statusCode = response.statusCode;

    // 1. Éxito: 200 OK o 201 Created
    if (statusCode == 200 || statusCode == 201) {
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (data['resumen'] is Map) {
          final resumen = data['resumen'] as Map<String, dynamic>;
          partida.score =
              (resumen['score_total'] as num?)?.toInt() ?? partida.score;
          partida.xpObtenida =
              (resumen['xp_obtenida'] as num?)?.toInt() ?? partida.xpObtenida;
        }
      } catch (_) {}
      return;
    }

    // 2. Sesión expirada: 401
    if (statusCode == 401) {
      throw const ApiException(
        'Tu sesión expiró, vuelve a iniciar sesión.',
        statusCode: 401,
      );
    }

    // 3. Error en datos de entrada: 400
    if (statusCode == 400) {
      String mensaje = 'Datos de solicitud inválidos.';
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (data['detalle'] is String) {
          mensaje = data['detalle'] as String;
        } else if (data['error'] is String) {
          mensaje = data['error'] as String;
        }
      } catch (_) {}
      throw ApiException(mensaje, statusCode: 400);
    }

    // 4. Errores del servidor: >= 500
    if (statusCode >= 500) {
      throw ApiException(
        'Error del servidor, intenta de nuevo.',
        statusCode: statusCode,
      );
    }

    // 5. Otros códigos no esperados
    throw ApiException(
      'Error inesperado del servidor.',
      statusCode: statusCode,
    );
  }

  @override
  Future<ProgresoUsuario?> obtenerProgreso(String idUsuario) async {
    // El idUsuario del puerto no se envía en el cuerpo ya que
    // la Edge Function lo extrae directamente del JWT autenticado.
    final accessToken = await tokenRepository.obtenerAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        'Tu sesión expiró, vuelve a iniciar sesión.',
        statusCode: 401,
      );
    }

    final urlLimpia = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$urlLimpia/functions/v1/obtener-progreso');

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

    // 1. Éxito: 200 OK
    if (statusCode == 200 || statusCode == 201) {
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final progresoMap = data['progreso'] as Map<String, dynamic>?;
        if (progresoMap == null) return null;

        return ProgresoUsuario(
          idUsuario: idUsuario,
          nivel: (progresoMap['nivel'] as num?)?.toInt() ?? 1,
          xpTotal: (progresoMap['xp_total'] as num?)?.toInt() ?? 0,
          questsCompletadas:
              (progresoMap['quests_completadas'] as num?)?.toInt() ?? 0,
          victorias: (progresoMap['victorias'] as num?)?.toInt() ?? 0,
          derrotas: (progresoMap['derrotas'] as num?)?.toInt() ?? 0,
          partidasJugadas:
              (progresoMap['partidas_jugadas'] as num?)?.toInt() ?? 0,
        );
      } catch (_) {
        throw ApiException(
          'Error al procesar la respuesta del servidor.',
          statusCode: statusCode,
        );
      }
    }

    // 2. Progreso no encontrado: 404
    if (statusCode == 404) {
      return null;
    }

    // 3. Sesión expirada: 401
    if (statusCode == 401) {
      throw const ApiException(
        'Tu sesión expiró, vuelve a iniciar sesión.',
        statusCode: 401,
      );
    }

    // 4. Error en datos de entrada: 400
    if (statusCode == 400) {
      String mensaje = 'Datos de solicitud inválidos.';
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (data['detalle'] is String) {
          mensaje = data['detalle'] as String;
        } else if (data['error'] is String) {
          mensaje = data['error'] as String;
        }
      } catch (_) {}
      throw ApiException(mensaje, statusCode: 400);
    }

    // 5. Errores del servidor: >= 500
    if (statusCode >= 500) {
      throw ApiException(
        'Error del servidor, intenta de nuevo.',
        statusCode: statusCode,
      );
    }

    // 6. Otros códigos no esperados
    throw ApiException(
      'Error inesperado del servidor.',
      statusCode: statusCode,
    );
  }

  @override
  Future<void> actualizarProgreso(ProgresoUsuario progreso) async {
    throw UnimplementedError(
      'actualizarProgreso aún no está implementado en HttpPartidaRepository.',
    );
  }
}
