@echo off
setlocal
cd /d "%~dp0"
if exist output rmdir /s /q output
set "STAGE=%TEMP%\Compendium5e_rdk_stage"
if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%STAGE%"
mkdir "%STAGE%\data"
for %%F in (module.xml compendium.lfm resultItem.lfm common.lua cr_engine.lua encounter_engine.lua loot_engine.lua loot_resolver.lua table_engine.lua) do copy /y "%%F" "%STAGE%\" >nul
copy /y data\*.lua "%STAGE%\data\" >nul
pushd "%STAGE%"
rdk c
set "RC=%ERRORLEVEL%"
popd
if not exist output mkdir output
if exist "%STAGE%\output\*.rpk" copy /y "%STAGE%\output\*.rpk" output\ >nul
rmdir /s /q "%STAGE%"
pause
exit /b %RC%
