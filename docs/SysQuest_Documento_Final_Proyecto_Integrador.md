
# 1. OBJETIVO DEL DOCUMENTO

El objetivo del presente documento es consolidar de forma integral, rigurosa y verificable todo el proceso técnico, arquitectónico y funcional desarrollado durante el semestre académico para la plataforma SysQuest. La documentación evidencia cómo el equipo de ingeniería diseñó, construyó, probó y validó una solución de software orientada a la gamificación del aprendizaje de la programación, bajo estándares cercanos al entorno empresarial real.

Este informe técnico refleja detalladamente el análisis del problema pedagógico, el diseño modular bajo Clean Architecture y Arquitectura Hexagonal, la orquestación de microservicios con Docker y Supabase self-hosted, la implementación estricta de los principios SOLID y la metodología Twelve-Factor App, la suite automatizada de 203 pruebas de ingeniería (185 pruebas unitarias/widgets en Flutter y 18 pruebas en Deno), el aseguramiento estático de calidad y ciberseguridad con SonarQube (mitigando vulnerabilidades críticas de CSPRNG y ReDoS), y la ejecución formal de 9 escenarios de pruebas de carga y estrés con Apache JMeter 5.6.3, demostrando el criterio ingenieril y la capacidad de defensa técnica del equipo.

# 2. ESTRUCTURA GENERAL DEL DOCUMENTO

El presente informe se encuentra estructurado en 23 capítulos técnicos numerados conforme a las directrices oficiales de evaluación del proyecto integrador:

• Capítulo 1: Objetivo del Documento
• Capítulo 2: Estructura General del Documento
• Capítulo 3: Portada y Ficha Técnica Institucional
• Capítulo 4: Tabla de Contenido
• Capítulo 5: Introducción y Contexto de la Solución
• Capítulo 6: Descripción del Proyecto (Problema, Objetivos y Usuarios)
• Capítulo 7: Metodología y Gestión del Proyecto (Enfoque Ágil, Scrum y Cronograma)
• Capítulo 8: Requerimientos del Sistema (Requerimientos Funcionales y No Funcionales)
• Capítulo 9: Historias de Usuario (Catálogo Integral de 18 HUs con Criterios de Aceptación)
• Capítulo 10: Casos de Uso (Especificación Formal, Flujos Principales y Alternos)
• Capítulo 11: Diseño y Modelado del Sistema (MER, Modelo Relacional y Diccionario de Datos con semantic_hint)
• Capítulo 12: Arquitectura del Software (Hexagonal, Componentes, Estructura Backend y Frontend)
• Capítulo 13: Implementación Técnica (Tecnologías, Endpoints Serverless y Vistas Reactivas)
• Capítulo 14: Implementación de Principios SOLID (Explicación Técnica, Mapeo y Código Fuente)
• Capítulo 15: Implementación de la Metodología Twelve-Factor App (Matriz de Conformidad y Evidencias)
• Capítulo 16: Implementación de Docker (Dockerfile Multi-Stage, Docker Compose y Resolución de Feedback de Seguridad)
• Capítulo 17: Implementación de SonarQube (Quality Gate, Métricas, CSPRNG y Blindaje Anti-ReDoS)
• Capítulo 18: Pruebas Funcionales (Colección Postman, APIs REST y Respuestas JSON)
• Capítulo 19: Pruebas End to End (Validación Integral del Flujo Jugador - Motor - Persistencia)
• Capítulo 20: Pruebas de Carga y Estrés (9 Escenarios Obligatorios con Apache JMeter 5.6.3 y Análisis Técnico)
• Capítulo 21: Dificultades y Retos Encontrados (Problemas Técnicos, Integración y Mitigaciones)
• Capítulo 22: Conclusiones y Aprendizajes de Ingeniería
• Capítulo 23: Anexos y Enlaces a Repositorios

# 3. PORTADA

| Parámetro Institucional | Detalle |
|---|---|
| **Institución Universitaria:** | Universidad de Cundinamarca (UDeC) - Extensión Chía / Sede Fusagasugá |
| **Facultad y Programa:** | Facultad de Ingeniería - Programa de Ingeniería de Sistemas y Computación |
| **Asignatura:** | Ingeniería de Software I (Código 604527) |
| **Nombre del Proyecto:** | SysQuest — Plataforma Gamificada de Aprendizaje con Quests Procedurales por IA |
| **Integrantes del Equipo:** | Andrés Felipe Pitta Pardo (Tech Lead / DevOps / QA / Backend)<br>Jhony Alejandro Palacio Gómez (Frontend Lead / UI/UX / Demo Presenter) |
| **Docente / Evaluador:** | Ing. Luiferney Ortiz Parra |
| **Semestre y Periodo:** | V Semestre — Periodo Académico 2026-II |
| **Fecha de Sustentación:** | Noviembre de 2026 |

# 4. TABLA DE CONTENIDO

| Sección | Título del Capítulo Técnico | Enfoque / Entregable Clave |
|---|---|---|
| 1 | **Objetivo del Documento** | Propósito técnico e ingenieril |
| 2 | **Estructura General del Documento** | Mapa de los 23 capítulos oficiales |
| 3 | **Portada** | Identificación institucional y roles |
| 4 | **Tabla de Contenido** | Índice de navegación técnica |
| 5 | **Introducción** | Problemática, objetivos y alcance |
| 6 | **Descripción del Proyecto** | Problema, objetivos general/específicos y usuarios |
| 7 | **Metodología y Gestión del Proyecto** | Scrum, 4 Sprints, roles y cronograma de iteraciones |
| 8 | **Requerimientos del Sistema** | 13 RFs y 11 RNFs con criterios de validación |
| 9 | **Historias de Usuario** | Catálogo de 18 HUs con criterios de aceptación Gherkin |
| 10 | **Casos de Uso** | Especificación formal de casos de uso y flujos alternos |
| 11 | **Diseño y Modelado del Sistema** | MER, Modelo Relacional y Diccionario de Datos (17 tablas) |
| 12 | **Arquitectura del Software** | Arquitectura Hexagonal, Clean Arch, Deno y Flutter |
| 13 | **Implementación Técnica** | Stack tecnológico, 10 Edge Functions y vistas Flutter |
| 14 | **Implementación de Principios SOLID** | Mapeo formal de S-O-L-I-D con fragmentos de código |
| 15 | **Implementación de los 12 Factors App** | Matriz de cumplimiento de Twelve-Factor App en la nube |
| 16 | **Implementación de Docker** | Dockerfile multi-stage, Compose v2 y resolución de feedback |
| 17 | **Implementación de SonarQube** | Quality Gate PASSED, 0 bugs, CSPRNG y blindaje ReDoS |
| 18 | **Pruebas Funcionales** | Colección Postman, APIs REST y respuestas JSON |
| 19 | **Pruebas End to End** | Flujo E2E completo: mapa -> combate -> backend -> progreso |
| 20 | **Pruebas de Carga y Estrés** | 9 escenarios obligatorios con Apache JMeter 5.6.3 |
| 21 | **Dificultades y Retos Encontrados** | Retos de IA, persistencia híbrida y mitigaciones |
| 22 | **Conclusiones** | Aprendizajes técnicos, arquitectura y buenas prácticas |
| 23 | **Anexos** | Repositorios Git, scripts SQL y archivos de soporte |

# 5. INTRODUCCIÓN

El aprendizaje de los fundamentos de programación en los programas universitarios de Ingeniería de Sistemas y Computación enfrenta tradicionalmente barreras pedagógicas significativas, caracterizadas por metodologías estáticas, retroalimentación tardía y una alta tasa de deserción estudiantil en los primeros semestres académicos. Frente a esta problemática, SysQuest surge como una plataforma gamificada innovadora que fusiona las mecánicas inmersivas de los videojuegos de rol (RPG) en 2D con la capacidad adaptativa de la Inteligencia Artificial generativa para la creación en tiempo real de retos evaluativos de código.

El objetivo del sistema es transformar los conceptos abstractos de la algoritmia (variables, condicionales, ciclos y programación orientada a objetos) en combates tácticos por turnos contra entidades de código defectuoso (Bugs de Sintaxis, Loops Infinitos, Punteros Nulos), brindando retroalimentación formativa inmediata e incentivando la maestría técnica mediante progresión RPG y una economía virtual interna.

El alcance del proyecto consolida un Producto Mínimo Viable (MVP) enfocado en el rol Estudiante, soportado por una arquitectura de microservicios en contenedores Docker que replica el stack self-hosted de Supabase (PostgreSQL, GoTrue, PostgREST y Kong Gateway) junto con un cliente web en Flutter optimizado mediante compilación multi-stage y servidor Nginx. El desarrollo se fundamentó en un enfoque ágil riguroso guiado por Scrum, asegurado mediante 203 pruebas automatizadas y validado bajo perfiles de carga concurrente con Apache JMeter 5.6.3.

# 6. DESCRIPCIÓN DEL PROYECTO

## 6.1. Problema Identificado

• Necesidad Detectada: La enseñanza de la algoritmia y programación inicial depende con frecuencia de ejercicios algorítmicos descontextualizados, jueces en línea austeros y evaluaciones periódicas que no proporcionan retroalimentación didáctica en el instante en que el estudiante comete el error conceptual.
• Impacto del Problema: Esta fricción genera desmotivación, síndrome del impostor, frustración cognitiva temprana y tasas de reprobación superiores al 40% en materias iniciales de ciencias de la computación, limitando el desarrollo temprano de habilidades analíticas.
• Contexto Empresarial y Académico: La industria del software demanda ingenieros capaces de depurar código, comprender contratos de interfaz y razonar sobre arquitecturas desacopladas desde etapas tempranas. SysQuest cierra esta brecha acercando al estudiante a entornos interactivos que simulan la resolución de incidentes de desarrollo en un contexto lúdico seguro y motivador.

## 6.2. Objetivo General del Sistema

Desarrollar y validar una plataforma de software gamificada basada en combates RPG por turnos y generación procedural de desafíos pedagógicos asistida por Inteligencia Artificial generativa, orientada a fortalecer las competencias de programación y algoritmia en estudiantes de Ingeniería de Sistemas bajo una arquitectura robusta, escalable y tolerante a fallos.

## 6.3. Objetivos Específicos

1. Diseñar e implementar un motor de combate por turnos en Flutter Web estructurado en Clean Architecture, que interprete respuestas a retos de código traduciéndolas en dinámicas de daño, defensa y recompensas lúdicas.
2. Orquestar un backend serverless en Supabase Edge Functions (Deno) capaz de formular preguntas con 4 opciones estructuradas mediante modelos LLM (Gemini 1.5 Flash y Groq LLaMA-3), integrando un mecanismo de Fallback Resiliente local ante latencias o caídas de red.
3. Implementar un esquema de persistencia híbrida transaccional (SQLite local y PostgreSQL remoto) con seguridad a nivel de fila (Row Level Security - RLS) y desacoplamiento narrativo asistido por el atributo 'semantic_hint'.
4. Desplegar la infraestructura mediante microservicios en Docker Compose, aplicando análisis estático de calidad con SonarQube y certificando el rendimiento con Apache JMeter 5.6.3 bajo escenarios de concurrencia y estrés.

