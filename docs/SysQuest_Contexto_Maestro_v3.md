# SysQuest — Documento Maestro de Contexto (v3)

*Actualizado el 24-sep-2026. Reemplaza a la v2. Pégalo completo como primer mensaje en cualquier chat nuevo (junto con `ESTADO_ACTUAL.md`) o súbelo a NotebookLM. Lo que aquí dice "PENDIENTE" o "PROPUESTO" NO está construido.*

---

## 1. Identidad del proyecto

- **Nombre:** SysQuest — plataforma gamificada de aprendizaje para Ingeniería de Sistemas.
- **Institución:** Universidad de Cundinamarca (UDeC), sede Fusagasugá, Programa de Ingeniería de Sistemas y Computación.
- **Asignatura:** Ingeniería de Software I (604527). Instructor: Luiferney Ortiz Parra (informalmente "Ferney Ortiz").
- **Equipo de desarrollo (2 personas):** Jhony Alejandro Palacio Gómez, Andrés Orley Pitta Pardo.
- **Equipo ampliado de emprendimiento:** 4 personas (los 2 anteriores + 2 de Innovación y Emprendimiento).
- **Semestre:** 16 semanas; el proyecto arrancó formalmente en la semana 4.
- **Presupuesto:** cero; todo el stack usa herramientas gratuitas o de muy bajo costo.
- **Ruta local:** `C:\Users\jhony\sysquest_app` (además contiene `SysQuest_Arquitectura.md`, `continuacion_sysquest.md`, `README.md`).
- **Informe académico vigente:** `SysQuest - Ing de Software V1.13.pdf` (en NotebookLM).

---

## 2. Historia del pivote de diseño (no repetir el ciclo)

1. **Versión original:** seis minijuegos independientes (Debug, Database, Algorithm, Network, Architecture, Cyber).
2. **Versión vigente:** un **único motor RPG 2D pixel art de combate por turnos**. El jugador escribe un tema libre, una IA genera una quest y las seis categorías pasan a ser **categorías temáticas sugeridas**, no juegos distintos.

**Referencia de jugabilidad:** *TBH: Task Bar Hero* (batalla en escena estática). No se necesita motor gráfico ni Flame: todo con widgets estándar de Flutter.

---

## 3. Arquitectura técnica — YA IMPLEMENTADA (no rediseñar)

**Patrón:** arquitectura hexagonal + SOLID.

```
lib/
├── domain/           ← reglas puras, sin Flutter ni SQLite
│   ├── entities/       Usuario, Quest, Encuentro, OpcionEncuentro,
│   │                   y en personaje_partida.dart: Personaje, Partida, ProgresoUsuario
│   ├── repositories/   QuestRepository, AuthRepository, PartidaRepository (puertos)
│   └── usecases/       ResponderEncuentroUseCase, RegistrarUsuarioUseCase, IniciarSesionUseCase,
│                       FinalizarPartidaUseCase, ObtenerProgresoUseCase, PasswordHasher
├── infrastructure/
│   └── persistence/sqlite/  DatabaseHelper (migraciones versionadas), SqliteQuestRepository,
│                            SqliteAuthRepository, SqlitePartidaRepository
├── presentation/     ← UI: screens/ (auth/, combate/, progreso/)
└── main.dart         ← única capa que elige implementaciones (inyección de dependencias)
```

**Funcionalidades del MVP funcionando de punta a punta:**
1. Autenticación local (registro/login, SHA-256, migraciones versionadas).
2. Quest/Encuentro (múltiples encuentros ordenados, incluido un jefe).
3. Combate por turnos (4 opciones por encuentro; `calidad` define crítico/normal/contraataque; al terminar se guarda la Partida y se actualiza el ProgresoUsuario).
4. Pantalla Mi Progreso (consulta y volver a jugar).

**Base de datos:** SQLite `sysquest.db`, esquema **versión 2**, 7 tablas: `usuario`, `personaje`, `progreso_usuario`, `quest`, `encuentro`, `opcion_encuentro`, `partida`. Diccionario completo y corregido en `V2SysQuest_Diccionario_de_Datos.md` (reemplaza al `.xlsx` desfasado). IDs `TEXT` (UUID v4); enumerados sin `CHECK`, validados en la app.

