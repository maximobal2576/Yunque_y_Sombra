@echo off
chcp 65001 >nul
title Yunque y Sombra - Servidor Web en Red Local (LAN)
cd /d "%~dp0"

if not exist "build\web\index.html" (
    echo [INFO] Compilando version Web HTML5 con Godot 4.7.2...
    if exist "C:\Users\admin\Downloads\Godot_v4.7.2-stable_win64_console.exe" (
        mkdir "build\web" 2>nul
        "C:\Users\admin\Downloads\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --export-release "Web" "build/web/index.html"
    )
)

python iniciar_servidor_web_lan.py
pause
