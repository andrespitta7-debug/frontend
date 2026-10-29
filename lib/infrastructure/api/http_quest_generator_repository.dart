import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../domain/entities/encuentro.dart';
import '../../domain/entities/opcion_encuentro.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_completa.dart';
import '../../domain/repositories/quest_generator_repository.dart';
import '../../domain/repositories/token_repository.dart';
import 'api_exception.dart';


/// Implementación HTTP de [QuestGeneratorRepository] que se comunica
/// con la Edge Function `generar-quest` de Supabase.
class HttpQuestGeneratorRepository implements QuestGeneratorRepository {
  final String baseUrl;
  final String anonKey;
  final TokenRepository _tokenRepository;
  final http.Client _client;
  final Uuid _uuid;

  HttpQuestGeneratorRepository({
    required this.baseUrl,
    required this.anonKey,
    required TokenRepository tokenRepository,
    http.Client? httpClient,
    Uuid? uuid,
  })  : _tokenRepository = tokenRepository,
        _client = httpClient ?? http.Client(),
        _uuid = uuid ?? const Uuid();

  @override
  Future<QuestCompleta> generarQuest(String tema) async {
    final accessToken = await _tokenRepository.obtenerAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        'Tu sesión expiró. Vuelve a iniciar sesión.',
        statusCode: 401,
        codigo: 'NO_AUTORIZADO',
      );
    }

    final urlLimpia = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$urlLimpia/functions/v1/generar-quest-completa');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'apikey': anonKey,
    };

    final body = {
      'tema': tema,
      'categoria': 'libre',
      'dificultad': 'facil',
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
        'No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.',
      );
    }

    final statusCode = response.statusCode;

    // 1. Éxito: 200 OK o 201 Created
    if (statusCode == 200 || statusCode == 201) {
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> questMap =
            data['quest'] as Map<String, dynamic>;

        final questId = questMap['id'] as String;
        final quest = Quest(
          idQuest: questId,
          titulo: questMap['titulo'] as String,
          tema: questMap['tema'] as String,
          categoria: questMap['categoria'] as String,
          dificultad: questMap['dificultad'] as String,
          descripcion: questMap['descripcion'] as String,
          fuenteGeneracion: 'ia', // El dominio espera 'ia' en minúscula
        );

        final List<dynamic> encuentrosJson = questMap['encuentros'] as List<dynamic>;
        final encuentros = <Encuentro>[];
        for (final item in encuentrosJson) {
          encuentros.add(_parsearEncuentro(item as Map<String, dynamic>, questId));
        }

        final Map<String, dynamic>? poolNarrativo = data['pool_narrativo'] as Map<String, dynamic>?;

        final List<Encuentro> preguntasExtra = <Encuentro>[];
        if (data['preguntas_extra'] is List<dynamic>) {
          final List<dynamic> extrasJson = data['preguntas_extra'] as List<dynamic>;
          for (final item in extrasJson) {
            preguntasExtra.add(_parsearEncuentro(item as Map<String, dynamic>, questId));
          }
        }

        return QuestCompleta(
          quest: quest,
          encuentros: encuentros,
          poolNarrativo: poolNarrativo,
          preguntasExtra: preguntasExtra,
          semilla: (data['semilla'] as num?)?.toInt() ?? 0,
          idPartida: data['id_partida'] as String? ?? '',
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          'Error al procesar la respuesta del servidor.',
          statusCode: statusCode,
        );
      }
    }
    


    // Manejo de errores específicos según código y statusCode
    String? codigo;
    String? detalle;
    try {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      codigo = data['codigo'] as String?;
      if (data['detalle'] is String) {
        detalle = data['detalle'] as String;
      } else if (data['error'] is String) {
        detalle = data['error'] as String;
      }
    } catch (_) {}

    final mensaje = _mapearError(
      statusCode: statusCode,
      codigo: codigo,
      detalle: detalle,
    );

    throw ApiException(
      mensaje,
      statusCode: statusCode,
      codigo: codigo,
    );
  }

  @override
  Future<List<Encuentro>> generarEncuentrosExtra({
    required String idQuest,
    required String tema,
    required String categoria,
    required String dificultad,
    required int ultimoNumero,
  }) async {
    final accessToken = await _tokenRepository.obtenerAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        'Tu sesión expiró. Vuelve a iniciar sesión.',
        statusCode: 401,
        codigo: 'NO_AUTORIZADO',
      );
    }

    final urlLimpia = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$urlLimpia/functions/v1/generar-encuentros-extra');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'apikey': anonKey,
    };

    final body = {
      'id_quest': idQuest,
      'tema': tema,
      'categoria': categoria,
      'dificultad': dificultad,
      'ultimo_numero': ultimoNumero,
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
        'No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.',
      );
    }

    final statusCode = response.statusCode;

    if (statusCode == 200 || statusCode == 201) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> encuentrosJson = data['encuentros'] as List<dynamic>;
        final encuentros = <Encuentro>[];

        for (final item in encuentrosJson) {
          final encMap = item as Map<String, dynamic>;
          final encuentroId = encMap['id'] as String;

          final List<dynamic> opcionesJson = encMap['opciones'] as List<dynamic>;
          final opciones = <OpcionEncuentro>[];

          for (final opItem in opcionesJson) {
            final opMap = opItem as Map<String, dynamic>;
            final idOpcion = (opMap['id'] as String?)?.isNotEmpty == true
                ? opMap['id'] as String
                : _uuid.v4();

            opciones.add(
              OpcionEncuentro(
                idOpcion: idOpcion,
                idEncuentro: encuentroId,
                letra: opMap['letra'] as String,
                texto: opMap['texto'] as String,
                calidad: (opMap['calidad'] as num).toInt(),
              ),
            );
          }

          encuentros.add(
            Encuentro(
              idEncuentro: encuentroId,
              idQuest: idQuest,
              numero: (encMap['numero'] as num).toInt(),
              pregunta: encMap['pregunta'] as String,
              dificultad: encMap['dificultad'] as String,
              tipoEncuentro: encMap['tipo_encuentro'] as String,
              vidaEnemigo: (encMap['vida_enemigo'] as num).toInt(),
              opciones: opciones,
            ),
          );
        }

        return encuentros;
      } catch (e) {
        throw ApiException(
          'Error al procesar la respuesta del servidor.',
          statusCode: statusCode,
        );
      }
    }

    String? codigo;
    String? detalle;
    try {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      codigo = data['codigo'] as String?;
      if (data['detalle'] is String) {
        detalle = data['detalle'] as String;
      } else if (data['error'] is String) {
        detalle = data['error'] as String;
      }
    } catch (_) {}

    final mensaje = _mapearError(
      statusCode: statusCode,
      codigo: codigo,
      detalle: detalle,
    );

    throw ApiException(
      mensaje,
      statusCode: statusCode,
      codigo: codigo,
    );
  }

  String _mapearError({
    required int statusCode,
    String? codigo,
    String? detalle,
  }) {
    switch (codigo) {
      case 'IA_TIMEOUT':
        return 'La IA tardó demasiado en responder. Intenta de nuevo o prueba con un tema más específico.';
      case 'IA_NO_DISPONIBLE':
        return 'El servicio de IA no está disponible en este momento. Espera un minuto y vuelve a intentar.';
      case 'IA_JSON_INVALIDO':
        return 'La IA generó una respuesta con formato inválido. Intenta de nuevo.';
      case 'IA_ESQUEMA_INVALIDO':
        return 'La IA generó una respuesta con estructura incorrecta. Intenta de nuevo.';
      case 'IA_POOL_INVALIDO':
        return 'La narrativa generada no es válida. Intenta de nuevo.';
      case 'IA_PREGUNTAS_INVALIDAS':
        return 'Las preguntas generadas no son válidas. Intenta de nuevo o prueba con un tema más simple.';
      case 'IA_OPCIONES_DESBALANCEADAS':
        return 'Las opciones generadas están desbalanceadas. Intenta de nuevo.';
      case 'IA_ENCUENTROS_INVALIDOS':
        return 'Los encuentros generados no son válidos. Intenta de nuevo.';
      case 'ERROR_PERSISTENCIA':
        return 'Hubo un problema al guardar la quest. Intenta de nuevo.';
      case 'NO_AUTORIZADO':
        return 'Tu sesión expiró. Vuelve a iniciar sesión.';
      default:
        if (statusCode == 401) {
          return 'Tu sesión expiró. Vuelve a iniciar sesión.';
        }
        if (statusCode == 400 && detalle != null && detalle.isNotEmpty) {
          return detalle;
        }
        return 'No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.';
    }
  }

  Encuentro _parsearEncuentro(Map<String, dynamic> encMap, String questId) {
    final encuentroId = encMap['id'] as String;

    final List<dynamic> opcionesJson = encMap['opciones'] as List<dynamic>;
    final opciones = <OpcionEncuentro>[];

    for (final opItem in opcionesJson) {
      final opMap = opItem as Map<String, dynamic>;
      final idOpcion = (opMap['id'] as String?)?.isNotEmpty == true
          ? opMap['id'] as String
          : _uuid.v4();

      opciones.add(
        OpcionEncuentro(
          idOpcion: idOpcion,
          idEncuentro: encuentroId,
          letra: opMap['letra'] as String,
          texto: opMap['texto'] as String,
          calidad: (opMap['calidad'] as num).toInt(),
        ),
      );
    }

    return Encuentro(
      idEncuentro: encuentroId,
      idQuest: questId,
      numero: (encMap['numero'] as num).toInt(),
      pregunta: encMap['pregunta'] as String,
      dificultad: encMap['dificultad'] as String,
      tipoEncuentro: encMap['tipo_encuentro'] as String,
      vidaEnemigo: (encMap['vida_enemigo'] as num).toInt(),
      opciones: opciones,
    );
  }
}
