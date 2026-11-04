@echo off
setlocal
cd /d "%~dp0"
if exist output rmdir /s /q output
set "STAGE=%TEMP%\Compendium5e_rdk_stage"
if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%STAGE%"
mkdir "%STAGE%\data"
copy /y module.xml "%STAGE%\" >nul
copy /y compendium.lfm "%STAGE%\" >nul
copy /y resultItem.lfm "%STAGE%\" >nul
copy /y common.lua "%STAGE%\" >nul
copy /y cr_engine.lua "%STAGE%\" >nul
copy /y encounter_engine.lua "%STAGE%\" >nul
copy /y loot_engine.lua "%STAGE%\" >nul
copy /y loot_resolver.lua "%STAGE%\" >nul
copy /y table_engine.lua "%STAGE%\" >nul
copy /y data\*.lua "%STAGE%\data\" >nul
pushd "%STAGE%"
rdk i
set "RC=%ERRORLEVEL%"
popd
if not exist output mkdir output
if exist "%STAGE%\output\*.rpk" copy /y "%STAGE%\output\*.rpk" output\ >nul
if "%RC%"=="0" (
 echo Instalacao concluida. RPK copiado para output.
) else (
 echo Falha no rdk i. Codigo: %RC%
)
rmdir /s /q "%STAGE%"
pause
exit /b %RC%
