# SYSQUEST — ARQUITECTURA TÉCNICA

## Documento técnico de referencia para desarrollo

Este documento complementa:

```text
SysQuest_Contexto_Maestro.md
```

Su objetivo es proporcionar a la IA de desarrollo una referencia técnica sobre la arquitectura, capas, entidades, repositorios, casos de uso, persistencia SQLite, controllers, pantallas y flujo de información de SysQuest.

---

# 1. PRINCIPIO ARQUITECTÓNICO

SysQuest utiliza una arquitectura basada en principios de **Arquitectura Hexagonal (Ports and Adapters)**.

La idea principal es separar:

```text
Lógica de negocio
        ↓
Interfaces / contratos
        ↓
Implementaciones concretas
        ↓
Base de datos / servicios externos
```

En Flutter, la estructura conceptual actual es:

```text
lib/
│
├── domain/
│
├── infrastructure/
│
└── presentation/
```

La regla fundamental es:

> La lógica del dominio no debe depender directamente de Flutter, SQLite ni de detalles de infraestructura.

---

# 2. VISIÓN GENERAL DE LAS CAPAS

```text
┌──────────────────────────────────────────┐
│              PRESENTATION                │
│                                          │
│ Screens / Controllers / Widgets          │
└───────────────────┬──────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────┐
│                 DOMAIN                   │
│                                          │
│ Entities / Repositories / Use Cases      │
└───────────────────┬──────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────┐
│             INFRASTRUCTURE               │
│                                          │
│ SQLite / Repository implementations      │
└───────────────────┬──────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────┐
│                 SQLite                   │
└──────────────────────────────────────────┘
```

La UI no debe saltarse las capas.

Evitar:

```text
Screen
  ↓
SQLite directamente
```

Preferir:

```text
Screen
  ↓
Controller
  ↓
Use Case
  ↓
Repository
  ↓
SQLite
```

---

# 3. ESTRUCTURA GENERAL ESPERADA

La estructura conocida del proyecto es aproximadamente:

```text
lib/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── infrastructure/
│   └── persistence/
│       └── sqlite/
│
└── presentation/
    └── screens/
        ├── combate/
        └── progreso/
```

Además existen componentes relacionados con autenticación y otras pantallas del proyecto.

IMPORTANTE:

Esta estructura representa la arquitectura conocida durante el desarrollo.

**No asumir que cada archivo mostrado en este documento existe exactamente con ese nombre en el repositorio actual.**

Antes de crear archivos, inspeccionar el proyecto.

---

# 4. CAPA DOMAIN

La capa `domain` contiene conceptos propios de SysQuest.

Debe ser la capa más independiente.

Estructura:

```text
lib/domain/
│
├── entities/
├── repositories/
└── usecases/
```

---

# 5. DOMAIN — ENTIDADES

Las entidades representan objetos importantes del dominio.

Entre las entidades conocidas están:

```text
Encuentro
OpcionEncuentro
Partida
Personaje
```

---

# 6. ENTIDAD ENCUENTRO

La entidad `Encuentro` representa un desafío individual dentro de una quest.

Conceptualmente contiene:

```text
id_encuentro
id_quest
numero
pregunta
dificultad
tipo_encuentro
vida_enemigo
opciones
```

El campo `opciones` representa las opciones de respuesta asociadas.

Ejemplo conceptual:

```text
Encuentro
│
├── ID
├── Quest
├── Número
├── Pregunta
├── Dificultad
├── Tipo
├── Vida del enemigo
└── Opciones
      ├── Opción A
      ├── Opción B
      ├── Opción C
      └── Opción D
```

---

# 7. TIPOS DE ENCUENTRO

Se han utilizado al menos dos tipos:

```text
normal
jefe
```

Ejemplo:

```text
enc-001 → normal
enc-002 → normal
enc-003 → jefe
```

El tipo de encuentro sirve principalmente para determinar comportamiento/presentación.

No crear una entidad completamente separada para `Jefe` mientras no sea necesario.

Un jefe sigue siendo un:

```text
Encuentro
```

con:

```text
tipo_encuentro = jefe
```

---

# 8. ENTIDAD OPCIÓN DE ENCUENTRO

`OpcionEncuentro` representa una respuesta posible a una pregunta.

Conceptualmente:

```text
OpcionEncuentro
│
├── id_opcion
├── id_encuentro
├── letra
├── texto
└── calidad
```

Ejemplo:

```text
A
"Un caso base que detenga la recursividad"
calidad = 2
```

La opción pertenece a un encuentro.

Relación:

```text
Encuentro 1 ──────── N Opciones
```

---

# 9. CAMPO CALIDAD

El sistema de combate utiliza un valor de calidad para determinar el resultado de la respuesta.

