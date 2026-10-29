# SysQuest — Documento Maestro de Contexto

*Última actualización: semana 4 del semestre (16 semanas totales, 13 restantes). Este documento reemplaza y amplía el contexto usado en el primer comité de arquitectura. Úsalo como fuente única de verdad para cualquier trabajo futuro (documento académico, presentación, código, IA de apoyo, etc.).*

> Nota de estado: la fusión de los seis minijuegos en un único motor de quest (descrita abajo) es la **dirección de diseño actual propuesta**, discutida y recomendada tras el comité, pero el equipo aún debe confirmarla formalmente antes de iniciar la programación. Se documenta aquí como la versión vigente porque es sobre la que se está trabajando.

---

## 1. Identidad del proyecto

- **Nombre:** SysQuest
- **Tipo:** Aplicación educativa gamificada (RPG de combate por turnos con generación de contenido asistida por IA)
- **Sector:** Educación superior
- **Institución de origen:** Universidad de Cundinamarca (UDeC), Facultad de Ingeniería, Programa de Ingeniería de Sistemas y Computación, sede Fusagasugá
- **Equipo de desarrollo (2 personas):** Jhony Alejandro Palacio Gómez, Andrés Orley Pitta Pardo
- **Equipo ampliado de emprendimiento:** 4 personas (los 2 anteriores + 2 compañeros adicionales para el componente de Innovación y Emprendimiento)
- **Docente (Proyecto Integrador / Arquitectura):** Ferney Ortiz
- **Contexto académico:** el proyecto se trabaja en paralelo en tres asignaturas — Proyecto Integrador / Arquitectura de Software, Innovación y Emprendimiento, y una futura asignatura de desarrollo donde se construirá la versión ampliada.
- **Tiempo disponible:** semestre de 16 semanas; el proyecto arrancó formalmente en la semana 4 (quedan 13 semanas para el primer ciclo de entrega).
- **Presupuesto:** cero. Todo el stack debe apoyarse en herramientas y niveles gratuitos.

---

## 2. Problema que resuelve

Los estudiantes de Ingeniería de Sistemas deben asimilar simultáneamente conceptos de múltiples áreas del plan de estudios (programación, bases de datos, algoritmia, redes, arquitectura de software, ciberseguridad), que suelen enseñarse de forma fragmentada y con poco refuerzo práctico fuera del aula. Las herramientas de estudio actuales (documentos extensos, videos, plataformas de quiz genéricas tipo Kahoot/Quizizz) dependen de conexión estable a internet, se limitan a preguntas cerradas y no permiten practicar procedimientos técnicos completos ni adaptarse al tema puntual que cada estudiante necesita reforzar en un momento dado.

Una exploración cualitativa preliminar (entrevistas semiestructuradas a estudiantes del programa) mostró una actitud favorable hacia herramientas gamificadas, con preferencia marcada por sistemas de progreso, retos cronometrados y mecánicas competitivas frente a la lectura repetitiva. Esta evidencia es exploratoria, no una validación estadística de mercado.

---

## 3. Propuesta de valor y visión de producto (versión vigente)

SysQuest ya no se concibe como seis minijuegos independientes, sino como **un único juego tipo RPG 2D pixel art de combate por turnos**, en el que el jugador puede pedirle a la aplicación que genere una "quest" sobre *cualquier tema técnico que quiera reforzar* (por ejemplo: "recursión en programación", "normalización de bases de datos", "modelo OSI"). Un agente de IA interpreta ese tema y genera una partida personalizada: enemigos, preguntas y niveles de dificultad progresivos relacionados con ese concepto.

Las seis categorías originales (Debug, Database, Algorithm, Network, Architecture, Cyber) pasan de ser seis juegos separados a ser **seis categorías temáticas sugeridas** dentro del mismo motor de juego, además de la opción de tema libre. Esto reduce el trabajo de construir seis sistemas de juego distintos a construir uno solo, y refuerza la propuesta de valor frente a competidores (Kahoot no genera contenido personalizado ni simula un procedimiento).

El modo multijugador (competencia local vía hotspot/Wi-Fi Direct, sin depender de los seis minijuegos) queda como una funcionalidad futura, separada del modo historia principal.

---

## 4. Jugabilidad (mecánica central)

1. **Pantalla de inicio de partida:** campo de texto donde el jugador escribe sobre qué tema quiere aprender/practicar (o elige una de las seis categorías sugeridas como atajo).
2. **Generación de la quest:** un agente de IA interpreta el tema, lo reescribe como título de nivel ("Quest de Recursión", por ejemplo) y genera una secuencia de encuentros con dificultad progresiva sobre ese concepto.
3. **Exploración:** el personaje corre automáticamente en el centro de la pantalla (orientación **vertical**), mientras el fondo se desplaza según la velocidad de avance, en un mapa de **avance lineal generado proceduralmente** (no mundo abierto).
4. **Encuentro con enemigo:** al toparse con un enemigo, se activa un **combate por turnos**:
   - El sistema presenta una pregunta de opción múltiple (A/B/C/D) generada por la IA sobre el tema de la quest.
   - Se plantean dos opciones incorrectas y dos correctas, donde una de las correctas es cualitativamente mejor que la otra (más precisa/completa).
   - Elegir la mejor respuesta correcta inflige más daño o un golpe crítico; la respuesta correcta "débil" inflige daño normal; una respuesta incorrecta permite que el enemigo contraataque y dañe al jugador.
