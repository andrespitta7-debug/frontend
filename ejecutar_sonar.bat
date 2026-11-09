@echo off
echo ========================================================
echo    EJECUTANDO SONARQUBE SCANNER - SYSQUEST FRONTEND
echo ========================================================
docker run --rm -v "%~dp0:/usr/src" -e SONAR_HOST_URL="http://host.docker.internal:9000" -e SONAR_TOKEN="squ_5fdd641f9cae635835a3a1968da5f88966a474ce" sonarsource/sonar-scanner-cli
echo.
echo ========================================================
echo Dashboard disponible en: http://localhost:9000/dashboard?id=sysquest-frontend
echo ========================================================
pause