Valores utilizados durante el desarrollo:

```text
2 → respuesta correcta / excelente
1 → respuesta parcialmente correcta
0 → incorrecta
```

No asumir que estos valores son universales para todas las futuras mecánicas.

La interpretación definitiva debe buscarse en:

```text
ResponderEncuentroUseCase
```

y en las clases relacionadas con el resultado del turno.

---

# 10. ENTIDAD PARTIDA

`Partida` representa una sesión de juego.

Conceptualmente contiene información como:

```text
idPartida
idUsuario
idQuest
encuentroActual
score
```

Durante el combate se crea una instancia:

```dart
Partida(
  idPartida: ...,
  idUsuario: ...,
  idQuest: ...,
)
```

El identificador se genera utilizando UUID.

Ejemplo conceptual:

```text
Usuario
   ↓
Partida
   ├── Quest
   ├── Encuentro actual
   └── Score
```

---

# 11. IDENTIFICACIÓN DE PARTIDAS

Se utiliza UUID para generar IDs de partidas.

La implementación utilizada anteriormente incluye:

```dart
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();
```

y:

```dart
_uuid.v4()
```

No sustituir este mecanismo por IDs manuales salvo que exista una razón clara.

---

# 12. ENTIDAD PERSONAJE

Existe una entidad relacionada con:

```text
Personaje
```

El contexto disponible indica su utilización dentro del sistema de combate/partida.

Antes de modificarla, revisar su implementación real en:

```text
lib/domain/entities/
```

No inventar propiedades que no existan en el código.

---

# 13. REPOSITORIOS

Los repositorios son contratos de acceso a datos.

Por ejemplo:

```text
QuestRepository
```

La idea es que el dominio conozca:

```text
"Necesito obtener quests/encuentros"
```

pero no conozca:

```text
"Necesito ejecutar SELECT en SQLite"
```

Por tanto:

```text
Domain
    ↓
QuestRepository
```

mientras que:

```text
Infrastructure
    ↓
implementación concreta de QuestRepository
```

---

# 14. QUEST REPOSITORY

El proyecto utiliza:

```text
QuestRepository
```

para acceder a información relacionada con quests y encuentros.

El controller de combate utiliza una instancia del repository:

```dart
final QuestRepository _questRepository;
```

y obtiene los encuentros mediante:

```dart
_encuentros = await _questRepository.obtenerEncuentros(idQuest);
```

Esto es importante:

**El CombateController no debe consultar SQLite directamente.**

---

# 15. USE CASES

Los casos de uso representan acciones del sistema.

Entre los casos de uso conocidos:

```text
ResponderEncuentroUseCase
FinalizarPartidaUseCase
```

También existe lógica relacionada con la consulta de progreso.

---

# 16. RESPONDER ENCUENTRO

El caso de uso:

```text
ResponderEncuentroUseCase
```

es responsable de procesar una opción seleccionada.

Conceptualmente:

```text
OpcionEncuentro
       ↓
ResponderEncuentroUseCase
       ↓
ResultadoTurno
       ↓
danoAlEnemigo
danoAlJugador
resultado
```

El controller no debería contener toda la lógica matemática de respuesta.

Debe delegarla al caso de uso.

---

# 17. RESULTADO DEL TURNO

Durante el combate se maneja un resultado que puede representar:

```text
critico
acierto
fallo
```

El resultado contiene información como:

```text
danoAlEnemigo
danoAlJugador
resultado
```

La implementación exacta debe consultarse en el código actual.

---

# 18. FLUJO DE UNA RESPUESTA

El flujo esperado es:

```text
Usuario selecciona opción
          │
          ▼
CombateScreen
          │
          ▼
CombateController.elegirOpcion()
          │
          ▼
ResponderEncuentroUseCase
          │
          ▼
Resultado del turno
          │
          ├───────────────┐
          ▼               ▼
Daño enemigo         Daño jugador
          │               │
          └───────┬───────┘
                  ▼
           Actualizar estado
                  │
                  ▼
             notifyListeners()
                  │
                  ▼
               UI
```

---

# 19. FINALIZAR PARTIDA

El caso de uso:

```text
FinalizarPartidaUseCase
```

se encarga de registrar el resultado de la partida.

El controller utiliza:

```dart
await _finalizarUseCase.ejecutar(
  partida: _partida,
  gano: gano,
);
```

La UI no debe encargarse directamente de insertar el resultado en SQLite.

---

# 20. CONDICIÓN DE FINALIZACIÓN

Hay una diferencia importante entre:

```text
Encuentro superado
```

y:

```text
Partida terminada
```

No son equivalentes.

### Encuentro superado

```text
Enemigo derrotado
+
quedan encuentros
```

Resultado:

