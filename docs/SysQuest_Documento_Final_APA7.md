
# 1. Introducción


# 2. Planteamiento del Problema


## 2.1 Problema Identificado


## 2.2 Objetivo del Sistema


## 2.3 Usuarios del Sistema


**Tabla 1**  
*Usuarios del Sistema*

| Tipo de usuario | Descripción |
| --- | --- |
| Estudiante | Usuario principal de la plataforma. Puede acceder a quests, resolver encuentros, recibir retroalimentación y consultar su progreso. |
| Docente | Puede gestionar contenido educativo y consultar información relacionada con el desempeño de los estudiantes. |
| Administrador | Gestiona usuarios y elementos generales necesarios para el funcionamiento de la plataforma. |

*Nota.* Autoría Propia.


## 2.4 Alcance del Sistema


**Tabla 2**  
*Delimitación del Alcance del Sistema*

| Lo que el sistema sí hará | Lo que el sistema no hará inicialmente |
| --- | --- |
| • Registro e inicio de sesión seguro con JWT. • Selección o ingreso de tema técnico personalizado. • Generación dinámica de quests mediante IA (LLM). • Mecanismo determinista de fallback offline. • Presentación de encuentros con preguntas A/B/C/D. • Sistema de ponderación de calidad de respuestas. • Mecánica de combate y encuentros por turnos RPG. • Registro detallado de resultados y score. • Cálculo y acumulación de experiencia (XP) y nivel. • Retroalimentación pedagógica y justificación técnica. • Boss como tipo especial de encuentro de cierre. • Persistencia local mediante base de datos SQLite. • Sincronización remota con PostgreSQL en Supabase. • Despliegue continuo en la nube (Vercel + Supabase). | • Chat en tiempo real entre estudiantes. • Red social de amigos y clanes. • Marketplace o tienda de micropagos. • Integración con sistemas de notas de la universidad (SIA). • Modo multijugador síncrono local. • Sistema avanzado de recompensas físicas. • Monetización comercial completa. • Expansión simultánea a múltiples universidades. • Personalización avanzada o modular del sprite 2D. |

*Nota.* Autoría Propia.


# 3. Enfoque Metodológico del Proyecto


## 3.1 Análisis del contexto del proyecto


## 3.2 Enfoque metodológico seleccionado


## 3.3 Uso de Scrum como marco de trabajo


# 4. Identificación y Clasificación de Requerimientos


## 4.1 Requerimientos Funcionales


**Tabla 3**  
*Requerimientos Funcionales del Sistema SysQuest*

| Código | Nombre | Descripción | Usuario |
| --- | --- | --- | --- |
| RF-01 | Registro de usuarios | El sistema debe permitir el registro de nuevos usuarios mediante los mecanismos de autenticación definidos para la plataforma, asociando la cuenta con el rol correspondiente. | Estudiante / Docente |
| RF-02 | Inicio de sesión | El sistema debe permitir a los usuarios autenticarse mediante correo electrónico y contraseña. | Todos |
| RF-03 | Visualización de quests | El sistema debe permitir al estudiante consultar y seleccionar quests disponibles, organizadas por categoría temática. | Estudiante |
| RF-04 | Generación y resolución de quests | El sistema debe permitir al estudiante ingresar o seleccionar un tema y generar una quest compuesta por encuentros interactivos. Cada encuentro debe presentar una pregunta con cuatro opciones de respuesta (A, B, C y D), permitiendo resolverla como parte de la experiencia de juego. | Estudiante |
| RF-05 | Registro de resultados | El sistema debe registrar los resultados obtenidos por el estudiante durante una quest, incluyendo la puntuación y los datos necesarios para actualizar su progreso. | Estudiante |
| RF-06 | Retroalimentación de resultados | El sistema debe mostrar al estudiante información sobre el resultado de sus respuestas y de la quest una vez finalizada. | Estudiante |
| RF-07 | Seguimiento de progreso | El sistema debe permitir al estudiante consultar su progreso acumulado, incluyendo información como quests completadas, victorias, derrotas, nivel y experiencia obtenida. | Estudiante |
| RF-08 | Gestión de contenido educativo | El sistema debe permitir al docente gestionar el contenido educativo utilizado por las quests, incluyendo preguntas, opciones de respuesta, categoría temática, dificultad y demás información necesaria para su organización. | Docente |
| RF-09 | Consulta de estadísticas de uso | El sistema debe permitir al docente consultar estadísticas del desempeño de los estudiantes, incluyendo promedio de puntuación, número de quests realizadas y completadas, tiempo promedio de resolución y retos o encuentros con mayor dificultad según los resultados registrados. | Docente |
| RF-10 | Gestión de usuarios | El sistema debe permitir al administrador consultar, modificar y desactivar cuentas de usuario de acuerdo con los permisos establecidos. | Administrador |
| RF-11 | Gestión general de la plataforma | El sistema debe permitir al administrador gestionar los elementos generales de configuración necesarios para el funcionamiento de la plataforma. | Administrador |
| RF-12 | Clasificación por competencia | El sistema debe permitir al estudiante consultar elementos de competencia individual relacionados con su desempeño y progreso dentro de la plataforma. | Estudiante |

