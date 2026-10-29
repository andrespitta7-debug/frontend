import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/encuentro.dart';
import '../../domain/entities/opcion_encuentro.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_completa.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/repositories/token_repository.dart';
import 'api_exception.dart';

/// Implementación HTTP de [QuestRepository] que se comunica con la
/// Edge Function `obtener-quest-completa` de Supabase.
class HttpQuestRepository implements QuestRepository {
  final String baseUrl;
  final String anonKey;
  final TokenRepository tokenRepository;
  final http.Client _client;

  HttpQuestRepository({
    required this.baseUrl,
    required this.anonKey,
    required this.tokenRepository,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  /// Realiza la llamada HTTP a la Edge Function `obtener-quest-completa`.
  /// Devuelve el mapa `quest` si existe, o `null` si la quest no fue encontrada (404).
  Future<Map<String, dynamic>?> _obtenerQuestJson(String idQuest) async {
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
    final uri = Uri.parse('$urlLimpia/functions/v1/obtener-quest-completa');

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
        body: jsonEncode({'id_quest': idQuest}),
      );
      if (kDebugMode) {
        debugPrint('[HttpQuestRepository] POST $uri');
        debugPrint(
          '[HttpQuestRepository] Body: ${jsonEncode({'id_quest': idQuest})}',
        );
        debugPrint('[HttpQuestRepository] Status: ${response.statusCode}');
        debugPrint('[HttpQuestRepository] Response body: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HttpQuestRepository] EXCEPCIÓN en fetch: $e');
      }
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
        return data['quest'] as Map<String, dynamic>?;
      } catch (_) {
        throw ApiException(
          'Error al procesar la respuesta del servidor.',
          statusCode: statusCode,
        );
      }
    }

    // 2. Quest no encontrada: 404
    if (statusCode == 404) {
      return null;
    }

    // 3. Sesión expirada o no autorizada: 401
    if (statusCode == 401) {
      throw const ApiException(
        'Tu sesión expiró, vuelve a iniciar sesión.',
        statusCode: 401,
      );
    }

    // 4. Parámetros inválidos: 400
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
  Future<Quest?> obtenerQuestPorId(String idQuest) async {
    if (kDebugMode) {
      debugPrint('[HttpQuestRepository] obtenerQuestPorId($idQuest)');
    }
    final questMap = await _obtenerQuestJson(idQuest);
    if (questMap == null) return null;

    return Quest(
      idQuest: questMap['id'] as String? ?? idQuest,
      titulo: questMap['titulo'] as String? ?? '',
      tema: questMap['tema'] as String? ?? '',
      categoria: questMap['categoria'] as String? ?? '',
      dificultad: questMap['dificultad'] as String? ?? 'facil',
      descripcion: questMap['descripcion'] as String? ?? '',
      fuenteGeneracion:
          (questMap['fuente_generacion'] as String?)?.toLowerCase() ?? 'manual',
    );
  }

  @override
  Future<List<Encuentro>> obtenerEncuentros(String idQuest) async {
    if (kDebugMode) {
      debugPrint('[HttpQuestRepository] obtenerEncuentros($idQuest)');
    }
    final questMap = await _obtenerQuestJson(idQuest);
    if (questMap == null) return [];

    final encuentrosJson = questMap['encuentros'] as List<dynamic>? ?? [];
    final List<Encuentro> encuentros = [];

    for (final item in encuentrosJson) {
      final encMap = item as Map<String, dynamic>;
      final idEncuentro = encMap['id'] as String;

      final opcionesJson = encMap['opciones'] as List<dynamic>? ?? [];
      final List<OpcionEncuentro> opciones = [];

      for (final opItem in opcionesJson) {
        final opMap = opItem as Map<String, dynamic>;
        opciones.add(
          OpcionEncuentro(
            idOpcion: opMap['id'] as String,
            idEncuentro: idEncuentro,
            letra: opMap['letra'] as String,
            texto: opMap['texto'] as String,
            calidad: (opMap['calidad'] as num).toInt(),
          ),
        );
      }

      encuentros.add(
        Encuentro(
          idEncuentro: idEncuentro,
          idQuest: questMap['id'] as String? ?? idQuest,
          numero: (encMap['numero'] as num).toInt(),
          pregunta: encMap['pregunta'] as String,
          dificultad: encMap['dificultad'] as String? ?? 'facil',
          tipoEncuentro: encMap['tipo_encuentro'] as String? ?? 'normal',
          vidaEnemigo: (encMap['vida_enemigo'] as num).toInt(),
          opciones: opciones,
        ),
      );
    }

    return encuentros;
  }

  @override
  Future<void> guardarQuest(Quest quest) async {
    throw UnimplementedError('No se usa en modo remoto');
  }

  @override
  Future<void> guardarQuestCompleta(QuestCompleta quest) async {
    throw UnimplementedError('No se usa en modo remoto');
  }
}
