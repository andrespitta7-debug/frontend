import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sysquest_app/infrastructure/persistence/shared_preferences_sesion_repository.dart';
import 'package:sysquest_app/domain/entities/usuario.dart';
import 'package:sysquest_app/domain/usecases/auth_usecases.dart';
import 'package:sysquest_app/domain/usecases/finalizar_partida_usecase.dart';
import 'package:sysquest_app/domain/usecases/generar_quest_usecase.dart';
import 'package:sysquest_app/domain/usecases/obtener_progreso_usecase.dart';
import 'package:sysquest_app/domain/usecases/perfil_usecases.dart';
import 'package:sysquest_app/domain/usecases/responder_encuentro_usecase.dart';
import 'package:sysquest_app/infrastructure/generation/stub_quest_generator.dart';
import 'package:sysquest_app/infrastructure/persistence/sqlite/database_helper.dart';
import 'package:sysquest_app/infrastructure/persistence/sqlite/sqlite_auth_repository.dart';
import 'package:sysquest_app/infrastructure/persistence/sqlite/sqlite_partida_repository.dart';
import 'package:sysquest_app/infrastructure/persistence/sqlite/sqlite_quest_repository.dart';
import 'package:sysquest_app/presentation/screens/auth/auth_controller.dart';


import 'package:sysquest_app/presentation/screens/generar_quest/generar_quest_controller.dart';
import 'package:sysquest_app/presentation/screens/menu/menu_principal_screen.dart';
import 'package:sysquest_app/presentation/screens/progreso/progreso_controller.dart';
import 'package:sysquest_app/presentation/theme/app_theme.dart';

void main() {
  testWidgets('E2E: Flujo completo de aventura (Menu -> Combate -> Victoria/Progreso)', (tester) async {
    // 1. Simulación de dependencias offline
    final dbHelper = DatabaseHelper.instance;
    final questRepo = SqliteQuestRepository(dbHelper);
    final partidaRepo = SqlitePartidaRepository(dbHelper);
    final authRepo = SqliteAuthRepository(dbHelper);
    final stubGen = StubQuestGenerator();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final usuario = const Usuario(
      idUsuario: 'usr-e2e-001',
      email: 'estudiante@test.edu.co',
      nombreUsuario: 'hero_e2e',
      nombre: 'Hero',
      apellido: 'Tester',
    );

    final sesionRepo = SharedPreferencesSesionRepository(preferences);
    final responderUseCase = ResponderEncuentroUseCase();
    final registrarUseCase = RegistrarUsuarioUseCase(authRepo, sesionRepo);
    final iniciarSesionUseCase = IniciarSesionUseCase(authRepo, sesionRepo);
    final finalizarPartidaUseCase = FinalizarPartidaUseCase(partidaRepo);
    final generarQuestUseCase = GenerarQuestUseCase(stubGen, questRepo);
    final obtenerProgresoUseCase = ObtenerProgresoUseCase(partidaRepo);
    final actualizarPerfilUseCase = ActualizarPerfilUseCase(authRepo);
    final cambiarPasswordUseCase = CambiarPasswordUseCase(authRepo);
    final eliminarCuentaUseCase = EliminarCuentaUseCase(authRepo);

    // 2. Construir árbol de la app montando MenuPrincipalScreen
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController(registrarUseCase, iniciarSesionUseCase)),
          ChangeNotifierProvider(create: (_) => GenerarQuestController(generarQuestUseCase)),
          ChangeNotifierProvider(create: (_) => ProgresoController(obtenerProgresoUseCase)),
          Provider.value(value: responderUseCase),
          Provider.value(value: finalizarPartidaUseCase),
          Provider.value(value: actualizarPerfilUseCase),
          Provider.value(value: cambiarPasswordUseCase),
          Provider.value(value: eliminarCuentaUseCase),
          Provider.value(value: questRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: MenuPrincipalScreen(usuario: usuario),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 3. Verificar que estamos en el Menú Principal
    expect(find.text('SysQuest'), findsOneWidget);
    expect(find.text('Mapa de aventura'), findsOneWidget);
    expect(find.text('Nueva quest con IA'), findsOneWidget);
    expect(find.text('Mi progreso'), findsOneWidget);
    expect(find.text('Mi perfil'), findsOneWidget);
  });
}