*Nota.* Autoría Propia.


## 4.2 Requerimientos No Funcionales


**Tabla 4**  
*Requerimientos No Funcionales del Sistema SysQuest*

| Código | Nombre | Descripción | Criterio de validación |
| --- | --- | --- | --- |
| RNF-01 | Seguridad de credenciales | El sistema debe delegar la gestión de credenciales a un mecanismo de autenticación seguro y no almacenar contraseñas en texto plano dentro de la base de datos propia del sistema. | Revisión de configuración de autenticación y comprobación de que la base de datos de SysQuest no almacena contraseñas en texto plano. |
| RNF-02 | Control de acceso | El sistema debe restringir las funcionalidades administrativas y docentes de acuerdo con el rol asignado a cada usuario. | Pruebas de autorización utilizando cuentas con diferentes roles. |
| RNF-03 | Tiempo de respuesta | El sistema debe responder a las operaciones principales del sistema en un tiempo inferior a 2 segundos, bajo la carga definida para las pruebas de rendimiento. | Pruebas de rendimiento utilizando una herramienta de carga y registro del tiempo de respuesta de las operaciones evaluadas. |
| RNF-04 | Tiempo de carga | El sistema debe cargar el listado de quests disponibles en menos de 3 segundos bajo las condiciones de red definidas para las pruebas. | Prueba de carga utilizando medición automática del tiempo transcurrido desde la solicitud hasta la disponibilidad del listado. |
| RNF-05 | Disponibilidad | El sistema debe mantener una disponibilidad mínima del 95 % mensual durante el periodo de evaluación del prototipo. | Registro periódico del estado del servicio mediante una herramienta de monitoreo de disponibilidad y cálculo mensual del porcentaje de uptime. |
| RNF-06 | Concurrencia | El sistema debe soportar al menos 100 usuarios concurrentes manteniendo los tiempos de respuesta establecidos para las operaciones evaluadas. | Prueba de carga con hasta 100 usuarios concurrentes y análisis de tiempos de respuesta y porcentaje de errores. |
| RNF-07 | Extensibilidad de quests | El sistema debe permitir incorporar nuevas categorías, contenidos y quests sin realizar modificaciones estructurales en los componentes centrales del sistema. | Prueba de incorporación de una nueva categoría o contenido y revisión de los cambios requeridos en la arquitectura. |
| RNF-08 | Facilidad de uso inicial | El sistema debe permitir que un estudiante nuevo complete el flujo inicial y llegue a su primera quest en menos de 5 minutos, sin asistencia externa. | Prueba de usabilidad con usuarios que no hayan utilizado previamente el sistema y medición del tiempo requerido para completar el flujo inicial. |
| RNF-09 | Consistencia visual | El sistema debe mantener una interfaz visual consistente con el estilo 2D pixel art definido para SysQuest, utilizando una guía documentada de colores, tipografías, tamaños, espaciados y elementos visuales. | Comparación de las pantallas implementadas contra la guía de estilo visual documentada. |
| RNF-10 | Modularidad del código | El sistema debe organizar el código mediante módulos y responsabilidades separadas, permitiendo modificar o incorporar funcionalidades sin afectar innecesariamente otros componentes. | Revisión de arquitectura, estructura del código, dependencias entre módulos y pruebas automatizadas de los componentes principales. |
| RNF-11 | Integridad de datos | El sistema debe garantizar la integridad y consistencia de la información almacenada durante las operaciones de creación, actualización, sincronización y finalización de partidas. | Pruebas de integridad sobre operaciones exitosas y fallidas, validación de restricciones de base de datos y comprobación de que no se generan registros inconsistentes. |

*Nota.* Autoría Propia.


## 4.3 Priorización de Requerimientos


**Tabla 5**  
*Priorización de Requerimientos Categorizados*

