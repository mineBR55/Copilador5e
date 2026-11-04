@echo off
cd /d "%~dp0"
if "%~1"=="" (
 echo Uso: importar.bat "C:\caminho\para\5etools\data"
 pause
 exit /b 1
)
python tools\import_5etools.py --source "%~1" --output data
pause
