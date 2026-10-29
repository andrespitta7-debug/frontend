import 'package:flutter/foundation.dart';
import '../../../domain/entities/personaje_partida.dart';
import '../../../domain/usecases/obtener_progreso_usecase.dart';

class ProgresoController extends ChangeNotifier {
  final ObtenerProgresoUseCase _useCase;
  ProgresoController(this._useCase);

  ProgresoUsuario? progreso;
  bool cargando = true;

  Future<void> cargar(String idUsuario) async {
    cargando = true;
    notifyListeners();
    progreso = await _useCase.ejecutar(idUsuario);
    cargando = false;
    notifyListeners();
  }
}