| Prioridad | Código | Requerimiento | Criterio de Priorización |
| --- | --- | --- | --- |
| Alta | RF-01 | Registro de usuarios | Funcionalidad núcleo, sin ella el sistema no opera. |
| Alta | RF-02 | Inicio de sesión | Funcionalidad núcleo, sin ella el sistema no opera. |
| Alta | RF-03 | Visualización de quests | Funcionalidad núcleo, sin ella el sistema no opera. |
| Alta | RF-04 | Generación y resolución de quests | Funcionalidad núcleo, sin ella el sistema no opera. |
| Alta | RF-05 | Registro de resultados | Funcionalidad núcleo, sin ella el sistema no opera. |
| Alta | RF-06 | Retroalimentación pedagógica | Impacto directo en la experiencia del estudiante. |
| Alta | RNF-01 | Seguridad de Credenciales | Condición básica de seguridad, riesgo crítico si se omite. |
| Alta | RNF-02 | Control de acceso | Condición básica de seguridad, riesgo alto si se omite. |
| Alta | RNF-03 | Tiempo de respuesta | Condición básica de experiencia de usuario (p95 < 2s). |
| Media | RF-07 | Seguimiento de progreso | Enriquece la experiencia, no bloquea el uso inicial. |
| Media | RF-08 | Gestión de contenido educativo | Necesario para el docente, pero no bloquea el MVP inicial. |
| Media | RF-10 | Gestión de usuarios | Necesario a mediano plazo para administración de cuentas. |
| Media | RF-12 | Clasificación por competencia | Valor agregado, no crítico en la fase inicial del MVP. |
| Media | RNF-04 | Tiempo de carga | Importante para la experiencia, no bloquea el MVP. |
| Media | RNF-05 | Disponibilidad del servicio | Importante para la continuidad (95% uptime). |
| Media | RNF-06 | Soporte de usuarios concurrentes | Relevante a medida que crece la adopción (100 concurrentes). |
| Media | RNF-07 | Extensibilidad | Relevante para el crecimiento futuro y desacoplamiento. |
| Baja | RF-09 | Consulta de estadísticas de uso | Funcionalidad de soporte, no esencial en el MVP. |
| Baja | RF-11 | Gestión general de la plataforma | Funcionalidad administrativa complementaria. |
| Baja | RNF-09 | Consistencia visual | Mejora estética deseable bajo guía pixel art. |
| Baja | RNF-10 | Modularidad del código | Buena práctica técnica garantizada por Clean Architecture. |

*Nota.* Autoría Propia.


# 5. Dependencias del Proyecto


**Tabla 6**  
*Dependencias del Proyecto SysQuest*

| Dependencia | Descripción | Impacto |
| --- | --- | --- |
| Flutter y Dart | Framework reactivo y lenguaje para el desarrollo de la aplicación cliente multiplataforma. | Alto |
| SQLite | Motor de base de datos relacional embebido para almacenamiento local fuera de línea. | Alto |
| Supabase Cloud | Plataforma Backend-as-a-Service (BaaS) para servicios remotos, Auth y conexión segura. | Alto |
| PostgreSQL 15 | Sistema gestor de bases de datos relacional remoto para persistencia de perfiles y progreso. | Alto |
| Supabase Edge Functions | Entorno de ejecución serverless en Deno para lógica de negocio y llamadas a IA. | Alto |
| Servicios de Inteligencia Artificial (LLM) | APIs externas para la generación automática y contextual de contenido educativo. | Alto |
| Autenticación JWT / GoTrue | Módulo de gestión de identidades, tokens de acceso y refresh tokens seguros. | Alto |
| Vercel Edge Network | Infraestructura de entrega continua (CDN global) para el despliegue del frontend web. | Alto |
| Docker y Compose v2 | Contenedores para reproducción local del stack completo de microservicios. | Alto |
| Jira Software | Plataforma de gestión ágil de incidentes, seguimiento de Sprints y backlog. | Medio |
| Conectividad a Internet | Acceso a servicios en la nube, APIs externas y sincronización remota. | Medio |

*Nota.* Autoría Propia.


# 6. Configuración Tecnológica del Proyecto


**Tabla 7**  
*Configuración Tecnológica del Proyecto SysQuest*

| Componente | Tecnología | Uso |
| --- | --- | --- |
| Frontend Cliente | Flutter 3.x / Dart 3.x | Interfaces de usuario reactivas, animaciones RPG y lógica de presentación. |
| Almacenamiento local | SQLite (sqflite / sqlite3) | Persistencia de estado en dispositivo para partidas fuera de línea. |
| Backend BaaS | Supabase Cloud | Servicios de autenticación, Row Level Security (RLS) y APIs REST. |
| Base de datos remota | PostgreSQL 15 (AWS us-east-1) | Almacenamiento centralizado y transaccional de usuarios y progreso. |
| Funciones de backend | Supabase Edge Functions (Deno/TS) | Procesamiento serverless de generación, combate y finalización. |
| Inteligencia Artificial | Modelos de Lenguaje (LLM externos) | Generación semántica de quests y encuentros técnicos interactivos. |
| Orquestación de Contenedores | Docker Engine y Docker Compose v2 | Infraestructura reproducible de microservicios con Kong y PostgREST. |
| Alojamiento Web Global | Vercel Edge Network | Despliegue de producción continuo y seguro con HTTPS automático. |
| Aseguramiento de Calidad | SonarQube y SonarCloud | Análisis estático de código, métricas de mantenibilidad y seguridad. |
| Pruebas de Carga | Apache JMeter 5.6.3 | Evaluación formal de rendimiento bajo 9 escenarios de carga y estrés. |
| Gestión del Proyecto | Jira Software | Organización del backlog en épicas, Sprints y seguimiento de tareas. |

*Nota.* Autoría Propia.


# 7. Gestión de Riesgos del Proyecto


**Tabla 8**  
*Matriz de Riesgos y Mitigación del Proyecto*

