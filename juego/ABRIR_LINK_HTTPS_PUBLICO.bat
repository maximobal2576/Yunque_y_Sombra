@echo off
chcp 65001 >nul
title Yunque y Sombra - Tunel HTTPS Oficial (Sin Certbot ni Licencias)
cd /d "%~dp0"

echo ==============================================================================
echo  🌐 INICIANDO SERVIDOR LOCAL + TUNEL HTTPS GRATUITO (localhost.run)
echo ==============================================================================
echo  1. Levantando el servidor Web local en segundo plano (puerto 8080)...
start /b python iniciar_servidor_web_lan.py >nul 2>&1
timeout /t 2 /nobreak >nul

echo  2. Generando enlace HTTPS oficial para abrir desde cualquier otra compu...
echo     (Copia el link https://...lhr.life que aparecera aqui abajo)
echo ==============================================================================
ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 nokey@localhost.run
pause
