@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: Switch to script directory
cd /d "%~dp0"

echo [INFO] Checking Python dependencies (uv)...
:: Sync environment
call uv sync
if %errorlevel% neq 0 (
    echo [ERROR] uv environment sync failed.
    pause
    exit /b 1
)

:: Check for --dev argument
if "%1"=="--dev" goto :DEV_MODE
goto :PROD_MODE

:DEV_MODE
echo ================================================
echo === DEV MODE: Backend + Frontend (Parallel) ===
echo ================================================
echo [START] Starting Backend (http://localhost:7860)...
start /b uv run uvicorn api_server:app --host 0.0.0.0 --port 7860 --reload

echo [START] Starting Frontend (http://localhost:3000)...
if not exist "frontend" (
    echo [ERROR] Frontend directory not found.
    pause
    exit /b 1
)
cd frontend
start /b npm run dev
cd ..
echo.
echo [HINT] Press Ctrl+C to stop services.
echo (You may need to manually terminate residual Node processes)
echo ================================================
pause >nul
exit /b 0

:PROD_MODE
echo ================================================
echo === PROD MODE: Build Frontend + Start Backend ===
echo ================================================
if not exist "frontend\dist" (
    echo [BUILD] Building frontend...
    cd frontend
    call npm install && call npm run build
    cd ..
)
echo [START] Starting Backend Server...
uv run python -m uvicorn api_server:app --host 0.0.0.0 --port 7860
pause