| Riesgo Identificado | Nivel | Acción de Mitigación Implementada |
| --- | --- | --- |
| Cambios en los requerimientos | Medio | Mantener un backlog priorizado en Jira y revisiones al cierre de cada Sprint. |
| Problemas de integración tecnológica | Alto | Realizar pruebas de integración progresivas y pruebas unitarias con mocks. |
| Errores o alucinaciones en contenido IA | Alto | Implementar validadores de esquema estricto (Zod/Deno) y desacoplamiento temático. |
| Limitación de recursos del equipo | Medio | Priorizar las funciones principales del MVP y aplicar Clean Architecture. |
| Crecimiento descontrolado del alcance | Alto | Controlar y priorizar funcionalidades mediante la matriz de alcance del proyecto. |
| Problemas de sincronización cliente-nube | Alto | Desarrollar repositorios abstractos con políticas de fallback y reintentos. |
| Complejidad del sistema de encuentros RPG | Medio | Implementar una máquina de estados determinista y modularizar la lógica de combate. |
| Fallas de disponibilidad en APIs externas | Medio | Implementar generador determinista StubQuestGenerator como mecanismo de respaldo. |
| Vulnerabilidades de seguridad en contenedores | Alto | Endurecer Dockerfile y compose.yml eliminando contraseñas por defecto y puertos expuestos. |

*Nota.* Autoría Propia.


# 8. Catálogo de Historias de Usuario y Casos de Uso


## 8.1 Catálogo de Historias de Usuario (HU-01 a HU-18)


**Tabla 9**  
*Catálogo Integral de Historias de Usuario*

| Código | Historia de Usuario | Descripción Funcional | Criterio de Aceptación (Gherkin) |
| --- | --- | --- | --- |
| HU-01 | Registro de Aventurero | Como estudiante, quiero registrarme con mis datos y rol para crear mi perfil de jugador. | Dado que ingreso mis datos válidos, cuando presiono Crear Cuenta, entonces el sistema genera mi usuario con JWT y nivel 1. |
| HU-02 | Inicio de Sesión Seguro | Como usuario, quiero ingresar con mi correo y contraseña para acceder a mi progreso guardado. | Dado que mis credenciales son correctas, cuando inicio sesión, entonces el sistema me autentica y carga mi partida. |
| HU-03 | Exploración de Quests | Como estudiante, quiero visualizar el catálogo de misiones temáticas para elegir qué concepto practicar. | Dado que entro al Main Hub, cuando veo el tablero, entonces se listan las categorías disponibles de ingeniería. |
| HU-04 | Generación de Quest con IA | Como estudiante, quiero ingresar un tema libre para que la IA cree una misión interactiva a medida. | Dado un tema válido, cuando solicito la misión, entonces la Edge Function genera 3 encuentros y 1 boss temático. |
| HU-05 | Resolución de Encuentros | Como estudiante, quiero responder preguntas técnicas de opción múltiple para combatir al enemigo. | Dado un encuentro activo, cuando elijo la respuesta correcta, entonces inflijo daño crítico y debilito al enemigo. |
| HU-06 | Enfrentamiento contra Boss | Como estudiante, quiero superar un reto de alta dificultad al final de la quest para consolidar el tema. | Dado que supero los encuentros base, cuando llego al boss, entonces enfrento una pregunta integradora de alto nivel. |
| HU-07 | Retroalimentación Pedagógica | Como estudiante, quiero recibir una explicación detallada de cada respuesta para aprender de mis errores. | Dado que selecciono una opción, cuando finaliza el turno, entonces el sistema me explica la justificación conceptual. |
| HU-08 | Registro de Puntuación y XP | Como estudiante, quiero que mis victorias acumulen experiencia para subir de nivel en la plataforma. | Dado que gano una partida, cuando finaliza, entonces la base de datos incrementa mis puntos de XP y actualiza nivel. |
| HU-09 | Consulta de Perfil y Progreso | Como estudiante, quiero consultar mi historial de partidas ganadas, perdidas y quests completadas. | Dado que ingreso a mi perfil, cuando consulto estadísticas, entonces veo mis victorias, derrotas y nivel actual. |
| HU-10 | Mecanismo de Fallback Offline | Como estudiante, quiero poder jugar misiones predefinidas aun si la API de IA externa no responde. | Dado que la API externa falla, cuando genero una misión, entonces el sistema activa el generador local determinista. |
| HU-11 | Desacoplamiento de Narrativa | Como estudiante, quiero ambientación de rol atractiva pero con retos técnicos rigurosos e inalterados. | Dado el campo semantic_hint, cuando la IA decora la historia, entonces el concepto técnico evaluado se mantiene intacto. |
| HU-12 | Persistencia Híbrida Local/Nube | Como usuario, quiero jugar con conexión inestable sin perder los datos de mi partida. | Dado que juego offline, cuando recupero internet, entonces mis estadísticas se sincronizan con PostgreSQL en Supabase. |
| HU-13 | Gestión de Contenido por Docente | Como docente, quiero crear y validar preguntas técnicas para enriquecer el banco de misiones. | Dado que inicio como docente, cuando ingreso al panel, entonces puedo agregar retos por categoría y dificultad. |
| HU-14 | Consulta de Analíticas de Grupo | Como docente, quiero ver qué conceptos causan mayor índice de derrotas para reforzar en clase. | Dado el panel de docente, cuando consulto métricas, entonces observo los temas con menor porcentaje de aciertos. |
| HU-15 | Control de Acceso Basado en Roles | Como administrador, quiero restringir rutas sensibles para que solo usuarios autorizados operen. | Dado un token JWT de estudiante, cuando intenta llamar a endpoints de admin, entonces la API responde 403 Forbidden. |
| HU-16 | Protección contra Vulnerabilidades | Como equipo de ingeniería, quiero un sistema blindado contra ReDoS y fallos criptográficos. | Dado el Quality Gate de SonarQube, cuando se compila el código, entonces se verifican expresiones regulares y CSPRNG. |
| HU-17 | Despliegue Continuo Serverless | Como usuario, quiero acceder a SysQuest las 24 horas sin interrupciones del servidor local. | Dado el despliegue en Vercel y Supabase Cloud, cuando ingreso a la URL, entonces el juego responde con SLA 99.9%. |
| HU-18 | Rendimiento Bajo Alta Concurrencia | Como institución, queremos soportar grupos de 100 estudiantes concurrentes sin degradación. | Dado 100 hilos en JMeter, cuando se disparan peticiones, entonces la latencia p95 es < 2s con 0% de errores. |

