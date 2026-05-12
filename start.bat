@echo off
echo Starting ShopFlow SMS SaaS...

:: Check for backend folder
if not exist "backend" (
    echo [ERROR] Backend folder not found! Make sure you are running this from the root directory.
    pause
    exit /b
)

:: Start Backend
echo Launching Backend...
start cmd /k "cd backend && npm.cmd run dev"

:: Start Frontend
echo Launching Frontend...
start cmd /k "cd frontend && npm.cmd run dev"

echo.
echo ==========================================
echo  ShopFlow is starting up!
echo  Frontend: http://localhost:5173
echo  Backend: http://localhost:3001
echo ==========================================
echo.
pause
