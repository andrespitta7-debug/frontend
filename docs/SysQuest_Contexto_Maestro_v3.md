# SysQuest — Documento Maestro de Contexto (v3 - Perfeccionado)

*Versión consolidada y perfeccionada a 05-nov-2026. Refleja fielmente la arquitectura distribuida, el backend serverless en producción, las mecánicas roguelite implementadas, la suite de calidad con SonarQube, las pruebas de carga con Apache JMeter y el modelado BPMN en Bizagi. Es la fuente única de verdad para NotebookLM, LLMs asistentes y sustentaciones académicas.*

---

## 1. Identidad del Proyecto y Equipo

* **Nombre del Producto:** SysQuest — Plataforma Educativa Gamificada Roguelite para Ingeniería de Sistemas.
* **Institución:** Universidad de Cundinamarca (UDeC), Sede Fusagasugá, Programa de Ingeniería de Sistemas y Computación.
* **Asignatura:** Ingeniería de Software I (Código 604527).
* **Docente / Evaluador:** Luiferney Ortiz Parra ("Ing. Ferney Ortiz").
* **Equipo de Desarrollo Core (2 integrantes):**
  * **Jhony Alejandro Palacio Gómez** (Desarrollo Frontend, Motor de Arena, Mecánicas Visuales y UI).
  * **Andrés Orley Pitta Pardo** (Arquitectura Backend, Base de Datos, Edge Functions, Calidad SonarQube, Pruebas de Carga JMeter y DevOps).
* **Equipo Ampliado de Emprendimiento:** 4 personas (los 2 anteriores + 2 integrantes de Innovación y Emprendimiento).
* **Cronograma Académico:** Semestre regular de 16 semanas. Estado actual: **Semana 11 (Fase de Pruebas de Carga, Deploy y Modelo BPMN)**.
* **Presupuesto del Proyecto:** \$0 COP (100% herramientas gratuitas, créditos educativos y tiers libres de uso institucional).
* **Estructura Multi-Repositorio Oficial (GitHub):**
  * **Frontend:** `https://github.com/andrespitta7-debug/frontend`
  * **Backend:** `https://github.com/andrespitta7-debug/backend`
* **Despliegues en Vivo (Producción):**
  * **Frontend Web:** `https://brick-carwash-culprit.ngrok-free.dev` (Túnel HTTPS activo) / Vercel SPA.
  * **Backend Cloud (Supabase):** `https://jctulgfdweeurqbmugot.supabase.co`
  * **Documentación Interactiva Swagger:** `https://jctulgfdweeurqbmugot.supabase.co/functions/v1/swagger-ui`

---

## 2. Visión del Producto y Pivote de Diseño Consolidado

1. **Versión Original (Superada):** Seis minijuegos independientes y aislados (Debug, Database, Algorithm, Network, Architecture, Cyber).
2. **Versión Definitiva Implementada:** Un **único motor RPG Roguelite 2D Pixel Art por turnos**. Las seis temáticas se integran como **categorías de conocimiento y biomas procedurales en la arena**, mientras que un motor de Inteligencia Artificial (Groq / Gemini) genera el contenido educativo de forma infinita y contextual.
3. **Referencias de Diseño:** *Task Bar Hero (TBH)* para el combate en arena estática, *Vampire Survivors* para el árbol de perks y sinergias roguelite, y *Dwarf Fortress* para la bitácora narrativa de combate en consola a color.
4. **Enfoque de Implementación:** Cero motores pesados externos (sin Unity ni Godot). Todo el frontend está construido puramente sobre **Flutter (Dart)** aprovechando Canvas, transformaciones de matriz y sprites optimizados.

---

## 3. Arquitectura del Sistema (Implementada y en Producción)

El sistema opera bajo una **Arquitectura Hexagonal (Puertos y Adaptadores)** en el cliente, desacoplada mediante un **API Gateway Kong** de un backend serverless transaccional:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             SYSQUEST CLIENT (FLUTTER)                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  [Presentation Layer]                                                       │
│    Screens: Login, MainHub (IndexedStack), Combate (Arena 2.5D), Progreso   │
│    Controllers: AuthController, CombateController, GenerarQuestController   │
│    Widgets: RetroBottomNav, RetroPanelBox, BattleFighterWidget, ConsoleLog  │
├─────────────────────────────────────────────────────────────────────────────┤
│  [Domain Layer - Núcleo Puro]                                              │
│    Entities: Usuario, Quest, Encuentro, Opcion, Partida, Progreso, Perk    │
│    Ports (Repositories): AuthRepo, QuestRepo, PartidaRepo, GeneratorRepo    │
│    Use Cases: IniciarSesion, Registrar, Responder, Finalizar, GenerarQuest │
├─────────────────────────────────────────────────────────────────────────────┤
│  [Infrastructure Layer]                                                     │
│    HTTP Adapters: AuthApiClient, HttpAuthRepo, HttpQuestRepo, HttpPartida   │
│    Local Cache: SecureTokenRepository, SharedPreferencesSesionRepo          │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ HTTPS / JSON (Bearer JWT + apikey)
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         KONG API GATEWAY (SUPABASE CLOUD)                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  Enrutamiento Inverso, CORS Headers (*), Verificación de Tokens y Rate Limit│
└──────────────────┬───────────────────────────────────────┬──────────────────┘
                   ▼                                       ▼