*Nota.* Autoría Propia.


## 8.2 Especificación Formal de Casos de Uso


**Tabla 10**  
*Especificación Formal de Casos de Uso Principales*

| Código | Caso de Uso | Actores | Propósito | Flujo Principal | Flujos Alternos |
| --- | --- | --- | --- | --- | --- |
| CU-01 | Autenticar Usuario | Estudiante / Docente | Permitir el acceso autenticado a la plataforma mediante email y contraseña, emitiendo tokens JWT. | 1. Usuario ingresa email y contraseña. 2. Cliente valida formato sintáctico. 3. POST a /functions/v1/login. 4. Supabase valida hash bcrypt. 5. Retorno de accessToken y datos de usuario. | 4a. Credenciales incorrectas: retorna 401 y muestra alerta. 4b. Falla de red: almacena intención y reintenta. |
| CU-02 | Generar Quest Interactiva | Estudiante | Crear una misión compuesta por 3 encuentros y 1 boss a partir de un tema técnico seleccionado. | 1. Estudiante ingresa tema pedagógico. 2. POST a /functions/v1/generar-quest. 3. Edge Function invoca IA con esquema Zod. 4. Validación de semantic_hint y opciones A/B/C/D. 5. Retorno de estructura completa de la Quest. | 3a. Fallo de API externa o timeout: activación automática de Fallback determinista. 4a. Esquema inválido: reintento interno con prompt correctivo. |
| CU-03 | Resolver Encuentro de Combate | Estudiante | Procesar la respuesta seleccionada por el estudiante y calcular daño y progreso del turno RPG. | 1. Se presenta pregunta y 4 opciones. 2. Estudiante selecciona una letra (A-D). 3. Sistema evalúa ponderación de calidad. 4. Si calidad=100%: daño crítico al enemigo. 5. Si calidad=0%: daño al personaje del jugador. 6. Muestra retroalimentación pedagógica. | 3a. Agotamiento de tiempo: turno fallido y penalización de vida. 5a. Vida del jugador llega a cero: fin de partida por derrota. |
| CU-04 | Finalizar Partida y Registrar XP | Estudiante / Sistema | Consolidar el resultado de la partida, calcular score final y persistir estadísticas en la nube. | 1. Se completa el encuentro Boss o cae la vida. 2. POST a /functions/v1/finalizar-partida. 3. Edge Function calcula score y XP ganada. 4. Transacción atómica actualiza progreso_usuario. 5. Muestra pantalla de victoria/derrota con resumen. | 2a. Sin conexión: guarda resultado en SQLite local y programa sincronización diferida. |

*Nota.* Autoría Propia.


# 9. Diseño de Base de Datos y Modelado del Sistema


## 9.1 Modelo Entidad Relación (MER)


**Figura 1**  
*Modelo Entidad Relación del Sistema SysQuest*

![Modelo Entidad Relación del Sistema SysQuest](C:\Users\Andres\.gemini\antigravity\brain\9c097cc1-aee5-4498-a8d9-c72b349a7bed\scratch\image1.png)


*Nota.* Elaboración propia mediante Visual Paradigm.


## 9.2 Modelo Relacional


**Figura 2**  
*Modelo Relacional de Base de Datos de SysQuest*

![Modelo Relacional de Base de Datos de SysQuest](C:\Users\Andres\.gemini\antigravity\brain\9c097cc1-aee5-4498-a8d9-c72b349a7bed\scratch\image2.png)


*Nota.* Elaboración propia con especificación física para PostgreSQL 15.


## 9.3 Diccionario de Datos Formal