### Reglas de negocio vigentes (`domain/usecases`)

| Regla | Valor |
|---|---|
| Vida inicial del jugador | 100 (`Partida.vidaJugador`, no se guarda en BD) |
| `calidad` 2 (crítico) | 25 de daño al enemigo |
| `calidad` 1 (acierto) | 12 de daño al enemigo |
| `calidad` 0 (fallo) | contraataque de 15 al jugador |
| Encuentro `jefe` | crítico +10, acierto +5, contraataque 25 |
| XP | victoria 50, derrota 10 |
| Nivel | `1 + xpTotal ~/ 100` |
| Contraseña mínima | 6 caracteres |

La partida se inserta en BD **solo al terminar** (`guardarPartida`).

---

## 3b. Hallazgos de la auditoría (24-sep-2026)

Estado: los marcados como hechos deben verificarse en el código antes de darlos por cerrados.

- [ ] **Datos de prueba:** `enc-001` opción D y `enc-003` opción D tienen `calidad: 1` siendo incorrectas; deben ser 0.
- [ ] **Orden de opciones:** `obtenerEncuentros` consulta `opcion_encuentro` sin `orderBy`; agregar `letra ASC`.
- [ ] **`vida_enemigo`:** default SQL 50 vs respaldo 30 en `SqliteQuestRepository`; unificar. Además, `ResponderEncuentroUseCase` no la usa: revisar en la pantalla de combate cómo se descuenta.
- [ ] **Llaves foráneas:** activar `PRAGMA foreign_keys = ON` vía `onConfigure`.
- [ ] **Migración v1→v2:** usuarios previos quedan con `password_hash = ''` (no podrían iniciar sesión). Solo afecta datos viejos de prueba.
- [ ] **`registrar`:** dos inserts (`usuario` + `progreso_usuario`) sin transacción.
- [ ] **Contraseñas:** SHA-256 sin salt. Aceptable en el MVP local; cambiar a bcrypt/argon2 cuando llegue el backend.
- [ ] **`personaje`:** tabla sin uso (ningún repositorio la lee ni escribe).
- [ ] **`partida.resultado`** duplica `estado`; **`started_at`** no refleja el inicio real (la partida se guarda al terminar).
- [ ] **`ProgresoUsuario`** (entidad) no expone `id_progreso` ni `updated_at`.

---

## 4. Roadmap (no construido)

**Siguiente hito (PROPUESTO, no implementado): generación de quests con IA**, respetando la arquitectura:
1. Puerto en `domain/`: `QuestGeneratorRepository` con `generarQuest(String tema)`.
2. Caso de uso `GenerarQuestUseCase`: valida que cada encuentro tenga exactamente 4 opciones (A–D) con **una sola** de `calidad` 2, al menos una de `calidad` 0, y usa el banco local de preguntas como respaldo si la IA falla.
3. Adaptador en `infrastructure/`: primero uno falso/local para probar el flujo; después el real.
4. Pantalla: campo de tema libre que llama al caso de uso.

**Resto del roadmap:**
- **Backend remoto:** híbrido SQLite (caché offline) + Supabase/PostgreSQL (cuentas sincronizadas, cosméticos, panel admin). La IA se llama **siempre vía backend**, nunca directo desde el celular (Gemini o Groq como opciones gratuitas evaluadas).
- **Personajes:** 2-3 skins predefinidos por género (sin capas combinables).
- **Multijugador local** (hotspot/Wi-Fi Direct): funcionalidad futura, separada del modo historia.
- **Web informativa bilingüe + APK + panel admin institucional:** planeado para ~semana 14.
- **Plataforma:** solo Android.

---

## 5. Ecosistema de herramientas (estado verificado el 24-sep-2026)

| Tarea | Herramienta |
|---|---|
| Escribir y modificar código Flutter/Dart | VS Code + GitHub Copilot Student |
| Consultar el proyecto ("¿qué decidimos sobre X?") | NotebookLM (ahora llamado **Gemini Notebook**), cuaderno "SysQuest" |
| Auditorías de conjunto e investigación de integraciones | Gemini web |
| Web informativa y panel admin (fase futura, NO la app Flutter) | Antigravity |
| Diseño, decisiones de arquitectura, revisión de código, documentos académicos | Claude (este chat) |

