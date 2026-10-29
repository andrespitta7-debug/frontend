# SysQuest — Estado actual (archivo vivo)

_Se actualiza al final de CADA sesión de trabajo (2 minutos). Va junto al
Contexto Maestro al abrir un chat nuevo. Mantenerlo corto: si crece, mover lo
antiguo a la bitácora._

**Último commit conocido:** `24f2e65` — feat(backend): timeout 60s + logs de
diagnostico en validator

---

## Hecho

- MVP funcionando: auth, quest/encuentros, combate por turnos, Mi Progreso (ver
  Maestro §3).
- Diccionario de datos v2 corregido (`V2SysQuest_Diccionario_de_Datos.md`).
- Auditoría de dominio e infraestructura realizada (hallazgos en Maestro §3b) —
  **4 arreglos aplicados**: `calidad` corregidos, `orderBy: 'letra ASC'`,
  `vida_enemigo` unificado, `PRAGMA foreign_keys = ON`.
- GitHub Student verificado (Jhony); Copilot Student activo en VS Code (créditos
  cerca del límite, usar con cuidado).
- Antigravity instalado y configurado como alternativa a Copilot cuando se
  agoten los créditos.
- `AGENTS.md` unificado en la raíz del repo (app Flutter + backend futuro) — es
  la fuente que leen Copilot y Antigravity. Referenciado desde
  `.agents/rules/sysquest-context.md` y desde `.github/copilot-instructions.md`.
- **Paso 1:** bug del número de daño flotante corregido.
- **Paso 2:** autenticación completa (registro/login validados) + sesión
  persistente (`shared_preferences`) + `AuthGate`.
- **Paso 3:** menú principal tras el login (quest del sistema / nueva quest IA /
  progreso / cerrar sesión).
- **Paso 4a:** perfil — ver y editar (nombre, apellido, usuario). Commit
  `ddc4810`.
- **Paso 4b:** cambiar contraseña, con las 5 validaciones (actual correcta,
  reglas de la nueva, distinta a la actual, confirmación coincide, guardado).
  Commit `7ebeace`.
- **Paso 4c:** eliminar cuenta, borrado transaccional (partida →
  progreso_usuario → personaje → usuario) + cierre de sesión + vuelta al login.
  Commit `33d9877`.
- Generación de quests con IA — base de dominio (A1: puerto + caso de uso +
  guardado transaccional; A2: `StubQuestGenerator` falso registrado en
  `main.dart`; A3: pantalla de tema libre conectada al combate).
- Revisión conjunta con el docente y Andrés de HU/CU, arquitectura y proceso Git
  (28-sep): ver "Decisiones cerradas" abajo.
- NotebookLM con fuentes cargadas (pendiente de refrescar con lo último, ver
  "Siguiente").
- **Edge Function `register` completada.** Supabase Auth + creación de perfil en
  `usuario` + inicialización de `progreso_usuario`. Colección Postman con 6
  casos en `docs/postman/`. Commit `4e2b1ff`.
- **Edge Function `login` completada.** Autenticación con Supabase Auth.
  Devuelve access_token, refresh_token, usuario y progreso. Commit `ed0cea9`.
- **Backend auth completo.** `register` + `login` deployados y probados en
  Postman con 10 casos en total (6 de register + 4 de login).
- **Ajustes Visuales Combate:** Integración de fuente "Press Start 2P" en
  títulos/botones, números de daño flotantes animados (fade-in, subida y
  fade-out), shake mejorado y barras de vida dinámicas. Textos largos mantienen
  la fuente legible.
- **Bugfix (Auth):** Arreglado contrato de `AuthRepository` para enviar
  contraseñas en plano, delegando el Hash a `SqliteAuthRepository` localmente.
  Esto solucionó el fallo de login remoto con Supabase (que requiere plaintext).
  Todos los tests pasaron exitosamente.
