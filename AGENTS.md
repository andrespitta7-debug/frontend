# AGENTS.md — SysQuest

Este archivo es el manual de trabajo para asistentes de código (GitHub
Copilot, Antigravity, Claude, DeepSeek, etc.) que contribuyan al
repositorio de SysQuest.

SysQuest tiene dos partes:
1. **App Flutter** (esta carpeta) — implementada, con SQLite local.
2. **Backend Supabase** (proyecto aparte) — planeado, aún no construido.

---

## PARTE 1: App Flutter (esta carpeta)

### Contexto

App educativa gamificada para estudiantes de Ingeniería de Sistemas.
Motor RPG de combate por turnos: el jugador elige un tema, se genera una
quest con encuentros, y cada encuentro es una pregunta A/B/C/D cuya
calidad afecta el combate.

### Documentos fuente

- `docs/SysQuest_Contexto_Maestro_v3.md` — fuente única de verdad.
- `docs/ESTADO_ACTUAL.md` — bitácora viva.
- `docs/V2SysQuest_Diccionario_de_Datos.md` — esquema SQLite.

### Stack

- Flutter + Dart.
- SQLite local vía `sqflite` (esquema versión 2, 7 tablas).
- `shared_preferences` para sesión persistente.
- Solo Android.

### Arquitectura (hexagonal — NO rediseñar)
lib/
├── domain/ ← reglas puras, sin Flutter ni SQLite
│ ├── entities/ Usuario, Quest, Encuentro, OpcionEncuentro,
│ │ Personaje, Partida, ProgresoUsuario
│ ├── repositories/ puertos (interfaces)
│ └── usecases/ casos de uso + PasswordHasher
├── infrastructure/
│ └── persistence/ adaptadores SQLite + shared_preferences
├── presentation/
│ ├── screens/ auth/, menu/, combate/, generar/, progreso/, perfil/
│ └── theme/ app_theme.dart
└── main.dart ← DI con Provider

text

Reglas duras:
- `domain/` no importa Flutter ni SQLite.
- `infrastructure/` implementa los puertos de `domain/`.
- `presentation/` usa los casos de uso inyectados con Provider.
- No inventar controladores nuevos si ya existe uno.

### Reglas de negocio vigentes

| Regla | Valor |
|---|---|
| Vida inicial | 100 |
| `calidad` 2 | 25 daño al enemigo |
| `calidad` 1 | 12 daño al enemigo |
| `calidad` 0 | 15 contraataque al jugador |
| Jefe | crítico +10, acierto +5, contraataque 25 |
| XP | victoria 50, derrota 10 |
| Nivel | `1 + xpTotal ~/ 100` |
| Contraseña | 8+ caracteres con letra y número (solo registro) |

### Protocolo de trabajo

1. Diseño en el chat (Claude/DeepSeek).
2. Implementación con Copilot/Antigravity.
3. Revisión pegando el `git diff` en el chat.
4. Commit pequeño, uno por paso.
5. Actualizar `docs/ESTADO_ACTUAL.md`.

### Reglas de Git (app Flutter)

- Commits pequeños, uno por paso del roadmap.
- Mensajes en español: `feat:`, `fix:`, `chore:`, `docs:`.
- **Ejecutar `flutter test` y `dart analyze` antes de cada commit.**
- No commitear si los tests fallan.
- No commitear `build/`, `.dart_tool/`, ni
  `macos/Flutter/GeneratedPluginRegistrant.swift`.

### Roadmap actual

- ✅ Paso 1: bug del daño flotante.
- ✅ Paso 2: auth + sesión persistente.
- ✅ Paso 3: menú principal.
- ✅ Paso 4a: perfil CRUD (ver + editar).
- ⏳ Paso 4b: cambiar contraseña.
- ⏳ Paso 4c: eliminar cuenta.
- ⏳ Paso 5: generar APK instalable.
- ⏳ Paso 6: 6 quests preset (Debug, Database, Algorithm, Network,
  Architecture, Cyber) con contenido pre-cargado.
- ⏳ Paso 7: continuar partida guardada.
- ⏳ Paso 8: menú de pausa en el combate.
- ⏳ Paso 9: mostrar puntuación al final de la partida.

---

## PARTE 2: Backend Supabase (proyecto aparte, aún no construido)

### Stack

- Supabase + PostgreSQL.
- Supabase Auth.
- Supabase Edge Functions.
- Generación con IA vía Gemini o Groq (siempre detrás del backend).

### Regla crítica

**La app Flutter NUNCA llama a la IA directamente.** Las API keys y
llamadas al proveedor viven solo detrás del backend.

### Flujo de responsabilidades
API → Business Logic → Services → Repositories → Supabase/PostgreSQL

text

### Seguridad

- Nunca hardcodear API keys, tokens, JWT secrets, service keys.
- Usar variables de entorno.
- Commitear `.env.example`, no `.env`.
- Tratar todo output de IA como input no confiable.

### Git (backend)

- Nunca trabajar en `main`.
- Ramas `feature/SQ-XXX-descripcion`.
- Commits con id de Jira: `SQ-001 add backend audit docs`.

### Estado

No construido. Comienza el miércoles. Este repo se creará aparte o en
una carpeta `backend/` dentro del mismo repo (por confirmar).

---

## Si eres un asistente leyendo esto

1. Lee `docs/ESTADO_ACTUAL.md` para saber en qué punto estamos.
2. Lee la sección relevante del `docs/SysQuest_Contexto_Maestro_v3.md`.
3. Revisa el código antes de modificarlo.
4. Pregunta si algo no está claro. **No inventes.**
5. Ejecuta `flutter test` y `dart analyze` al final.
