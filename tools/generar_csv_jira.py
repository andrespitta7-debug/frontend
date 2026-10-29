import csv
import os

csv_path = r"C:\Users\Andres\Desktop\Personal\Universidad de Cundinamarca\V Semestre\Ingeniería de Software\SysQuest_Jira_Import.csv"

# Campos estándar de Jira para importación
headers = ["Issue Type", "Summary", "Description", "Priority", "Component/s", "Sprint"]

issues = [
    # --- SPRINT 1 (Completado / MVP Estudiante) ---
    ["Story", "HU-01: Registro de nuevo usuario", 
     "Como estudiante o docente, quiero registrarme en la plataforma mediante correo y contraseña para acceder al sistema. Implementado con Supabase Auth + persistencia de perfil y progreso.", 
     "High", "Autenticación", "Sprint 1"],
    ["Story", "HU-02: Inicio de sesión y autenticación persistente", 
     "Como usuario registrado, quiero iniciar sesión para acceder a mis funcionalidades y mantener mi sesión activa mediante JWT seguro en flutter_secure_storage.", 
     "High", "Autenticación", "Sprint 1"],
    ["Story", "HU-03: Visualización y catálogo de quests", 
     "Como estudiante, quiero consultar y seleccionar quests disponibles filtradas por categoría temática y dificultad.", 
     "High", "Quests", "Sprint 1"],
    ["Story", "HU-04: Iniciar quest por tema libre y presets", 
     "Como estudiante, quiero ingresar un tema de mi interés o elegir un tema de ingeniería para comenzar una misión gamificada.", 
     "High", "Quests", "Sprint 1"],
    ["Story", "HU-05: Generación procedural de quests mediante IA", 
     "Como estudiante, quiero que el sistema genere quests automáticamente utilizando modelos de lenguaje (Groq / Gemini) con preguntas balanceadas y narrativa inmersiva.", 
     "High", "Inteligencia Artificial", "Sprint 1"],
    ["Story", "HU-06: Mecanismo de fallback local offline", 
     "Como estudiante, quiero poder jugar con un banco de misiones precargadas en SQLite cuando no haya conectividad o falle la API de IA.", 
     "Medium", "Persistencia", "Sprint 1"],
    ["Story", "HU-07: Resolución de preguntas y encuentros", 
     "Como estudiante, quiero responder preguntas de opción múltiple (A/B/C/D) con retroalimentación instantánea y bloqueo anti-spam de 700ms.", 
     "High", "Combate", "Sprint 1"],
    ["Story", "HU-08: Combate por turnos con Game Feel y Wildcards", 
     "Como estudiante, quiero que el combate se resuelva según la calidad de respuesta (bono por acierto, contraataque en fallo), con efectos visuales (hitstop de 80ms, shake) y 4 comodines (50/50, robo de vida, golpe doble, pista).", 
     "High", "Combate", "Sprint 1"],
    ["Story", "HU-09: Registro transaccional de partida y cálculo de nivel", 
     "Como estudiante, quiero que al finalizar la partida se persista el score, XP (+50 victoria, +10 derrota) y se actualice el nivel mediante la fórmula cerrada nivel = 1 + floor(xp/100).", 
     "High", "Progreso", "Sprint 1"],
    ["Story", "HU-10: Retroalimentación y resumen de resultados", 
     "Como estudiante, quiero ver un desglose completo de mi desempeño al finalizar la misión y acceder al menú de pausa con estadísticas en vivo.", 
     "Medium", "Combate", "Sprint 1"],
    ["Story", "HU-11: Consulta de progreso individual", 
     "Como estudiante, quiero consultar mis estadísticas acumuladas (nivel, XP, victorias, derrotas, quests completadas) protegidas mediante RLS.", 
     "Medium", "Progreso", "Sprint 1"],

    # --- TAREAS TÉCNICAS (Arquitectura y Calidad) ---
    ["Task", "DOC-01: Documentación de Metodología The Twelve-Factor App", 
     "Formalizar en el documento de arquitectura la aplicación de los 12 factores (variables de entorno, logs como event streams, backing services desacoplados y paridad dev/prod con Docker).", 
     "High", "Arquitectura", "Sprint 1"],
    ["Task", "DOC-02: Matriz de Atributos de Calidad e ISO/IEC 25010 y 27001", 
     "Definir e incorporar la matriz de calidad de software y seguridad (rendimiento < 2s, tolerancia a fallos, RLS en PostgreSQL, 117 tests automatizados).", 
     "High", "Arquitectura", "Sprint 1"],
    ["Task", "API-01: Implementación de Swagger UI interactivo", 
     "Crear y exponer la interfaz interactiva de Swagger UI conectada a PostgREST en docs/swagger.html para documentación y pruebas de endpoints.", 
     "Medium", "Backend", "Sprint 1"],

    # --- SPRINT 2 (Backlog Refinado - Docente y Competencia) ---
    ["Story", "HU-12: Ranking global de estudiantes (Leaderboard)", 
     "Como estudiante, quiero consultar la tabla de posiciones clasificada por xp_total manteniendo la privacidad de correos y datos sensibles.", 
     "Low", "Progreso", "Sprint 2"],
    ["Story", "HU-13: Creación de contenido educativo por docentes", 
     "Como docente, quiero crear misiones y encuentros personalizados asignando el enum fuente_generacion = 'DOCENTE'.", 
     "Medium", "Docente", "Sprint 2"],
    ["Story", "HU-14: Edición inmutable y versionado de quests", 
     "Como docente, quiero modificar quests existentes generando una nueva versión inmutable (version + 1) sin alterar partidas activas.", 
     "Medium", "Docente", "Sprint 2"],
    ["Story", "HU-15: Desactivación lógica de quests", 
     "Como docente, quiero desactivar misiones obsoletas mediante activa = false sin romper la integridad referencial de partidas históricas.", 
     "Low", "Docente", "Sprint 2"],

    # --- SPRINT 3 (Backlog - Métricas y Administración) ---
    ["Story", "HU-16: Tablero de métricas y estadísticas pedagógicas", 
     "Como docente, quiero consultar la tasa de error por encuentro, promedio de puntuación y tiempos de resolución de los estudiantes.", 
     "Low", "Docente", "Sprint 3"],
    ["Story", "HU-17: Administración de usuarios y control de roles", 
     "Como administrador, quiero asignar roles (estudiante, docente, admin) y revocar tokens de acceso a cuentas desactivadas.", 
     "Low", "Administración", "Sprint 3"],
    ["Story", "HU-18: Gestión de parámetros globales del sistema", 
     "Como administrador, quiero configurar parámetros del juego (timeout_ia en 10s, XP de victoria/derrota y límite de wildcards).", 
     "Low", "Administración", "Sprint 3"]
]

with open(csv_path, mode='w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(headers)
    writer.writerows(issues)

print(f"Archivo CSV generado con éxito en: {csv_path}")
