@chcp 65001>nul
@echo off
title LLM Proxy - Query Models
cd /d "%~dp0"

REM 优先用项目 venv 的 python（依赖已装齐；无 venv 时回退系统 python，需自行装依赖）
if exist ".venv\Scripts\python.exe" (
    set "PY=.venv\Scripts\python.exe"
) else (
    set "PY=python"
)
%PY% scripts/get_models.py %*
echo.
pause
