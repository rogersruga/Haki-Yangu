@echo off
echo Generating SHA-1 fingerprint for debug keystore...
echo.

REM Try to find keytool in common Java installation paths
set KEYTOOL_PATH=""

REM Check if keytool is in PATH
where keytool >nul 2>&1
if %errorlevel% == 0 (
    set KEYTOOL_PATH=keytool
    goto :run_keytool
)

REM Check common Java paths
if exist "C:\Program Files\Java\jdk*\bin\keytool.exe" (
    for /d %%i in ("C:\Program Files\Java\jdk*") do (
        if exist "%%i\bin\keytool.exe" (
            set KEYTOOL_PATH="%%i\bin\keytool.exe"
            goto :run_keytool
        )
    )
)

if exist "C:\Program Files\Java\jre*\bin\keytool.exe" (
    for /d %%i in ("C:\Program Files\Java\jre*") do (
        if exist "%%i\bin\keytool.exe" (
            set KEYTOOL_PATH="%%i\bin\keytool.exe"
            goto :run_keytool
        )
    )
)

REM Check Android Studio embedded JDK
if exist "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" (
    set KEYTOOL_PATH="C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    goto :run_keytool
)

echo ERROR: keytool not found!
echo Please ensure Java JDK is installed and keytool is in your PATH.
echo.
echo Alternative: You can manually run this command:
echo keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
echo.
pause
exit /b 1

:run_keytool
echo Using keytool at: %KEYTOOL_PATH%
echo.
echo Debug keystore SHA-1 fingerprint:
echo ================================
%KEYTOOL_PATH% -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android | findstr "SHA1:"
echo.
echo Copy the SHA1 fingerprint above and add it to your Firebase project settings.
echo.
pause