**Estado por herramienta:**
- **GitHub Student:** verificado para Jhony el 21-sep-2026 (vigencia de ~2 años). Andrés debe verificar con su propia cuenta *(por confirmar)*.
- **Copilot Student:** selección de modelo **solo en modo Auto** (sin selector manual, desde el 24-jun-2026). Incluye completado ilimitado, una asignación de créditos de GitHub AI y uso limitado de chat/agente. Ya existe `.github/copilot-instructions.md` en el proyecto.
- **NotebookLM:** cuaderno con 5 fuentes (código domain/infra en .txt, informe V1.13, maestro, diccionario). **Regla:** eliminar/deseleccionar versiones viejas del maestro al subir una nueva; el resumen automático mezcló v1 y v2 y ya mostró datos falsos (Supabase como actual, 13 semanas).
- **Antigravity:** plan individual gratuito con cuota semanal (recortada varias veces desde su lanzamiento; no depender de ella). El Gemini CLI dejó de servir cuentas individuales el 18-jun-2026; lo reemplaza el Antigravity CLI.
- **Suscripción Gemini de 18 meses por $40.000 COP (revendedor):** **SIN VERIFICAR.** El anuncio promociona "Gemini 1.5 Pro" (desactualizado) y 5 TB (dato propio de una promoción estudiantil de EE. UU.). Acciones: revisar en one.google.com quién paga y qué plan aparece; si se entregó contraseña, cambiarla y activar verificación en dos pasos; no guardar ahí copias únicas. **Alternativa legítima:** Google AI Plus gratis 12 meses para estudiantes (140+ mercados, hasta 31-dic-2026, verificación SheerID, requiere método de pago y se renueva a pago: poner recordatorio). Solicitud en `gemini.google/students` con cuenta personal.
- **Abandonado:** Claude Code vía OmniRoute (gateway gratuito). No retomar.

---

## 6. Modelo de negocio (Innovación y Emprendimiento)

- Licenciamiento institucional a universidades (panel admin + contenido propio).
- Cosméticos/skins ("juego gratis, cosméticos de pago").
- Publicidad no intrusiva en la versión libre sin convenio institucional.
- Todo se presenta como **hipótesis de negocio en validación**, nunca como mercado demostrado.

---

## 7. Reglas de comunicación (para cualquier documento o presentación)

1. No afirmar que SysQuest "resuelve" el problema del aprendizaje; es alternativa/complemento en exploración.
2. Diferenciar **investigado** / **decidido y construido** / **futuro-hipotético**.
3. Las entrevistas iniciales son evidencia cualitativa exploratoria, no validación estadística.
4. El equipo de desarrollo son 2 personas, aunque el de emprendimiento sea de 4.

---

## 8. Protocolo de continuidad (cómo trabajamos)

**Ciclo por tarea:** (1) diseño en el chat con Claude → (2) implementación en VS Code con Copilot usando ese diseño → (3) revisión en el chat pegando el `git diff` → (4) commit pequeño → (5) actualizar `ESTADO_ACTUAL.md` y, si cambió una decisión, este documento.

**Fuentes de verdad, en orden:** código en GitHub → este documento → `ESTADO_ACTUAL.md` → NotebookLM (solo consulta) → chats (no son fuente).

**Arrancar un chat nuevo:** pegar este documento y `ESTADO_ACTUAL.md` como texto (nunca PDFs ni capturas, por el límite de imágenes por mensaje) y, si hace falta, el `codigo_domain_infra.txt` generado por `tools/exportar_contexto.ps1`. Decir al final qué se quiere hacer.

**Regla de decisiones:** toda decisión que cambie el rumbo se anota en la bitácora de `ESTADO_ACTUAL.md` con fecha y motivo, para no discutirla dos veces.

*Fin del documento. Es la fuente única de verdad: actualízalo cuando cambie el alcance o una decisión técnica.*