5. **Progresión de dificultad:** los enemigos escalan en dificultad conforme avanza la partida (más vida, preguntas más específicas).
6. **Jefe de área:** al final de un tramo de la quest aparece un jefe con más vida y preguntas más exigentes; el jugador puede usar pistas o mejoras/ítems conseguidos durante la partida para apoyarse en esta batalla.
7. **Prioridad de desarrollo:** por ahora se prioriza que el sistema sea **funcional** (lógica de combate, IA, puntuación) antes que visualmente pulido; las animaciones de combate más fluidas quedan para una iteración posterior.

---

## 5. Personalización de personaje

- Selección de género del personaje (masculino/femenino) y personalización visual estilo pixel art, en la línea de referentes como *Among Us* o *R.E.P.O.* (identidad visual propia y reconocible dentro del juego).
- Sistema de equipamiento progresivo: prendas, armas, armaduras y accesorios que se desbloquean a medida que el jugador avanza, permitiendo comparar el progreso visual entre compañeros.
- **Alcance realista para este semestre:** dado que un sistema completo de capas independientes (cuerpo + ropa + arma + armadura + accesorios, combinables libremente) requiere producción de arte considerable sin presupuesto ni artista dedicado, la versión de este ciclo se limita a **2-3 skins predefinidos desbloqueables por género**, usando paquetes de pixel art gratuitos/CC0 como base. El sistema de capas combinables queda documentado como visión de producto para una iteración futura.

---

## 6. Arquitectura técnica

### 6.1 Frontend (aplicación móvil)
- **Framework:** Flutter
- **Lenguaje:** Dart
- **Motor 2D:** se evalúa el uso del paquete **Flame** (motor de juegos 2D nativo del ecosistema Flutter, no una tecnología externa) específicamente para el scroll del mapa, el movimiento del personaje y las colisiones con enemigos; el resto de la interfaz (menús, pantallas de progreso, personalización) se construye con widgets estándar de Flutter.
- **Orientación:** vertical (portrait), pensado para sostener el celular con una mano.
- **Plataforma objetivo de esta fase:** únicamente Android (publicar en iOS requiere Mac y cuenta de Apple Developer de pago, fuera de alcance sin presupuesto).

### 6.2 Backend / lógica de negocio
- Una capa de servicios interna a la app (carpeta `services/`) maneja autenticación, reglas de cada partida, cálculo de puntuación y, a futuro, las sesiones de conectividad local para el modo multijugador.
- **Backend remoto (nuevo, necesario por el cambio de alcance):** dado que ahora existen cuentas sincronizadas entre app y web, un panel de administración en la nube, y llamadas a un modelo de IA que no deben hacerse directo desde el celular (por seguridad de la API key y control de costos), se incorpora un backend remoto.
  - **Recomendación:** **Supabase** (plan gratuito) por ser Postgres real (relacional, coherente con lo aprendido en Estructuras de Información), e incluir autenticación y funciones en la nube sin costo para el volumen de un proyecto universitario. Firebase es la alternativa evaluada si se prefiere un modelo NoSQL.
  - Las llamadas al agente de IA se hacen desde una función del backend (no desde el cliente), para no exponer credenciales y poder aplicar límites de uso.

### 6.3 Base de datos — modelo híbrido (decisión clave del cambio de alcance)

SQLite por sí solo ya no cubre el alcance actual. Se adopta un modelo de **dos niveles**:

| Nivel | Motor | Qué guarda | Por qué |
|---|---|---|---|
| Local (dispositivo) | **SQLite** (paquete `sqflite`) | Caché de la partida activa, progreso reciente, contenido de la quest ya descargado | Permite seguir jugando aunque se pierda la conexión a mitad de partida |
| Remoto (nube) | **Postgres vía Supabase** | Cuentas de usuario, inventario de cosméticos, progreso "oficial" sincronizado, licencias institucionales, contenido gestionable desde la web admin, historial agregado | Necesario para que exista fuera del celular, se vea desde la web y se sincronice entre dispositivos |

Entidades principales previstas (a nivel remoto, con reflejo parcial local): `usuarios`, `personajes` (skin/equipo activo), `quests` (temas generados y su metadata), `encuentros` (preguntas generadas por partida), `partidas`, `progreso_usuario`, `inventario_cosmeticos`, `universidades` (para licenciamiento institucional).

