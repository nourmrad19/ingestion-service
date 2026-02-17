@echo off
REM Open Service Web Interfaces for Windows

echo ╔════════════════════════════════════════════╗
echo ║    Opening Service Web Interfaces...      ║
echo ╚════════════════════════════════════════════╝
echo.

echo Opening RabbitMQ Management UI...
echo   URL: http://localhost:15672
echo   Username: user
echo   Password: password
start http://localhost:15672

timeout /t 1 /nobreak >nul

echo.
echo Opening MinIO Console...
echo   URL: http://localhost:9001
echo   Username: minio_access_key
echo   Password: minio_secret_key
start http://localhost:9001

echo.
echo ╔════════════════════════════════════════════╗
echo ║         Services Info                      ║
echo ╠════════════════════════════════════════════╣
echo ║ Services with Web Interfaces:              ║
echo ║                                            ║
echo ║ √ RabbitMQ: http://localhost:15672        ║
echo ║ √ MinIO:    http://localhost:9001         ║
echo ║                                            ║
echo ║ Services without Web Interfaces:           ║
echo ║                                            ║
echo ║ • PostgreSQL: localhost:5432               ║
echo ║ • Redis:      localhost:6379               ║
echo ╚════════════════════════════════════════════╝
echo.

pause
