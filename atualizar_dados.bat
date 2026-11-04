@echo off
cd /d "%~dp0"
if "%~1"=="" (
  python tools\update_data.py
) else (
  python tools\update_data.py --local "%~1"
)
pause
