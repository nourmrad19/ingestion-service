# PowerShell setup script for Alembic migrations

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Alembic Database Migration Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Starting PostgreSQL and pgAdmin..." -ForegroundColor Yellow
Push-Location postgres
docker-compose up -d
Pop-Location

Write-Host ""
Write-Host "[2/3] Installing Python dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt

Write-Host ""
Write-Host "[3/3] Running initial migration..." -ForegroundColor Yellow
alembic upgrade head

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "PostgreSQL:   localhost:5432" -ForegroundColor Green
Write-Host "pgAdmin:      http://localhost:5050" -ForegroundColor Green
Write-Host "Admin Email:  admin@example.com" -ForegroundColor Green
Write-Host "Admin Pass:   admin" -ForegroundColor Green
Write-Host ""
Write-Host "Database Credentials:" -ForegroundColor Cyan
Write-Host "  User: user" -ForegroundColor Cyan
Write-Host "  Pass: password" -ForegroundColor Cyan
Write-Host "  DB:   mydatabase" -ForegroundColor Cyan
Write-Host ""
Write-Host "Common Commands:" -ForegroundColor Cyan
Write-Host "  alembic upgrade head                (apply all migrations)" -ForegroundColor Cyan
Write-Host "  alembic downgrade -1                (rollback last one)" -ForegroundColor Cyan
Write-Host "  alembic revision --autogenerate -m ""description""  (create new)" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"
