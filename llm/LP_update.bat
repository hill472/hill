@chcp 65001>nul
@echo off
title LLM Proxy - Update
cd /d "%~dp0"

REM 优先用项目 venv 的 python（依赖已装齐；无 venv 时回退系统 python，需自行装依赖）
if exist ".venv\Scripts\python.exe" (
    set "PY=.venv\Scripts\python.exe"
) else (
    set "PY=python"
)
%PY% scripts/update.py
if errorlevel 1 (
    echo.
    echo [ERROR] update.py failed, skipping init.
    goto :after_replace
)

echo.
echo ─────────────────────────────────────────────────────────
set /p RUN_INIT="update 完成。是否执行 init (Y/n)? "
if /i "%RUN_INIT%"=="n" goto :skip_init
if /i "%RUN_INIT%"=="no" goto :skip_init

echo.
echo 正在执行 init...
echo.
%PY% scripts/init.py
goto :after_init

:skip_init
echo [INFO] 已跳过 init。如需初始化请手动运行 LP_init.bat 或 python scripts/init.py

:after_init

:after_replace
echo.
pause

:: After pause — check if LP_update.bat itself was updated (saved as _LP_update.bat.pending).
:: Launch a detached process to replace it, then exit to release the file lock.
if exist "%~dp0_LP_update.bat.pending" (
    echo [INFO] LP_update.bat updated, replacing...
    >"%TEMP%\_llmproxy_replace.bat" (
        echo @echo off
        echo ping -n 2 127.0.0.1 ^>nul
        echo move /y "%~dp0_LP_update.bat.pending" "%~dp0LP_update.bat" ^>nul 2^>^&1
        echo if errorlevel 1 ^(
        echo     echo [WARN] Failed to replace, please rename _LP_update.bat.pending to LP_update.bat manually
        echo     pause
        echo ^) else ^(
        echo     echo [INFO] LP_update.bat replaced successfully
        echo ^)
    )
    start "" /min cmd /c "%TEMP%\_llmproxy_replace.bat"
)

exit /b
