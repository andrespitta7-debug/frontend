# SysQuest — Documento Maestro de Contexto de Ingeniería (Versión 4.0 - Shark Tank)

*Documento Maestro Integral y Oficial para Sustentación Final (Shark Tank), sincronización de equipo y alimentación de NotebookLM. Refleja el estado real, operativo y auditado del repositorio de Backend, Frontend, Infraestructura, Base de Datos y Calidad.*

---

## 1. Identidad del Proyecto y Equipo

- **Nombre del Sistema:** SysQuest — Plataforma Gamificada de Aprendizaje de Programación con Quests Procedurales mediante Inteligencia Artificial.
- **Institución:** Universidad de Cundinamarca (UDeC), Sede Fusagasugá / Extensión Chía, Programa de Ingeniería de Sistemas y Computación.
- **Asignatura:** Ingeniería de Software I (Código 604527).
- **Docente / Evaluador:** Ing. Luiferney Ortiz Parra ("Ing. Ferney Ortiz").
- **Equipo de Ingeniería y Roles Scrum:**
  - **Andrés Felipe Pitta Pardo:** Tech Lead, Backend & DevOps/QA. Responsable de arquitectura hexagonal, Edge Functions en Deno, modelo relacional PostgreSQL y políticas RLS en Supabase, suite de 203 pruebas automatizadas, pruebas de carga con Apache JMeter 5.6.3, análisis estático SonarQube (CSPRNG y ReDoS), modelado BPMN 2.0 en Bizagi y CI/CD.
  - **Jhony Alejandro Palacio Gómez:** Frontend Lead & UI/UX. Responsable de la interfaz Flutter retro-pixel art, gestión de estado reactiva (Provider/GetIt), desacoplamiento narrativo en la presentación, flujo interactivo del mapa de aventura y combate, y demostración en vivo (Demo Presenter).
- **Entorno Productivo:** Frontend desplegado en Vercel; Backend, Base de Datos y Auth en Supabase Cloud; Modelos LLM en Gemini 1.5 Flash y Groq LLaMA-3.
- **Documento Académico Oficial:** `SysQuest - Ing de Software  V4.0 - SharkTank.docx` (910 KB, 259 párrafos, 13 tablas técnicas).

---

## 2. Visión del Producto y Propuesta de Valor

SysQuest aborda la alta deserción y frustración estudiantil en los primeros semestres de Ingeniería de Sistemas mediante la transformación del aprendizaje de la programación en una experiencia RPG interactiva en 2D:
1. **Mecánica Central:** Combate por turnos contra entidades temáticas de código (*Bugs de Sintaxis*, *Loops Infinitos*, *Punteros Nulos*, *Stack Overflow*).
2. **Generación con IA y Fallback Resiliente:** Los retos pedagógicos son generados en tiempo real mediante LLMs (Gemini / Groq) bajo contratos JSON estrictos. Si la IA o la red experimentan latencia (>5s) o fallos, el sistema conmuta automáticamente y sin interrupción a un **Banco Curado Local de Respaldo**.
3. **Desacoplamiento Narrativo (`semantic_hint`):** La base de datos y la arquitectura separan la ambientación fantástica de la evaluación técnica. El campo `semantic_hint` provee a la IA y a las analíticas un descriptor conceptual técnico puro sin sesgos narrativos.
4. **Economía Virtual:** Canje de monedas de oro en la *Tienda del Mercader* por consumibles tácticos (*Poción de Vida*, *Pergamino de Escudo*, *Pista IA*).
5. **Persistencia Híbrida Offline-First:** Persistencia local en SQLite con sincronización remota transaccional en PostgreSQL de Supabase.

---

## 3. Catálogo y Trazabilidad Integral de Historias de Usuario (HU) y Casos de Uso (CU)

El sistema cuenta con un catálogo formal de **18 Historias de Usuario** y **18 Casos de Uso**. Se priorizaron **12 HUs en el MVP de Fase 1 (Rol Estudiante)**, mientras que **6 HUs (Roles Docente y Administrador) fueron formalmente diferidas a la Fase 2**, contando con modelo de datos y seguridad RLS listos en backend.

