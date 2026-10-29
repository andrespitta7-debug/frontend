import 'package:flutter/foundation.dart';

import '../../../domain/entities/quest_completa.dart';
import '../../../domain/usecases/generar_quest_usecase.dart';
import '../../../infrastructure/api/api_exception.dart';

enum GenerarQuestEstado { inicial, generando, exito, error }

class GenerarQuestController extends ChangeNotifier {
  final GenerarQuestUseCase _useCase;
  int _peticionActual = 0;

  GenerarQuestController(this._useCase);

  GenerarQuestEstado estado = GenerarQuestEstado.inicial;
  QuestCompleta? questGenerada;
  String? mensajeError;
  String? codigoError;

  bool get esErrorReintentable =>
      codigoError == 'IA_TIMEOUT' ||
      codigoError == 'IA_NO_DISPONIBLE' ||
      codigoError == 'ERROR_PERSISTENCIA';

  bool get puedeUsarFallback =>
      codigoError != null &&
      codigoError!.startsWith('IA_');

  String questSemillaAleatoria() {
    const semillas = [
      '00000000-0000-0000-0000-000000000001', // Programación Básica
      '00000000-0000-0000-0000-000000000002', // Matemáticas Básicas
      '00000000-0000-0000-0000-000000000003', // Historia Universal
    ];
    return semillas[DateTime.now().millisecond % semillas.length];
  }

  void cancelar() {
    _peticionActual++;
    estado = GenerarQuestEstado.inicial;
    mensajeError = null;
    codigoError = null;
    notifyListeners();
  }

  Future<void> generar(String tema) async {
    final peticionId = ++_peticionActual;
    estado = GenerarQuestEstado.generando;
    questGenerada = null;
    mensajeError = null;
    codigoError = null;
    notifyListeners();

    try {
      final res = await _useCase.ejecutar(tema);
      if (_peticionActual != peticionId) return;
      questGenerada = res;
      estado = GenerarQuestEstado.exito;
    } on QuestInvalidaException catch (error) {
      if (_peticionActual != peticionId) return;
      mensajeError = error.mensaje;
      codigoError = null;
      estado = GenerarQuestEstado.error;
    } on ApiException catch (error) {
      if (_peticionActual != peticionId) return;
      if (kDebugMode) {
        debugPrint('[GenerarQuest] Error: ${error.codigo} - ${error.mensaje}');
      }
      mensajeError = error.mensaje;
      codigoError = error.codigo;
      estado = GenerarQuestEstado.error;
    } catch (e) {
      if (_peticionActual != peticionId) return;
      if (kDebugMode) {
        debugPrint('[GenerarQuest] Error inesperado: $e');
      }
      mensajeError =
          'No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.';
      codigoError = null;
      estado = GenerarQuestEstado.error;
    }

    notifyListeners();
  }
}
