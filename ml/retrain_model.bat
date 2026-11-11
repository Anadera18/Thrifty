@echo off
echo ===================================================
echo     THRIFTY AI MODEL RE-TRAINING PIPELINE
echo ===================================================
echo.

cd /d "%~dp0\.."

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

echo [INFO] Using Python: %PYTHON_CMD%
echo.
echo Langkah 1: Memeriksa dan Menjalankan Training Model...
%PYTHON_CMD% ml/training/train.py
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Training gagal.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Langkah 2: Menjalankan Evaluasi Dataset Riil Google Drive...
%PYTHON_CMD% ml/training/test_with_drive_dataset.py

echo.
echo ===================================================
echo   Re-Training & Evaluasi Sukses Selesai!
echo   Model baru tersimpan di: ml/models/
echo   Grafik visual tersimpan di: ml/reports/ dan ml/results/
echo ===================================================
pause