| HU ID | Título de Historia de Usuario | CU Asociado | RF / RNF Vinculado | Rol / Actor | Alcance y Estado | Criterio de Aceptación Clave / Entregable |
|:---:|:---|:---:|:---:|:---:|:---:|:---|
| **HU-01** | Registro de nuevo usuario | CU-01 | RF-01 | Estudiante | **Fase 1 (MVP Implementado)** | Registro con credenciales, aceptación obligatoria de 5 términos legales y confirmación por correo. |
| **HU-02** | Inicio de sesión dual y OAuth | CU-02 | RF-02 | Estudiante | **Fase 1 (MVP Implementado)** | Login tolerante a correo electrónico O nombre de usuario; accesos visuales OAuth; token JWT. |
| **HU-03** | Exploración de Mapa de Aventura | CU-03 | RF-03 | Estudiante | **Fase 1 (MVP Implementado)** | Mapa interactivo por nodos temáticos (Variables, Bucles, POO) con progreso visible. |
| **HU-04** | Generación y resolución de quests | CU-04 | RF-04 | Estudiante | **Fase 1 (MVP Implementado)** | Quests de 3 retos con 4 opciones (A/B/C/D); IA con conmutación a Fallback local curado ante error. |
| **HU-05** | Registro de progreso y resultados RPG | CU-05 | RF-05 | Estudiante | **Fase 1 (MVP Implementado)** | Persistencia de nivel, XP, victorias, derrotas y monedas de oro en SQLite y Supabase. |
| **HU-06** | Retroalimentación didáctica y balance | CU-06 | RF-06 | Estudiante | **Fase 1 (MVP Implementado)** | Explicación formativa inmediata tras responder y pantalla de balance con opción 'Volver a Jugar'. |
| **HU-07** | Seguimiento de perfil y estadísticas | CU-07 | RF-07 | Estudiante | **Fase 1 (MVP Implementado)** | Consulta de racha de victorias, experiencia acumulada y alerta reactiva al guardar sin cambios. |
| **HU-08** | Pausa y retirada táctica del combate | CU-08 | RF-03 | Estudiante | **Fase 1 (MVP Implementado)** | Retirada segura desde el combate hacia el mapa preservando la sesión activa. |
| **HU-09** | Uso de comodines en combate | CU-09 | RF-13 | Estudiante | **Fase 1 (MVP Implementado)** | Activación de Poción de Vida (+HP), Pergamino de Escudo y Pista IA consumiendo inventario. |
| **HU-10** | Tienda del Mercader e inventario | CU-10 | RF-13 | Estudiante | **Fase 1 (MVP Implementado)** | Canje de monedas de oro por consumibles y persistencia atómica en inventario. |
| **HU-11** | Clasificación y competencia | CU-11 | RF-12 | Estudiante | **Fase 1 (MVP Implementado)** | Leaderboard de estudiantes ordenado por experiencia acumulada y logros desbloqueados. |
| **HU-12** | Modo offline-first y persistencia local | CU-12 | RNF-05 | Estudiante | **Fase 1 (MVP Implementado)** | Operatividad completa sin conexión a internet mediante SQLite y banco curado. |
| **HU-13** | Crear contenido educativo | CU-13 | RF-08 | Docente | **Fase 2 (Diferido Post-MVP)** | Tabla relacional `CONTENIDO_EDUCATIVO` y políticas RLS creadas en PostgreSQL. |
| **HU-14** | Editar contenido educativo | CU-14 | RF-08 | Docente | **Fase 2 (Diferido Post-MVP)** | Endpoints y soporte de base de datos implementados; UI docente en backlog de Fase 2. |
| **HU-15** | Desactivar contenido educativo | CU-15 | RF-08 | Docente | **Fase 2 (Diferido Post-MVP)** | Soporte de borrado lógico relacional e integridad referencial asegurada. |
| **HU-16** | Consultar estadísticas de aula | CU-16 | RF-09 | Docente | **Fase 2 (Diferido Post-MVP)** | Vistas analíticas agregadas diseñadas en PostgreSQL para futura interfaz. |
| **HU-17** | Gestionar cuentas y roles de usuario | CU-17 | RF-10 | Administrador | **Fase 2 (Diferido Post-MVP)** | Esquema RBAC funcional en tabla `ROL` con soporte de asignación de roles. |
| **HU-18** | Configuración global de plataforma | CU-18 | RF-11 | Administrador | **Fase 2 (Diferido Post-MVP)** | Parametrización general y pistas de auditoría implementadas a nivel de base de datos. |

---

## 4. Trazabilidad Vertical Profunda de HUs Críticas

