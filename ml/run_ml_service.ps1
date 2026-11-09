# Thrifty ML Service Runner PowerShell Script
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$PythonCmd = "python"
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    $fallback = "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
    if (Test-Path $fallback) {
        $PythonCmd = $fallback
    } else {
        Write-Error "Python executable not found. Please install Python 3.10+."
    }
}

Write-Host "===================================================" -ForegroundColor Green
Write-Host "  Thrifty AI Grading & Classification Service     " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Green
Write-Host "Using Python: $PythonCmd" -ForegroundColor Yellow
Write-Host "API running at: http://localhost:8000" -ForegroundColor Green
Write-Host "Swagger Docs:   http://localhost:8000/docs" -ForegroundColor Yellow
Write-Host ""

& $PythonCmd -m uvicorn service.app:app --host 0.0.0.0 --port 8000 --reload