```text
encuentroSuperado = true
```

No se finaliza la partida.

### Partida terminada

Puede ocurrir porque:

```text
Jugador muere
```

o:

```text
Jugador derrota el último encuentro
```

Resultado:

```text
combateTerminado = true
```

y se guarda el resultado.

---

# 21. INFRASTRUCTURE

La infraestructura contiene los detalles técnicos.

Actualmente la persistencia utiliza:

```text
SQLite
```

La ubicación conocida es:

```text
lib/infrastructure/persistence/sqlite/
```

---

# 22. DATABASE HELPER

Archivo:

```text
lib/infrastructure/persistence/sqlite/database_helper.dart
```

Este componente gestiona la conexión/operaciones SQLite y contiene datos de prueba.

No debe ser utilizado directamente desde las pantallas.

---

# 23. TABLA QUEST

La conversación documenta una tabla:

```text
quest
```

Con campos utilizados durante la inserción de prueba:

```text
id_quest
titulo
tema
categoria
dificultad
descripcion
fuente_generacion
```

Ejemplo:

```text
id_quest:
quest-001

titulo:
Quest de Recursión

tema:
Recursión en programación

categoria:
debug

dificultad:
facil

descripcion:
Practica el concepto de recursión.

fuente_generacion:
manual
```

---

# 24. TABLA ENCUENTRO

La conversación documenta una tabla:

```text
encuentro
```

Campos utilizados:

```text
id_encuentro
id_quest
numero
pregunta
dificultad
tipo_encuentro
vida_enemigo
```

Relación conceptual:

```text
quest
  │
  │ 1:N
  ▼
encuentro
```

Una quest puede tener varios encuentros.

---

# 25. TABLA OPCION_ENCUENTRO

La conversación documenta:

```text
opcion_encuentro
```

Campos utilizados:

```text
id_opcion
id_encuentro
letra
texto
calidad
```

Relación:

```text
encuentro
   │
   │ 1:N
   ▼
opcion_encuentro
```

Por tanto:

```text
1 Quest
   ↓
N Encuentros
   ↓
N Opciones por encuentro
```

---

# 26. MODELO RELACIONAL CONOCIDO

El modelo documentado puede representarse así:

```text
┌────────────────────┐
│       QUEST        │
├────────────────────┤
│ id_quest           │
│ titulo             │
│ tema               │
│ categoria          │
│ dificultad         │
│ descripcion        │
│ fuente_generacion  │
└─────────┬──────────┘
          │
          │ 1:N
          ▼
┌────────────────────┐
│     ENCUENTRO      │
├────────────────────┤
│ id_encuentro       │
│ id_quest           │
│ numero             │
│ pregunta           │
│ dificultad         │
│ tipo_encuentro     │
│ vida_enemigo       │
└─────────┬──────────┘
          │
          │ 1:N
          ▼
┌────────────────────┐
│ OPCION_ENCUENTRO   │
├────────────────────┤
│ id_opcion          │
│ id_encuentro       │
│ letra              │
│ texto              │
│ calidad            │
└────────────────────┘
```

---

# 27. IMPORTANTE — ESQUEMA INCOMPLETO

El contexto disponible no contiene el esquema completo de todas las tablas SQLite.

Por lo tanto, NO asumir que estas son las únicas tablas del proyecto.

El proyecto también maneja información relacionada con:

* Usuarios.
* Partidas.
* Resultados.
* Progreso.

Antes de realizar modificaciones de base de datos, inspeccionar:

```text
database_helper.dart
```

y cualquier repository/DAO existente.

El código real es la fuente definitiva.

---

# 28. DATOS DE PRUEBA

Actualmente se documentaron tres encuentros para:

```text
quest-001
```

Orden:

```text
numero 1 → enc-001
numero 2 → enc-002
numero 3 → enc-003
```

El tercero es el jefe.

---

# 29. REGLA DE ORDEN DE ENCUENTROS

Los encuentros se cargan mediante:

```text
QuestRepository.obtenerEncuentros(idQuest)
```

El sistema espera recibirlos en el orden correcto.

El controller utiliza:

```dart
List<Encuentro> _encuentros = [];
```

y:

```dart
int _indiceActual = 0;
```

Por tanto, conceptualmente:

```text
_encuentros[0]
_encuentros[1]
_encuentros[2]
...
```

representan el orden de la quest.

Si en algún momento se detecta que el repository no garantiza el orden por `numero`, debe revisarse la consulta SQL o la implementación del repository.

No arreglarlo duplicando lógica de ordenamiento en múltiples capas.

---

# 30. COMBATE CONTROLLER

Archivo conocido:

```text
lib/presentation/screens/combate/combate_controller.dart
```

Responsabilidad:

* Mantener el estado del combate.
* Cargar la quest.
* Mantener encuentro actual.
* Procesar selección de opción.
* Actualizar vida.
* Determinar si hay más encuentros.
* Avanzar al siguiente encuentro.
* Finalizar la partida.

No debería:

* Ejecutar SQL directamente.
* Construir widgets.
* Contener toda la lógica de dominio.
* Duplicar la lógica de `ResponderEncuentroUseCase`.

---

# 31. ESTADO DEL COMBATE

El controller utiliza variables conceptualmente equivalentes a:

```dart
List<Encuentro> _encuentros = [];

int _indiceActual = 0;

late Partida _partida;

int vidaJugador = 100;

int vidaEnemigo = 30;

String? mensajeUltimoTurno;

bool cargando = true;

bool encuentroSuperado = false;

bool combateTerminado = false;

bool jugadorGano = false;

bool guardandoResultado = false;
```

---

# 32. GETTER DEL ENCUENTRO ACTUAL

El patrón utilizado es:

```dart
Encuentro? get encuentroActual =>
    _encuentros.isEmpty ? null : _encuentros[_indiceActual];
```

Esto permite que la pantalla trabaje con:

```text
encuentroActual
```

sin acceder directamente a la lista interna.

---

# 33. CARGA DE LA QUEST

Flujo:

```text
cargarQuest()
      ↓
reset de estado
      ↓
repository.obtenerEncuentros()
      ↓
guardar lista
      ↓
indice = 0
      ↓
cargar HP primer enemigo
      ↓
crear Partida
      ↓
mostrar UI
```

El jugador comienza con:

```text
100 HP
```

y el enemigo comienza con la vida especificada por el primer encuentro.

---

# 34. TRANSICIÓN ENTRE ENCUENTROS

Cuando:

```text
vidaEnemigo <= 0
```

se comprueba:

```text
¿Hay otro encuentro?
```

Conceptualmente:

```dart
final hayMasEncuentros =
    _indiceActual + 1 < _encuentros.length;
```

Si:

```text
true
```

entonces:

```text
encuentroSuperado = true
```

Si:

```text
false
```

entonces:

```text
combateTerminado = true
jugadorGano = true
```

---

# 35. CONTINUAR SIGUIENTE ENCUENTRO

La transición debe:

```text
incrementar índice
```

y:

```text
vidaEnemigo = vida del nuevo encuentro
```

Además:

```text
mensajeUltimoTurno = null
encuentroSuperado = false
```

No reiniciar:

```text
vidaJugador
```

---

# 36. REGLA DE VIDA DEL JUGADOR

La vida del jugador pertenece a la partida completa.

Ejemplo:

```text
Inicio:
100 HP

Después del encuentro 1:
80 HP

Encuentro 2:
comienza con 80 HP

Después:
55 HP

Jefe:
comienza con 55 HP
```

Esto permite que las decisiones anteriores tengan consecuencias.

---

# 37. REGLA DE VIDA DEL ENEMIGO

Cada encuentro tiene su propia vida.

Ejemplo:

```text
enc-001 → 30
enc-002 → 40
enc-003 → 70
```

Al pasar al siguiente:

```text
vidaEnemigo =
encuentroActual.vidaEnemigo
```

---

# 38. COMBATE SCREEN

Archivo:

```text
lib/presentation/screens/combate/combate_screen.dart
```

Responsabilidad:

* Presentar estado.
* Mostrar pregunta.
* Mostrar respuestas.
* Mostrar HP.
* Mostrar resultado.
* Mostrar botón continuar.
* Mostrar resultado final.
* Navegar a progreso.

No debe implementar reglas complejas del juego.

---

# 39. MANEJO DEL ESTADO EN LA UI

Se utiliza:

```dart
Consumer<CombateController>
```

para reconstruir la interfaz cuando el controller llama:

```dart
notifyListeners();
```

El patrón conceptual es:

```text
Controller cambia estado
       ↓
notifyListeners()
       ↓
Provider
       ↓
Consumer
       ↓
UI reconstruida
```

---

# 40. PANTALLA DE PROGRESO

Ubicación conocida:

```text
lib/presentation/screens/progreso/
```

La pantalla muestra:

```text
Nivel
XP
Victorias
Derrotas
Tasa de victoria
```

La pantalla no debería consultar SQLite directamente.

Debe utilizar el flujo de repositorio/caso de uso existente.

---

# 41. FLUJO COMPLETO DE LECTURA DE PROGRESO

Conceptualmente:

```text
ProgresoScreen
      ↓
Controller / UseCase
      ↓
Repository
      ↓
SQLite
      ↓
Datos de progreso
      ↓
UI
```

Antes de implementar nuevas estadísticas, revisar cómo está resuelto actualmente.