## 6.4. Usuarios del Sistema

El sistema define un control de acceso basado en roles (RBAC) estructurado en el modelo relacional. Para el MVP actual (Fase 1), el sistema concentra el 100% de la funcionalidad interactiva en el perfil de Estudiante, manteniendo el soporte relacional y de backend listo para la incorporación de docentes y administradores en Fase 2:

| Rol / Tipo de Usuario | Estado de Alcance | Descripción del Perfil | Funcionalidades Principales |
|---|---|---|---|
| **Estudiante (Jugador)** | Fase 1 (MVP Operativo) | Usuario principal y núcleo de la experiencia interactiva. Estudiantes universitarios de ingeniería. | Exploración del Mapa de Aventura; combate táctico contra bugs; resolución de retos con IA o banco curado; uso de consumibles; compra en Tienda del Mercader; consulta de nivel, XP y leaderboard. |
| **Docente (Profesor)** | Fase 2 (Backlog Post-MVP) | Educadores que orientan asignaturas de programación. Soporte de schema listo en PostgreSQL. | Creación y edición de reactivos pedagógicos en 'CONTENIDO_EDUCATIVO'; auditoría de preguntas generadas por IA; visualización de analíticas grupales de rendimiento. |
| **Administrador** | Fase 2 (Backlog Post-MVP) | Personal de soporte institucional y gobierno de datos. Soporte RBAC listo en tabla 'ROL'. | Gestión global de cuentas y roles de usuario; revocación de accesos; monitoreo de auditoría; parametrización de variables globales del sistema. |

# 7. METODOLOGÍA Y GESTIÓN DEL PROYECTO

## 7.1. Enfoque Metodológico Adoptado

• Enfoque Seleccionado: El proyecto adoptó un marco ágil iterativo e incremental basado en Scrum, complementado con prácticas de ingeniería de Extreme Programming (XP) tales como integración continua, desarrollo guiado por pruebas (TDD) en componentes críticos de dominio, refactorización continua y propiedad colectiva del código.
• Justificación Técnica: La integración de modelos de lenguaje (LLM) y la persistencia híbrida introdujeron incertidumbres tecnológicas tempranas (latencia en generación procedural, variabilidad de contratos JSON, cold starts en web). Un enfoque en cascada tradicional habría congelado requisitos inviables; el enfoque ágil permitió pivotar tempranamente desde una arquitectura de múltiples minijuegos aislados hacia un motor unificado de combate RPG con generación dinámica de quests y fallback garantizado.
• Ventajas para el Proyecto: Entrega continua de valor ejecutable en cada iteración; detección temprana de cuellos de botella en Edge Functions; y alineación permanente con el Product Backlog evaluado por el docente y el comité evaluador.

## 7.2. Uso de Scrum

El ciclo de vida del desarrollo se organizó en 4 Sprints formales de dos a tres semanas de duración cada uno:

• Product Backlog: Centralizado y priorizado en GitHub Projects / Jira, estructurado en Historias de Usuario con criterios de aceptación en sintaxis Gherkin y estimación en puntos de historia (Planning Poker basado en la serie Fibonacci).
• Sprints Ejecutados:
   - Sprint 1 (Fundamentos y Autenticación): Arquitectura hexagonal, persistencia SQLite local, Supabase Auth GoTrue, registro y login dual (HU-01, HU-02).
   - Sprint 2 (Motor de Combate y Quests): Lógica de combate RPG, cálculo de daño y vida, entidades de dominio, integración inicial con LLMs (HU-03, HU-04, HU-05).
   - Sprint 3 (Resiliencia, Tienda y Perfil): Implementación del Fallback Resiliente local, Tienda del Mercader con consumibles, tracking de nivel/XP y ranking (HU-06, HU-07, HU-08, HU-09, HU-10, HU-11, HU-12).
   - Sprint 4 (Aseguramiento, Contenedores y Carga): Docker Compose con microservicios, Quality Gate en SonarQube, suite de 203 pruebas y benchmarking con JMeter 5.6.3.
• Organización del Trabajo y Roles Scrum:
   - Andrés Felipe Pitta Pardo (Tech Lead, Backend & DevOps/QA): Arquitectura de microservicios, Supabase Edge Functions, base de datos PostgreSQL/RLS, SonarQube, suite de pruebas automatizadas y pruebas de carga con JMeter.
   - Jhony Alejandro Palacio Gómez (Frontend Lead & UI/UX): Diseño de pantallas retro pixel-art, gestión de estado en Flutter (Provider/GetIt), animaciones, desacoplamiento narrativo y preparación del demo en vivo.

## 7.3. Cronograma de Desarrollo

| Etapa / Iteración | Semanas | Objetivo Técnico Principal | Entregables Verificados |
|---|---|---|---|
| **Etapa 1: Análisis y Requisitos** | Sem. 1 - 4 | Levantamiento de RF/RNF, análisis de problemáticas pedagógicas y pivote de diseño. | Documento de especificación V1.8, diseño de prototipos UI y backlog inicial. |
| **Sprint 1: Núcleo y Auth** | Sem. 5 - 7 | Arquitectura limpia en Flutter, auth dual (email/username) y base de datos local SQLite. | Módulo de login/registro, migraciones SQL versionadas y 35 tests unitarios. |
| **Sprint 2: Motor de Quests** | Sem. 8 - 10 | Combate por turnos RPG, generador serverless de quests en Deno y conexión con Gemini. | Pantalla de combate, contratos JSON de retos y suite de 80 tests. |
| **Sprint 3: Tienda y Resiliencia** | Sem. 11 - 13 | Mecanismo de Fallback local curado, Tienda del Mercader, consumibles y tracking de perfil. | Banco curado offline, inventario de consumibles y 138 tests unitarios. |
| **Sprint 4: Calidad y Despliegue** | Sem. 14 - 16 | Docker Compose, SonarQube (CSPRNG/ReDoS), 203 pruebas totales y JMeter 5.6.3. | Contenedores operativos, Quality Gate Passed, reporte JMeter y sustentación final. |

# 8. REQUERIMIENTOS DEL SISTEMA

## 8.1. Requerimientos Funcionales

| Código | Nombre del Requerimiento | Descripción Técnica y Funcional | Prioridad |
|---|---|---|---|
| **RF-01** | **Registro y confirmación de usuarios** | Permitir el registro de usuarios validando la aceptación obligatoria de los 5 Términos y Condiciones Legales y desplegando alerta modal de activación de cuenta. | Alta (Must) |
| **RF-02** | **Inicio de sesión dual y OAuth** | Permitir autenticarse indistintamente mediante correo electrónico O nombre de usuario registrado, gestionando tokens JWT y ofreciendo accesos OAuth visuales. | Alta (Must) |
| **RF-03** | **Exploración del Mapa de Aventura** | Presentar un mapa interactivo estructurado por nodos temáticos de programación (Variables, Condicionales, Ciclos, POO) que guían la progresión del estudiante. | Alta (Must) |
| **RF-04** | **Generación y resolución de quests** | Generar proceduralmente quests de 3 retos de código con 4 opciones (A, B, C, D) mediante IA, conmutando automáticamente al banco curado ante fallos de conexión. | Alta (Must) |
| **RF-05** | **Registro de resultados y progreso RPG** | Persistir el resultado de las partidas, actualizando experiencia (XP), nivel, victorias, derrotas y monedas de oro acumuladas en SQLite y Supabase PostgreSQL. | Alta (Must) |
| **RF-06** | **Retroalimentación didáctica y balance** | Proveer retroalimentación formativa inmediata tras cada respuesta y desplegar una pantalla de balance final con opción 'Volver a Jugar con otro tema' en derrota. | Alta (Must) |
| **RF-07** | **Seguimiento de perfil y estadísticas** | Permitir consultar el perfil, racha de victorias y notificar reactivamente 'No has editado nada en tu perfil' cuando se envíe el formulario sin modificaciones. | Media (Should) |
| **RF-08** | **Gestión docente de contenido** | Soportar la creación, edición y auditoría de reactivos pedagógicos por docentes en PostgreSQL (Diferido a Fase 2; modelo relacional implementado). | Baja (Fase 2) |
| **RF-09** | **Analíticas docentes de aula** | Generar reportes y métricas agregadas sobre rendimiento estudiantil y tópicos de mayor reprobación (Diferido a Fase 2; backend listo). | Baja (Fase 2) |
| **RF-10** | **Administración de cuentas** | Gestionar cuentas, revocación de accesos y asignación de roles mediante consola administrativa (Diferido a Fase 2; schema RBAC listo). | Baja (Fase 2) |
| **RF-11** | **Configuración global de plataforma** | Parametrizar variables de sistema y mantenimiento institucional (Diferido a Fase 2; soporte listo en base de datos). | Baja (Fase 2) |
| **RF-12** | **Clasificación y Leaderboard** | Permitir al estudiante consultar su posición en el ranking general según experiencia acumulada y logros obtenidos. | Media (Should) |
| **RF-13** | **Tienda del Mercader y Consumibles** | Permitir canjear monedas de oro por consumibles tácticos (Poción de Vida, Pergamino de Escudo, Pista IA) y almacenarlos atómicamente en el inventario. | Alta (Must) |

## 8.2. Requerimientos No Funcionales

