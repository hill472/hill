@chcp 65001>nul
@echo off
title LLM Proxy - Run
cd /d "%~dp0"

REM 优先用项目 venv 的 python（依赖已装齐；无 venv 时回退系统 python，需自行装依赖）
if exist ".venv\Scripts\python.exe" (
    set "PY=.venv\Scripts\python.exe"
) else (
    set "PY=python"
)

REM 前置检查：未初始化时引导用户先跑 LP_init.bat，避免 main.py 直接抛 FileNotFoundError
if not exist "config.yaml" (
    echo [ERROR] 未找到 config.yaml，项目尚未初始化。
    echo         请先双击 LP_init.bat 完成初始化后再启动。
    echo.
    pause
    exit /b 1
)

%PY% main.py %*
echo.
pause