- **Edge Function `generar-quest` completada y probada.** Flujo end-to-end
  Flutter/Postman → Edge Function → Groq → validación → Postgres. Modelo
  `openai/gpt-oss-120b` (Groq free tier: 1000 RPD). Caché de quests para reducir
  consumo. Commit `791ea1a`.
- **Retry automático y factory de proveedores.** Diseño preparado para alternar
  entre Groq y Gemini sin tocar código, solo con la variable de entorno
  `AI_PROVIDER`.
- **Mejoras de gameplay.** Opciones balanceadas (validación V9 rechaza si la
  respuesta correcta es >2× más larga). Combate por turnos sin spam (botones
  deshabilitados ~700ms mientras se procesa el turno). Orden aleatorio de
  encuentros normales (el jefe siempre va al final).
- **Sub-paso B.2 — Run extendida backend.** Edge Function
  `generar-quest-completa` con mega-prompt (quest + pool narrativo + 9 preguntas
  extra). Caché narrativa por tema+categoría+dificultad. Timeout configurable
  (60s run completa). RPC `crear_run_completa` transaccional. Commit `24f2e65`.
- **Sub-paso B.3a y B.3b — Run extendida frontend.** Reescritura del
  `CombateController` y `combate_screen.dart` para soportar preguntas extra,
  transición automática de enemigos al morir, uso del pool narrativo inmersivo y
  modal de pausa con retiro/continuar.
- **Fix fallback parámetros combate:** Fallback seguro en `CombateController.cargarQuest` para `temaQuest` ('Aventura General'), `categoriaQuest` ('libre') y `dificultadQuest` ('facil'), evitando errores 400 del backend al solicitar más encuentros en quests predeterminadas/semilla.

## En curso

## Decisiones cerradas (28-sep-2026, revisión HU/CU con el docente y Andrés)

1. **Nivel:** `nivel = 1 + floor(xp_total / 100)`. XP inicial 0, victoria +50,
   derrota +10. Coincide con el prototipo actual; se formaliza en HU-09/CU-09.
2. **Timeout de IA:** la Edge Function tiene un límite total de 10s; si el
   proveedor no responde correctamente, se activa fallback automático. Sin
   reintentos hacia el estudiante. El fallo se registra en logs.
3. **Origen del fallback:** banco curado y versionado de quests en
   Postgres/Supabase (por categoría, tema y dificultad). El `StubQuestGenerator`
   local queda solo para pruebas offline del prototipo, no es la fuente oficial
   del fallback.
4. **Enum `fuente_generacion`:** tres valores únicos en toda la pila (BD, API,
   Flutter, HU/CU): `AI`, `FALLBACK`, `DOCENTE`. Reemplaza a `manual`/`ia` que
   usa hoy el prototipo local.
5. **Vida del jugador y reanudación:** `partida` persiste `vida_jugador_actual`,
   `vida_enemigo_actual`, `encuentro_actual`, `updated_at`. La vida del jugador
   se conserva toda la quest; la del enemigo se reinicia por encuentro. **Es la
   decisión con más impacto**: sin esto no hay reanudación real ni resultados
   auditables.
6. **Edición de quests con partidas activas:** no se edita en caliente. Editar
   crea una nueva versión; las partidas en curso siguen en la versión anterior,
   las nuevas parten de la versión publicada.

**Deuda declarada del prototipo local (SQLite):** hoy
`calidad`/`fuente_generacion` no siguen este enum y la vida del jugador vive
solo en memoria del controlador de combate. Se declara honestamente como deuda
del prototipo offline (no se oculta) y se corrige cuando se construya el backend
real, no antes.

## Siguiente

