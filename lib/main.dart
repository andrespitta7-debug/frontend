import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/entities/usuario.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/partida_repository.dart';
import 'domain/repositories/quest_generator_repository.dart';
import 'domain/repositories/quest_repository.dart';
import 'domain/repositories/token_repository.dart';
import 'domain/usecases/auth_usecases.dart';
import 'domain/usecases/finalizar_partida_usecase.dart';
import 'domain/usecases/generar_encuentros_extra_usecase.dart';
import 'domain/usecases/generar_quest_usecase.dart';
import 'domain/usecases/obtener_progreso_usecase.dart';
import 'domain/usecases/perfil_usecases.dart';
import 'domain/usecases/responder_encuentro_usecase.dart';
import 'infrastructure/api/auth_api_client.dart';
import 'infrastructure/api/http_auth_repository.dart';
import 'infrastructure/api/http_partida_repository.dart';
import 'infrastructure/api/http_quest_generator_repository.dart';
import 'infrastructure/api/http_quest_repository.dart';
import 'infrastructure/generation/stub_quest_generator.dart';
import 'infrastructure/persistence/secure_token_repository.dart';
import 'infrastructure/persistence/shared_preferences_sesion_repository.dart';
import 'infrastructure/persistence/sqlite/database_helper.dart';
import 'infrastructure/persistence/sqlite/sqlite_auth_repository.dart';
import 'infrastructure/persistence/sqlite/sqlite_partida_repository.dart';
import 'infrastructure/persistence/sqlite/sqlite_quest_repository.dart';
import 'presentation/screens/auth/auth_controller.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/combate/combate_controller.dart';
import 'presentation/screens/generar_quest/generar_quest_controller.dart';
import 'presentation/screens/menu/menu_principal_screen.dart';
import 'presentation/screens/progreso/progreso_controller.dart';
import 'presentation/theme/app_theme.dart';

// El flag usarBackendRemoto controla si la app usa el backend real
// (Supabase + Edge Functions) o el prototipo local (SQLite + StubQuestGenerator).
// Para usar el backend real al correr, pasar:
//   flutter run --dart-define=SUPABASE_ANON_KEY=<tu_key>
// El flag debe quedar en true para la demo del docente.
const bool usarBackendRemoto = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Composición de dependencias (único lugar que elige SQLite) ---
  final dbHelper = DatabaseHelper.instance;
  if (!kIsWeb) {
    await dbHelper.insertarDatosDePrueba();
  }

  final preferences = await SharedPreferences.getInstance();
  final sesionRepository = SharedPreferencesSesionRepository(preferences);

  const secureStorage = FlutterSecureStorage();
  final tokenRepository = SecureTokenRepository(secureStorage);

  final AuthRepository authRepository;
  final QuestRepository questRepository;
  final PartidaRepository partidaRepository;
  final QuestGeneratorRepository questGenerator;

  if (usarBackendRemoto) {
    const anonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
    );
    const supabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://jctulgfdweeurqbmugot.supabase.co',
    );

    final authClient = AuthApiClient(baseUrl: supabaseUrl, anonKey: anonKey);

    authRepository = HttpAuthRepository(authClient, tokenRepository);
    questRepository = HttpQuestRepository(
      baseUrl: supabaseUrl,
      anonKey: anonKey,
      tokenRepository: tokenRepository,
    );
    partidaRepository = HttpPartidaRepository(
      baseUrl: supabaseUrl,
      anonKey: anonKey,
      tokenRepository: tokenRepository,
    );
    questGenerator = HttpQuestGeneratorRepository(
      baseUrl: supabaseUrl,
      anonKey: anonKey,
      tokenRepository: tokenRepository,
    );
  } else {
    authRepository = SqliteAuthRepository(dbHelper);
    questRepository = SqliteQuestRepository(dbHelper);
    partidaRepository = SqlitePartidaRepository(dbHelper);
    questGenerator = StubQuestGenerator();
  }

  final responderUseCase = ResponderEncuentroUseCase();
  final registrarUseCase = RegistrarUsuarioUseCase(
    authRepository,
    sesionRepository,
  );
  final iniciarSesionUseCase = IniciarSesionUseCase(
    authRepository,
    sesionRepository,
  );
  final restaurarSesionUseCase = RestaurarSesionUseCase(
    sesionRepository,
    authRepository,
  );
  final cerrarSesionUseCase = CerrarSesionUseCase(sesionRepository);
  final actualizarPerfilUseCase = ActualizarPerfilUseCase(authRepository);
  final cambiarPasswordUseCase = CambiarPasswordUseCase(authRepository);
  final eliminarCuentaUseCase = EliminarCuentaUseCase(authRepository);
  final finalizarPartidaUseCase = FinalizarPartidaUseCase(
    partidaRepository,
    guardarLocalmente: !usarBackendRemoto,
  );
  final obtenerProgresoUseCase = ObtenerProgresoUseCase(partidaRepository);

  // Cuando el backend está activo, el Edge Function ya guarda la
  // quest en Postgres, por eso no se guarda local.
  final generarQuestUseCase = GenerarQuestUseCase(
    questGenerator,
    questRepository,
    guardarLocalmente: !usarBackendRemoto, // false si backend, true si stub
  );
  
  final generarEncuentrosExtraUseCase = GenerarEncuentrosExtraUseCase(questGenerator);

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenRepository>(create: (_) => tokenRepository),
        Provider<GenerarQuestUseCase>(create: (_) => generarQuestUseCase),
        Provider<RestaurarSesionUseCase>(create: (_) => restaurarSesionUseCase),
        Provider<CerrarSesionUseCase>(create: (_) => cerrarSesionUseCase),
        Provider<ActualizarPerfilUseCase>(
          create: (_) => actualizarPerfilUseCase,
        ),
        Provider<CambiarPasswordUseCase>(
          create: (_) => cambiarPasswordUseCase,
        ),
        Provider<EliminarCuentaUseCase>(
          create: (_) => eliminarCuentaUseCase,
        ),
        ChangeNotifierProvider(
          create: (_) => GenerarQuestController(generarQuestUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => CombateController(
            questRepository,
            responderUseCase,
            finalizarPartidaUseCase,
            generarEncuentrosExtraUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthController(registrarUseCase, iniciarSesionUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgresoController(obtenerProgresoUseCase),
        ),
      ],
      child: const SysQuestApp(),
    ),
  );
}



class SysQuestApp extends StatelessWidget {
  const SysQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SysQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Usuario? _usuario;
  bool _restaurando = true;

  @override
  void initState() {
    super.initState();
    _restaurarSesion();
  }

  Future<void> _restaurarSesion() async {
    try {
      final usuario = await context
          .read<RestaurarSesionUseCase>()
          .ejecutar()
          .timeout(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _usuario = usuario;
        _restaurando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _usuario = null;
        _restaurando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_restaurando) {
      return const Scaffold(
        backgroundColor: AppTheme.fondoNoche,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.verdeVida),
          ),
        ),
      );
    }
    if (_usuario == null) return const LoginScreen();
    return MenuPrincipalScreen(usuario: _usuario!);
  }
}
