# Script Re-training Model AI THRIFTY
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "     THRIFTY AI MODEL RE-TRAINING PIPELINE         " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

$workspaceRoot = Split-Path -Parent $PSScriptRoot
Set-Location $workspaceRoot

$pythonCmd = "python"
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    $stdPath = "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
    if (Test-Path $stdPath) {
        $pythonCmd = $stdPath
    } else {
        Write-Error "Python tidak ditemukan di PATH atau direktori standar."
        exit 1
    }
}

Write-Host "[INFO] Menggunakan Python: $pythonCmd" -ForegroundColor Green
Write-Host ""
Write-Host "Langkah 1: Menjalankan Training Model..." -ForegroundColor Yellow
& $pythonCmd ml/training/train.py

if ($LASTEXITCODE -ne 0) {
    Write-Error "Proses training mengalami kegagalan."
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Langkah 2: Menjalankan Evaluasi Dataset Riil Google Drive..." -ForegroundColor Yellow
& $pythonCmd ml/training/test_with_drive_dataset.py

Write-Host ""
Write-Host "===================================================" -ForegroundColor Green
Write-Host "  Re-Training & Evaluasi Sukses Selesai!            " -ForegroundColor Green
Write-Host "  Model baru tersimpan di: ml/models/              " -ForegroundColor Green
Write-Host "  Grafik visual di: ml/reports/ dan ml/results/     " -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
