import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import '../../../infrastructure/api/api_exception.dart';

/// Estado inmutable de la invocación y reintentos con backoff exponencial.
class QuestRetryState {
  final int attempt;
  final int secondsUntilNextRetry;
  final bool isGenerating;
  final String? errorMessage;
  final bool isCancelled;

  const QuestRetryState({
    this.attempt = 0,
    this.secondsUntilNextRetry = 0,
    this.isGenerating = false,
    this.errorMessage,
    this.isCancelled = false,
  });

  QuestRetryState copyWith({
    int? attempt,
    int? secondsUntilNextRetry,
    bool? isGenerating,
    String? errorMessage,
    bool? isCancelled,
  }) {
    return QuestRetryState(
      attempt: attempt ?? this.attempt,
      secondsUntilNextRetry: secondsUntilNextRetry ?? this.secondsUntilNextRetry,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: errorMessage ?? this.errorMessage,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}

/// Controlador para auto-reintentos con backoff exponencial en la generación de quests.
class QuestGenerationRetryController extends ValueNotifier<QuestRetryState> {
  QuestGenerationRetryController() : super(const QuestRetryState());

  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  Completer<void>? _esperaCompleter;

  /// Cancela la invocación activa y cualquier cuenta regresiva en curso.
  void cancelarInvocacion() {
    _isCancelled = true;
    if (_esperaCompleter != null && !_esperaCompleter!.isCompleted) {
      _esperaCompleter!.complete();
    }
    _esperaCompleter = null;
    value = value.copyWith(
      isCancelled: true,
      isGenerating: false,
      secondsUntilNextRetry: 0,
    );
  }

  /// Reinicia el estado del controlador para una nueva invocación.
  void reiniciar() {
    _isCancelled = false;
    _esperaCompleter = null;
    value = const QuestRetryState();
  }

  /// Ejecuta [executeUseCase] con auto-reintento y backoff exponencial ante errores de IA.
  /// Devuelve el resultado si es exitoso, o `null` si fue cancelado o falla de forma fatal.
  Future<T?> generarQuestConReintentos<T>({
    required Future<T?> Function() executeUseCase,
  }) async {
    _isCancelled = false;
    int intento = 0;

    while (!_isCancelled) {
      try {
        value = value.copyWith(
          attempt: intento + 1,
          isGenerating: true,
          secondsUntilNextRetry: 0,
          errorMessage: null,
          isCancelled: false,
        );

        final result = await executeUseCase();
        if (_isCancelled) return null;

        value = value.copyWith(
          isGenerating: false,
          secondsUntilNextRetry: 0,
        );
        return result;
      } catch (e) {
        if (_isCancelled) return null;

        if (_esErrorIA(e)) {
          intento++;
          // Tiempo exponencial: math.min(math.pow(2, intento), 30) segundos
          final int segundosEspera =
              math.min(math.pow(2, intento).toInt(), 30);

          value = value.copyWith(
            attempt: intento,
            isGenerating: false,
            secondsUntilNextRetry: segundosEspera,
            errorMessage: e is ApiException ? e.mensaje : e.toString(),
          );

          // Cuenta regresiva segundo a segundo
          for (int s = segundosEspera; s > 0; s--) {
            if (_isCancelled) return null;
            value = value.copyWith(secondsUntilNextRetry: s);

            _esperaCompleter = Completer<void>();
            await Future.any([
              Future.delayed(const Duration(seconds: 1)),
              _esperaCompleter!.future,
            ]);
            _esperaCompleter = null;

            if (_isCancelled) return null;
          }

          value = value.copyWith(secondsUntilNextRetry: 0);
        } else {
          // Error no recuperable con backoff
          value = value.copyWith(
            isGenerating: false,
            errorMessage: e is ApiException ? e.mensaje : e.toString(),
          );
          rethrow;
        }
      }
    }

    return null;
  }

  /// Determina si una excepción corresponde a un fallo de IA recuperable (Rate Limit o Timeout).
  bool _esErrorIA(Object error) {
    if (error is ApiException) {
      final codigo = error.codigo;
      if (codigo == 'IA_NO_DISPONIBLE' ||
          codigo == 'IA_TIMEOUT' ||
          codigo == 'RATE_LIMIT' ||
          codigo == 'IA_RATE_LIMIT' ||
          codigo == 'ERROR_PERSISTENCIA') {
        return true;
      }
      if (error.statusCode == 429 ||
          error.statusCode == 503 ||
          error.statusCode == 504) {
        return true;
      }
      if (codigo != null &&
          codigo.startsWith('IA_') &&
          codigo != 'IA_JSON_INVALIDO') {
        return true;
      }
    }
    final msg = error.toString().toUpperCase();
    return msg.contains('IA_NO_DISPONIBLE') ||
        msg.contains('IA_TIMEOUT') ||
        msg.contains('RATE_LIMIT') ||
        msg.contains('429');
  }
}

