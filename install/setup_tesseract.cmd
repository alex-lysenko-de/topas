@echo off
setlocal enabledelayedexpansion

REM === URL for downloading Tesseract Setup ===
set "TES_EXE_URL=https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-v5.3.0.20221214.exe"

REM === Temporary path for the installer ===
set "TEMP_FILE=%TEMP%\tesseract_setup.exe"

echo Downloading Tesseract OCR installer...
powershell -Command "Invoke-WebRequest -Uri '%TES_EXE_URL%' -OutFile '%TEMP_FILE%'"

if not exist "%TEMP_FILE%" (
    echo ERROR: Failed to download the Tesseract installer.
    pause
    exit /b 1
)

echo Installing Tesseract OCR with languages: English, German, Russian...
"%TEMP_FILE%"  /LANG=eng+deu+rus


echo Cleaning up temporary files...
del /f /q "%TEMP_FILE%"


REM === Add Tesseract to system PATH ===
set "TESS_PATH=C:\Program Files\Tesseract-OCR"

REM Check if the directory exists
if exist "%TESS_PATH%" (
    echo Adding Tesseract to the system PATH...
    powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';%TESS_PATH%', 'Machine')"
) else (
    echo WARNING: Tesseract installation folder not found: %TESS_PATH%
)

echo Tesseract OCR installation completed successfully.
endlocal
exit /b 0
