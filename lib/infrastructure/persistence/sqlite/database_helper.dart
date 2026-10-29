import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Adaptador de infraestructura. Es el único lugar del proyecto
/// que sabe que existe SQLite. El dominio nunca importa este archivo.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'sysquest.db');
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crearTablas,
      onUpgrade: _migrar,
    );
  }

  /// Sube cada vez que cambian el esquema. Nunca la bajen ni la reutilicen.
  static const int _dbVersion = 2;

  /// Aquí va UNA migración por versión, nunca se borra la anterior.
  /// Así alguien que tiene v1 instalada pasa a v2 sin perder sus datos,
  /// y alguien que instala de cero directamente cae en _crearTablas con
  /// el esquema ya completo (por eso _crearTablas siempre debe reflejar
  /// la versión MÁS RECIENTE, como ya está).
  Future<void> _migrar(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v1 -> v2: se agregó password_hash a usuario.
      await db.execute(
        "ALTER TABLE usuario ADD COLUMN password_hash TEXT NOT NULL DEFAULT ''",
      );
    }
    // if (oldVersion < 3) { ... el próximo cambio futuro va aquí ... }
  }

  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario (
        id_usuario TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        nombre_usuario TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        nombre TEXT,
        apellido TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE personaje (
        id_personaje TEXT PRIMARY KEY,
        id_usuario TEXT UNIQUE NOT NULL,
        nombre TEXT,
        genero TEXT,
        skin TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE progreso_usuario (
        id_progreso TEXT PRIMARY KEY,
        id_usuario TEXT UNIQUE NOT NULL,
        nivel INTEGER DEFAULT 1,
        xp_total INTEGER DEFAULT 0,
        quests_completadas INTEGER DEFAULT 0,
        victorias INTEGER DEFAULT 0,
        derrotas INTEGER DEFAULT 0,
        partidas_jugadas INTEGER DEFAULT 0,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE quest (
        id_quest TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        tema TEXT,
        categoria TEXT,
        dificultad TEXT,
        descripcion TEXT,
        fuente_generacion TEXT DEFAULT 'manual',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE encuentro (
        id_encuentro TEXT PRIMARY KEY,
        id_quest TEXT NOT NULL,
        numero INTEGER,
        pregunta TEXT NOT NULL,
        dificultad TEXT,
        tipo_encuentro TEXT DEFAULT 'normal',
        vida_enemigo INTEGER DEFAULT 50,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_quest) REFERENCES quest (id_quest)
      );
    ''');

    await db.execute('''
      CREATE TABLE opcion_encuentro (
        id_opcion TEXT PRIMARY KEY,
        id_encuentro TEXT NOT NULL,
        letra TEXT,
        texto TEXT,
        calidad INTEGER,
        FOREIGN KEY (id_encuentro) REFERENCES encuentro (id_encuentro)
      );
    ''');

    await db.execute('''
      CREATE TABLE partida (
        id_partida TEXT PRIMARY KEY,
        id_usuario TEXT NOT NULL,
        id_quest TEXT NOT NULL,
        estado TEXT DEFAULT 'en_curso',
        encuentro_actual INTEGER DEFAULT 0,
        score INTEGER DEFAULT 0,
        xp_obtenida INTEGER DEFAULT 0,
        tiempo_segundos INTEGER DEFAULT 0,
        resultado TEXT,
        started_at TEXT DEFAULT CURRENT_TIMESTAMP,
        finished_at TEXT,
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
        FOREIGN KEY (id_quest) REFERENCES quest (id_quest)
      );
    ''');
  }

  /// Datos de prueba fijos para poder probar el combate YA,
  /// sin esperar a la IA ni a Supabase.
  Future<void> insertarDatosDePrueba() async {
    final db = await database;

    final existentes = await db.query('quest');
    if (existentes.isNotEmpty) return; // ya hay datos, no duplicar

    await db.insert('quest', {
      'id_quest': 'quest-001',
      'titulo': 'Quest de Programación Básica',
      'tema': 'Variables, condicionales y funciones',
      'categoria': 'debug',
      'dificultad': 'facil',
      'descripcion':
          'Repasa conceptos básicos de programación con ejemplos simples.',
      'fuente_generacion': 'manual',
    });

    // Encuentro 1 (normal)
    await db.insert('encuentro', {
      'id_encuentro': 'enc-001',
      'id_quest': 'quest-001',
      'numero': 1,
      'pregunta': '¿Para qué sirve una variable en un programa?',
      'dificultad': 'facil',
      'tipo_encuentro': 'normal',
      'vida_enemigo': 30,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-001',
      'id_encuentro': 'enc-001',
      'letra': 'A',
      'texto': 'Para guardar un valor para usarlo después',
      'calidad': 2,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-002',
      'id_encuentro': 'enc-001',
      'letra': 'B',
      'texto': 'Para hacer que el programa se detenga',
      'calidad': 0,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-003',
      'id_encuentro': 'enc-001',
      'letra': 'C',
      'texto': 'Para crear una imagen en pantalla',
      'calidad': 0,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-004',
      'id_encuentro': 'enc-001',
      'letra': 'D',
      'texto': 'Para borrar información del programa',
      'calidad': 0,
    });

    // Encuentro 2 (normal, un poco más difícil)
    await db.insert('encuentro', {
      'id_encuentro': 'enc-002',
      'id_quest': 'quest-001',
      'numero': 2,
      'pregunta': '¿Qué hace una condicional if en programación?',
      'dificultad': 'medio',
      'tipo_encuentro': 'normal',
      'vida_enemigo': 40,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-005',
      'id_encuentro': 'enc-002',
      'letra': 'A',
      'texto': 'Evalúa una condición y decide qué hacer según el resultado',
      'calidad': 2,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-006',
      'id_encuentro': 'enc-002',
      'letra': 'B',
      'texto': 'Guarda un valor en memoria',
      'calidad': 1,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-007',
      'id_encuentro': 'enc-002',
      'letra': 'C',
      'texto': 'Crea una nueva ventana del sistema',
      'calidad': 0,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-008',
      'id_encuentro': 'enc-002',
      'letra': 'D',
      'texto': 'Borra el código del programa',
      'calidad': 0,
    });

    // Encuentro 3 (JEFE)
    await db.insert('encuentro', {
      'id_encuentro': 'enc-003',
      'id_quest': 'quest-001',
      'numero': 3,
      'pregunta': '¿Qué es una función en programación?',
      'dificultad': 'dificil',
      'tipo_encuentro': 'jefe',
      'vida_enemigo': 70,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-009',
      'id_encuentro': 'enc-003',
      'letra': 'A',
      'texto':
          'Un bloque de instrucciones reutilizable para realizar una tarea',
      'calidad': 2,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-010',
      'id_encuentro': 'enc-003',
      'letra': 'B',
      'texto': 'Un tipo de dato que solo guarda números',
      'calidad': 0,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-011',
      'id_encuentro': 'enc-003',
      'letra': 'C',
      'texto': 'Una base de datos pequeña',
      'calidad': 0,
    });
    await db.insert('opcion_encuentro', {
      'id_opcion': 'op-012',
      'id_encuentro': 'enc-003',
      'letra': 'D',
      'texto': 'Una pantalla de inicio del programa',
      'calidad': 0,
    });
  }
}
