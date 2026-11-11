@echo off
echo ===================================================
echo   Starting Thrifty AI Grading & Classification Service
echo ===================================================

cd /d "%~dp0"

set PYTHON_CMD=python
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    if exist "%LOCALAPPDATA%\Programs\Python\Python313\python.exe" (
        set PYTHON_CMD="%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
    ) else (
        echo [ERROR] Python not found in PATH or standard location.
        pause
        exit /b 1
    )
)

echo Using Python: %PYTHON_CMD%
echo Serving ML Microservice on http://localhost:8000
echo Swagger documentation: http://localhost:8000/docs
echo.

%PYTHON_CMD% -m uvicorn service.app:app --host 0.0.0.0 --port 8000 --reload
pause