### 6.4 Generación de contenido con IA
- El tema libre que escribe el jugador se envía a un modelo de lenguaje a través del backend.
- **Opciones gratuitas evaluadas:** Google Gemini API (nivel gratuito) o Groq (nivel gratuito, alta velocidad de respuesta).
- **Plan de contingencia obligatorio:** si el servicio de IA falla o se agota el límite gratuito, el juego debe poder caer a un banco de preguntas pre-generadas localmente, para que una demo o sustentación nunca dependa 100% de un servicio externo en vivo.

### 6.5 Sitio web
- Landing informativa bilingüe (español/inglés) explicando el producto, con capturas/video y botón de descarga directa del APK (mientras no esté en tiendas oficiales).
- Un apartado de acceso administrativo (no visible en la navegación principal, solo accesible con credenciales institucionales autorizadas) desde donde los administradores gestionan usuarios, contenido y licencias almacenados en Supabase.
- Este sitio será también el punto donde, a futuro, se relacionen las cuentas creadas en la app con la gestión institucional.

---

## 7. Usuarios del sistema

- **Estudiante (usuario final):** se registra, juega el modo historia con quests personalizadas por tema, personaliza su personaje, revisa su progreso y ranking.
- **Administrador institucional:** asignado por cada universidad con licencia; gestiona el contenido de retos/temas propios de su institución y consulta el uso agregado de sus estudiantes.
- **Administrador SysQuest:** equipo desarrollador; controla el catálogo general, supervisa la operación de la plataforma y gestiona las licencias otorgadas.

---

## 8. Alcance para este ciclo de 13 semanas (semana 4 a semana 16)

**Sí incluido:**
- Registro/login con sincronización app-web (Supabase Auth)
- Motor de combate por turnos funcional (sin animaciones complejas todavía)
- Generación de quest por IA con tema libre + fallback local si la IA falla
- Progreso individual, guardado local (SQLite) y remoto (Supabase)
- 2-3 skins de personaje desbloqueables por género (sin sistema de capas completo)
- Jefe de área con sistema básico de pistas/ítems
- Web informativa bilingüe + descarga de APK + panel admin básico

**No incluido en este ciclo (roadmap futuro / próxima asignatura de desarrollo):**
- Multijugador local por hotspot/Wi-Fi Direct
- Sistema de equipamiento por capas completamente combinable
- Animaciones de combate fluidas / spritesheets avanzados
- Publicación en iOS
- Monetización completamente implementada (cosméticos como fuente de ingreso queda documentado como modelo de negocio, no como funcionalidad construida)

---

## 9. Riesgos identificados

- Complejidad técnica del motor de combate + generación de IA en el tiempo disponible.
- Dependencia de servicios externos gratuitos (límites de tasa, disponibilidad) para la IA.
- Producción de arte pixel art sin artista dedicado ni presupuesto.
- Configuración de entorno (Flutter/Android SDK/NDK), ya enfrentada y documentada en proyectos previos del equipo.
- Alcance ambicioso frente al tiempo académico: mitigado mediante la delimitación estricta de esta sección.

---

## 10. Modelo de negocio (para Innovación y Emprendimiento)

- **Propuesta de valor institucional:** herramienta de refuerzo académico gamificada y personalizable por tema, sin depender de infraestructura de red adicional para el modo individual.
- **Fuentes de ingreso propuestas (hipótesis de negocio, no validadas comercialmente aún):**
  - Licenciamiento institucional a universidades (acceso al panel admin, gestión de contenido propio).
  - Venta de cosméticos/skins como modelo de monetización directa a estudiantes independientes (modelo tipo "juego gratuito, cosméticos de pago"), que ahora tiene mayor sustento por el sistema de personalización descrito arriba.
  - Publicidad no intrusiva en la versión gratuita para usuarios sin convenio institucional.
- Este componente debe presentarse siempre como hipótesis en validación, no como mercado demostrado.

---

## 11. Reglas de comunicación del proyecto (vigentes para cualquier presentación o documento)

1. No afirmar que SysQuest "resuelve" el problema del aprendizaje; se presenta como una alternativa/complemento en exploración.
2. Diferenciar siempre entre lo **investigado** (entrevistas, diseño), lo **decidido** (Flutter, Dart, Supabase, SQLite híbrido, motor de combate por turnos) y lo **futuro/hipotético** (multijugador, expansión institucional, monetización, sistema de capas completo).
3. Las entrevistas son evidencia cualitativa exploratoria, nunca una validación estadística de mercado.
4. Priorizar que el núcleo funcione antes de ampliar funcionalidades visuales o secundarias.
5. El equipo de desarrollo son 2 personas; no presentar 4 desarrolladores aunque el equipo de emprendimiento sea de 4.

---

*Fin del documento maestro. Cualquier avance, cambio de alcance o decisión técnica nueva debe reflejarse aquí para mantenerlo como fuente única de verdad.*