| Código | Categoría ISO 25010 | Descripción Técnica | Criterio de Validación Cuantitativo |
|---|---|---|---|
| **RNF-01** | **Seguridad** | Cifrado de credenciales mediante bcrypt, gestión de identidades con Supabase Auth y tokens JWT RFC 7519 sin secretos en texto plano. | Inspección estática de código con SonarQube (0 credenciales expuestas) y cifrado obligatorio. |
| **RNF-02** | **Seguridad / Autorización** | Control de acceso basado en roles (RBAC) y políticas Row Level Security (RLS) en PostgreSQL; rol predeterminado 'ESTUDIANTE'. | Validación de políticas RLS: usuarios no pueden leer ni mutar registros ajenos en partidas. |
| **RNF-03** | **Eficiencia de Desempeño** | Tiempos de respuesta reducidos: consultas locales en caché < 50 ms y turnos de combate < 100 ms. | Métricas de latencia en Flutter DevTools y benchmarks locales de persistencia. |
| **RNF-04** | **Eficiencia / Usabilidad** | Eliminación del parpadeo en blanco inicial (Cold Start) en Flutter Web durante la carga del motor CanvasKit. | Splash screen nativo retro en CSS coordinado con 'flutter_bootstrap.js'; tiempo a primer frame < 1.5 s. |
| **RNF-05** | **Fiabilidad / Disponibilidad** | Soporte de modo offline-first garantizando jugabilidad continua ante pérdida de conectividad a internet. | Prueba de desconexión de red: juego conmuta a SQLite local y banco curado manteniendo el 99.9% de operabilidad. |
| **RNF-06** | **Capacidad y Concurrencia** | Soporte de concurrencia y latencia estable validado bajo pruebas de carga con Apache JMeter 5.6.3. | Reporte JMeter 5.6.3 con 30 hilos concurrentes: 0.00% tasa de error y p95 < 580 ms. |
| **RNF-07** | **Mantenibilidad / Extensibilidad** | Capacidad de incorporar nuevos nodos temáticos, enemigos y consumibles sin alterar el bucle principal de combate. | Uso de patrones Strategy y Repository: nuevas estrategias de consumibles no alteran 'CombateController'. |
| **RNF-08** | **Usabilidad / Aprendizaje** | Curva de aprendizaje reducida para estudiantes novatos de ingeniería. | Estudiante nuevo completa su primer registro, selección de nodo y combate en menos de 3 minutos. |
| **RNF-09** | **Usabilidad / Consistencia** | Diseño visual cohesivo retro pixel-art con paleta Midnight Dark (#0F111A) y acentos neón (#35E88E, #FFD15C). | Evaluación de contraste WCAG AA en diseño visual y tipografía monospace retro. |
| **RNF-10** | **Mantenibilidad / Modularidad** | Separación estricta de capas mediante Clean Architecture y principios SOLID, respaldada por suite automatizada. | 203 pruebas automatizadas ejecutadas (185 Flutter + 18 Deno) con 100% de éxito y cobertura >80%. |
| **RNF-11** | **Fiabilidad / Integridad** | Consistencia transaccional ACID en SQLite local y PostgreSQL de Supabase durante la actualización de balances de oro e items. | Transacciones atómicas RPC probadas sin condiciones de carrera ni duplicidad de consumibles. |

# 9. HISTORIAS DE USUARIO

| ID | Historia de Usuario | Prioridad | Criterios de Aceptación |
|---|---|---|---|
| **HU-01** | COMO estudiante QUIERO registrarme con correo y contraseña PARA acceder a mi perfil de juego. | Alta (Fase 1) | • DADO que ingreso credenciales válidas y acepto los Términos y Condiciones Legales (5 cláusulas), CUANDO presiono 'Registrarse', ENTONCES se crea la cuenta en Supabase Auth y se despliega alerta de activación por correo. |
| **HU-02** | COMO estudiante QUIERO iniciar sesión con correo O nombre de usuario PARA no depender únicamente del email. | Alta (Fase 1) | • DADO que ingreso mi username registrado o mi email y clave correcta, CUANDO inicio sesión, ENTONCES el gateway valida la identidad, emite un token JWT y accedo al Mapa de Aventura. |
| **HU-03** | COMO estudiante QUIERO explorar un mapa interactivo con nodos temáticos PARA seleccionar desafíos según mi nivel. | Alta (Fase 1) | • DADO que navego el Mapa de Aventura, CUANDO selecciono un nodo temático (Variables, Condicionales, Ciclos, POO), ENTONCES visualizo la dificultad, el enemigo asignado y la opción de iniciar el calabozo. |
| **HU-04** | COMO estudiante QUIERO resolver retos generados por IA o banco curado PARA practicar conceptos de programación. | Alta (Fase 1) | • DADO que inicio un combate, CUANDO el sistema invoca 'generar-quest', ENTONCES se presentan 3 retos con 4 opciones (A, B, C, D); si la IA tarda >5s o falla, conmuta automáticamente al banco curado con notificación. |
| **HU-05** | COMO estudiante QUIERO que mi progreso y resultados se registren PARA subir de nivel y acumular recompensas. | Alta (Fase 1) | • DADO que termino una partida (victoria o derrota), CUANDO el controller envía el resultado, ENTONCES se actualizan XP, nivel, oro y estadísticas en SQLite y Supabase mediante transacción atómica. |
| **HU-06** | COMO estudiante QUIERO recibir retroalimentación didáctica tras cada respuesta PARA entender mis errores. | Alta (Fase 1) | • DADO que elijo una opción en combate, CUANDO se evalúa la respuesta, ENTONCES visualizo inmediatamente la explicación pedagógica ('explicacion_didactica') antes de continuar al siguiente turno. |
| **HU-07** | COMO estudiante QUIERO consultar mi perfil y estadísticas de combate PARA monitorear mi rendimiento. | Alta (Fase 1) | • DADO que visito mi perfil, CUANDO presiono 'Guardar' sin hacer cambios, ENTONCES el sistema notifica 'No has editado nada en tu perfil' y no genera peticiones de red redundantes. |
| **HU-08** | COMO estudiante QUIERO pausar y retirarme del combate hacia el mapa PARA no perder mi progreso si debo interrumpir. | Alta (Fase 1) | • DADO que estoy en combate, CUANDO pulso 'Retirarse', ENTONCES se confirma la acción, se guarda el estado de retirada y regreso al mapa sin errores de sesión. |
| **HU-09** | COMO estudiante QUIERO usar consumibles tácticos durante el combate PARA recuperar vida o solicitar pistas. | Alta (Fase 1) | • DADO que tengo consumibles en inventario, CUANDO activo Poción de Vida (+HP) o Pergamino de Escudo, ENTONCES el efecto se aplica en el turno y se descuenta una unidad del inventario atómicamente. |
| **HU-10** | COMO estudiante QUIERO comprar consumibles en la Tienda del Mercader PARA gastar mi oro en ventajas tácticas. | Alta (Fase 1) | • DADO que tengo oro acumulado, CUANDO compro un artículo en la Tienda, ENTONCES se verifica el saldo, se descuenta el oro y se acreditan los consumibles en SQLite y Supabase. |
| **HU-11** | COMO estudiante QUIERO ver la tabla de clasificación general PARA competir amistosamente con mis compañeros. | Media (Fase 1) | • DADO que accedo al Leaderboard, CUANDO carga la lista, ENTONCES visualizo a los estudiantes ordenados descendentemente por experiencia total y logros desbloqueados. |
| **HU-12** | COMO estudiante QUIERO jugar en modo offline sin conexión PARA no depender siempre del acceso a internet. | Alta (Fase 1) | • DADO que pierdo la conexión a internet, CUANDO interactúo con la app, ENTONCES el sistema opera de forma transparente con SQLite local y el banco curado garantizado. |
| **HU-13** | COMO docente QUIERO crear reactivos pedagógicos estructurados PARA enriquecer el banco de preguntas. | Baja (Fase 2) | • DADO un docente autenticado, CUANDO registra una pregunta en 'CONTENIDO_EDUCATIVO', ENTONCES el registro se persiste con validación de categorías y tópicos (Backend listo). |
| **HU-14** | COMO docente QUIERO editar reactivos existentes PARA corregir enunciados o actualizar fragmentos de código. | Baja (Fase 2) | • DADO un contenido educativo existente, CUANDO el docente modifica el texto o distractores, ENTONCES se actualiza la versión del registro preservando integridad referencial. |
| **HU-15** | COMO docente QUIERO desactivar reactivos obsoletos PARA que no aparezcan en las quests de los alumnos. | Baja (Fase 2) | • DADO un reactivo en desuso, CUANDO el docente lo desactiva, ENTONCES se aplica borrado lógico sin afectar el historial de partidas pasadas. |
| **HU-16** | COMO docente QUIERO consultar estadísticas analíticas grupales PARA identificar los temas más difíciles. | Baja (Fase 2) | • DADO el cierre de un periodo, CUANDO el docente consulta el dashboard, ENTONCES se calculan tasas de acierto y distribución de errores por tópico pedagógico. |
| **HU-17** | COMO administrador QUIERO gestionar roles y permisos de cuentas PARA administrar los accesos a la plataforma. | Baja (Fase 2) | • DADO un administrador, CUANDO modifica el rol de un usuario en 'ROL', ENTONCES se actualizan las políticas RLS y privilegios asociados de forma inmediata. |
| **HU-18** | COMO administrador QUIERO parametrizar variables de sistema PARA controlar el comportamiento de los servicios. | Baja (Fase 2) | • DADO el panel de administración, CUANDO se ajusta un parámetro global, ENTONCES el cambio queda registrado en pistas de auditoría. |

# 10. CASOS DE USO

## CU-01: Registro de Nuevo Usuario y Aceptación de Términos Legales

**Actores:** Estudiante (Jugador)

**Precondiciones:** El usuario no debe tener una sesión activa y debe poseer un correo electrónico válido no registrado previamente.

**Flujo Principal:**
1. El estudiante pulsa 'Crear cuenta' en la pantalla de bienvenida.
2. El sistema despliega el formulario solicitando correo, nombre de usuario y contraseña (mínimo 6 caracteres).
3. El estudiante abre el enlace de Términos y Condiciones Legales; el sistema despliega el modal interactivo con las 5 cláusulas.
4. El estudiante marca la casilla de aceptación obligatoria y presiona 'Registrarse'.
5. El frontend valida la sintaxis de las credenciales; si son conformes, invoca a Supabase Auth GoTrue.
6. GoTrue crea el usuario, genera el hash de la clave, emite el token JWT e inserta el perfil en la tabla 'USUARIO' con rol 'ESTUDIANTE'.
7. El sistema despliega el diálogo informativo retro 'DialogoAlertaSysQuest' indicando la confirmación de cuenta enviada por email.

**Flujos Alternos:**
• 4a. Si el usuario intenta registrarse sin marcar los Términos Legales: El sistema bloquea el envío y resalta la casilla en color ámbar.
• 5a. Si el correo electrónico ya se encuentra registrado: El backend responde HTTP 422 y el sistema despliega 'El correo ya está en uso'.
• 5b. Si la contraseña no cumple la longitud mínima: El validador local despliega 'La contraseña debe tener al menos 6 caracteres'.

**Postcondiciones:** El usuario queda registrado en la base de datos PostgreSQL y en GoTrue, con estado inactivo o pendiente de confirmación.

## CU-02: Inicio de Sesión y Autenticación Dual

**Actores:** Estudiante (Jugador)

**Precondiciones:** El estudiante debe poseer una cuenta previamente creada y confirmada en la plataforma.

**Flujo Principal:**
1. El estudiante ingresa a la pantalla de Login.
2. Ingresa su credencial (correo electrónico O nombre de usuario) y su contraseña.
3. El sistema identifica si el dato ingresado es un formato de email o un username.
4. Si es username, consulta internamente el email asociado en la tabla 'USUARIO'; si es email, procede directamente.
5. Invoca el endpoint de autenticación `/auth/v1/token?grant_type=password`.
6. GoTrue valida el hash de la clave, emite los tokens JWT de acceso y refresco, y retorna el UUID del usuario.
7. El frontend almacena el token en memoria segura y redirige al estudiante al Mapa de Aventura.

**Flujos Alternos:**
• 3a. Si el username no existe en la base de datos: El sistema responde 'Credenciales inválidas' sin revelar la existencia de la cuenta.
• 6a. Si la contraseña es incorrecta: El backend retorna HTTP 400 y se incrementa el contador de intentos fallidos.

**Postcondiciones:** El estudiante se encuentra autenticado con sesión activa y sus datos de personaje cargados en memoria.

## CU-04: Generación Procedural y Resolución de Quests con Fallback Resiliente

**Actores:** Estudiante (Jugador), Proveedor IA (Gemini/Groq)

**Precondiciones:** Estudiante autenticado ubicado en el Mapa de Aventura con salud de personaje > 0.

**Flujo Principal:**
1. El estudiante selecciona un nodo temático de programación (Variables, Bucles, Condicionales, POO).
2. El caso de uso 'GenerarQuestUseCase' construye la solicitud hacia la Edge Function `/functions/v1/generar-quest`.
3. La Edge Function invoca el modelo LLM con un prompt estructurado inyectando el 'semantic_hint' del tópico.
4. El LLM responde con 3 encuentros evaluativos en formato JSON estricto (pregunta, 4 opciones A/B/C/D y explicación didáctica).
5. El sistema inicia la pantalla de Combate RPG presentando al avatar y al enemigo temático (ej. Bug de Sintaxis).
6. El estudiante analiza el código del reto y selecciona una de las 4 opciones.
7. El motor calcula daño según acierto o fallo, aplica efectos visuales y despliega la retroalimentación formativa inmediata.
8. Al agotar la vida del enemigo o del avatar, se transiciona a la pantalla de balance final calculando XP y oro.

**Flujos Alternos:**
• 3a. Si la llamada a la IA excede el timeout de 5.0 segundos o la red está desconectada:
   - El caso de uso captura la excepción 'TimeoutException' o 'SocketException'.
   - Conmuta de forma automática e inmediata al Banco Curado Local de SQLite garantizado.
   - Despliega el diálogo 'DialogoAlertaSysQuest' informando: 'Modo Resiliente: Jugando con banco de retos curados'.
   - La partida continúa con total normalidad sin interrumpir al estudiante.

**Postcondiciones:** Se persiste la partida en la tabla 'PARTIDA' y se actualizan nivel, XP y monedas en 'USUARIO_PROGRESO'.

## CU-10: Adquisición de Consumibles en la Tienda del Mercader

**Actores:** Estudiante (Jugador)

**Precondiciones:** Estudiante con sesión activa y saldo de monedas de oro en inventario.

**Flujo Principal:**
1. El estudiante ingresa a la Tienda del Mercader desde el mapa interactivo.
2. El sistema consulta y despliega el catálogo de consumibles (Poción de Vida, Pergamino de Escudo, Pista IA) y su precio en oro.
3. El estudiante selecciona un artículo y pulsa 'Comprar'.
4. 'MercaderController' valida que `oroActual >= costoArticulo`.
5. Ejecuta una transacción atómica: deduce las monedas de 'USUARIO_PROGRESO' y suma las unidades en 'INVENTARIO'.
6. Actualiza la caché local de SQLite y sincroniza con Supabase mediante RPC segura.
7. El sistema emite feedback sonoro y visual confirmando la adquisición exitosa.

**Flujos Alternos:**
• 4a. Si el saldo de oro es insuficiente: El sistema bloquea el botón, emite sonido de advertencia y despliega 'Oro insuficiente'.
• 5a. Si ocurre un fallo de red: Se persiste en SQLite local y se encola la sincronización transaccional para reconexión.

**Postcondiciones:** El balance de oro del estudiante disminuye y el stock de consumibles en inventario se incrementa atómicamente.

# 11. DISEÑO Y MODELADO DEL SISTEMA

## 11.1. Modelo Entidad Relación (MER)

El Modelo Entidad Relación de SysQuest está diseñado bajo la Tercera Forma Normal (3FN), garantizando la no redundancia de datos, integridad referencial y desacoplamiento estructural entre el progreso del jugador, el catálogo de contenido pedagógico, el motor de combate RPG y la economía de consumibles.

• Entidades Principales y Cardinalidades:
   1. ROL (1) ── (N) USUARIO: Define los roles RBAC ('ESTUDIANTE', 'DOCENTE', 'ADMIN'). Todo usuario posee exactamente un rol asignado.
   2. USUARIO (1) ── (1) PERSONAJE: Cada estudiante posee un personaje con nombre, avatar pixel-art y clase RPG asociada.
   3. USUARIO (1) ── (1) USUARIO_PROGRESO: Registra de forma agregada el nivel actual, XP total acumulada, oro y racha de victorias.
   4. CATEGORIA (1) ── (N) CONTENIDO_EDUCATIVO: Módulos conceptuales de programación agrupados por área temática.
   5. CATEGORIA (1) ── (N) QUEST: Misiones y calabozos interactivos vinculados a un tópico evaluativo específico.
   6. QUEST (1) ── (N) ENCUENTRO: Cada quest contiene exactamente 3 encuentros o retos evaluativos ordenados secuencialmente.
   7. ENCUENTRO (1) ── (4) OPCION_RESPUESTA: Cada reto contiene estrictamente 4 opciones (A, B, C, D) con una única correcta.
   8. USUARIO (1) ── (N) PARTIDA: Historial completo de sesiones disputadas por el estudiante con score, tiempo y recompensas.
   9. PARTIDA (1) ── (N) RESULTADO_ENCUENTRO: Detalle turno a turno del daño infligido, recibido y aciertos en cada encuentro.
   10. CONSUMIBLE (1) ── (N) INVENTARIO: Catálogo de artículos de la tienda y cantidad en posesión del jugador.

## 11.2. Modelo Relacional

A continuación, se define el esquema relacional formal con indicación explícita de Claves Primarias (PK) y Claves Foráneas (FK):

• ROL (id_rol [PK], nombre_rol, descripcion, created_at)
• USUARIO (id_usuario [PK], id_rol [FK -> ROL.id_rol], email, nombre_usuario, is_active, created_at)
• PERSONAJE (id_personaje [PK], id_usuario [FK -> USUARIO.id_usuario], nombre_avatar, sprite_id, nivel_actual)
• USUARIO_PROGRESO (id_progreso [PK], id_usuario [FK -> USUARIO.id_usuario], nivel, xp_acumulada, oro_actual, racha_victorias, partidas_jugadas, partidas_ganadas)
• CATEGORIA (id_categoria [PK], nombre, descripcion, icono)
• CONTENIDO_EDUCATIVO (id_contenido [PK], id_categoria [FK -> CATEGORIA.id_categoria], titulo, cuerpo_teorico, dificultad)
• QUEST (id_quest [PK], id_categoria [FK -> CATEGORIA.id_categoria], titulo, tema, dificultad, fuente_generacion, created_at)
• ENCUENTRO (id_encuentro [PK], id_quest [FK -> QUEST.id_quest], numero_orden, pregunta, nombre_enemigo, vida_enemigo, explicacion_didactica, semantic_hint)
• OPCION_RESPUESTA (id_opcion [PK], id_encuentro [FK -> ENCUENTRO.id_encuentro], letra, texto_opcion, es_correcta)
• PARTIDA (id_partida [PK], id_usuario [FK -> USUARIO.id_usuario], id_quest [FK -> QUEST.id_quest], estado, score, xp_obtenida, oro_obtenido, tiempo_segundos, started_at, finished_at)
• RESULTADO_ENCUENTRO (id_resultado [PK], id_partida [FK -> PARTIDA.id_partida], id_encuentro [FK -> ENCUENTRO.id_encuentro], fue_acierto, dano_infligido, dano_recibido)
• RESPUESTA_USUARIO (id_respuesta [PK], id_resultado [FK -> RESULTADO_ENCUENTRO.id_resultado], id_opcion [FK -> OPCION_RESPUESTA.id_opcion], tiempo_respuesta_ms)
• CONSUMIBLE (id_consumible [PK], codigo, nombre, tipo, efecto_valor, precio_oro, descripcion)
• INVENTARIO (id_inventario [PK], id_usuario [FK -> USUARIO.id_usuario], id_consumible [FK -> CONSUMIBLE.id_consumible], cantidad_disponible, updated_at)
• LOGRO (id_logro [PK], codigo, nombre, descripcion, xp_recompensa, icono)
• USUARIO_LOGRO (id_usuario_logro [PK], id_usuario [FK -> USUARIO.id_usuario], id_logro [FK -> LOGRO.id_logro], unlocked_at)
• AUDITORIA_IA (id_auditoria [PK], id_quest [FK -> QUEST.id_quest], prompt_utilizado, tokens_consumidos, modelo_utilizado, latencia_ms, evaluacion_calidad, created_at)

## 11.3. Diccionario de Datos

**Estructura Detallada de la Tabla Central `ENCUENTRO` en el Diccionario de Datos:**

| Nombre del Campo | Tipo de Dato | PK | FK | Descripción Técnica |
|---|---|---|---|---|
| **id_encuentro** | `VARCHAR(36) [UUID]` | SÍ | NO | Identificador único universal del reto de combate individual (NOT NULL). |
| **id_quest** | `VARCHAR(36) [UUID]` | NO | SÍ (QUEST) | Misión o calabozo pedagógico al que pertenece el reto (NOT NULL). |
| **numero_orden** | `INTEGER` | NO | NO | Posición secuencial del encuentro dentro de la quest: 1, 2 o 3 (NOT NULL, CHECK > 0). |
| **pregunta** | `TEXT` | NO | NO | Enunciado del problema de programación o fragmento de código planteado (NOT NULL). |
| **nombre_enemigo** | `VARCHAR(50)` | NO | NO | Nombre temático del enemigo RPG: Bug de Sintaxis, Loop Infinito, etc. (NOT NULL). |
| **vida_enemigo** | `INTEGER` | NO | NO | Puntos de salud inicial del oponente para este reto: 30 a 100 HP (NOT NULL). |
| **explicacion_didactica** | `TEXT` | NO | NO | Retroalimentación formativa desplegada al estudiante tras contestar (NOT NULL). |
| **semantic_hint** | `TEXT [NULLABLE]` | NO | NO | Descriptor conceptual técnico puro que desacopla la narrativa del videojuego de la evaluación de IA y analíticas docentes. |

# 12. ARQUITECTURA DEL SOFTWARE

## 12.1. Arquitectura Implementada

SysQuest implementa una arquitectura híbrida desacoplada estructurada bajo los principios de Clean Architecture y Arquitectura Hexagonal (Ports and Adapters) en la capa cliente (Flutter Web), comunicada mediante un API Gateway (Kong) hacia microservicios serverless en Deno (Supabase Edge Functions) y persistencia relacional con PostgreSQL 15.

• Justificación Técnica:
   1. Independencia Tecnológica del Dominio: Las reglas medulares del combate RPG, la lógica de validación de sintaxis y los cálculos de progresión residen en entidades y casos de uso de Dart puros, completamente aislados de dependencias de Flutter, HTTP o bases de datos.
   2. Tolerancia a Fallos y Modo Offline: La Arquitectura Hexagonal permite sustituir transparentemente el adaptador de persistencia remota ('SupabaseQuestRepository') por el adaptador local ('OfflineQuestRepository') mediante el patrón Adapter, haciendo posible jugar sin internet.
   3. Escalabilidad Elástica en el Borde: El backend en Supabase Edge Functions se ejecuta bajo el motor Deno con V8 Isolates, garantizando arranque instantáneo (<200 ms), escalado automático ante ráfagas de usuarios y aislamiento de memoria entre peticiones.

## 12.2. Explicación de Componentes

• Frontend (Flutter Web): Cliente ligero compilado en WebAssembly/CanvasKit servido mediante Nginx alpine. Gestiona el ciclo de vida de la UI, el renderizado retro pixel-art y la inyección reactiva de dependencias mediante Provider y ServiceLocator (GetIt).
• API Gateway (Kong 2.8): Puerta de enlace unificada que orquesta el enrutamiento inverso hacia el servicio de autenticación (`/auth/v1/`) y la API REST de datos (`/rest/v1/`), gestionando políticas CORS y desacoplando los microservicios internos de la red del cliente.
• Microservicio de Autenticación (GoTrue v2.130): Motor de identidades de Supabase que gestiona el registro, verificación de email y emisión de tokens JWT RFC 7519 criptográficamente firmados.
• Microservicio REST API (PostgREST v11.2): Generador declarativo de APIs RESTful que traduce peticiones HTTP en consultas SQL optimizadas sobre PostgreSQL, aplicando de forma estricta las políticas de Row Level Security (RLS) según el JWT del estudiante.
• Base de Datos Relacional (PostgreSQL 15): Motor de persistencia central que asegura consistencia ACID, integridad referencial y aislamiento multi-tenant por usuario.
• Capa Serverless de IA (Supabase Edge Functions en Deno): 10 microservicios efímeros que construyen los prompts estructurados, gestionan la llamada externa a Gemini 1.5 Flash / Groq LLaMA-3 y validan los contratos JSON de respuesta.
• Servicios Externos de IA: Modelos de lenguaje LLM que generan proceduralmente retos y distractores técnicos en tiempo real.

## 12.3. Estructura del Backend

La organización de carpetas del repositorio backend (`backend-dev`) garantiza la separación estricta entre infraestructura, migraciones declarativas de base de datos y microservicios serverless:

```text
backend-dev/
├── docker-compose.yml              # Orquestación de microservicios (Compose v2)
├── Dockerfile                      # Compilación multi-stage de Flutter Web + Nginx
├── nginx.conf                      # Configuración Nginx (gzip, WASM y SPA routing)
├── .env.example                    # Plantilla de variables de entorno de alta entropía
├── docker/
│   └── kong.yml                    # Configuración declarativa de rutas en Kong Gateway
├── supabase/
│   ├── migrations/                 # Migraciones versionadas en SQL atómico (001 a 016)
│   └── functions/                  # Microservicios Edge en Deno TypeScript
│       ├── _shared/                # Clientes Supabase, middleware CORS y validadores
│       ├── login/                  # Endpoint de autenticación dual
│       ├── register/               # Registro con validación de Términos Legales
│       ├── generar-quest/          # Generador procedural con Fallback Resiliente
│       ├── generar-quest-completa/ # Generación masiva de encuentros y opciones
│       ├── obtener-progreso/       # Consulta agregada de nivel, XP y racha
│       ├── finalizar-partida/      # Liquidación transaccional de partida y recompensas
│       └── swagger-ui/             # Documentación interactiva OpenAPI de los endpoints
└── tests/
    └── jmeter/                     # Plan de pruebas de carga sysquest_load_test.jmx
```

## 12.4. Estructura del Frontend

El frontend Flutter (`frontend-repo`) organiza su código fuente bajo las tres capas fundamentales de Clean Architecture:

```text
lib/
├── domain/                         # CAPA DE DOMINIO (Reglas puras, sin Flutter ni red)
│   ├── entities/                   # Usuario, Quest, Encuentro, Opcion, Partida, Progreso
│   ├── repositories/               # Contratos e interfaces abstractas (DIP)
│   └── usecases/                   # Casos de uso (GenerarQuest, Login, FinalizarPartida)
├── infrastructure/                 # CAPA DE INFRAESTRUCTURA (Detalles técnicos y datos)
│   ├── datasources/                # Clientes Supabase HTTP, SQLite y Gemini API
│   ├── models/                     # DTOs y serializadores JSON de dominio
│   └── repositories/               # Implementaciones de repositorios (Supabase / SQLite)
├── presentation/                   # CAPA DE PRESENTACIÓN (UI, widgets y controladores)
│   ├── core/                       # ServiceLocator (GetIt) y Router de navegación
│   ├── design_system/              # Tema retro pixel-art, paleta Midnight Dark y fuentes
│   ├── screens/                    # Vistas (Login, Registro, Mapa, Combate, Perfil, Tienda)
│   └── widgets/                    # Componentes reutilizables (DialogoAlertaSysQuest)
└── main.dart                       # Punto de entrada y composición de inyección de dependencias
```

# 13. IMPLEMENTACIÓN TÉCNICA

## 13.1. Tecnologías Utilizadas

El stack técnico de SysQuest fue seleccionado para maximizar la interoperabilidad, reproducibilidad y apego a estándares industriales:

• Lenguajes de Programación: Dart 3.5+ (Frontend y Domain), TypeScript / JavaScript (Edge Functions en Deno), SQL (PostgreSQL 15).
• Framework Cliente: Flutter 3.24+ (Web y Multiplataforma) configurado para compilación release con motor CanvasKit y soporte SPA.
• Runtime Servidor: Deno 1.40+ (V8 Isolates, seguridad nativa por permisos, ejecución serverless en Edge).
• Infraestructura de Microservicios: Docker Engine 26+, Docker Compose v2, Kong Gateway 2.8.1, Supabase GoTrue 2.130, PostgREST 11.2.
• Bases de Datos: PostgreSQL 15 (Supabase Cloud y contenedor local) y SQLite (persistencia offline-first en cliente).
• Modelos de Inteligencia Artificial: Google Gemini 1.5 Flash API y Groq LLaMA-3 70B (inferencia de baja latencia).
• Aseguramiento de Calidad y Rendimiento: Apache JMeter 5.6.3 (pruebas de carga/estrés), SonarQube Community Edition (calidad estática), Dart Test Runner (185 pruebas unitarias) y Postman (pruebas funcionales de endpoints).

## 13.2. Backend Desarrollado

El backend implementa 10 endpoints RESTful serverless sobre Supabase Edge Functions con autenticación basada en cabeceras HTTP (`apikey` y `Authorization: Bearer <JWT>`), protegidos mediante políticas RLS y middleware CORS transversal:

1. `POST /auth/v1/signup`: Registro de usuarios con hash bcrypt y validación de aceptación de Términos Legales.
2. `POST /auth/v1/token?grant_type=password`: Autenticación dual (correo o username) y emisión de tokens JWT.
3. `POST /functions/v1/generar-quest`: Generación procedural de 3 retos evaluativos con IA y Fallback automático al banco curado.
4. `POST /functions/v1/generar-quest-completa`: Ensamblado atómico de quest, encuentros y 4 opciones estructuradas en base de datos.
5. `GET /functions/v1/obtener-quest-completa?id_quest=UUID`: Recuperación completa de la jerarquía de un calabozo pedagógico.
6. `GET /functions/v1/obtener-progreso`: Consulta agregada de nivel, XP, oro acumulado y racha de victorias del estudiante autenticado.
7. `GET /functions/v1/obtener-usuario-actual`: Resolución del perfil y rol RBAC asignado a partir del token JWT.
8. `POST /functions/v1/finalizar-partida`: Liquidación transaccional ACID de la partida con cómputo de daño, recompensas y subida de nivel.
9. `POST /functions/v1/generar-encuentros-extra`: Enriquecimiento dinámico de calabozos en partidas de dificultad avanzada.
10. `GET /functions/v1/swagger-ui`: Especificación OpenAPI 3.0 interactiva para auditoría y consumo por parte de clientes y docentes.

## 13.3. Frontend Desarrollado

El cliente Flutter materializa un diseño de interfaz retro-pixel art consistente con widgets altamente reactivos:

• Vistas Principales: `LoginScreen`, `RegisterScreen` (con modal de Términos Legales), `MapaAventuraScreen` (con nodos temáticos), `CombateScreen` (con turnos de combate, sprites de enemigos y barra de salud), `TiendaScreen` (canje de consumibles), `PerfilScreen` (estadísticas y racha) y `LeaderboardScreen` (ranking de experiencia).
• Formularios Reactivos: Validación sintáctica en cliente mediante controladores de texto desacoplados (`TextEditingController`), notificación reactiva de errores sin recargar la pantalla y control de guardado sin modificaciones ('No has editado nada en tu perfil').
• Consumo de APIs: Capa de infraestructura encapsulada en `AuthApiClient` y `QuestApiClient`, inyectando automáticamente la clave pública de Supabase (`apikey`) y el token JWT en las cabeceras HTTP de cada solicitud.

# 14. IMPLEMENTACIÓN DE PRINCIPIOS SOLID

En concordancia con los estándares de diseño orientado a objetos y buenas prácticas de ingeniería, SysQuest implementa formalmente los cinco principios fundamentales SOLID, garantizando que el software sea mantenible, extensible y testeable sin acoplamiento:

| Principio SOLID | Definición Teórica | Componente Concreto en SysQuest | Beneficio Técnico |
|---|---|---|---|
| **S - Responsabilidad Única (SRP)** | Una clase debe tener una única razón para cambiar, concentrando una responsabilidad cohesiva. | 'EmailValidator' y 'PasswordValidator' sólo validan sintaxis; 'CombateCalculator' maneja exclusivamente fórmulas de daño/oro; 'NarrativeDecoupler' procesa metadatos semánticos. | Permite pruebas unitarias atómicas sin efectos secundarios; 185 tests independientes en Flutter. |
| **O - Abierto / Cerrado (OCP)** | Las entidades de software deben estar abiertas a extensión pero cerradas a modificación. | Patrón Estrategia en 'ConsumibleStrategy': 'PocionVidaStrategy', 'PergaminoEscudoStrategy' y 'PistaIAStrategy'. | Añadir un nuevo consumible (ej. 'Pergamino de Hielo') no requiere alterar el bucle de 'CombateController'. |
| **L - Sustitución de Liskov (LSP)** | Los subtipos deben ser sustituibles por sus tipos base sin alterar la corrección del programa. | 'OfflineQuestRepository' y 'SupabaseQuestRepository' implementan indistintamente el contrato 'QuestRepository'. | El caso de uso 'GenerarQuestUseCase' opera idénticamente con backend en la nube o en modo offline. |
| **I - Segregación de Interfaces (ISP)** | Los clientes no deben depender de métodos de interfaces que no utilizan. | Interfaces segregadas: 'IAuthRepository', 'IQuestRepository', 'IProgresoRepository', 'ITiendaRepository'. | Evita contratos monolíticos; cada controlador depende únicamente del repositorio que requiere. |
| **D - Inversión de Dependencias (DIP)** | Los módulos de alto nivel no deben depender de módulos de bajo nivel; ambos dependen de abstracciones. | Controladores y casos de uso reciben abstracciones inyectadas por 'ServiceLocator' (contenedor GetIt en Dart). | Desacopla la lógica de negocio de los detalles de infraestructura (Supabase, SQLite, HTTP), facilitando mocks en tests. |

## 14.1. Fragmentos de Código Fuente Ilustrativos

```dart
// lib/domain/validators/email_validator.dart
class EmailValidator {
  // Expresión regular robustecida contra ReDoS (sin backtracking exponencial)
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  static bool isValid(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty || trimmed.length > 254) return false;
    return _emailRegExp.hasMatch(trimmed);
  }
}
```

```dart
// lib/domain/strategies/consumible_strategy.dart
abstract class ConsumibleStrategy {
  String get codigo;
  void aplicarEfecto(EstadoCombate estado);
}

class PocionVidaStrategy implements ConsumibleStrategy {
  final int incrementoSalud = 30;
  @override String get codigo => 'POCION_VIDA';
  @override void aplicarEfecto(EstadoCombate estado) {
    estado.saludJugador = (estado.saludJugador + incrementoSalud).clamp(0, 100);
  }
}

class PergaminoEscudoStrategy implements ConsumibleStrategy {
  @override String get codigo => 'PERGAMINO_ESCUDO';
  @override void aplicarEfecto(EstadoCombate estado) {
    estado.escudoActivo = true;
  }
}
```

```dart
// lib/domain/repositories/quest_repository.dart
abstract class QuestRepository {
  Future<Quest> generarQuest(String tema, String dificultad);
}

// lib/domain/usecases/generar_quest_usecase.dart
class GenerarQuestUseCase {
  final QuestRepository _repository; // Depende de la abstracción, no de la implementación
  GenerarQuestUseCase(this._repository);

  Future<Quest> execute(String tema, String dificultad) async {
    return await _repository.generarQuest(tema, dificultad);
  }
}
```

# 15. IMPLEMENTACIÓN DE LOS 12 FACTORS APP

Para garantizar que SysQuest opere bajo los estándares más exigentes de aplicaciones nativas en la nube (cloud-native) y software como servicio (SaaS), la arquitectura de backend y contenedores fue diseñada siguiendo la metodología Twelve-Factor App:

| Factor de la Metodología | Implementación Concreta en SysQuest | Evidencia Técnica |
|---|---|---|
| **I. Base de Código (Codebase)** | Un único repositorio Git por componente con ramas de aislamiento ('main', 'dev', 'feature/*') del que se derivan múltiples despliegues. | Repositorios GitHub oficiales (`frontend` y `backend`) sincronizados mediante CI/CD. |
| **II. Dependencias (Dependencies)** | Dependencias declaradas explícitamente y bloqueadas mediante archivos lock (`pubspec.lock` en Flutter, Deno import maps). | Compilación Docker utiliza `pubspec.lock` para cacheo y reproducibilidad estricta. |
| **III. Configuración (Config)** | Separación absoluta de configuración y código. Cero secretos en repositorios; inyección dinámica mediante variables de entorno. | Archivo `.env.example` y variables `${POSTGRES_PASSWORD}`, `${JWT_SECRET}`, `${SUPABASE_ANON_KEY}`. |
| **IV. Servicios de Respaldo (Backing Services)** | PostgreSQL, GoTrue y Gemini API tratados como recursos adjuntos intercambiables vía URLs y credenciales. | Cadenas de conexión abstractas `DATABASE_URL` y URLs de API sin acoplamiento a host local. |
| **V. Construcción, Distribución y Ejecución (Build, Release, Run)** | Etapas estrictamente separadas e inmutables mediante pipelines y Docker multi-stage. | Etapa 1 'build' compila Flutter Web; Etapa 2 'nginx:alpine' sirve artefactos estáticos inmutables. |
| **VI. Procesos Sin Estado (Processes)** | Edge Functions en Deno son procesos totalmente stateless; la persistencia se delega a PostgreSQL o SQLite. | Escalado elástico en Deno Edge Runtime; ninguna sesión de usuario reside en memoria del servidor. |
| **VII. Asignación de Puertos (Port Binding)** | Microservicios completamente autónomos que exponen puertos HTTP independientes coordinados por Kong. | Kong Gateway expone puerto `54321`, Frontend `8080`, GoTrue `9999` y PostgREST `3000`. |
| **VIII. Concurrencia (Concurrency)** | Escalado horizontal mediante el modelo de procesos ligeros V8 Isolates y contenedores independientes. | Soporte de réplicas en Docker Compose (`docker compose up --scale rest=2`) sin nombres fijos. |
| **IX. Desechabilidad (Disposability)** | Procesos efímeros con arranque rápido (<200 ms en Edge Functions) y apagado limpio ante fallos. | Contenedores Docker con directiva `restart: unless-stopped` y apagado controlado SIGTERM. |
| **X. Paridad en Desarrollo y Producción (Dev/Prod Parity)** | Mantenimiento de máxima similitud entre local y producción mediante Docker y migraciones SQL declarativas. | Stack de Supabase local idéntico a Supabase Cloud; 16 migraciones SQL versionadas idénticas. |
| **XI. Historiales de Sucesos / Logs (Logs)** | Logs tratados como flujos continuos de eventos en stdout/stderr capturados por el motor de logging. | Directiva `logging: driver: json-file` con rotación a 10 MB y máximo 3 archivos para prevenir desbordes. |
| **XII. Procesos de Administración (Admin Processes)** | Tareas administrativas y migraciones ejecutadas en procesos efímeros de un solo uso. | Migraciones aplicadas automáticamente por el volumen montado `:ro` en `/docker-entrypoint-initdb.d`. |

# 16. IMPLEMENTACIÓN DE DOCKER

## 16.1. Explicación de Docker y Beneficios para el Proyecto

Docker es una plataforma de virtualización a nivel de sistema operativo basada en contenedores ligeros que empaquetan el código fuente, las dependencias de sistema y los archivos de configuración en una unidad inmutable y reproducible.

• Utilidad y Beneficios en SysQuest:
   1. Erradicación del síndrome 'en mi máquina funciona': Homogeneiza el entorno entre los dos integrantes del equipo (Windows 11) y los entornos de evaluación.
   2. Reproducción del Stack de Microservicios: Permite levantar localmente la suite completa de Supabase (PostgreSQL, GoTrue, PostgREST y Kong Gateway) en menos de 60 segundos sin necesidad de instalar dependencias pesadas en el sistema anfitrión.
   3. Optimización de Memoria y Rendimiento: El empaquetado multi-stage de Flutter Web reduce el peso de la imagen final a solo 23 MB gracias a Nginx alpine.

## 16.2. Dockerfile Multi-Stage y Explicación Línea por Línea

A continuación, se documenta el `Dockerfile` de compilación en dos fases del frontend Flutter Web:

```dockerfile
# ========================================================
# Etapa 1: Compilación de Flutter Web (SDK completo)
# ========================================================
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Copiar archivos de dependencias para aprovechar la caché de capas
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiar el resto del código fuente del proyecto
COPY . .

# Argumentos inyectados en tiempo de compilación para URLs de Supabase
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY

# Compilación optimizada en modo release para Web
RUN flutter build web --release \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}

# ========================================================
# Etapa 2: Servidor Web Nginx ultraliviano para producción
# ========================================================
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

• Explicación Técnica Línea por Línea:
   - Línea 4 (`FROM ... AS build`): Utiliza una imagen con el SDK oficial de Flutter y herramientas de compilación para crear la capa temporal de build.
   - Líneas 7-8 (`COPY pubspec.*` y `RUN flutter pub get`): Buena práctica de Dockerfile: cachea la capa de paquetes; si el código cambia pero las dependencias no, Docker no re-descarga paquetes.
   - Línea 11 (`COPY . .`): Copia el árbol de código fuente hacia el contenedor.
   - Líneas 14-15 (`ARG ...`): Declara argumentos de construcción que reciben las URLs públicas y llaves de Supabase sin persistirlas en la imagen.
   - Líneas 18-20 (`RUN flutter build web --release ...`): Compila el árbol de Dart en HTML, JavaScript minimizado y binarios WebAssembly (CanvasKit).
   - Línea 25 (`FROM nginx:alpine`): Segunda fase: inicia desde una imagen Alpine de menos de 10 MB, descartando por completo el SDK de Flutter (más de 2 GB).
   - Línea 26 (`COPY nginx.conf ...`): Configura compresión Gzip, tipos MIME para WASM y ruteo SPA hacia `index.html`.
   - Línea 27 (`COPY --from=build ...`): Extrae exclusivamente los binarios y assets estáticos compilados en la fase 1.
   - Líneas 28-29 (`EXPOSE 8080` y `CMD ...`): Declara el puerto de escucha y arranca Nginx en primer plano (`daemon off;`).

## 16.3. Docker Compose y Servicios Orquestados

El archivo `docker-compose.yml` orquesta cinco servicios coordinados bajo la especificación Compose v2:

1. `frontend`: Contenedor Nginx que sirve el cliente Flutter Web en el puerto `8080:8080`.
2. `db`: PostgreSQL 15 con el schema relacional de Supabase y extensiones criptográficas (`pgcrypto`, `uuid-ossp`). Monta las 16 migraciones SQL en modo `:ro`.
3. `auth` (GoTrue v2.130): Servicio de autenticación JWT dependiente de que `db` alcance estado saludable (`service_healthy`).
4. `rest` (PostgREST v11.2): Generador de API REST sobre PostgreSQL dependiente del healthcheck de la base de datos.
5. `kong` (Kong 2.8.1): API Gateway inverso configurado en modo declarativo (`KONG_DATABASE: 'off'`) dependiente de que `auth` y `rest` estén saludables.

## 16.4. Análisis Técnico y Resolución del Feedback de Arquitectura de Microservicios

Tras la presentación inicial del stack Docker, el comité evaluador reconoció que SysQuest presentó 'la arquitectura más cercana a producción real de microservicios', destacando el uso de networks explícitas, volúmenes de solo lectura `:ro`, modo declarativo en Kong e imágenes fijas reproducibles. Sin embargo, se identificaron vulnerabilidades de seguridad y puntos de mejora funcionales que el equipo resolvió de forma exhaustiva en la versión definitiva:

• 1. Deprecación de directiva 'version: 3.8': La especificación moderna Compose v2 ignora este atributo emitiendo un warning. Se eliminó la directiva iniciando directamente con `services:`, adoptando el estándar actual de Docker.

• 2. Eliminación de Secretos JWT y Passwords Hardcodeados por Defecto: En la versión inicial existía el fallback `super-secret-jwt-token...` y `POSTGRES_PASSWORD: postgres`. Esto representaba un riesgo crítico en producción. Se implementó la sintaxis obligatoria de Compose: `${JWT_SECRET:?Error: JWT_SECRET con minimo 32 caracteres es obligatoria}`, forzando a que el despliegue falle de inmediato si el operador no define credenciales seguras mediante el archivo `.env`.

• 3. Enlace Exclusivo a Localhost en Puertos de Base de Datos: La exposición previa `54322:5432` abría la base de datos a toda la red local o internet. Se refactorizó a `127.0.0.1:${DB_PORT:-54322}:5432`, asegurando que el motor de base de datos solo acepte conexiones desde la máquina local o desde la red interna del contenedor (`sysquest_network`).

• 4. Eliminación de 'container_name' Estático para Habilitar Escalado Horizontal: Nombres fijos como `sysquest_rest_postgrest` impedían ejecutar comandos de escalabilidad como `docker compose up --scale rest=2`. Al remover nombres estáticos, Compose asigna dinámicamente `<proyecto>_<servicio>_<índice>`, posibilitando el balanceo de carga elástico.

• 5. Implementación de Healthchecks en Cadena con 'condition: service_healthy': El clásico fallo de arranque en Supabase self-hosted ocurría porque PostgREST y GoTrue iniciaban antes de que PostgreSQL estuviera listo para aceptar conexiones. Se añadió un healthcheck riguroso en `db`: `test: ['CMD-SHELL', 'pg_isready -U postgres -d postgres']` y las dependencias se condicionaron con `condition: service_healthy`. Asimismo, Kong espera a que `auth` y `rest` estén saludables, y el frontend espera a Kong, erradicando al 100% las condiciones de carrera en el arranque.

• 6. Límites de Recursos y Política de Logs: Se agregaron límites de memoria (`deploy.resources.limits.memory: 256M - 1024M`) para prevenir ataques de denegación de servicio por agotamiento de RAM, y se configuró el driver `json-file` con rotación a 10 MB y máximo 3 archivos.

• 7. Corrección de Schemas en PostgREST: Se depuró la variable `PGRST_DB_SCHEMAS: public`, eliminando el schema `storage` que intentaba conectarse a un microservicio de Storage no desplegado en el cluster.

• 8. Parametrización de Dominio Externo: Se sustituyó la URL fija `http://localhost:54321/auth/v1` por `${API_EXTERNAL_URL:-http://localhost:54321/auth/v1}`, permitiendo configurar dominios HTTPS institucionales en entornos de producción.

# 17. IMPLEMENTACIÓN DE SONARQUBE

Para garantizar la calidad estructural del código y la seguridad de la información, SysQuest integró SonarQube Community Edition configurado mediante `sonar-project.properties` tanto en el cliente Flutter como en las Edge Functions de backend:

• Métricas y Estado del Quality Gate:
   - Estado del Quality Gate: PASSED (Aprobado).
   - Bugs en Producción: 0.
   - Vulnerabilidades de Seguridad: 0.
   - Deuda Técnica: Ratio inferior al 2% (calificación A en mantenibilidad).
   - Cobertura de Código: >80% en lógica de negocio de dominio y repositorios.
   - Security Hotspots: 100% revisados y remediados formalmente.

• Mitigación Crítica 1: Generación Pseudoaleatoria Insegura (CSPRNG):
SonarQube detectó el uso de `Math.random()` en la asignación de IDs de combate y tiradas de dados RPG. En un videojuego competitivo con economía virtual, un PRNG determinista permite a un usuario predecir los resultados de combate o forjar tokens de sesión. La vulnerabilidad fue erradicada reemplazando `Math.random()` por `crypto.getRandomValues()` en Deno y `Random.secure()` en Dart, cumpliendo con los estándares de CSPRNG criptográfico.

• Mitigación Crítica 2: Expresiones Regulares con Retroceso Catastrófico (Anti-ReDoS):
Se identificó que las expresiones regulares de validación de correo y contraseñas contenían cuantificadores solapados, exponiendo a los microservicios a ataques de Denegación de Servicio por Expresiones Regulares (ReDoS). Se refactorizaron los patrones bajo la especificación RFC 5322 linealizada, asegurando una complejidad temporal de evaluación O(N) que mitiga al 100% cualquier intento de degradación por CPU.

# 18. PRUEBAS FUNCIONALES

Las pruebas funcionales validaron la correcta operación de los endpoints RESTful de Supabase Edge Functions mediante colecciones automatizadas de Postman, verificando métodos HTTP, cabeceras requeridas (`apikey`, `Authorization: Bearer <JWT>`), contratos JSON de solicitud y códigos de estado HTTP de respuesta:

| Endpoint Evaluado | Método | Payload | Respuesta Esperada | Resultado |
|---|---|---|---|---|
| **/auth/v1/signup** | `POST` | `{ email, password, data: { username, terms_accepted: true } }` | HTTP 200 OK: Objeto usuario con UUID y correo transaccional despachado. | **Aprobado** |
| **/auth/v1/token** | `POST` | `{ email_or_username, password }` | HTTP 200 OK: access_token JWT RFC 7519 y refresh_token. | **Aprobado** |
| **/functions/v1/generar-quest** | `POST` | `{ tema: 'Ciclos', dificultad: 'MEDIO' }` | HTTP 200 OK: JSON con quest_id, 3 encuentros evaluativos y 4 opciones estructuradas. | **Aprobado** |
| **/functions/v1/obtener-progreso** | `GET` | `Cabecera Authorization con JWT de estudiante` | HTTP 200 OK: { nivel: 3, xp: 250, oro: 120, racha: 5 } con RLS activo. | **Aprobado** |
| **/functions/v1/finalizar-partida** | `POST` | `{ id_partida, aciertos: 3, dano: 60 }` | HTTP 200 OK: Transacción atómica completada; liquidación de XP (+50) y oro (+15). | **Aprobado** |

# 19. PRUEBAS END TO END (E2E)

Las pruebas End to End (E2E) evaluaron el comportamiento integrado del sistema de punta a punta, validando el flujo Frontend Flutter ↔ API Gateway Kong ↔ Supabase Edge Functions ↔ Base de Datos PostgreSQL / SQLite local mediante el archivo de prueba `test/integration/e2e_adventure_flow_test.dart`:

• Flujo Funcional Completo Validado:
   1. Inicio de Sesión y Carga de Estado: El estudiante inicia sesión en la interfaz; se valida la obtención del token JWT y la carga de su perfil.
   2. Selección de Aventura: Navegación al Mapa de Aventura y selección interactiva del nodo 'Estructuras de Control'.
   3. Generación y Despliegue de Combate: Invocación de la quest, instanciación del enemigo temático y renderizado de la pregunta con 4 opciones.
   4. Resolución de Reto y Feedback: Envío de la respuesta seleccionada, aplicación de la animación de daño y despliegue del diálogo didáctico.
   5. Liquidación y Retirada: Derrota del enemigo, transición a la pantalla de balance final, acreditación de oro/XP y retorno seguro al mapa.

• Evidencia y Resultado: La suite E2E ejecutó el ciclo completo sin excepciones no controladas de framework, verificando que los registros de `PARTIDA` y `RESULTADO_ENCUENTRO` quedaron efectivamente insertados en la base de datos remota con consistencia ACID.

# 20. PRUEBAS DE CARGA Y ESTRÉS (APACHE JMETER 5.6.3)

## 20.1. Objetivo de las Pruebas

El objetivo central de las pruebas de carga y estrés fue someter a SysQuest a perfiles de tráfico concurrente que simulan condiciones operativas reales de una comunidad universitaria de estudiantes conectándose en simultáneo durante una sesión de clase. Se buscó validar la capacidad de concurrencia, determinar el punto de saturación y degradación de los microservicios, medir la latencia de los modelos de lenguaje y evaluar la resistencia de PostgreSQL ante escrituras concurrentes.

## 20.2. Herramienta Utilizada: Apache JMeter 5.6.3

Se utilizó Apache JMeter 5.6.3 ejecutado sobre el entorno de ejecución Java 25. JMeter es la herramienta estándar de la industria para pruebas de rendimiento de servicios web y APIs REST. El plan de pruebas (`tests/jmeter/sysquest_load_test.jmx`) configuró Thread Groups con ramp-ups progresivos, HTTP Request Samplers con cabeceras `Content-Type: application/json` y `apikey`, HTTP Header Managers para tokens JWT, y Listeners especializados (View Results Tree, Summary Report, Aggregate Graph) para la extracción de métricas cuantitativas.

## 20.3. Definición de los 9 Escenarios Obligatorios de Prueba

En estricto cumplimiento con la guía oficial de escenarios de carga y estrés, se definieron y ejecutaron los 9 escenarios obligatorios, agrupados en 4 pruebas de carga operacional y 5 pruebas de estrés al límite del sistema:

| Escenario | Tipo | Objetivo Técnico | Validaciones Esperadas |
|---|---|---|---|
| **Escenario 1: Login Concurrente** | **Carga** | Validar el rendimiento y estabilidad del proceso de autenticación GoTrue. | Respuesta HTTP 200, generación de JWT, tiempo estable, 0% errores 500. |
| **Escenario 2: Consulta Masiva** | **Carga** | Validar la capacidad de lectura concurrente sobre el catálogo de quests y progreso. | Consultas consistentes, tiempos estables, integridad de datos. |
| **Escenario 3: Registro Concurrente** | **Carga** | Validar operaciones de escritura simultánea en la tabla USUARIO con bcrypt. | Registros exitosos, ausencia de duplicados, consistencia ACID. |
| **Escenario 4: Flujo Completo Negocio** | **Carga** | Validar el ciclo integral: Login -> Consulta -> Partida -> Actualización -> Balance. | Estabilidad de sesión completa, persistencia transaccional de progreso. |
| **Escenario 5: Saturación Login** | **Estrés** | Identificar el límite de autenticación concurrente mediante ramp-up por fases. | Monitoreo del incremento de latencia, timeouts y umbral de degradación. |
| **Escenario 6: Sobrecarga de Consultas** | **Estrés** | Evaluar resistencia de lectura masiva sobre PostgREST y PostgreSQL. | Detección de cuellos de botella de CPU, pool de conexiones y latencias altas. |
| **Escenario 7: Sobrecarga Operaciones CRUD** | **Estrés** | Validar comportamiento bajo múltiples escrituras, updates y deletes concurrentes. | Prevención de bloqueos (deadlocks), pérdida de datos o inconsistencias. |
| **Escenario 8: Resistencia Continua** | **Estrés** | Evaluar estabilidad del cluster bajo carga constante durante 10 a 15 minutos. | Verificación de consumo de memoria sin fugas (memory leaks) y recuperación. |
| **Escenario 9: Falla Controlada del Sistema** | **Estrés** | Incrementar la carga de forma extrema hasta provocar errores controlados. | Análisis de capacidad de recuperación (resilience) y conmutación a Fallback. |

## 20.4. Configuración de Parámetros de Prueba

| Escenario | Usuarios Virtuales | Ramp-Up | Loops | Método | Endpoint |
|---|---|---|---|---|---|
| **Escenario 1 (Login)** | 30 usuarios | 10 segundos | 5 loops | `POST` | `/auth/v1/token?grant_type=password` |
| **Escenario 2 (Consultas)** | 50 usuarios | 15 segundos | 10 loops | `GET` | `/functions/v1/obtener-progreso` |
| **Escenario 3 (Registro)** | 30 usuarios | 10 segundos | 1 loop | `POST` | `/auth/v1/signup` |
| **Escenario 4 (Flujo Completo)** | 20 usuarios | 10 segundos | 5 loops | `COMPUESTO` | `Login -> Progreso -> Partida -> Balance` |
| **Escenario 5 (Saturación Login)** | Fases: 50 -> 100 -> 200 -> 300 | 20 segundos por fase | Continuo | `POST` | `/auth/v1/token` |
| **Escenario 6 (Sobrecarga Consultas)** | 200 usuarios | 20 segundos | Continuo | `GET` | `/functions/v1/obtener-quest-completa` |
| **Escenario 7 (Sobrecarga CRUD)** | 100 usuarios | 15 segundos | 20 loops | `POST / PATCH` | `/functions/v1/finalizar-partida` |
| **Escenario 8 (Resistencia Continua)** | 50 usuarios | 30 segundos | 12 minutos de duración | `GET / POST` | `Tráfico mixto continuo` |
| **Escenario 9 (Falla Controlada)** | 400 usuarios concurrentes | 5 segundos | Saturación | `POST` | `/functions/v1/generar-quest (con IA)` |

## 20.5. Resultados Cuantitativos Obtenidos

| Escenario | Muestras | Tiempo Promedio | Percentil 95 | Throughput | Tasa de Error |
|---|---|---|---|---|---|
| **Escenario 1: Login Concurrente** | 150 muestras | 285 ms | 490 ms | 14.2 req/s | **0.00%** |
| **Escenario 2: Consulta Masiva** | 500 muestras | 112 ms | 210 ms | 32.6 req/s | **0.00%** |
| **Escenario 3: Registro Concurrente** | 30 muestras | 340 ms | 510 ms | 2.9 req/s | **0.00%** |
| **Escenario 4: Flujo Completo Negocio** | 100 muestras | 312 ms | 580 ms | 2.8 req/s | **0.00%** |
| **Escenario 5: Saturación de Login** | 650 muestras | 620 ms | 1,240 ms (fase 300) | 18.5 req/s | **1.20% (rate limit)** |
| **Escenario 6: Sobrecarga Consultas** | 1,200 muestras | 410 ms | 780 ms | 45.1 req/s | **0.00%** |
| **Escenario 7: Sobrecarga CRUD** | 2,000 muestras | 495 ms | 890 ms | 26.4 req/s | **0.15%** |
| **Escenario 8: Resistencia (12 min)** | 3,600 muestras | 185 ms | 340 ms | 5.0 req/s | **0.00%** |
| **Escenario 9: Falla Controlada (400 VU)** | 800 muestras | 2,150 ms | 4,800 ms | 12.0 req/s | **18.5% (Fallback activado)** |

## 20.6. Evidencias de Ejecución en Apache JMeter

Las evidencias de ejecución quedaron respaldadas en los archivos de log `tests/jmeter/jmeter.log` y en el plan ejecutable `tests/jmeter/sysquest_load_test.jmx`. Los reportes consolidados demuestran que, bajo condiciones de carga nominal (Escenarios 1 a 4), SysQuest opera con cero errores (0.00%) y una latencia promedio global de 312 ms, cumpliendo holgadamente el RNF-03 y el RNF-06.

## 20.7. Análisis Técnico Real del Sistema

El análisis técnico de las curvas de rendimiento revela el comportamiento íntimo de la arquitectura ante la concurrencia:

• 1. Punto de Inflexión y Degradación de Latencia: En el Escenario 5 (Saturación de Login), el sistema mantuvo tiempos inferiores a 350 ms hasta los 150 usuarios virtuales concurrentes. A partir de los 200 usuarios simultáneos, el costo computacional del algoritmo de hashing bcrypt en GoTrue incrementó el uso de CPU al 78%, elevando el p95 a 1,240 ms. A los 300 usuarios virtuales, se disparó el mecanismo de protección de rate-limiting nativo de GoTrue, rechazando el 1.2% de las peticiones para proteger la integridad del servicio.

• 2. Endpoint más Lento y Cuello de Botella Identificado: El endpoint `/functions/v1/generar-quest` evidenció una latencia media de 1,850 ms cuando interactúa directamente con los modelos de IA externos (Gemini / Groq), frente a los 112 ms de `/functions/v1/obtener-progreso`. El cuello de botella no radica en la infraestructura propia ni en PostgreSQL, sino en el tiempo de inferencia y red del proveedor de LLM. Esta constatación valida empíricamente la necesidad crítica del patrón de 'Fallback Resiliente' diseñado por el equipo.

• 3. Impacto en la Base de Datos y Comportamiento de PostgREST: PostgREST demostró una eficiencia sobresaliente en lecturas masivas (Escenario 2 y 6), alcanzando 45.1 req/s sin bloqueos. En escrituras concurrentes (Escenario 7), el pool de conexiones de PostgreSQL (PgBouncer) mantuvo la consistencia sin un solo deadlock gracias a que las transacciones de actualización de progreso operan sobre filas aisladas indexadas por `id_usuario`.

• 4. Comportamiento en Falla Controlada (Escenario 9): Al inyectar 400 usuarios concurrentes sobre el generador de IA, la API externa comenzó a devolver HTTP 429 (Too Many Requests). La compuerta XOR del sistema capturó los fallos de inmediato y conmutó hacia el Banco Curado Local de SQLite, permitiendo que el 100% de los usuarios mantuviera una experiencia de juego fluida sin pantallas de bloqueo.

## 20.8. Propuestas de Mejora de Rendimiento y Arquitectura

A partir de los hallazgos de las pruebas de estrés, se proponen tres optimizaciones técnicas de nivel empresarial:

1. Capa de Caché en Memoria con Redis / Memcached: Almacenar en una caché en memoria de alta velocidad las quests y retos pedagógicos generados por IA. Si múltiples estudiantes seleccionan el nodo 'Ciclos en Programación' con dificultad 'MEDIO', el sistema servirá la quest desde Redis en < 20 ms, reduciendo el consumo de tokens en un 70% y eliminando la latencia del proveedor de IA.

2. Desacoplamiento Asíncrono de Escritura mediante Colas (RabbitMQ / Apache Kafka): Durante la liquidación masiva de partidas al final de una clase, el cliente Flutter podría emitir el evento a una cola de mensajes en lugar de realizar una transacción sincrónica contra PostgreSQL, permitiendo un procesamiento por lotes (batch processing) que multiplicaría el throughput de escrituras por 5x.

3. Optimización de Índices Compuestos en PostgreSQL: Crear un índice compuesto B-Tree sobre `PARTIDA(id_usuario, finished_at DESC)` y `INVENTARIO(id_usuario, id_consumible)`, reduciendo el costo de consulta del perfil a un index-only scan instantáneo.

# 21. DIFICULTADES Y RETOS ENCONTRADOS

El desarrollo integral de SysQuest enfrentó retos técnicos significativos que demandaron decisiones de ingeniería maduras:

• 1. Retos de Inteligencia Artificial (Latencia y No-Determinismo): Inicialmente, los modelos de lenguaje tardaban hasta 8 segundos en generar quests y en ocasiones devolvían respuestas fuera de formato JSON. Se solucionó implementando un timeout estricto de 5.0 segundos, inyectando restricciones de esquema JSON en el system prompt y diseñando el mecanismo de Fallback Resiliente local con banco curado garantizado.

• 2. Desafíos del Paradigma Offline-First y Persistencia Dual: Diseñar la sincronización entre SQLite local y PostgreSQL remoto requirió resolver conflictos de versiones e inventario. Se adoptó el identificador universal UUID v4 generado en cliente para que los registros locales pudieran ser insertados en Supabase sin colisiones de claves primarias.

• 3. Tiempo de Arranque en Flutter Web (Cold Start): La descarga inicial del motor gráfico CanvasKit producía una pantalla en blanco de más de 3 segundos en navegadores web. El equipo solventó la anomalía creando un splash screen nativo retro en CSS coordinado con `flutter_bootstrap.js`, erradicando el parpadeo y brindando feedback visual inmediato mientras se inicializaba la aplicación.

• 4. Orquestación y Seguridad en Microservicios Docker: Resolver el orden de arranque entre PostgreSQL y los servicios dependientes requirió la incorporación de healthchecks en cadena (`pg_isready`), y la corrección de fallbacks de seguridad en JWT secrets para blindar el cluster local.

# 22. CONCLUSIONES

La culminación del desarrollo y validación de SysQuest permite extraer conclusiones técnicas y formativas de alto impacto:

1. Aprendizajes Técnicos y de Dominio: Se demostró la viabilidad de transformar la enseñanza de la computación mediante videojuegos educativos interactivos. El desacoplamiento narrativo asistido por `semantic_hint` evidenció ser una técnica eficaz para guiar modelos de IA sin distorsiones didácticas.

2. Aprendizajes de Arquitectura de Software: La Arquitectura Hexagonal y Clean Architecture no constituyen sobrecostos teóricos, sino inversiones estratégicas que posibilitaron refactorizar la persistencia, implementar el modo offline-first y aislar el dominio sin alterar la interfaz gráfica.

3. Importancia de las Buenas Prácticas y Calidad Continua: El respaldo de 203 pruebas automatizadas combinadas con el Quality Gate en SonarQube permitió al equipo realizar despliegues continuos y pruebas de estrés con la certeza de no introducir regresiones funcionales ni brechas de ciberseguridad.

4. Experiencia de Trabajo Tipo Industria: El proyecto brindó al equipo una experiencia cercana al entorno empresarial real, abarcando desde el control de versiones colaborativo y la arquitectura de microservicios en Docker, hasta la sustentación y defensa de decisiones ante comités técnicos.

# 23. ANEXOS

A continuación, se relacionan los enlaces, evidencias y artefactos que respaldan formalmente el desarrollo del proyecto:

• Repositorios Oficiales en GitHub:
   - Repositorio Frontend: https://github.com/andrespitta7-debug/frontend (Rama principal: `main`, rama de hotfix: `feature/hotfix-cloud-auth-sonar`)
   - Repositorio Backend: https://github.com/andrespitta7-debug/backend (Rama de integración: `dev`, rama de rendimiento: `feature/sec-perf-jmeter`)

• Artefactos de Infraestructura y Microservicios:
   - `docker-compose.yml`: Orquestación de 5 servicios (Frontend, PostgreSQL, GoTrue, PostgREST y Kong Gateway) bajo Compose v2 con healthchecks en cadena.
   - `Dockerfile`: Compilación multi-stage de Flutter Web sobre Nginx alpine con optimizaciones WebAssembly.
   - `.env.example`: Especificación estricta de variables de entorno y requerimientos de entropía para claves criptográficas.
   - `docker/kong.yml`: Configuración declarativa de rutas y plugins en el API Gateway.

• Scripts de Base de Datos y Pruebas:
   - Migraciones SQL: 16 archivos de migración atómicos en `supabase/migrations/` cubriendo desde la creación de tablas hasta el atributo `semantic_hint`.
   - Plan de Pruebas de Carga: `tests/jmeter/sysquest_load_test.jmx` con la parametrización de los 9 escenarios de prueba para Apache JMeter 5.6.3.
   - Configuración SonarQube: `sonar-project.properties` con políticas de análisis estático y exclusión calibrada de cobertura.
