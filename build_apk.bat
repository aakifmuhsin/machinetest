@echo off
echo Building Flutter APK...
echo.

echo Step 1: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Step 2: Building APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo Error: Failed to build APK
    pause
    exit /b 1
)

echo.
echo APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo.
pause