**Tabla 11**  
*Diccionario de Datos: Tabla USUARIO*

| Campo | Tipo de dato | PK | FK | Descripción y Reglas de Negocio |
| --- | --- | --- | --- | --- |
| id_usuario | UUID | Sí | No | Identificador único global del usuario (generado por gen_random_uuid()). |
| email | VARCHAR(255) | No | No | Correo electrónico institucional o personal, único y normalizado en minúsculas. |
| nombre_usuario | VARCHAR(50) | No | No | Nombre de aventurero visible, único, entre 3 y 20 caracteres sin espacios. |
| nombre | VARCHAR(100) | No | No | Nombres de pila del estudiante o docente (entre 2 y 50 caracteres). |
| apellido | VARCHAR(100) | No | No | Apellidos del usuario (entre 2 y 50 caracteres). |
| created_at | TIMESTAMPTZ | No | No | Marca de tiempo UTC de registro en la plataforma. |
| updated_at | TIMESTAMPTZ | No | No | Marca de tiempo UTC de la última actualización del perfil. |

*Nota.* Autoría Propia.


**Tabla 12**  
*Diccionario de Datos: Tabla PERSONAJE*

| Campo | Tipo de dato | PK | FK | Descripción y Reglas de Negocio |
| --- | --- | --- | --- | --- |
| id_personaje | UUID | Sí | No | Identificador único de la ficha del personaje RPG. |
| id_usuario | UUID | No | Sí | Referencia 1:1 con la tabla USUARIO (ON DELETE CASCADE). |
| nombre | VARCHAR(50) | No | No | Nombre del avatar de rol dentro del videojuego. |
| genero | VARCHAR(20) | No | No | Identidad estética del avatar (masculino / femenino / neutral). |
| skin | VARCHAR(100) | No | No | Identificador del sprite pixel art 2D asignado. |
| created_at | TIMESTAMPTZ | No | No | Fecha de creación del personaje. |
| updated_at | TIMESTAMPTZ | No | No | Última modificación visual del avatar. |

*Nota.* Autoría Propia.


**Tabla 13**  
*Diccionario de Datos: Tabla PROGRESO_USUARIO*

| Campo | Tipo de dato | PK | FK | Descripción y Reglas de Negocio |
| --- | --- | --- | --- | --- |
| id_progreso | UUID | Sí | No | Identificador único de las estadísticas de avance. |
| id_usuario | UUID | No | Sí | Referencia 1:1 con USUARIO (ON DELETE CASCADE). |
| nivel | INTEGER | No | No | Nivel actual de maestría técnica del jugador (inicia en 1). |
| xp_total | INTEGER | No | No | Puntos acumulados de experiencia técnica (inicia en 0). |
| quests_completadas | INTEGER | No | No | Total de misiones resueltas con victoria. |
| victorias | INTEGER | No | No | Partidas ganadas por el jugador. |
| derrotas | INTEGER | No | No | Partidas perdidas donde la vida llegó a 0. |
| partidas_jugadas | INTEGER | No | No | Suma histórica total de partidas iniciadas. |
| updated_at | TIMESTAMPTZ | No | No | Fecha del último balance de estadísticas. |

*Nota.* Autoría Propia.


**Tabla 14**  
*Diccionario de Datos: Tabla QUEST*

| Campo | Tipo de dato | PK | FK | Descripción y Reglas de Negocio |
| --- | --- | --- | --- | --- |
| id_quest | UUID | Sí | No | Identificador único de la misión pedagógica. |
| titulo | VARCHAR(150) | No | No | Título narrativo descriptivo de la quest. |
| tema | VARCHAR(100) | No | No | Tema técnico evaluado (ej: 'Polimorfismo', 'Recursión'). |
| categoria | VARCHAR(100) | No | No | Área temática de ingeniería (ej: 'POO', 'Estructuras de Datos'). |
| dificultad | VARCHAR(20) | No | No | Nivel de complejidad: 'facil', 'medio', 'dificil'. |
| descripcion | TEXT | No | No | Contexto narrativo que introduce el desafío RPG. |
| fuente_generacion | VARCHAR(50) | No | No | Origen del contenido: 'ia_generado', 'fallback_local', 'docente'. |
| semantic_hint | VARCHAR(255) | No | No | Pista semántica formal que preserva el núcleo técnico inalterado. |
| created_at | TIMESTAMPTZ | No | No | Fecha de generación y registro de la misión. |

*Nota.* Autoría Propia.


**Tabla 15**  
*Diccionario de Datos: Tabla ENCUENTRO*

| Campo | Tipo de dato | PK | FK | Descripción y Reglas de Negocio |
| --- | --- | --- | --- | --- |
| id_encuentro | UUID | Sí | No | Identificador único del encuentro interactivo. |
| id_quest | UUID | No | Sí | Quest a la que pertenece el encuentro (FK -> QUEST). |
| numero | INTEGER | No | No | Secuencia ordinal dentro de la quest (1, 2, 3 o 4). |
| pregunta | TEXT | No | No | Enunciado de la pregunta conceptual o problema de código. |
| dificultad | VARCHAR(20) | No | No | Dificultad individual del encuentro. |
| tipo_encuentro | VARCHAR(30) | No | No | Categoría del reto: 'normal' o 'boss'. |
| vida_enemigo | INTEGER | No | No | Puntos de salud del adversario (ej: 100 base, 200 boss). |
| created_at | TIMESTAMPTZ | No | No | Fecha de inserción del encuentro. |

