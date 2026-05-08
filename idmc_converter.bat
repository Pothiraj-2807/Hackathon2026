@echo off
REM ==========================================
REM IDMC to PySpark Converter - Windows Batch Script
REM ==========================================
REM Description: Automates the conversion of IDMC XML/ZIP files to PySpark code
REM Author: Hackathon2026
REM Date: 2026-05-08
REM ==========================================

setlocal enabledelayedexpansion

REM Define color codes for output
REM Note: Color codes work in Windows 10+
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

REM Log the start
echo [%date% %time%] Process Started >> "%LOG_FILE%"

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
cd /d "%INPUT_DIR%" 2>nul
if exist "*.xml" (
    echo   - XML files:
    dir /b *.xml
) else (
    if exist "*.zip" (
        echo   - ZIP files:
        dir /b *.zip
    ) else (
        if exist "*.json" (
            echo   - JSON files:
            dir /b *.json
        ) else (
            echo   [No files found in input directory]
        )
    )
)
cd /d "%SCRIPT_DIR%"
echo.

set /p INPUT_FILE="Enter input filename (with extension): "

if not exist "%INPUT_DIR%\%INPUT_FILE%" (
    echo.
    echo [ERROR] File not found: %INPUT_FILE%
    echo.
    pause
    exit /b 1
)

echo [%date% %time%] Input File Selected: %INPUT_FILE% >> "%LOG_FILE%"
echo.

REM ==========================================
REM VALIDATE FILE EXTENSION - FIXED LOGIC
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
echo Processing: %INPUT_DIR%\%INPUT_FILE%
echo Output Directory: %OUTPUT_DIR%
echo.

REM Create Python command to convert IDMC to PySpark
echo Generating PySpark code from IDMC mapping...
echo [%date% %time%] Starting IDMC to PySpark conversion >> "%LOG_FILE%"

python "%PYTHON_SCRIPT%" "%INPUT_DIR%\%INPUT_FILE%" "%OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Conversion failed. Check log file: %LOG_FILE%
    echo [%date% %time%] Conversion Failed >> "%LOG_FILE%"
    echo.
    echo Showing last 20 lines of log file:
    echo.
    powershell -Command "Get-Content '%LOG_FILE%' -Tail 20"
    echo.
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

if exist "%OUTPUT_DIR%\*.py" (
    echo PySpark files generated:
    dir /b "%OUTPUT_DIR%\*.py"
    echo.
    echo [%date% %time%] Output Files Generated Successfully >> "%LOG_FILE%"
) else (
    echo [ERROR] No PySpark output files generated
    echo [%date% %time%] No Output Files Generated >> "%LOG_FILE%"
    pause
    exit /b 1
)

REM ==========================================
REM STEP 5: GITHUB PUSH
REM ==========================================
echo.
echo ==========================================
echo   STEP 5: GITHUB REPOSITORY CONFIGURATION
echo ==========================================
echo.
echo The PySpark code has been generated successfully!
echo.
echo To push the output to GitHub, you need to provide:
echo   1. GitHub Repository URL
echo   2. GitHub Personal Access Token (PAT)
echo.

set /p GITHUB_REPO="Enter GitHub Repository URL (e.g., https://github.com/username/repo): "

if "%GITHUB_REPO%"=="" (
    echo.
    echo GitHub push skipped. Output files are available at:
    echo %OUTPUT_DIR%
    echo.
    echo To push manually:
    echo   1. Navigate to: %OUTPUT_DIR%
    echo   2. Copy the .py files
    echo   3. Commit to GitHub: git add . ^&^& git commit -m "Add IDMC to PySpark conversion output"
    echo   4. Push: git push origin main
    echo.
    pause
    exit /b 0
)

REM Validate GitHub URL
echo.
echo Validating GitHub URL...
echo %GITHUB_REPO% | findstr /r "https://github.com/.*/.*" >nul
if errorlevel 1 (
    echo [ERROR] Invalid GitHub URL format
    echo Expected: https://github.com/username/repo
    echo.
    pause
    exit /b 1
)

