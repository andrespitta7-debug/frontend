import os
import glob
import docx

folder_unrev = r"C:\Users\Andres\Desktop\Personal\Universidad de Cundinamarca\V Semestre\Ingeniería de Software\Historias de Usuario y Casos de Uso\documentos sin revisar generado en claude SYSQUEST"
folder_dest = r"C:\Users\Andres\Desktop\Personal\Universidad de Cundinamarca\V Semestre\Ingeniería de Software\Historias de Usuario y Casos de Uso"

# Mapeo de reemplazos por archivo
modificaciones_hu = {
    "HU-08": [
        ("Pendiente", "Definido e implementado"),
        ("Sin registros adicionales por el momento.", 
         "1. Anti-Spam: Botones de respuesta bloqueados durante 700ms tras seleccionar opción.\n"
         "2. Game Feel: Hitstop de 80ms al impactar, sacudida de pantalla dual (suave en acierto, fuerte en daño recibido), flash rojo en enemigo y outline dinámico en daño flotante.\n"
         "3. Wildcards: Soporte de 4 comodines (50/50, Robo de vida +10HP, Golpe doble 2x daño, Pista de longitud). Se inicia con 1 de cada tipo; se recarga +1 aleatorio cada 3 enemigos derrotados (máx 3).\n"
         "4. Consola Narrativa: Panel scrollable plegable estilo Dwarf Fortress que acumula el registro de turnos."),
        ("Sin registros adicionales", "Criterios de Game Feel, Wildcards y Consola Narrativa implementados en CombateController.")
    ],
    "HU-09": [
        ("Pendiente de definir la fórmula exacta que traduce xp_total en nivel.", 
         "Fórmula oficial cerrada y aplicada: nivel = 1 + floor(xp_total / 100). Incrementos: Victoria = +50 XP (y +100 puntos de score base, +500 por ronda superada), Derrota = +10 XP. Todo cálculo se persiste de manera atómica."),
        ("Pendiente de definir", "nivel = 1 + floor(xp_total / 100)"),
        ("Sin registros adicionales por el momento.", 
         "1. Persistencia Dual: Flag guardarLocalmente permite persistir en SQLite local o invocar Edge Function finalizar-partida conectada a PostgreSQL mediante RPC transaccional.\n"
         "2. Reanudación y Vida: Se persiste vida_jugador_actual, vida_enemigo_actual, ronda y enemigos_derrotados para auditar y soportar la Run Extendida.")
    ],
    "HU-10": [
        ("Pendiente", "Implementado"),
        ("Sin registros adicionales por el momento.", 
         "1. Pantalla de Resumen Final: Muestra resultado (Victoria/Derrota), score final acumulado, XP obtenida, nivel resultante y desglose de preguntas acertadas/falladas.\n"
         "2. Menú de Pausa en Vivo: Permite consultar en tiempo real las estadísticas acumuladas de la partida (Ronda actual, Enemigos derrotados, Score vivo y Vida).")
    ],
    "HU-11": [
        ("Pendiente", "Implementado"),
        ("Sin registros adicionales por el momento.", 
         "1. Pantalla Mi Progreso: Consulta en tiempo real nivel, XP total, quests completadas, victorias, derrotas y total de partidas jugadas mediante Edge Function obtener-progreso o SQLite local.\n"
         "2. Seguridad e Identidad: Los datos se aíslan estrictamente mediante token JWT y políticas RLS en PostgreSQL, impidiendo que un estudiante consulte el progreso de otro.")
    ]
}

modificaciones_cu = {
    "CU-08": [
        ("CU-007 Responder pregunta de", "CU-08 Resolver combate por turnos"),
        ("09/24//2026", "09/28/2026"),
        ("Tiempo entre responder y ver el resultado", "Menor a 1.0 segundo. Bloqueo anti-spam de 700ms y animación de hitstop de 80ms."),
        ("Pendiente de definir", "< 1 segundo")
    ],
    "CU-09": [
        ("Pendiente de definir la fórmula exacta que traduce xp_total en nivel", 
         "Fórmula oficial: nivel = 1 + floor(xp_total / 100). Victoria: +50 XP; Derrota: +10 XP."),
        ("Pendiente de definir", "Atómico (RPC crear_run_completa / finalizar_partida)")
    ],
    "CU-10": [
        ("Pendiente de definir", "< 1.5 segundos")
    ],
    "CU-11": [
        ("Pendiente de definir", "< 2.0 segundos")
    ]
}

def procesar_archivo(codigo, tipo):
    prefix = f"{tipo}-{codigo}"
    patron = os.path.join(folder_unrev, f"{prefix}*.docx")
    archivos = glob.glob(patron)
    if not archivos:
        print(f"No se encontró archivo para {prefix}")
        return
    
    archivo_origen = archivos[0]
    nombre_base = os.path.basename(archivo_origen)
    archivo_destino = os.path.join(folder_dest, nombre_base)
    
    doc = docx.Document(archivo_origen)
    modos = modificaciones_hu.get(prefix, []) if tipo == "HU" else modificaciones_cu.get(prefix, [])
    
    cambios_realizados = 0
    # Reemplazar en párrafos
    for p in doc.paragraphs:
        for viejo, nuevo in modos:
            if viejo in p.text:
                p.text = p.text.replace(viejo, nuevo)
                cambios_realizados += 1
                
    # Reemplazar en tablas
    for t in doc.tables:
        for row in t.rows:
            for cell in row.cells:
                for viejo, nuevo in modos:
                    if viejo in cell.text:
                        cell.text = cell.text.replace(viejo, nuevo)
                        cambios_realizados += 1
                        
    # Actualizar encabezados si faltaba fecha o aprobador
    for t in doc.tables:
        for row in t.rows:
            for cell in row.cells:
                if "Andres Orley Pitta Pardo" in cell.text and "1.0" in cell.text:
                    pass

    doc.save(archivo_destino)
    print(f"Guardado corregido en destino: {nombre_base} ({cambios_realizados} correcciones aplicadas)")

for num in ["08", "09", "10", "11"]:
    procesar_archivo(num, "HU")
    procesar_archivo(num, "CU")

print("Proceso completado exitosamente.")
