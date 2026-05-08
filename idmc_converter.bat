@echo off
REM ==========================================
REM IDMC to PySpark Converter - Windows Batch Script
REM ==========================================
REM Description: Automates the conversion of IDMC XML/ZIP files to PySpark code
REM Author: Hackathon2026
REM Date: 2026-05-08
REM ==========================================

setlocal enabledelayedexpansion

cls
title IDMC to PySpark Converter - Windows Automation

REM ==========================================
REM CONFIGURATION
REM ==========================================
set "SCRIPT_DIR=%~dp0"
set "LOG_FILE=%SCRIPT_DIR%idmc_converter.log"
set "INPUT_DIR=%SCRIPT_DIR%input"
set "OUTPUT_DIR=%SCRIPT_DIR%output"
set "TEMP_DIR=%SCRIPT_DIR%temp"
set "PYTHON_SCRIPT=%SCRIPT_DIR%idmc_converter.py"

REM Create required directories
if not exist "%INPUT_DIR%" mkdir "%INPUT_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

REM ==========================================
REM START PROCESS
REM ==========================================
echo.
echo ==========================================
echo   IDMC to PySpark Converter
echo   Windows Batch Automation Tool
echo ==========================================
echo.
echo Timestamp: %date% %time%
echo Script Location: %SCRIPT_DIR%
echo.

REM Clear and initialize log
echo [%date% %time%] === NEW CONVERSION SESSION STARTED === > "%LOG_FILE%"

REM ==========================================
REM CHECK PYTHON INSTALLATION
REM ==========================================
echo Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.7+ and add it to system PATH
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('python --version') do set "PYTHON_VERSION=%%i"
echo Python found: %PYTHON_VERSION%
echo [%date% %time%] Python Check: OK - %PYTHON_VERSION% >> "%LOG_FILE%"
echo.

REM ==========================================
REM PROMPT FOR INPUT FILE
REM ==========================================
echo.
echo ==========================================
echo   STEP 1: INPUT FILE SELECTION
echo ==========================================
echo.
echo Supported file formats:
echo   - XML files (*.xml) - IDMC mapping export
echo   - ZIP files (*.zip) - Compressed IDMC exports
echo   - JSON files (*.json) - IDMC configuration
echo.
echo Place your input file in:
echo   %INPUT_DIR%
echo.
echo Files found:
pushd "%INPUT_DIR%"
if exist "*.xml" (
    echo   - XML files:
    dir /b *.xml
) else if exist "*.zip" (
    echo   - ZIP files:
    dir /b *.zip
) else if exist "*.json" (
    echo   - JSON files:
    dir /b *.json
) else (
    echo   [No files found in input directory]
)
popd
echo.

set /p INPUT_FILE="Enter input filename (with extension): "

if not exist "%INPUT_DIR%\%INPUT_FILE%" (
    echo.
    echo [ERROR] File not found: %INPUT_FILE%
    echo Looking in: %INPUT_DIR%
    echo.
    pause
    exit /b 1
)

echo [%date% %time%] Input File Selected: %INPUT_FILE% >> "%LOG_FILE%"
echo.

REM ==========================================
REM VALIDATE FILE EXTENSION
REM ==========================================
echo Validating file format...
for %%A in ("%INPUT_FILE%") do set "FILE_EXT=%%~xA"

set "FILE_TYPE="

if /i "%FILE_EXT%"==".xml" (
    set "FILE_TYPE=XML"
    echo File Type: XML (IDMC Mapping Definition)
    goto :extension_validated
)

if /i "%FILE_EXT%"==".zip" (
    set "FILE_TYPE=ZIP"
    echo File Type: ZIP (Compressed Archive)
    goto :extension_validated
)

if /i "%FILE_EXT%"==".json" (
    set "FILE_TYPE=JSON"
    echo File Type: JSON (JSON Configuration)
    goto :extension_validated
)

REM If we reach here, no valid extension was found
echo [ERROR] Unsupported file format: %FILE_EXT%
echo Supported formats: .xml, .zip, .json
echo.
pause
exit /b 1

:extension_validated
echo [%date% %time%] File Type Validated: %FILE_TYPE% >> "%LOG_FILE%"
echo.