┌──────────────────────────────────────┐  ┌───────────────────────────────────┐
│     DENO EDGE FUNCTIONS (TYPESCRIPT) │  │       POSTGRESQL 17 DATABASE      │
├──────────────────────────────────────┤  ├───────────────────────────────────┤
│ • /login & /register                 │  │ • 14 Migraciones Versionadas      │
│ • /obtener-usuario-actual            │  │ • Tablas: usuario, personaje,     │
│ • /generar-quest (Groq AI)           │  │   progreso_usuario, quest,        │
│ • /generar-quest-completa (MegaRun)  │  │   encuentro, opcion_encuentro,    │
│ • /generar-encuentros-extra          │  │   partida, quest_cache            │
│ • /obtener-quest-completa            │  │ • RPCs Atómicas:                  │
│ • /obtener-progreso                  │  │   - crear_run_completa()          │
│ • /finalizar-partida (Anti-Cheat)    │  │   - crear_quest_completa()        │
│ • /swagger-ui (Documentación OpenAPI)│  │   - obtener_progreso_usuario()    │
│                                      │  │ • RLS Policies & Pgcrypto         │
└──────────────────────────────────────┘  └───────────────────────────────────┘
```

### 3.1 Decisiones Técnicas Cerradas y Auditadas
* **Flutter NUNCA llama a PostgreSQL directo:** Toda interacción pasa obligatoriamente por las Edge Functions de Supabase. Esto garantiza la separación estricta de capas impuesta en la revisión técnica.
* **Liquidación y Puntaje Server-Side (Anti-Cheat):** El cliente Flutter reporta únicamente hechos auditables (`enemigos_derrotados`, `rondas_temerarias`, `racha_maxima`). La Edge Function `finalizar-partida` recalcula el score y la XP en el servidor impidiendo trampas de memoria.
* **Persistencia de Estado de Combate:** La entidad `partida` persiste `vida_jugador_actual`, `vida_enemigo_actual`, `encuentro_actual` y `updated_at`. La vida del jugador se conserva durante toda la mazmorra; la del enemigo se reinicia por encuentro.
* **Enum `fuente_generacion` Unificado:** Toda la pila (Base de datos, Deno, Flutter y documentación) maneja exactamente 3 valores: `AI`, `FALLBACK`, `DOCENTE`.
* **Criptografía en Contraseñas:** El hash se delega al motor de Supabase Auth (bcrypt/argon2). Las contraseñas viajan seguras vía TLS 1.3 y no se almacenan hashes planos.

---

## 4. Reglas de Negocio y Mecánicas de Juego Vigentes

| Regla de Juego | Implementación y Valor | Ubicación de la Lógica |
| :--- | :--- | :--- |
| **Vida Inicial del Héroe** | 100 HP | `domain/entities/partida.dart` |
| **Opción Crítica (`calidad: 2`)** | +25 daño al enemigo (afectado por perks y racha) | `ResponderEncuentroUseCase` |
| **Opción Acierto (`calidad: 1`)** | +12 daño al enemigo | `ResponderEncuentroUseCase` |
| **Opción Fallo (`calidad: 0`)** | Contraataque de 15 daño al jugador | `ResponderEncuentroUseCase` |
| **Encuentro con Jefe (`boss`)** | Crítico +10 daño, Acierto +5 daño, Contraataque 25 daño | `ResponderEncuentroUseCase` |
| **Fórmula de Nivel** | `nivel = 1 + floor(xp_total / 100)` | Backend `finalizar-partida` + Dominio |
| **Fórmula de Score** | `enemigos * 100 * mult + bono_racha + bono_victoria` | Server-Side en `finalizar-partida` |
| **Sistema de Racha (Combo)** | 1.25x (Racha 3), 1.5x (Racha 5), 1.75x (Racha 7+) | `CombateController` + Validación |
| **Sistema Riesgo/Recompensa** | Descanso Seguro (+25 HP) vs Pacto Temerario (-10 HP, +30% daño, +200 pts) | Evento inter-rondas validado en server |
| **Comodines (Wildcards)** | 50/50 (oculta 2), Robo de vida (+10 HP), Golpe doble (2x daño), Pista | `CombateController` (1 uso inicial) |
| **Perks Roguelite (15 Perks)** | Modificadores pasivos acumulables de daño, crítico, defensa y velocidad | `RoguelitePerk` en cliente |
| **Timeout de IA y Fallback** | Límite estricto de 10s. Si falla, activa banco semilla | Edge Function `generar-quest` |

---

## 5. Ecosistema de Calidad, Pruebas y DevOps

### 5.1 Calidad de Código con SonarQube
Ambos repositorios se encuentran auditados en la instancia local de SonarQube Community Edition:
* **Frontend (`sysquest-frontend`):**
  * **Quality Gate:** **PASSED (OK)**.
  * **Bugs:** 0 | **Vulnerabilidades:** 0 | **Security Hotspots:** 0 | **Code Smells:** 0.
  * **Cobertura (Coverage):** **>80%** en lógica de negocio (Dominio e Infraestructura), excluyendo vistas de presentación con `sonar.coverage.exclusions`.
  * **Tests Unitarios e Integrados:** **185/185 pasando** (100% de éxito).
* **Backend (`sysquest-backend`):**
  * **Quality Gate:** **PASSED (OK)**.
  * **Bugs:** 0 | **Vulnerabilidades:** 0 (todas las alertas de PRNG resueltas con `crypto.getRandomValues`).
  * **Code Smells:** 0 (expresiones regulares optimizadas sin backtracking).
  * **Líneas de Código:** 3,856 líneas en TypeScript y SQL.

### 5.2 Pruebas de Carga con Apache JMeter (v5.6.3)
Plan de estrés formalizado en `tests/jmeter/sysquest_load_test.jmx` ejecutado contra el backend en la nube:
* **Concurrencia:** 25 usuarios virtuales (hilos) en rampa de aceleración de 5 segundos.
* **Muestreadores:** Swagger UI (entrega estática/gateway), OPTIONS Preflight (CORS), POST Login (validación defensiva).
* **Métricas Obtenidas:**
  * **Tasa de Error:** **0.00%** (30/30 transacciones exitosas sin caídas).
  * **Latencia Mínima:** 88 ms.
  * **Latencia Mediana:** 148 ms.
  * **Latencia Promedio:** 312 ms.
  * **Rendimiento:** 6.08 transacciones/segundo sostenidas.
* **Dashboard HTML Generado:** Disponible en `tests/jmeter/reporte_html/index.html`.

### 5.3 Modelado de Procesos de Negocio en Bizagi (BPMN 2.0)
Documentado en `tests/jmeter/DOCUMENTACION_PRUEBAS_CARGA.md` con los 3 flujos clave:
1. **Proceso 1:** Autenticación de Estudiante y Carga de Perfil/Progreso.
2. **Proceso 2:** Generación Procedural con Inteligencia Artificial y Fallback de Contingencia.
3. **Proceso 3:** Ciclo de Combate Roguelite y Liquidación Segura Anti-trampas.

---

## 6. Estado Actual del Repositorio y Flujo Git

* **Estrategia de Ramas:**
  `feature/SYSQ-XX-descripcion` ➡️ `dev` ➡️ `preprod` ➡️ `main`
* **Regla de Integración:** Ningún commit directo a `main`. Todo avance se fusiona mediante Pull Requests revisados entre Jhony y Andrés.
* **Manejo de Secretos:** Variables de entorno y llaves sensibles (`SUPABASE_SERVICE_ROLE_KEY`, `GROQ_API_KEY`, `GEMINI_API_KEY`) almacenadas fuera del control de versiones mediante `supabase secrets`.

---

## 7. Protocolo de Continuidad para Sesiones de Trabajo

1. **Orden de Verdad:**
   1. Código fuente en GitHub (`dev` / `main`).
   2. Este documento (`SysQuest_Contexto_Maestro_v3.md`).
   3. Bitácora viva en `ESTADO_ACTUAL.md`.
   4. NotebookLM (Gemini Notebook) como fuente pasiva de consulta.
2. **Al arrancar un chat nuevo:** Pegar este documento junto con `ESTADO_ACTUAL.md` para situar al agente inmediatamente en el estado exacto del proyecto sin alucinaciones ni reinicios de contexto.

---
*SysQuest — Ingeniería de Software I — Universidad de Cundinamarca.*