echo GitHub URL validated successfully!
echo Repository: %GITHUB_REPO%
echo.

REM ==========================================
REM STEP 6: GITHUB AUTHENTICATION
REM ==========================================
echo.
echo ==========================================
echo   STEP 6: GITHUB AUTHENTICATION
echo ==========================================
echo.
echo You will be prompted for GitHub credentials.
echo Use your Personal Access Token (PAT) as password.
echo.
echo Create a PAT at: https://github.com/settings/tokens
echo Scopes needed: repo, workflow
echo.

set /p GITHUB_USER="Enter GitHub username: "

if "%GITHUB_USER%"=="" (
    echo GitHub authentication skipped.
    echo.
    pause
    exit /b 0
)

REM Note: Password input is not directly supported in batch, so we'll use git credential manager
echo.
echo Git will use your system credentials manager for authentication.
echo If you haven't configured credentials, you'll be prompted.
echo.

REM ==========================================
REM STEP 7: CLONE/INIT GIT REPOSITORY
REM ==========================================
echo.
echo ==========================================
echo   STEP 7: GIT CONFIGURATION
echo ==========================================
echo.

set "GIT_DIR=%SCRIPT_DIR%github_repo"

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed or not in PATH
    echo Please install Git from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

REM Create git directory if it doesn't exist
if not exist "%GIT_DIR%" (
    echo Cloning GitHub repository...
    git clone "%GITHUB_REPO%" "%GIT_DIR%" 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to clone repository
        echo Please check:
        echo   1. Repository URL is correct
        echo   2. Repository is accessible
        echo   3. Your credentials are valid
        echo.
        pause
        exit /b 1
    )
) else (
    echo Updating existing repository...
    cd /d "%GIT_DIR%"
    git pull origin main 2>&1
    cd /d "%SCRIPT_DIR%"
)

echo Repository ready at: %GIT_DIR%
echo.

REM ==========================================
REM STEP 8: COPY OUTPUT FILES TO GIT DIR
REM ==========================================
echo.
echo ==========================================
echo   STEP 8: COPYING OUTPUT FILES
echo ==========================================
echo.

echo Copying PySpark files to repository...
copy "%OUTPUT_DIR%\*.py" "%GIT_DIR%\" /Y >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy files
    pause
    exit /b 1
)

echo Files copied successfully!
dir /b "%GIT_DIR%\*.py"
echo.

REM ==========================================
REM STEP 9: GIT COMMIT AND PUSH
REM ==========================================
echo.
echo ==========================================
echo   STEP 9: COMMITTING AND PUSHING
echo ==========================================
echo.

cd /d "%GIT_DIR%"

echo Setting git user configuration...
git config user.name "%GITHUB_USER%" 2>nul
git config user.email "%GITHUB_USER%@users.noreply.github.com" 2>nul

echo Adding files to staging...
git add *.py 2>nul

echo Creating commit...
set "COMMIT_MSG=Add IDMC to PySpark conversion output - %date% %time%"
git commit -m "%COMMIT_MSG%" 2>&1

if errorlevel 1 (
    echo.
    echo Note: Commit may have failed if there are no changes.
    echo This is normal if files already exist in the repository.
    echo.
)

echo Pushing to GitHub...
git push origin main 2>&1
if errorlevel 1 (
    echo.
    echo [WARNING] Push may have failed due to authentication
    echo Files have been staged locally. You can push manually with:
    echo   cd "%GIT_DIR%"
    echo   git push origin main
    echo.
) else (
    echo Push successful!
)

cd /d "%SCRIPT_DIR%"
echo.

REM ==========================================
REM COMPLETION
REM ==========================================
echo.
echo ==========================================
echo   PROCESS COMPLETED
echo ==========================================
echo.
echo Summary:
echo   Input File: %INPUT_FILE%
echo   Output Directory: %OUTPUT_DIR%
echo   GitHub Repository: %GITHUB_REPO%
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