---

# 42. FLUJO COMPLETO DE UNA QUEST

La arquitectura funcional completa puede representarse así:

```text
                    ┌─────────────┐
                    │    LOGIN    │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    HOME     │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    QUEST    │
                    └──────┬──────┘
                           │
                           ▼
              ┌────────────────────────┐
              │    COMBATE CONTROLLER  │
              └────────────┬───────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ ENCUENTRO 1 │
                    └──────┬──────┘
                           │
                     derrotado
                           │
                           ▼
                    ┌─────────────┐
                    │ ENCUENTRO 2 │
                    └──────┬──────┘
                           │
                     derrotado
                           │
                           ▼
                    ┌─────────────┐
                    │    JEFE     │
                    └──────┬──────┘
                           │
                     derrotado
                           │
                           ▼
                    ┌─────────────┐
                    │   VICTORIA  │
                    └──────┬──────┘
                           │
                           ▼
                 FinalizarPartidaUseCase
                           │
                           ▼
                        SQLite
                           │
                           ▼
                    Mi Progreso
```

---

# 43. FLUJO DE DATOS DE UNA RESPUESTA

```text
Usuario
  │
  │ selecciona A/B/C/D
  ▼
CombateScreen
  │
  ▼
CombateController
  │
  ▼
ResponderEncuentroUseCase
  │
  ▼
ResultadoTurno
  │
  ├── daño enemigo
  │
  ├── daño jugador
  │
  └── tipo resultado
  │
  ▼
CombateController
  │
  ├── actualiza HP
  ├── determina victoria/derrota
  └── determina siguiente encuentro
  │
  ▼
notifyListeners()
  │
  ▼
CombateScreen
```

---

# 44. FLUJO DE GUARDADO

Cuando termina una partida:

```text
CombateController
       │
       ▼
FinalizarPartidaUseCase
       │
       ▼
Repository
       │
       ▼
SQLite
```

El resultado debe almacenarse de manera persistente.

---

# 45. FLUJO DE CONSULTA

Para mostrar progreso:

```text
ProgresoScreen
       │
       ▼
Use Case / Controller
       │
       ▼
Repository
       │
       ▼
SQLite
       │
       ▼
Datos
       │
       ▼
UI
```

---

# 46. RELACIONES CONCEPTUALES

La estructura conceptual del dominio es:

```text
Usuario
  │
  │
  ├───────────────┐
  │               │
  ▼               ▼
Partida          Progreso
  │
  │
  ▼
Quest
  │
  ├──────────────┐
  │              │
  ▼              ▼
Encuentro 1    Encuentro 2 ...
                  │
                  ▼
                Jefe
                  │
                  ▼
              Opciones
```

Una forma más precisa para la parte de quest:

```text
Quest
  │
  ├── Encuentro 1
  │      ├── Opción A
  │      ├── Opción B
  │      ├── Opción C
  │      └── Opción D
  │
  ├── Encuentro 2
  │      ├── Opción A
  │      ├── Opción B
  │      ├── Opción C
  │      └── Opción D
  │
  └── Encuentro 3 (Jefe)
         ├── Opción A
         ├── Opción B
         ├── Opción C
         └── Opción D
```

---

# 47. REGLAS DE DEPENDENCIA

## Permitido

```text
Presentation → Domain
Infrastructure → Domain
```

porque infraestructura implementa contratos del dominio.

## Evitar

```text
Domain → Flutter
Domain → SQLite
Domain → Widgets
```

También evitar:

```text
Screen → DatabaseHelper
```

cuando exista un repository/use case adecuado.

---

# 48. RESPONSABILIDAD POR COMPONENTE

| Componente                | Responsabilidad                         |
| ------------------------- | --------------------------------------- |
| Entity                    | Representar datos/conceptos del dominio |
| Repository                | Definir acceso a datos                  |
| Repository implementation | Implementar acceso concreto             |
| Use Case                  | Ejecutar una acción del negocio         |
| Controller                | Gestionar estado de la UI               |
| Screen                    | Mostrar/interactuar con el usuario      |
| DatabaseHelper            | Manejar detalles SQLite                 |
| SQLite                    | Persistencia                            |

---

# 49. DÓNDE DEBE IR CADA COSA

## Regla práctica

Si la pregunta es:

> "¿Esto es una regla del juego?"

Probablemente:

```text
domain
```

Si la pregunta es:

> "¿Esto es una consulta/inserción de SQLite?"

Probablemente:

```text
infrastructure
```

Si la pregunta es:

> "¿Esto solo sirve para mostrar algo?"

Probablemente:

```text
presentation
```

---

# 50. EJEMPLO: NUEVA REGLA DE COMBATE

Supongamos que se quiere implementar:

> Un golpe especial si el jugador responde correctamente tres veces seguidas.

No colocar toda la regla en el widget.

La separación ideal sería:

```text
Domain
  ↓
Regla del combate / caso de uso

Presentation
  ↓
Mostrar contador y animación

Infrastructure
  ↓
Solo si hay que persistir el dato
```

---

# 51. EJEMPLO: NUEVA CONSULTA SQLITE

Si se necesita:

> Obtener las quests completadas.

No hacer:

```dart
db.query(...)
```

desde una pantalla.

Hacer conceptualmente:

```text
Screen
 ↓
UseCase
 ↓
Repository
 ↓
SQLite implementation
```

---

# 52. EJEMPLO: NUEVO CAMPO DE ENCUENTRO

Si se agrega:

```text
recompensa_xp
```

debe analizarse:

1. Entidad `Encuentro`.
2. Esquema SQLite.
3. Repository.
4. Mapper/model si existe.
5. Caso de uso.
6. UI solamente si debe mostrarse.

No modificar solamente SQLite y asumir que todo lo demás funcionará.

---

# 53. CAMBIOS DE BASE DE DATOS

Antes de cambiar el esquema:

1. Revisar versión actual de SQLite.
2. Revisar `onCreate`.
3. Revisar `onUpgrade`.
4. Revisar tablas existentes.
5. Revisar foreign keys.
6. Revisar repositories.
7. Revisar entidades/modelos.

No borrar la base de datos del usuario como solución permanente.

---

# 54. DATOS DE PRUEBA VS DATOS REALES

Los datos de prueba actualmente sirven para desarrollar el MVP.

Ejemplo:

```text
quest-001
enc-001
enc-002
enc-003
```

No asumir que estos IDs representan contenido definitivo.

El sistema debe poder evolucionar posteriormente hacia datos reales.

---

# 55. ORDEN DE DESARROLLO RECOMENDADO

Cuando se agregue una nueva funcionalidad relacionada con datos:

```text
1. Entidad
2. Repository contract
3. Repository implementation
4. Use Case
5. Controller
6. Screen
```

No siempre será necesario modificar todas las capas.

Modificar solamente las necesarias.

---

# 56. ORDEN DE DESARROLLO PARA UNA FUNCIONALIDAD VISUAL

Si solamente se necesita cambiar presentación:

```text
Screen
Widget
Theme/Style
```

No tocar:

```text
SQLite
Repository
Domain
```

si no es necesario.

---

# 57. ORDEN DE DESARROLLO PARA UNA REGLA DEL JUEGO

Preferir:

```text
Entity / Domain
       ↓
Use Case
       ↓
Controller
       ↓
UI
```

---

# 58. ORDEN DE DESARROLLO PARA PERSISTENCIA

Preferir:

```text
Entity
   ↓
Repository contract
   ↓
Repository implementation
   ↓
DatabaseHelper
   ↓
SQLite
```

---

# 59. PRUEBAS FUNCIONALES DEL COMBATE

Cada cambio relacionado con combate debería comprobar al menos:

### Caso 1 — Respuesta correcta

Debe:

* Dañar al enemigo.
* Mostrar mensaje correspondiente.
* Mantener al jugador vivo.

### Caso 2 — Respuesta incorrecta

Debe:

* Dañar al jugador.
* Actualizar HP.
* Mostrar mensaje.

### Caso 3 — Enemigo derrotado con encuentros restantes

Debe:

* Mostrar "Encuentro superado".
* Mostrar "Continuar".
* No finalizar la partida.

### Caso 4 — Último enemigo derrotado

Debe:

* Mostrar victoria.
* Guardar resultado.
* Permitir consultar progreso.

### Caso 5 — Jugador derrotado

Debe:

* Mostrar derrota.
* Guardar resultado como derrota.
* No continuar al siguiente encuentro.

---

# 60. INVARIANTES DEL SISTEMA

Estas condiciones deben mantenerse.

## Invariante 1

Nunca debe existir un:

```text
encuentroActual
```

fuera de:

```text
0 <= indice < encuentros.length
```

## Invariante 2

No avanzar después de que:

```text
combateTerminado == true
```

## Invariante 3

No procesar nuevas respuestas después de terminar la partida.

## Invariante 4

No guardar victoria completa antes del último encuentro.

## Invariante 5

La vida del jugador no debe reiniciarse automáticamente al cambiar de encuentro.

## Invariante 6

La vida del enemigo sí debe reiniciarse al cargar el nuevo encuentro.

---

# 61. POSIBLES ESTADOS DEL COMBATE

El combate puede entenderse como una pequeña máquina de estados:

```text
                ┌───────────────┐
                │   CARGANDO    │
                └───────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │   ENCUENTRO   │
                └───────┬───────┘
                        │
             ┌──────────┼──────────┐
             │          │          │
             ▼          ▼          ▼
          jugador    enemigo     respuesta
           muere     muere       procesada
             │          │
             ▼          ▼
         DERROTA     ¿quedan?
                        │
                ┌───────┴───────┐
                │               │
               sí              no
                │               │
                ▼               ▼
        ENCUENTRO SUPERADO    VICTORIA
                │
                ▼
          CONTINUAR
                │
                ▼
          SIGUIENTE
                │
                └──────────→ ENCUENTRO
```

---

# 62. SOBRE PROVIDER

El proyecto utiliza `ChangeNotifier` y Provider para comunicar cambios entre controller y UI.

Patrón:

```text
Controller extends ChangeNotifier
```

La UI utiliza:

```dart
Consumer<CombateController>
```

Los cambios de estado llaman:

```dart
notifyListeners();
```

No mezclar innecesariamente Provider con otro sistema de gestión de estado.

---

# 63. SOBRE UUID

UUID se utiliza para IDs generados dinámicamente, especialmente partidas.

No utilizar UUID para reemplazar IDs semánticos de contenido si el proyecto utiliza IDs como:

```text
quest-001
enc-001
```

para datos de prueba/manuales.

---

# 64. SOBRE NOMBRES

Mantener nombres existentes.

Ejemplos:

```text
Encuentro
OpcionEncuentro
Partida
QuestRepository
ResponderEncuentroUseCase
FinalizarPartidaUseCase
CombateController
CombateScreen
ProgresoScreen
```

No cambiar nombres solamente por preferencias estilísticas.

---

# 65. SOBRE MODELOS Y ENTIDADES

Si existe una separación entre:

```text
Entity
Model
```

mantenerla.

No mezclar automáticamente:

```text
SQLite Map
```

con:

```text
Domain Entity
```

si el proyecto ya utiliza mapeadores.

Primero revisar el código actual.

---

# 66. SOBRE MAPPERS

Si el proyecto tiene métodos como:

```text
fromMap()
toMap()
```

o equivalentes:

mantenerlos dentro de la capa correspondiente.

No colocar SQL directamente en las entidades de dominio.

---

# 67. SOBRE ERRORES

Los errores de infraestructura no deberían filtrarse directamente a la UI sin tratamiento cuando exista una capa adecuada para manejarlos.

Ejemplo conceptual:

```text
SQLite error
     ↓
Repository
     ↓
UseCase
     ↓
Controller
     ↓
mensaje UI
```

La implementación exacta depende del patrón actual.

---

# 68. SOBRE ASINCRONÍA

Las operaciones SQLite/repository son normalmente asíncronas.

Ejemplo:

```dart
_encuentros =
    await _questRepository.obtenerEncuentros(idQuest);
```

No bloquear la UI con operaciones síncronas innecesarias.

---

# 69. SOBRE ESTADO ASÍNCRONO

El controller utiliza estados como:

```text
cargando
guardandoResultado
```

Esto permite evitar mostrar una UI incompleta durante operaciones asíncronas.

Mantener este patrón cuando se agreguen operaciones similares.

---

# 70. SOBRE NAVEGACIÓN POST-COMBATE

Cuando se termina el combate se puede navegar a:

```text
ProgresoScreen
```

mediante:

```text
Navigator.pushReplacement
```

Esto evita mantener la pantalla de combate como pantalla principal del flujo después de terminar la partida.

Si posteriormente se cambia el sistema de navegación, hacerlo de manera consistente en toda la aplicación.

---

# 71. PRIMER DIAGNÓSTICO QUE COPILOT DEBE HACER

Al recibir este documento y tener acceso al repositorio, revisar:

```text
lib/
pubspec.yaml
```

y localizar:

```text
domain/entities
domain/repositories
domain/usecases
infrastructure/persistence/sqlite
presentation/screens/combate
presentation/screens/progreso
```

Después identificar:

```text
1. Todas las entidades reales.
2. Todos los repositories reales.
3. Todos los use cases reales.
4. Implementaciones SQLite.
5. Tablas reales.
6. Controllers.
7. Screens.
8. Relaciones entre componentes.
```

---

# 72. MATRIZ DE TRAZABILIDAD

| Funcionalidad | Presentation             | Domain                    | Infrastructure          |
| ------------- | ------------------------ | ------------------------- | ----------------------- |
| Login         | LoginScreen/Auth UI      | Auth logic                | Persistencia usuario    |
| Quest         | Quest UI                 | Quest entities/use cases  | Quest repository/SQLite |
| Encuentro     | CombateScreen            | Encuentro                 | SQLite                  |
| Respuesta     | CombateController        | ResponderEncuentroUseCase | No necesariamente       |
| Combate       | CombateController        | Reglas de dominio         | No necesariamente       |
| Finalización  | CombateScreen/Controller | FinalizarPartidaUseCase   | Persistencia            |
| Progreso      | ProgresoScreen           | Caso de uso de progreso   | SQLite/repository       |

