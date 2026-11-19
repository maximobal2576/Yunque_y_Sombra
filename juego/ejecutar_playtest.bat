@echo off
title Yunque y Sombra - Playtesting en Pantalla (/playtester)
echo Iniciando Sesion de Playtesting Interactivo en tu Pantalla...
set GODOT_PLAYTEST=1
start "" "C:\Users\admin\Downloads\Godot_v4.7.2-stable_win64.exe" --path "%~dp0."
