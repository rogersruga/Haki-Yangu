@echo off
echo ========================================
echo Haki Yangu - Gradle Build Recovery Script
echo ========================================
echo.

echo [1/8] Stopping any running Flutter processes...
taskkill /f /im dart.exe 2>nul
taskkill /f /im flutter.exe 2>nul
taskkill /f /im java.exe 2>nul
echo Done.
echo.

echo [2/8] Cleaning Flutter build cache...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)
echo Done.
echo.

echo [3/8] Removing build directories manually...
if exist "build" (
    echo Removing build directory...
    rmdir /s /q "build"
)
if exist "android\build" (
    echo Removing android\build directory...
    rmdir /s /q "android\build"
)
if exist "android\app\build" (
    echo Removing android\app\build directory...
    rmdir /s /q "android\app\build"
)
echo Done.
echo.

echo [4/8] Cleaning Gradle cache...
cd android
call gradlew.bat clean --no-daemon
if %errorlevel% neq 0 (
    echo WARNING: Gradle clean had issues, continuing...
)
cd ..
echo Done.
echo.

echo [5/8] Clearing Gradle user cache...
if exist "%USERPROFILE%\.gradle\caches" (
    echo Removing Gradle user cache...
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
)
if exist "%USERPROFILE%\.android\build-cache" (
    echo Removing Android build cache...
    rmdir /s /q "%USERPROFILE%\.android\build-cache"
)
echo Done.
echo.

echo [6/8] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)
echo Done.
echo.

echo [7/8] Attempting to build the app...
echo Trying debug build first...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo Debug build failed, trying release build...
    flutter build apk --release
    if %errorlevel% neq 0 (
        echo ERROR: Both debug and release builds failed!
        echo Please check the error messages above.
        pause
        exit /b 1
    )
)
echo Build successful!
echo.

echo [8/8] Running the app...
echo Starting app in debug mode...
flutter run
if %errorlevel% neq 0 (
    echo ERROR: Failed to run the app!
    echo Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build recovery completed successfully!
echo Your text changes should now be visible:
echo - "Modules Done" instead of "Modules"
echo - "Test Your Knowledge" instead of "Know Your Rights"
echo - "Learn rights in a simplified way"
echo - "Take a Civic quiz"
echo ========================================
pause
