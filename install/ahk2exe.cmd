@echo off
setlocal

:: --- Configuration ---
:: Set the path to Ahk2Exe.exe. Adjust this if your AutoHotkey installation is in a different location.
:: Common paths:
:: For 64-bit AutoHotkey on 64-bit Windows: C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
:: For 32-bit AutoHotkey on 64-bit Windows: C:\Program Files (x86)\AutoHotkey\Compiler\Ahk2Exe.exe
set "AHK2EXE_PATH=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"

:: Set the path to the base AutoHotkey.exe file. This is usually in the parent directory of Ahk2Exe.exe.
:: Adjust this if your AutoHotkey installation is in a different location.
set "BASE_FILE_PATH=C:\Program Files\AutoHotkey\v2\AutoHotkey.exe"

:: Input AHK script file path (relative to the batch file's location)
set "INPUT_AHK=..\topas.ahk"

:: Output directory for the compiled executable (relative to the batch file's location)
set "OUTPUT_DIR=.\dist"

:: Output executable file name
set "OUTPUT_EXE_NAME=topas.exe"

:: --- Script Logic ---

echo.
echo Checking for Ahk2Exe.exe...
if not exist "%AHK2EXE_PATH%" (
    echo ERROR: Ahk2Exe.exe not found at "%AHK2EXE_PATH%".
    echo Please update the AHK2EXE_PATH variable in this script to your correct AutoHotkey installation path.
    goto myEOF
)
echo Ahk2Exe.exe found.

echo.
echo Checking for base AutoHotkey.exe file...
if not exist "%BASE_FILE_PATH%" (
    echo ERROR: Base AutoHotkey.exe file not found at "%BASE_FILE_PATH%".
    echo Please update the BASE_FILE_PATH variable in this script to the correct path.
    goto myEOF
)
echo Base AutoHotkey.exe found.

echo.
echo Checking for input AHK script: %INPUT_AHK%
if not exist "%INPUT_AHK%" (
    echo ERROR: Input AHK script "%INPUT_AHK%" not found.
    echo Please ensure topas.ahk is in the correct relative path.
    goto myEOF
)
echo Input AHK script found.

echo.
echo Creating output directory: %OUTPUT_DIR%
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to create directory "%OUTPUT_DIR%".
        goto myEOF
    )
    echo Directory created.
) else (
    echo Directory already exists.
)

set "FULL_OUTPUT_PATH=%OUTPUT_DIR%\%OUTPUT_EXE_NAME%"

echo.
echo Compiling %INPUT_AHK% to %FULL_OUTPUT_PATH%...
:: The command format is: Ahk2Exe.exe /in <input_ahk_file> /out <output_exe_file> /base <base_ahk_exe_file>
"%AHK2EXE_PATH%" /in "%INPUT_AHK%" /out "%FULL_OUTPUT_PATH%" /base "%BASE_FILE_PATH%" /icon ".\topas.ico"

if %errorlevel% equ 0 (
    echo.
    echo Compilation successful!
    echo Executable created at: %FULL_OUTPUT_PATH%
) else (
    echo.
    echo ERROR: Compilation failed.
    echo Please check the output above for any errors from Ahk2Exe.exe.
)
:myEOF
echo.
rem pause
endlocal
