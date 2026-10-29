# Instrucciones para Copilot - SysQuest

## Contexto del proyecto

Este proyecto sigue una arquitectura hexagonal con separación clara de capas:

- `lib/domain/`: lógica de negocio pura
  - `entities/`: entidades del dominio
  - `repositories/`: contratos (puertos) del dominio
  - `usecases/`: casos de uso
- `lib/infrastructure/`: adaptadores concretos
  - `persistence/sqlite/`: implementaciones SQLite
- `lib/presentation/`: UI, controllers y pantallas

Regla principal:

- El dominio no debe depender de Flutter, SQLite ni de detalles de infraestructura.
- La presentación no debe consultar SQLite directamente.
- La UI debe pasar por controller → use case → repository → SQLite.

## Reglas de trabajo

1. Mantener la arquitectura hexagonal.
2. No introducir lógica de negocio en pantallas ni widgets.
3. No tocar directamente SQLite desde los controllers o la UI.
4. Si se necesita acceso a datos, crear o usar un repositorio y un caso de uso del dominio.
5. Si se modifica el dominio, mantener interfaces y contratos coherentes con las implementaciones concretas.
6. Priorizar lógica funcional antes que estética.
7. No trabajar todavía en web admin, Supabase, multijugador ni extensiones fuera del alcance actual.
8. Preferir cambios incrementales y validados.

## Estructura esperada

```text
lib/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── infrastructure/
│   └── persistence/
│       └── sqlite/
├── presentation/
│   └── screens/
└── main.dart
```

## Patrones que debe respetar Copilot

- `QuestRepository` define el puerto para acceso a quests.
- `SqliteQuestRepository` implementa ese puerto usando SQLite.
- `ResponderEncuentroUseCase` encapsula la lógica de resolver una respuesta.
- `FinalizarPartidaUseCase` encapsula la lógica de progresión y finalización.
- Los controllers sólo orquestan y no tienen lógica de negocio compleja.

## Validación

Antes de dar por terminado un cambio, validar con pruebas o análisis relevantes:

- `flutter test` si se cambia lógica de dominio o casos de uso
- `flutter analyze` si se cambia estructura o compilación

## Scope actual

No ampliar el alcance a:

- panel administrativo web
- Supabase
- arquitectura multiusuario
- sincronización remota
- cambios de esquema no vinculados con la lógica funcional actual

## Objetivo

Mantener el proyecto funcionando con la lógica de SysQuest y respetando la separación de capas definida en la documentación del proyecto.