Esta tabla es conceptual.

El código real tiene prioridad.

---

# 73. REGLA DE ORO PARA COPILOT

Antes de crear:

```text
archivo
clase
tabla
repository
use case
controller
```

buscar primero si ya existe.

Antes de cambiar:

```text
entidad
tabla
repository
controller
```

leer primero su implementación.

Antes de refactorizar:

```text
comprobar si realmente es necesario
```

---

# 74. REGLA DE ORO SOBRE SQLITE

Nunca solucionar un problema de lógica de aplicación simplemente borrando la base de datos.

Si es un problema de:

```text
datos de prueba
```

puede ser aceptable durante desarrollo.

Si es un problema de:

```text
esquema
```

se debe considerar una migración.

---

# 75. REGLA DE ORO SOBRE QUESTS

Una quest es un contenedor de múltiples encuentros.

```text
Quest
  ↓
Encuentro
  ↓
Opciones
```

El combate recorre los encuentros secuencialmente.

---

# 76. REGLA DE ORO SOBRE JEFES

Un jefe:

```text
ES un Encuentro
```

No es una categoría de datos completamente independiente.

Se diferencia mediante:

```text
tipo_encuentro
```

y puede tener:

* mayor vida;
* mayor dificultad;
* presentación visual diferente;
* contenido más complejo.

---

# 77. REGLA DE ORO SOBRE PROGRESO

El progreso debe representar el resultado de partidas reales.

No generar estadísticas artificiales.

No insertar:

```text
victorias falsas
XP falso
porcentajes falsos
```

para hacer que la pantalla parezca funcional.

Los datos de prueba deben estar claramente separados de los datos reales.

---

# 78. REGLA DE ORO SOBRE EL MVP

No implementar funcionalidades futuras antes de cerrar correctamente el flujo:

```text
Login
→ Quest
→ Combate
→ Múltiples encuentros
→ Jefe
→ Resultado
→ Persistencia
→ Progreso
```

Este flujo es la columna vertebral actual de SysQuest.

---

# 79. ESTADO DE ARQUITECTURA DE REFERENCIA

La arquitectura conceptual de referencia es:

```text
                       SYSQUEST
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   PRESENTATION         DOMAIN          INFRASTRUCTURE
        │                  │                  │
        │                  │                  │
   Screens             Entities          SQLite
   Controllers         Repositories      DatabaseHelper
   Widgets             UseCases          Repository impl.
        │                  │                  │
        └──────────┬───────┘                  │
                   │                          │
                   └──────────────────────────┘
```

La interpretación concreta depende de las implementaciones actuales.

---

# 80. CONTEXTO TÉCNICO FINAL

El estado conceptual del proyecto es:

```text
Flutter
│
├── Presentation
│   ├── Authentication
│   ├── Home
│   ├── Quest
│   ├── Combate
│   │   ├── Controller
│   │   └── Screen
│   └── Progreso
│
├── Domain
│   ├── Entities
│   │   ├── Encuentro
│   │   ├── OpcionEncuentro
│   │   ├── Partida
│   │   └── Personaje
│   │
│   ├── Repositories
│   │   └── QuestRepository
│   │
│   └── Use Cases
│       ├── ResponderEncuentroUseCase
│       └── FinalizarPartidaUseCase
│
└── Infrastructure
    └── Persistence
        └── SQLite
            └── DatabaseHelper
```

---

# 81. SIGUIENTE ACCIÓN DE COPILOT

Después de leer este documento:

**NO comenzar a modificar archivos automáticamente.**

Primero inspeccionar el repositorio actual y entregar un diagnóstico breve:

```text
## Estado actual detectado

### Arquitectura
...

### Entidades
...

### Repositories
...

### Use Cases
...

### SQLite
...

### Combate
...

### Progreso
...

### Diferencias respecto al contexto
...

### Errores encontrados
...

### Próximo punto de desarrollo
...
```

Después esperar la instrucción del usuario.

---

# 82. PRINCIPIO FINAL

SysQuest debe evolucionar mediante cambios pequeños, comprobables y reversibles.

La arquitectura existente es una guía para mantener orden, no una excusa para sobreingeniería.

La prioridad es:

```text
CORRECCIÓN
    ↓
ESTABILIDAD
    ↓
CLARIDAD
    ↓
FUNCIONALIDAD
    ↓
MEJORAS
```

Siempre preservar lo que ya funciona antes de agregar algo nuevo.