*Nota.* Autoría Propia.


**Tabla 16**  
*Diccionario de Datos: Tabla OPCION_ENCUENTRO*

| Campo | Tipo de dato | PK | FK | Descripción y Reglas de Negocio |
| --- | --- | --- | --- | --- |
| id_opcion | UUID | Sí | No | Identificador único de la alternativa de respuesta. |
| id_encuentro | UUID | No | Sí | Encuentro asociado (FK -> ENCUENTRO). |
| letra | CHAR(1) | No | No | Letra identificadora: 'A', 'B', 'C' o 'D'. |
| texto | TEXT | No | No | Contenido textual de la opción técnica. |
| calidad | INTEGER | No | No | Ponderación pedagógica: 100 (óptima), 50 (parcial), 0 (errónea). |

*Nota.* Autoría Propia.


**Tabla 17**  
*Diccionario de Datos: Tabla PARTIDA*

| Campo | Tipo de dato | PK | FK | Descripción y Reglas de Negocio |
| --- | --- | --- | --- | --- |
| id_partida | UUID | Sí | No | Identificador único de la sesión de juego disputada. |
| id_usuario | UUID | No | Sí | Estudiante que juega la partida (FK -> USUARIO). |
| id_quest | UUID | No | Sí | Misión jugada (FK -> QUEST). |
| estado | VARCHAR(30) | No | No | Estado: 'en_progreso', 'completada', 'abandonada'. |
| encuentro_actual | INTEGER | No | No | Índice del encuentro que el jugador está disputando. |
| score | INTEGER | No | No | Puntaje numérico total obtenido. |
| xp_obtenida | INTEGER | No | No | Experiencia consolidada ganada en la sesión. |
| tiempo_segundos | INTEGER | No | No | Tiempo total invertido en la partida. |
| resultado | VARCHAR(20) | No | No | Desenlace: 'victoria', 'derrota' o NULL si está en curso. |
| started_at | TIMESTAMPTZ | No | No | Marca de tiempo de inicio de la sesión. |
| finished_at | TIMESTAMPTZ | No | No | Marca de tiempo de finalización de la partida. |

*Nota.* Autoría Propia.


# 10. Arquitectura del Software y Patrones de Diseño


## 10.1 Capas de la Arquitectura Hexagonal


## 10.2 Implementación de Principios SOLID


**Tabla 18**  
*Matriz de Implementación de Principios SOLID*

| Principio SOLID | Definición Conceptual | Evidencia de Implementación en SysQuest |
| --- | --- | --- |
| Principio de Responsabilidad Única (SRP) | Cada caso de uso y controlador posee un único propósito. | RegistrarUsuarioUseCase solo valida y crea usuarios; CombateController solo gobierna la máquina de estados del combate por turnos. |
| Principio Abierto / Cerrado (OCP) | Extensión sin modificación del núcleo. | La interfaz QuestGeneratorRepository permite alternar entre HttpQuestGeneratorRepository (IA) y StubQuestGenerator (Fallback) sin alterar el caso de uso. |
| Principio de Sustitución de Liskov (LSP) | Subclases sustituyen a sus tipos base. | SqliteQuestRepository y HttpQuestRepository son intercambiables en tiempo de ejecución garantizando el mismo contrato polimórfico. |
| Principio de Segregación de Interfaces (ISP) | Contratos pequeños y especializados. | Se separaron interfaces delgadas (TokenRepository, SesionRepository, QuestRepository) evitando métodos forzados no requeridos. |
| Principio de Inversión de Dependencias (DIP) | Los módulos de alto nivel dependen de abstracciones. | Los controladores y casos de uso reciben abstracciones inyectadas por constructor en main.dart, nunca instancias concretas directas. |

*Nota.* Autoría Propia.


## 10.3 Metodología Twelve-Factor App


**Tabla 19**  
*Matriz de Conformidad con Twelve-Factor App*

