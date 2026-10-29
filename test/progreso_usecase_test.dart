import 'package:flutter_test/flutter_test.dart';
import 'package:sysquest_app/domain/entities/opcion_encuentro.dart';
import 'package:sysquest_app/domain/entities/personaje_partida.dart';
import 'package:sysquest_app/domain/repositories/partida_repository.dart';
import 'package:sysquest_app/domain/usecases/finalizar_partida_usecase.dart';
import 'package:sysquest_app/domain/usecases/responder_encuentro_usecase.dart';

class FakePartidaRepository implements PartidaRepository {
  ProgresoUsuario? progreso;
  Partida? partidaGuardada;

  @override
  Future<void> guardarPartida(Partida partida) async {
    partidaGuardada = partida;
  }

  @override
  Future<ProgresoUsuario?> obtenerProgreso(String idUsuario) async {
    progreso ??= ProgresoUsuario(idUsuario: idUsuario);
    return progreso;
  }

  @override
  Future<void> actualizarProgreso(ProgresoUsuario progresoActualizado) async {
    progreso = progresoActualizado;
  }
}

void main() {
  group('FinalizarPartidaUseCase', () {
    test('actualiza el progreso correctamente al ganar una partida', () async {
      final repo = FakePartidaRepository();
      final useCase = FinalizarPartidaUseCase(repo);

      final partida = Partida(
        idPartida: 'partida-01',
        idUsuario: 'usuario-01',
        idQuest: 'quest-001',
      );

      await useCase.ejecutar(partida: partida, gano: true);

      expect(repo.progreso, isNotNull);
      expect(repo.progreso!.victorias, 1);
      expect(repo.progreso!.questsCompletadas, 1);
      expect(repo.progreso!.partidasJugadas, 1);
      expect(repo.progreso!.xpTotal, FinalizarPartidaUseCase.xpPorVictoria);
      expect(repo.progreso!.nivel, 1);
      expect(partida.estado, 'ganada');
    });

    test('actualiza el progreso correctamente al perder una partida', () async {
      final repo = FakePartidaRepository();
      final useCase = FinalizarPartidaUseCase(repo);

      final partida = Partida(
        idPartida: 'partida-02',
        idUsuario: 'usuario-02',
        idQuest: 'quest-001',
      );

      await useCase.ejecutar(partida: partida, gano: false);

      expect(repo.progreso, isNotNull);
      expect(repo.progreso!.derrotas, 1);
      expect(repo.progreso!.partidasJugadas, 1);
      expect(repo.progreso!.xpTotal, FinalizarPartidaUseCase.xpPorDerrota);
      expect(repo.progreso!.nivel, 1);
      expect(partida.estado, 'perdida');
    });
  });

  group('ResponderEncuentroUseCase', () {
    test(
      'una respuesta crítica inflige más daño que una correcta y una incorrecta',
      () {
        final useCase = ResponderEncuentroUseCase();

        final opcionCritica = OpcionEncuentro(
          idOpcion: 'op-critica',
          idEncuentro: 'enc-01',
          letra: 'A',
          texto: 'Respuesta crítica',
          calidad: 2,
        );

        final opcionCorrecta = OpcionEncuentro(
          idOpcion: 'op-correcta',
          idEncuentro: 'enc-01',
          letra: 'B',
          texto: 'Respuesta correcta',
          calidad: 1,
        );

        final opcionIncorrecta = OpcionEncuentro(
          idOpcion: 'op-incorrecta',
          idEncuentro: 'enc-01',
          letra: 'C',
          texto: 'Respuesta mala',
          calidad: 0,
        );

        final critica = useCase.ejecutar(opcionCritica);
        final correcta = useCase.ejecutar(opcionCorrecta);
        final incorrecta = useCase.ejecutar(opcionIncorrecta);

        expect(critica.resultado, ResultadoTurno.critico);
        expect(correcta.resultado, ResultadoTurno.acierto);
        expect(incorrecta.resultado, ResultadoTurno.fallo);
        expect(critica.danoAlEnemigo, greaterThan(correcta.danoAlEnemigo));
        expect(incorrecta.danoAlJugador, greaterThan(0));
      },
    );

    test('un jefe puede hacer más daño al jugador cuando falla', () {
      final useCase = ResponderEncuentroUseCase();
      final opcionIncorrecta = OpcionEncuentro(
        idOpcion: 'op-mala',
        idEncuentro: 'enc-jefe',
        letra: 'D',
        texto: 'Respuesta mala',
        calidad: 0,
      );

      final resultado = useCase.ejecutar(opcionIncorrecta, esJefe: true);

      expect(resultado.resultado, ResultadoTurno.fallo);
      expect(
        resultado.danoAlJugador,
        greaterThan(ResponderEncuentroUseCase.danoBaseContraataque),
      );
    });
  });
}
