@echo off
SETLOCAL EnableDelayedExpansion

echo Select the installation folder:
set "folder="
for /f "delims=" %%a in ('powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms; $folder = ''; $dialog = New-Object System.Windows.Forms.FolderBrowserDialog; $dialog.Description = 'Select the installation folder'; $dialog.RootFolder = 'MyComputer'; $dialog.ShowNewFolderButton = $true; if($dialog.ShowDialog() -eq 'OK'){ $folder = $dialog.SelectedPath }; $folder"') do set "folder=%%a"

if "%folder%"=="" (
    echo No folder selected. Exiting.
    exit /b 1
)

echo Installation folder selected: %folder%
echo.

set "valid_versions=1.8.8 1.12.2 1.16.5 1.19.4 1.20.2 1.20.4"

echo Available versions:
echo 1.8.8
echo 1.12.2
echo 1.16.5
echo 1.19.4
echo 1.20.2
echo 1.20.4
echo.

:version_input
set /p version="Enter your Version (e.g. 1.20.4): "

set "valid=0"
for %%v in (%valid_versions%) do (
    if "%version%" equ "%%v" (
        set "valid=1"
        goto version_valid
    )
)

if %valid% equ 0 (
    echo Invalid version. Please enter a valid version from the list.
    goto version_input
)

:version_valid
echo Selected version: %version%

if "%version%" equ "1.8.8" (
    set "download_url=https://api.papermc.io/v2/projects/paper/versions/1.8.8/builds/445/downloads/paper-1.8.8-445.jar"
) else if "%version%" equ "1.12.2" (
    set "download_url=https://api.papermc.io/v2/projects/paper/versions/1.12.2/builds/1620/downloads/paper-1.12.2-1620.jar"
) else if "%version%" equ "1.16.5" (
    set "download_url=https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar"
) else if "%version%" equ "1.19.4" (
    set "download_url=https://api.papermc.io/v2/projects/paper/versions/1.19.4/builds/550/downloads/paper-1.19.4-550.jar"
) else if "%version%" equ "1.20.2" (
    set "download_url=https://api.papermc.io/v2/projects/paper/versions/1.20.2/builds/318/downloads/paper-1.20.2-318.jar"
) else if "%version%" equ "1.20.4" (
    echo Getting Dynamic Link...
    timeout /t 1 >nul
    set "download_url=https://paper.gabr3al.dev"
)



echo Downloading %version% from %download_url%...
timeout /t 1 >nul
echo This may take a while. Please wait...
echo Dont close this window!

curl -L -o "%folder%\paper-%version%.jar" "%download_url%"
if %errorlevel% neq 0 (
    echo Download failed. Exiting.
    exit /b 1
)
echo Download complete.
timeout /t 1 >nul

echo.
echo How many GB of RAM should the server use?
set /p ram="Enter the amount of RAM in GB (e.g. 1): "

echo Creating start script...

(
    echo @echo off
    echo java -Xms%ram%G -Xmx%ram%G -jar paper-%version%.jar nogui
    echo pause
) > "%folder%\start.bat"

timeout /t 1 >nul

echo.
echo Accepting Minecraft EULA...
echo Starting the server once to properly accept eula.txt...


cd "%folder%"
java -Xms%ram%G -Xmx%ram%G -jar "%folder%\paper-%version%.jar" nogui
echo Stopping the server...


timeout /t 2 >nul

set "line_number=0"
set "new_line=eula=true"

(for /f "delims=" %%a in ('type "%folder%\eula.txt"') do (
    set /a "line_number+=1"
    if !line_number! equ 3 (
        echo !new_line!
    ) else (
        echo %%a
    )
)) > "%folder%\eula_temp.txt"

move /y "%folder%\eula_temp.txt" "%folder%\eula.txt" >nul

echo.
echo EULA ACCEPTED!
echo.

echo.
echo Installation complete. You can start the server by running start.bat in the installation folder.
echo Thanks for using this Installer!
echo Made by _0x1337_ - gabr3al.dev
echo.

pause