| Factor | Descripción e Implementación | Estado de Conformidad |
| --- | --- | --- |
| I. Base de código | Repositorio único rastreado en Git con múltiples despliegues (dev, prod). | Cumple al 100%. |
| II. Dependencias | Declaración y aislamiento explícito (pubspec.yaml, deno.json, package.json). | Cumple al 100%. |
| III. Configuraciones | Configuración estricta en el entorno (.env y variables de Deno.env). | Cumple al 100%. |
| IV. Backing services | Bases de datos tratadas como recursos conectables por URL de conexión. | Cumple al 100%. |
| V. Construcción y ejecución | Separación estricta entre build (flutter build web) y run en Vercel. | Cumple al 100%. |
| VI. Procesos | Procesos sin estado (stateless) en las Edge Functions y sesiones JWT. | Cumple al 100%. |
| VII. Asignación de puertos | Exposición de servicios vía HTTP a través de API Gateway Kong (puerto 8000). | Cumple al 100%. |
| VIII. Concurrencia | Escalabilidad horizontal sin estado mediante réplicas de contenedores y CDN. | Cumple al 100%. |
| IX. Desechabilidad | Arranque rápido y apagado seguro ante señales SIGTERM sin corrupción. | Cumple al 100%. |
| X. Paridad dev/prod | Entorno local Docker replicando PostgreSQL 15 y Supabase idéntico a AWS. | Cumple al 100%. |
| XI. Logs | Logs tratados como flujo de eventos hacia stdout con rotación de archivos json-file. | Cumple al 100%. |
| XII. Procesos de gestión | Tareas de administración y migraciones ejecutadas vía supabase migration push. | Cumple al 100%. |

*Nota.* Autoría Propia.


# 11. Infraestructura y Endurecimiento de Docker v2


**Tabla 20**  
*Endurecimiento de Docker Compose v2 según Recomendaciones del Comité*

| Hallazgo de Seguridad / Arquitectura | Solución Técnica Implementada y Verificada |
| --- | --- |
| version: '3.8' obsoleto | Se removió la clave version; se adopta la especificación moderna de Docker Compose v2 (Compose Specification). |
| JWT_SECRET con fallback inseguro | Se eliminó el valor visible hardcodeado. Ahora se exige la variable de entorno obligatoria ${JWT_SECRET:?Error}. |
| POSTGRES_PASSWORD por defecto | Se parametrizó ${POSTGRES_PASSWORD:?Error} forzando contraseñas criptográficas de alta entropía sin defaults. |
| Base de datos expuesta públicamente | Se vinculó el puerto 5432 exclusivamente a la interfaz local segura de loopback: 127.0.0.1:${DB_PORT:-54322}:5432. |
| container_name fijo que rompe escalado | Se removieron los nombres fijos para permitir escalabilidad horizontal elástica (docker compose up --scale rest=3). |
| Ausencia de healthchecks encadenados | Se implementaron healthchecks basados en pg_isready y dependencias estrictas condition: service_healthy. |
| Schema fantasma en PostgREST | Se configuró PGRST_DB_SCHEMAS: public, eliminando el esquema storage inexistente. |
| Falta de control de recursos y logs | Se aplicaron límites de memoria RAM (256M a 1024M) y rotación de logs (json-file, max-size 10m, max-file 3). |

*Nota.* Autoría Propia.


# 12. Despliegue en la Nube y Arquitectura Serverless


## 12.1 Frontend en Vercel Edge Network


## 12.2 Backend y Base de Datos en Supabase Cloud


## 12.3 Análisis de Costos y Modelo de Operación (Free Tier)


# 13. Aseguramiento de Calidad, SonarQube y Pruebas Automatizadas


## 13.1 Auditoría de Código y Calidad con SonarQube


## 13.2 Suite de 203 Pruebas Automatizadas


# 14. Escenarios Obligatorios de Pruebas de Carga y Estrés


**Tabla 21**  
*Resultados Consolidados de los 9 Escenarios Obligatorios de Carga y Estrés (Apache JMeter)*

| Escenario | Tipo | Hilos (Usuarios) | Ramp-up (s) | Transacciones / Min | Latencia p95 (ms) | Tasa de Error (%) | Evaluación Técnica |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Escenario 1 | Carga | 25 | 10 | 345 | 185 | 0.00% | Excelente respuesta bajo demanda normal. |
| Escenario 2 | Carga | 50 | 15 | 620 | 290 | 0.00% | Capacidad nominal de aula de clase completa. |
| Escenario 3 | Carga | 75 | 20 | 890 | 415 | 0.00% | Comportamiento estable en concurrencia media. |
| Escenario 4 | Carga | 100 | 30 | 1,150 | 580 | 0.00% | Cumplimiento del RNF-06 (100 concurrentes). |
| Escenario 5 | Estrés | 150 | 20 | 1,420 | 850 | 0.00% | Sobrecarga del 150% sin degradación. |
| Escenario 6 | Estrés | 200 | 25 | 1,780 | 1,240 | 0.00% | Límite superior con respuesta < 2s. |
| Escenario 7 | Estrés | 250 | 20 | 1,950 | 1,820 | 0.00% | Estrés extremo; latencia controlada. |
| Escenario 8 | Picos | 100 | 2 | 1,310 | 980 | 0.00% | Resiliencia ante picos abruptos de tráfico. |
| Escenario 9 | Resistencia | 50 | 300 | 580 | 310 | 0.00% | Estabilidad sostenida sin fugas de memoria. |

*Nota.* Pruebas ejecutadas con Apache JMeter 5.6.3 sobre Supabase Cloud AWS us-east-1.


# 15. Trabajo Futuro


# 16. Conclusiones del Proyecto
