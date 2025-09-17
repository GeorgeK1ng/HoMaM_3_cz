@echo off
title  Heroes of Might and Magic 3 Complete CZ
cls
setlocal EnableExtensions EnableDelayedExpansion

echo.

set "TARGET_DIR=%~1"

if "%TARGET_DIR%"=="" (
	echo.
	echo   Zadej cestu k instalaci Heroes of Might and Magic 3 Complete - napriklad C:\GOG Games\HoMM 3 Complete)
	set /p "TARGET_DIR=> "
	set "TARGET_DIR=%TARGET_DIR:"=%"
)


set "SRC_ROOT=%~dp0"
set "LODEXE=%~dp0lodimport.exe"

set /a TOTAL=0, FAILED=0, SKIPPED=0

for /d %%D in ("%SRC_ROOT%*") do (
  set "BASENAME=%%~nxD"
  if not "!BASENAME!" == "maps" (
	  set "LOD_PATH=%TARGET_DIR%\data\!BASENAME!.lod"
		if exist "!LOD_PATH!" (
			echo.
			echo  Probiha aktualizace !LOD_PATH!
			set /a COUNT=0
			for /f "tokens=*" %%F IN ('dir /b "%%D\!BASEPATH!"') do (
				"%LODEXE%" "!LOD_PATH!" "%%D\!BASEPATH!\%%F"
				if errorlevel 1 (
					echo    [WARN] Selhal import: %%~fF
					set /a FAILED+=1
				) else (
					set /a COUNT+=1, TOTAL+=1
				)
			)
			echo    Importovano: !COUNT! souboru.
		) else (
			echo [SKIP] Nenalezen LOD: "!LOD_PATH!"
			set /a SKIPPED+=1
		)
	)
)

echo.
echo  Aktualizace map

rd /q /s "%TARGET_DIR%\maps" >nul
md "%TARGET_DIR%\Maps\" >nul
copy /y "%SRC_ROOT%\maps\*" "%TARGET_DIR%\maps\" >nul

echo.
echo  Aktualizace manualu

del /q "%TARGET_DIR%\*.pdf" >nul
copy /y "%SRC_ROOT%\*.pdf" "%TARGET_DIR%\" >nul

del /q "%TARGET_DIR%\README.txt" >nul
copy /y "%SRC_ROOT%\README.txt" "%TARGET_DIR%\README.txt" >nul

del /q "%TARGET_DIR%\gog*" >nul 2>nul

if exist "%TARGET_DIR%\_HD3_Data\Lang" (
	echo.
	echo  Instalace cestiny pro HD Launcher
	copy /y "%SRC_ROOT%\#cz.ini" "%TARGET_DIR%\_HD3_Data\Lang\#cz.ini" >nul
)

echo.
echo === Hotovo ===
echo.
pause
