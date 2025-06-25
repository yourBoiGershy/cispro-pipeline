@echo off
echo === GitLab Deployment Script (Windows) ===
echo Starting deployment process...
echo.

echo Step 1: Navigating to project directory...
cd %~dp0
echo Current directory: %CD%
echo.

echo Step 2: Pulling latest code from git...
git pull origin main
if %ERRORLEVEL% NEQ 0 (
  echo × Git pull failed
  exit /b 1
) else (
  echo √ Code pulled successfully
)
echo.

echo Step 3: Building backend...
cd backend
if %ERRORLEVEL% NEQ 0 (
  echo × Failed to navigate to backend directory
  exit /b 1
) else (
  echo √ Navigated to backend directory
)

echo Installing backend dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
  echo × Backend npm install failed
  exit /b 1
) else (
  echo √ Backend dependencies installed
)

echo Building backend...
call npm run build
if %ERRORLEVEL% NEQ 0 (
  echo × Backend build failed
  exit /b 1
) else (
  echo √ Backend built successfully
)
echo.

echo Step 4: Building frontend...
cd ..\frontend
if %ERRORLEVEL% NEQ 0 (
  echo × Failed to navigate to frontend directory
  exit /b 1
) else (
  echo √ Navigated to frontend directory
)

echo Installing frontend dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
  echo × Frontend npm install failed
  exit /b 1
) else (
  echo √ Frontend dependencies installed
)

echo Building frontend...
call npm run build
if %ERRORLEVEL% NEQ 0 (
  echo × Frontend build failed
  exit /b 1
) else (
  echo √ Frontend built successfully
)

echo Copying build contents to parent directory...
if exist build (
  mkdir ..\build 2>nul
  del /Q ..\build\*
  xcopy /E /Y build\* ..\build\
  if %ERRORLEVEL% NEQ 0 (
    echo × Failed to copy build contents
    exit /b 1
  ) else (
    echo √ Build contents copied to build directory
  )
) else (
  echo × Build folder not found
  exit /b 1
)
echo.

echo Step 5: Starting backend server...
cd ..\backend
if %ERRORLEVEL% NEQ 0 (
  echo × Failed to navigate back to backend directory
  exit /b 1
) else (
  echo √ Navigated back to backend directory
)

echo Stopping any existing processes on port 4000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :4000') do (
  echo Found process: %%a
  taskkill /F /PID %%a 2>nul
  if %ERRORLEVEL% EQU 0 (
    echo √ Successfully stopped process on port 4000
  )
)
timeout /t 1 /nobreak >nul

echo Starting backend with npm start...
start /B npm start
if %ERRORLEVEL% NEQ 0 (
  echo × Backend server failed to start
  exit /b 1
) else (
  echo √ Backend server started successfully
)
echo.

echo === Deployment Summary ===
echo Status: SUCCESS
echo Time: %DATE% %TIME%
echo Frontend build: %CD%\..\build
echo Backend server: Running
echo.
echo 🎉 Deployment completed successfully!
echo Backend server is now running in the background.