### 4.1 HU-04: Generación Dinámica y Resolución de Quests de Programación
- **Criterios Gherkin:**
  - *Escenario 1 (Generación exitosa con IA):*
    ```gherkin
    DADO QUE el estudiante autenticado selecciona un nodo temático en el Mapa de Aventura,
    CUANDO el sistema invoca la Edge Function 'generar-quest' y el LLM responde en < 5.0 segundos,
    ENTONCES se instancian 3 encuentros evaluativos con 4 opciones estructuradas (A, B, C, D), una única respuesta válida y una pista semántica oculta,
    Y el combate RPG inicia presentando al enemigo temático correspondiente.
    ```
  - *Escenario 2 (Activación transparente de Fallback Resiliente):*
    ```gherkin
    DADO QUE ocurre una caída de red, indisponibilidad del servicio de IA o latencia > 5.0 s,
    CUANDO el caso de uso 'GenerarQuestUseCase' captura la excepción,
    ENTONCES el sistema conmuta de forma automática e inmediata al Banco Curado Local garantizado,
    Y despliega el diálogo informativo retro 'DialogoAlertaSysQuest' permitiendo al estudiante jugar sin interrupción.
    ```
- **Mapeo por Capas:**
  - *Presentación:* `CombateScreen`, `CombateController`, `DialogoAlertaSysQuest`.
  - *Dominio:* `GenerarQuestUseCase`, contrato `QuestRepository`, entidades `Quest`, `Encuentro`, `OpcionRespuesta`.
  - *Datos / Infraestructura:* `SupabaseQuestRepository`, `OfflineQuestRepository` (SQLite), Edge Function `generar-quest` (Deno), tablas `QUEST`, `ENCUENTRO` (columna `semantic_hint`), `OPCION_RESPUESTA`.
  - *Pruebas:* `generar_quest_usecase_test.dart`, `combate_controller_test.dart`, `e2e_adventure_flow_test.dart`.

### 4.2 HU-07: Seguimiento de Perfil, Progresión y Estadísticas
- **Criterios Gherkin:**
  - *Escenario 1 (Consulta de progreso):*
    ```gherkin
    DADO QUE el estudiante accede a su pantalla de perfil,
    CUANDO el controlador carga los registros del repositorio,
    ENTONCES se presentan nivel actual, XP acumulada, oro, racha de victorias consecutivas y tasa de aciertos.
    ```
  - *Escenario 2 (Control reactivo de guardado sin cambios):*
    ```gherkin
    DADO QUE el estudiante abre el diálogo de edición de su avatar o datos de perfil,
    CUANDO presiona 'Guardar' sin haber alterado ningún campo,
    ENTONCES el sistema despliega la notificación retro 'No has editado nada en tu perfil',
    Y no emite ninguna solicitud de red innecesaria hacia el backend.
    ```
- **Mapeo por Capas:**
  - *Presentación:* `PerfilScreen`, `PerfilController`.
  - *Dominio:* `ObtenerProgresoUseCase`, `ActualizarPerfilUseCase`, entidad `UsuarioProgreso`.
  - *Datos / Infraestructura:* Edge Function `obtener-progreso`, tabla `USUARIO_PROGRESO` con RLS, sincronización SQLite.
  - *Pruebas:* `perfil_controller_test.dart`.

---

## 5. Modelado de Procesos BPMN 2.0 en Bizagi Process Modeler

Los flujos operativos clave fueron formalizados en BPMN 2.0 mediante Bizagi:
1. **Proceso 1 (Autenticación y Registro con Términos Legales):**
   - *Carriles:* Estudiante, Frontend Flutter, Supabase Auth (GoTrue), Base de Datos PostgreSQL.
   - *Gateways:* Validación de 5 cláusulas legales obligatorias; resolución dual email/username.
2. **Proceso 2 (Generación Procedural y Combate con Fallback Resiliente):**
   - *Carriles:* Estudiante, CombateController, Supabase Edge Function `generar-quest`, Proveedor LLM (Gemini/Groq), Banco Curado Local.
   - *Gateways / Eventos:* Temporizador de 5.0 s; validación de esquema JSON; conmutación automática a Fallback local con diálogo informativo.
3. **Proceso 3 (Tienda del Mercader y Persistencia Transaccional):**
   - *Carriles:* Estudiante, TiendaScreen, MercaderController, SQLite Local, Supabase Database.
   - *Gateways:* Validación de balance de oro; transacción atómica de deducción y acreditación en inventario.

---

## 6. Mapeo de Arquitectura Hexagonal a Principios SOLID y 12-Factor App

