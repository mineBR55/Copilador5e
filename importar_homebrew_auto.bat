@echo off
setlocal
if "%~1"=="" goto usage
if "%~2"=="" goto usage
python tools\import_homebrew_auto.py --source "%~1" --homebrew "%~2" --output data
if errorlevel 1 exit /b 1
echo.
echo Importacao concluida. Recompile e reinstale o plugin com rdk c e rdk i.
exit /b 0
:usage
echo Uso: importar_homebrew_auto.bat "C:\caminho\5etools\data" "C:\caminho\homebrew"
exit /b 2
