[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# SysQuest - exporta el código y los cambios en archivos de texto listos para
# NotebookLM o para pegar en un chat nuevo.
#
# Uso (desde la raíz del proyecto, C:\Users\jhony\sysquest_app):
#   .\tools\exportar_contexto.ps1
#   .\tools\exportar_contexto.ps1 -IncluirPresentation
#
# Salida en docs\export\ :
#   codigo_domain_infra.txt  -> código de domain/ e infrastructure/ (subir a NotebookLM)
#   ultimo_diff.txt          -> cambios sin commitear (pegar en el chat para revisión)

param(
    [switch]$IncluirPresentation
)

$raiz = (Get-Location).Path
$salida = Join-Path $raiz "docs\export"
New-Item -ItemType Directory -Force -Path $salida | Out-Null

# Carpetas a exportar
$carpetas = @("lib\domain", "lib\infrastructure")
if ($IncluirPresentation) { $carpetas += "lib\presentation" }

# 1) Código concatenado
$archivoCodigo = Join-Path $salida "codigo_domain_infra.txt"
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm"
"// SysQuest - exportado el $fecha" | Out-File $archivoCodigo -Encoding utf8

foreach ($carpeta in $carpetas) {
    if (-not (Test-Path $carpeta)) {
        Write-Warning "No existe la carpeta $carpeta, se omite."
        continue
    }
    Get-ChildItem $carpeta -Recurse -Filter *.dart | ForEach-Object {
        $rel = $_.FullName.Substring($raiz.Length + 1)
        "`n// ===== $rel =====`n" | Out-File $archivoCodigo -Append -Encoding utf8
        Get-Content $_.FullName -Encoding utf8 | Out-File $archivoCodigo -Append -Encoding utf8
    }
}
Write-Host "Codigo exportado: $archivoCodigo"

# 2) Cambios pendientes (requiere git)
$archivoDiff = Join-Path $salida "ultimo_diff.txt"
if (Get-Command git -ErrorAction SilentlyContinue) {
    git add -N lib test docs tools 2>$null
    git diff HEAD | Out-File $archivoDiff -Encoding utf8
    Write-Host "Diff exportado:   $archivoDiff"
} else {
    Write-Warning "git no está disponible; no se generó ultimo_diff.txt."
}

Write-Host ""
Write-Host "Siguiente paso: sube codigo_domain_infra.txt a NotebookLM (reemplaza el anterior)"
Write-Host "o pega ultimo_diff.txt en el chat para que revise los cambios."