REM ==========================================
REM EXTRACT ZIP IF NEEDED
REM ==========================================
if /i "%FILE_TYPE%"=="ZIP" (
    echo.
    echo ==========================================
    echo   STEP 2: EXTRACTING ZIP FILE
    echo ==========================================
    echo.
    echo Extracting: %INPUT_FILE%
    echo To: %TEMP_DIR%
    echo.
    
    REM Use PowerShell to extract ZIP
    powershell -Command "Expand-Archive -Path '%INPUT_DIR%\%INPUT_FILE%' -DestinationPath '%TEMP_DIR%' -Force" 2>nul
    if errorlevel 1 (
        echo [ERROR] Failed to extract ZIP file
        echo [%date% %time%] ZIP Extraction Failed >> "%LOG_FILE%"
        pause
        exit /b 1
    )
    
    echo Extraction successful!
    echo [%date% %time%] ZIP Extraction: SUCCESS >> "%LOG_FILE%"
    echo.
    
    REM Find XML file in extracted contents
    for /r "%TEMP_DIR%" %%F in (*.xml) do (
        set "INPUT_FILE=%%~nxF"
        set "INPUT_DIR=%TEMP_DIR%"
        goto :found_xml
    )
    
    :found_xml
)

REM ==========================================
REM STEP 3: RUN PYTHON CONVERSION
REM ==========================================
echo.
echo ==========================================
echo   STEP 3: CONVERTING TO PYSPARK CODE
echo ==========================================
echo.
echo Input File: %INPUT_DIR%\%INPUT_FILE%
echo Output Directory: %OUTPUT_DIR%
echo.

REM Create Python command to convert IDMC to PySpark
echo Generating PySpark code from IDMC mapping...
echo [%date% %time%] Starting IDMC to PySpark conversion >> "%LOG_FILE%"

REM Run Python with explicit output
cd /d "%SCRIPT_DIR%"
python "%PYTHON_SCRIPT%" "%INPUT_DIR%\%INPUT_FILE%" "%OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Python conversion failed!
    echo.
    echo Debugging Information:
    echo ========================
    echo Checking input file...
    if exist "%INPUT_DIR%\%INPUT_FILE%" (
        echo Input file found: %INPUT_DIR%\%INPUT_FILE%
    ) else (
        echo [ERROR] Input file not found!
    )
    echo.
    echo Python version:
    python --version
    echo.
    echo Python path:
    where python
    echo.
    echo Log file contents:
    type "%LOG_FILE%"
    echo.
    echo [%date% %time%] Conversion Failed >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo Conversion successful!
echo [%date% %time%] Conversion: SUCCESS >> "%LOG_FILE%"
echo.

REM ==========================================
REM STEP 4: VERIFY OUTPUT
REM ==========================================
echo.
echo ==========================================
echo   STEP 4: VERIFYING OUTPUT
echo ==========================================
echo.

set "OUTPUT_FOUND=0"
for %%F in ("%OUTPUT_DIR%\*.py") do (
    if exist "%%F" (
        set "OUTPUT_FOUND=1"
        echo PySpark file generated: %%~nxF
    )
)

if %OUTPUT_FOUND%==1 (
    echo.
    echo [%date% %time%] Output Files Generated Successfully >> "%LOG_FILE%"
) else (
    echo [ERROR] No PySpark output files generated
    echo [%date% %time%] No Output Files Generated >> "%LOG_FILE%"
    echo.
    pause
    exit /b 1
)

REM ==========================================
REM COMPLETION - SKIP GITHUB PUSH BY DEFAULT
REM ==========================================
echo.
echo ==========================================
echo   PROCESS COMPLETED
echo ==========================================
echo.
echo Summary:
echo   Input File: %INPUT_FILE%
echo   Output Directory: %OUTPUT_DIR%
echo   Log File: %LOG_FILE%
echo.
echo Generated PySpark files are available at:
echo   %OUTPUT_DIR%
echo.
echo To view the files:
echo   explorer "%OUTPUT_DIR%"
echo.
echo [%date% %time%] Process Completed Successfully >> "%LOG_FILE%"
echo.

pause
exit /b 0