### 6.1 Principios SOLID
- **S (Single Responsibility):** Clases segregadas con responsabilidad única: `EmailValidator`, `PasswordValidator`, `CombateCalculator` (fórmulas de daño/vida), `NarrativeDecoupler` (pistas semánticas).
- **O (Open/Closed):** Patrón Estrategia en `ConsumibleStrategy` (`PocionVidaStrategy`, `PergaminoEscudoStrategy`, `PistaIAStrategy`), permitiendo añadir nuevos consumibles sin modificar el bucle de combate.
- **L (Liskov Substitution):** `OfflineQuestRepository` y `SupabaseQuestRepository` sustituibles bajo la abstracción `QuestRepository`.
- **I (Interface Segregation):** Interfaces específicas: `IAuthRepository`, `IQuestRepository`, `IProgresoRepository`, `ITiendaRepository`.
- **D (Dependency Inversion):** Controladores y casos de uso dependen de abstracciones, inyectadas mediante `ServiceLocator` (GetIt) facilitando mocks en pruebas.

### 6.2 Adopción de Twelve-Factor App
- **Factor I (Codebase):** Repositorios rastreados en Git con ramas de aislamiento (`main`, `dev`, `feature/*`).
- **Factor III (Config):** Configuración en variables de entorno (`.env`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GEMINI_API_KEY`).
- **Factor IV (Backing Services):** PostgreSQL, Supabase Auth y APIs de LLM tratados como recursos vinculados vía URL/credenciales.
- **Factor VI (Processes):** Edge Functions en Deno son procesos sin estado (stateless) de alta escalabilidad.
- **Factor IX (Disposability):** Tiempos de arranque en borde <200 ms y apagado limpio.
- **Factor X (Dev/Prod Parity):** Paridad de base de datos asegurada mediante migraciones SQL versionadas idénticas.

---

## 7. Estrategia de Pruebas y Resultados Cuantitativos

### 7.1 Métricas de Pruebas Automatizadas (203 Tests Totales)
- **Pruebas Unitarias y Widgets (Flutter / Dart Test):** **185/185 pruebas aprobadas (100%)** en 11.2 segundos. Cobertura >80% en lógica de negocio y dominio.
- **Pruebas de Servicios Serverless (Deno Test Runner):** **18/18 pruebas aprobadas (100%)** sobre las 10 Edge Functions.
- **Pruebas de Integración y Persistencia:** Aprobadas con SQLite In-Memory y consistencia transaccional ACID.
- **Pruebas End-to-End (E2E):** Flujo completo verificado en `e2e_adventure_flow_test.dart`.

### 7.2 Pruebas de Carga y Rendimiento con Apache JMeter 5.6.3
Plan de pruebas formal ejecutado con Java 25 y JMeter 5.6.3 (`tests/jmeter/sysquest_load_test.jmx`):
- **Grupo de Hilos:** 30 hilos concurrentes con rampa de subida de 10 segundos.
- **Muestras Totales:** 30 peticiones HTTP registradas.
- **Tasa de Error:** **0.00% (cero solicitudes fallidas)**.
- **Latencia Promedio (Avg Latency):** **312 ms**.
- **Percentil 90 (p90):** **495 ms**.
- **Percentil 95 (p95):** **580 ms**.
- **Throughput Sostenido:** **2.8 req/s**.

### 7.3 Aseguramiento de Calidad Estática con SonarQube
- **Quality Gate:** **PASSED**.
- **Vulnerabilidades:** 0.
- **Bugs:** 0.
- **Security Hotspots:** 100% revisados y remediados.
- **Mitigación CSPRNG:** Reemplazo de `Math.random()` por generadores criptográficamente seguros (`crypto.getRandomValues` en Deno y `Random.secure()` en Dart) para aleatoriedad de dados RPG e IDs de sesión.
- **Mitigación Anti-ReDoS:** Expresiones regulares de validación refactorizadas para eliminar recursión exponencial catastrófica.

---

## 8. Distribución de Repositorios y Ramas

- **Frontend:** `https://github.com/andrespitta7-debug/frontend`
  - Rama de entrega/producción: `main`
  - Rama de características y hotfix cloud: `feature/hotfix-cloud-auth-sonar` (Commit `1911175`)
- **Backend:** `https://github.com/andrespitta7-debug/backend`
  - Rama de integración: `dev`
  - Rama de características y rendimiento: `feature/sec-perf-jmeter` (Commit `177f733`)
