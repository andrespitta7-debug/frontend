<#
.SYNOPSIS
    Sincronización automatizada de Historias y Tareas técnicas en Atlassian Jira para SysQuest.
#>

param (
    [string]$JiraUrl,
    [string]$Email,
    [string]$ApiToken,
    [string]$ProjectKey
)

if (-not $JiraUrl) { $JiraUrl = Read-Host "Ingresa la URL de tu Jira (ej: https://tu-equipo.atlassian.net)" }
if (-not $Email) { $Email = Read-Host "Ingresa tu correo de Atlassian" }
if (-not $ApiToken) { 
    $SecurePass = Read-Host "Ingresa tu API Token de Atlassian" -AsSecureString
    $ApiToken = [System.Net.NetworkCredential]::new("", $SecurePass).Password
}
if (-not $ProjectKey) { $ProjectKey = Read-Host "Ingresa el Key de tu proyecto (ej: SQ o SYSQ)" }

$JiraUrl = $JiraUrl.TrimEnd('/')
$Base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Email}:${ApiToken}"))
$Headers = @{
    "Authorization" = "Basic $Base64Auth"
    "Content-Type"  = "application/json"
    "Accept"        = "application/json"
}

$Items = @(
    @{
        Type = "Task"
        Summary = "Documentación: Aplicar metodología 12-Factor App al Backend"
        Description = "Formalizar en el documento de arquitectura la aplicación de los 12 factores (config en variables de entorno, logs como event streams, backing services desacoplados y paridad dev/prod con Docker)."
    },
    @{
        Type = "Task"
        Summary = "Documentación: Definición de Atributos de Calidad e ISO/IEC 25010 y 27001"
        Description = "Documentar la matriz de trazabilidad de atributos de calidad (desempeño, seguridad, confiabilidad) alineados con las normas ISO 25010 e ISO 27001 aplicadas a Flutter y Supabase."
    },
    @{
        Type = "Story"
        Summary = "Implementar Swagger UI interactivo en Edge Functions"
        Description = "Crear endpoint de documentación OpenAPI/Swagger UI conectado a PostgREST para documentar y probar las entidades y endpoints del backend."
    },
    @{
        Type = "Story"
        Summary = "Refinar Game Feel y mecánicas de combate por turnos"
        Description = "Incorporar hitstop (80ms), sacudida de pantalla dual, outline dinámico en daño y sistema de wildcards (50/50, robo de vida, golpe doble y pista)."
    },
    @{
        Type = "Story"
        Summary = "Integración de Run Infinita y generación procedural de narrativa con IA"
        Description = "Conectar Edge Function generar-quest-completa con pool narrativo dinámico y banco de preguntas extra asistido por Groq/Gemini."
    },
    @{
        Type = "Task"
        Summary = "Auditoría y alineación de Historias de Usuario (HU) y Casos de Uso (CU)"
        Description = "Auditar HU-01 a HU-18 respecto al código implementado en el repositorio GitHub y formalizar el backlog de Sprint 2 y 3."
    }
)

Write-Host "`nIniciando carga de actividades en Jira ($ProjectKey)..." -ForegroundColor Cyan

foreach ($item in $Items) {
    $Body = @{
        fields = @{
            project   = @{ key = $ProjectKey }
            summary   = $item.Summary
            description = @{
                type = "doc"
                version = 1
                content = @(
                    @{
                        type = "paragraph"
                        content = @(
                            @{
                                type = "text"
                                text = $item.Description
                            }
                        )
                    }
                )
            }
            issuetype = @{ name = $item.Type }
        }
    } | ConvertTo-Json -Depth 10

    try {
        $Response = Invoke-RestMethod -Uri "$JiraUrl/rest/api/3/issue" -Method Post -Headers $Headers -Body $Body
        Write-Host " [+] Creado: [$($item.Type)] $($item.Summary) -> Clave: $($Response.key)" -ForegroundColor Green
    } catch {
        Write-Host " [-] Error al crear '$($item.Summary)': $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nProceso finalizado con éxito." -ForegroundColor Cyan