1. Confirmar y commitear (o revertir) el cambio pendiente en `app_theme.dart`.
2. **Backend real (prioridad de la semana, reemplaza la meta original de "solo
   esquema"):**
   - Terminar de crear el proyecto Supabase (nombre correcto, región, contraseña
     guardada fuera del repo).
   - Copiar `Project URL`, `anon key`, `service_role key` (Project Settings →
     Data API / API Keys) y guardarlas fuera del repo.
   - `supabase init` en el repo `backend`, carpeta `supabase/`.
   - Esquema Postgres con las 6 decisiones cerradas incorporadas.
   - Primer endpoint (Edge Function) de login/registro con JWT de Supabase Auth,
     con `.env`/`.env.example`, probado en Postman — Flutter nunca llama a
     Supabase directo, siempre pasa por este backend. Esto es lo que pide la
     Guía de Primera Review Técnica (demo end-to-end, capas separadas, Postman,
     sin frontend conectado directo a la BD).
3. Paso 5: generar APK instalable (después del backend mínimo).
4. Refrescar NotebookLM: subir `AGENTS.md`, reemplazar el código exportado y
   eliminar fuentes obsoletas (maestro original, maestro v2).
5. Roadmap ampliado del prototipo Flutter (no urgente, después del backend):
   - Paso 6: 6 quests preset (Debug, Database, Algorithm, Network, Architecture,
     Cyber) con contenido pre-cargado — resuelve la diferencia entre el informe
     V1.13 ("6 minijuegos") y el motor único ya construido.
   - Paso 7: continuar partida guardada (depende de la decisión 5).
   - Paso 8: menú de pausa en el combate.
   - Paso 9: mostrar puntuación al final de la partida.
   - Paso 10: botón/pantalla de tutorial o ayuda para jugadores nuevos.
   - Paso 11 (backend): moderación de temas para la generación con IA — la Edge
     Function antepone un system prompt fijo (no editable desde Flutter) que
     reformula o rechaza temas con groserías, fuera de alcance académico o
     demasiado ambiguos, antes de llamar al proveedor de IA.

## Decisiones pendientes

- Formato JSON exacto que debe devolver la IA (encuentros, opciones, calidad) —
  para cuando se reemplace el `StubQuestGenerator` por el adaptador real.
- Proveedor de IA (Gemini vs Groq) — decisión del backend.
- Qué hacer con la suscripción de Gemini revendida (verificar / reemplazar por
  la promoción estudiantil).
- Confirmar que Andrés verificó su cuenta de GitHub Student.
- OmniRoute: **resuelto** — se desinstaló, no estaba en el repo, no hay key
  comprometida en el historial.
- Corregir encabezados/códigos inconsistentes en HU-04, CU-04, CU-08, CU-09
  (pendiente según la revisión del 28-sep).
- Normalizar ramas Git: `feature/SYSQ-XX-descripcion` → `dev` → `preprod` →
  `main`, con PRs de reconciliación transparentes (main está 17 commits por
  delante de dev/preprod; no se debe simular historial falso).

## Notas para el próximo chat

- No rediseñar la arquitectura hexagonal; ya funciona.
- Pegar texto, no PDFs ni capturas.
- Si se quiere revisar código: pegar el `git diff` o el
  `codigo_domain_infra.txt`.
- El backend debe seguir 12 factores clave: config en variables de entorno
  (nunca hardcodeada), backing services intercambiables por config, logs como
  flujo de eventos.
- Flutter NUNCA llama a Supabase/Postgres directo: siempre pasa por el backend
  (Edge Functions). Esto fue una corrección explícita del docente.

---

## Bitácora de decisiones y sesiones

| 30-sep-2026 | Se alinean las ramas remotas `dev` y `preprod` con `main`
(estaban divergentes por commits aislados de SQ-001). Se crean las ramas locales
`dev` y `preprod` apuntando a `origin`. Los commits de SQ-001 quedan preservados
en `feature/SQ-001-initial-audit`. | Normalización de ramas acordada con Andrés
y el docente: `feature/SYSQ-XX` → `dev` → `preprod` → `main`. |

| Fecha          | Qué se decidió / hizo                                                                                                                                                                                                                   | Motivo                                                                                                         |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 24-sep-2026    | Se crea el protocolo de continuidad (Maestro v3 + este archivo + script de exportación)                                                                                                                                                 | Un chat anterior se cortó por límite de imágenes y no hubo forma de migrar el contexto                         |
| 24-sep-2026    | Copilot Student se usa solo en modo Auto; el razonamiento largo se hace en el chat de Claude                                                                                                                                            | Sin selector manual de modelos desde jun-2026                                                                  |
| 24-sep-2026    | La suscripción Gemini revendida se trata como "sin verificar" y sin copias únicas de archivos                                                                                                                                           | Señales de riesgo en el anuncio                                                                                |
| 24-sep-2026    | Meta de la semana: base de datos Supabase desplegada (esquema + datos de prueba + RLS) para mostrar al docente                                                                                                                          | El docente pidió avance en base de datos externa                                                               |
| 25/26-sep-2026 | Pasos 1, 2, 3, 4a completados (bug de daño, auth + sesión persistente, menú principal, perfil ver/editar)                                                                                                                               | Avance de roadmap, trabajado con Copilot                                                                       |
| 27/28-sep-2026 | Se crea `AGENTS.md` unificado (app Flutter + backend futuro) como fuente que leen los agentes; se configura Antigravity como alternativa a Copilot                                                                                      | Copilot llegó al 90% de créditos; se necesitaba continuidad entre herramientas                                 |
| 27/28-sep-2026 | Pasos 4b (cambiar contraseña) y 4c (eliminar cuenta) completados con Antigravity, siguiendo el mismo patrón (puerto → caso de uso → infraestructura → UI → tests)                                                                       | Cierre del CRUD de perfil                                                                                      |
| 27/28-sep-2026 | Se detecta y resuelve el riesgo de OmniRoute (gateway local corriendo sin autenticación); se desinstala                                                                                                                                 | Ya estaba marcado como abandonado en el Maestro; no debía seguir instalado                                     |
| 27/28-sep-2026 | Se decide resolver la diferencia entre el informe V1.13 ("6 minijuegos") y el motor único ya construido con 6 "quests preset" (una por categoría) en vez de reescribir el informe                                                       | No retrasa el código, mantiene el informe entregado como válido, es defendible ante el docente                 |
| 28-sep-2026    | Revisión conjunta HU/CU con el docente y Andrés: se cierran 6 decisiones (nivel, timeout IA, origen fallback, enum fuente_generacion, persistencia de vida/reanudación, versionado de quests editadas)                                  | Alinear HU/CU, Jira y arquitectura en el mismo lenguaje antes de seguir                                        |
| 29-sep-2026    | Se confirma que 4b y 4c quedaron pusheados (`33d9877`); queda un cambio sin commitear en `app_theme.dart` por revisar                                                                                                                   | Verificación de continuidad tras trabajar con varias IAs en paralelo                                           |
| 29-sep-2026    | Se replantea la prioridad de la semana: de "solo esquema Supabase" a "backend mínimo end-to-end con JWT y Postman", según la Guía de Primera Review Técnica                                                                             | La guía exige demo funcional front+backend+BD, capas separadas y Postman, no solo una base de datos desplegada |
| 29-sep-2026    | El docente confirma verbalmente: todo al repo `backend` por ahora, reorganización frontend/backend antes de la expo                                                                                                                     | Evitar bloquear el trabajo mientras se define el reparto final                                                 |
| 29-sep-2026    | Edge Function `register` completada y probada. Registra en Supabase Auth + crea perfil + progreso en una llamada. 6 casos verificados en Postman. Commit `4e2b1ff`.                                                                     | Avance del roadmap backend                                                                                     |
| 29-sep-2026    | Edge Function `login` completada y probada. Devuelve JWT + perfil + progreso. 4 casos en Postman (200, 401, 400, 405). Commit `ed0cea9`.                                                                                                | Avance del roadmap backend                                                                                     |
| 30-sep-2026    | Refinamiento visual (CombateScreen con estilo retro y animaciones) y Fix de AuthRepository (cambio de contrato a contraseñas en plano para soportar login con Supabase nativamente sin romper SQLite).                                  | Mejorar inmersión de usuario y solucionar bug de 'contraseña incorrecta' por culpa del hash a nivel Dominio.   |
| 01-oct-2026    | Edge Function `generar-quest` completada y probada end-to-end. Groq (modelo `openai/gpt-oss-120b`) como proveedor IA principal. Caché de quests implementado. Puerto abstracto `AiProvider` para futuros proveedores. Commit `791ea1a`. | Cierre del Sub-paso 2b: generación de quests con IA funcionando gratis                                         |
| 01-oct-2026    | Sub-paso B.2 completado. Edge Function `generar-quest-completa` deployada y probada.                                                                                                                                                    | Mecánica de run extendida con narrativa procedural                                                             |
| _(fecha)_      | _(siguiente entrada)_                                                                                                                                                                                                                   |                                                                                                                |
| (Fecha de hoy) | Sub-paso B.3a y B.3b completados. Integración de la UI y lógica para soportar la narrativa y preguntas extra en el frontend del combate.                                                                                                | Cierre del flujo de la run extendida en cliente                                                                |
| 01-oct.-2026 | Run Infinita completada (Frontend + Backend). Edge Function generar-encuentros-extra corregida y desplegada. | Mejora de gameplay (Run Infinita) |
| 2026-10-01 | Run Infinita completada end-to-end. Frontend conectado a `generar-quest-completa` (pool narrativo + 9 preguntas extra + semilla). `CombateController` ahora guarda tema/categoría/dificultad de la quest y los pasa correctamente a `generar-encuentros-extra`. 117 tests pasan. | Cierre del bloque Run Infinita |
| 2026-10-01 | Menu principal rediseñado en grid 2x2 con tarjetas centradas y estilo tablero de aventuras. | Bloque C |
| 2026-10-01 | Prompt universal del narrador: la IA ya no está limitada a contenido de Ingenieria de Sistemas, ahora genera para cualquier tema. | Bloque A |
| 2026-10-01 | Consola narrativa scrollable estilo Dwarf Fortress en CombateScreen. El historial de eventos se acumula y el jugador puede deslizar para revisarlo. | Bloque B |
| 2026-10-01 | Coherencia tematica reforzada en prompts: la IA ahora respeta estrictamente el tema indicado. | Bloque 1 |
| 2026-10-01 | Bug de vida del enemigo resuelto (context.watch). Consola narrativa invertida (ultimo evento arriba) y plegable con AnimatedContainer. | Bloque 2 |
| 2026-10-01 | Animacion de ataque/contraataque con emojis temporales (jugador avanza al acertar, enemigo avanza al fallar). | Bloque 3 |
| 2026-10-01 | Pausa pulida: PopScope (back button abre modal), boton pixel-art con estilo dorado, modal con stats en vivo (Score/Ronda/Enemigos/Vida). Score acumulado en el controller: +100 acierto, +125 critico, +500 por ronda (cada 3 enemigos). | Bloque 4 |
| 2026-10-01 | Pausa pulida: PopScope (back button abre modal), boton pixel-art con estilo dorado, modal con stats en vivo (Score/Ronda/Enemigos/Vida). Score acumulado en el controller: +100 acierto, +125 critico, +500 por ronda (cada 3 enemigos). | Bloque 4 |
| 2026-10-01 | Sistema de wildcards implementado: 50/50 (oculta 2 incorrectas), robo de vida (cura 10 HP al acertar), golpe doble (dano x2 al acertar), pista (revela longitud de la correcta). Se inicia con 1 de cada tipo, +1 aleatoria cada 3 enemigos derrotados, maximo 3 por tipo. | Bloque 5 |
| 2026-10-01 | Game feel implementado: hitstop de 80ms, flash rojo en enemigo al recibir dano, zoom+rotacion del emoji del jugador al atacar, particulas de impacto, sacudida de pantalla dual (suave al acertar, fuerte al recibir dano), numeros de dano con outline y tamano dinamico, flash blanco en barras de vida al bajar. | Bloque 5.5 |
| 2026-10-05 | Fix XP proporcional al score. Barra de vida del enemigo reactiva con didUpdateWidget + test de widget. Mensajes de error especificos con accion Reintentar en SnackBar (IA_TIMEOUT, IA_NO_DISPONIBLE, IA_POOL_INVALIDO, etc.). | Fixes pre-expo |
| 2026-10-05 | Prompt del narrador optimizado: dominio literal universal, mapa de conocimiento anti-repeticion con campo concepto, pool narrativo 3 variantes (24 total), vida balanceada 40-60/80-120, JSON compacto. Schema, validador y normalizacion defensiva sincronizados. Detalle de errores en IA para mejor diagnostico. | Backend optimizado |
| 2026-10-05 | Fix critico: pregunta cambia en cada turno (no solo al fallar). Edge Function generar-encuentros-extra implementada (run infinita real). RPC insertar_encuentros_extra. | Fixes pre-expo |
| 2026-10-10 | Fix critico de seguridad: score y XP se calculan ahora en el servidor (formula: enemigos_derrotados * 100 * mult_dificultad). El cliente solo reporta hechos. Validacion server-side: enemigos_derrotados no puede exceder el total de encuentros. Probado en Postman con 3 casos: normal, trampa (ignora 999999) y exceso (400). | Fase 1 - Seguridad |
| 2026-10-10 | Fallback IA: 2 quests semilla nuevas (matematicas basicas, historia universal). El cliente Flutter ofrece 'Jugar quest de respaldo' cuando la IA falla (rate limit, timeout, etc.). Reutiliza la infraestructura existente sin endpoint nuevo. | Fase 1 - Confiabilidad |
| 2026-10-13 | Sistema de racha (combo) implementado: multiplicador de dano escalonado (1.25x en racha 3, 1.5x en 5, 1.75x en 7+), bonos de score (+50/+100), widget animado _IndicadorRacha en CombateScreen y test integral (133 tests pasando). | Fase 2 - Bloque 8 |
| 2026-10-13 | Consola narrativa a color (Bloque 10): registro etiquetado de ataques, criticos, contraataques con nombre del enemigo, uso de comodines y rachas. Parser visual _EstiloLineaNarrativa con bordes y fondos semanticos (134 tests pasando). | Fase 2 - Bloque 10 |
| 2026-10-13 | Balance de puntos y Resumen de Partida (Bloque 9): formula server-side con puntos por enemigos, bonus de racha (+50/+150), bonus de victoria (+150*mult) y 0 XP si muere sin puntos. Tarjeta _ResumenPartidaCard al finalizar combate (135 tests pasando). | Fase 2 - Bloque 9 |
| 2026-10-13 | Balance de puntos y Resumen de Partida (Bloque 9): formula server-side con desglose (enemigos, racha, victoria) y tarjeta _ResumenPartidaCard al finalizar combate. | Fase 2 - Bloque 9 |
| 2026-10-13 | Sistema Riesgo/Recompensa Push Your Luck (Bloque 6): altar entre rondas con Descanso Seguro (+25 HP) vs Pacto Temerario (-10 HP, +30% dano, +5 riesgo, +200 pts/ronda validado en servidor). 136 tests pasando. | Fase 2 - Bloque 6 |
| 2026-10-14 | Eventos con decision entre combates (Bloque 7): arquetipos interactivos Codice Arcano y Mercader del Abismo en encuentros intermedios, integrados con HP, score, comodines y consola narrativa (137 tests pasando). Fase 2 Gameplay completada. | Fase 2 - Bloque 7 |
