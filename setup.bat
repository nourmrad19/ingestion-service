@echo off
REM Quick setup script for Alembic migrations

echo.
echo ========================================
echo Alembic Database Migration Setup
echo ========================================
echo.

echo [1/3] Starting PostgreSQL and pgAdmin...
cd postgres
docker-compose up -d
cd ..

echo [2/3] Installing Python dependencies...
pip install -r requirements.txt

echo.
echo [3/3] Running initial migration...
alembic upgrade head

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo PostgreSQL:   localhost:5432
echo pgAdmin:      http://localhost:5050
echo Admin Email:  admin@example.com
echo Admin Pass:   admin
echo.
echo Database Credentials:
echo   User: user
echo   Pass: password
echo   DB:   mydatabase
echo.
echo To manual run migrations:
echo   alembic upgrade head           (apply all)
echo   alembic downgrade -1           (rollback)
echo   alembic revision --autogenerate -m "description"  (create new)
echo.
pause
