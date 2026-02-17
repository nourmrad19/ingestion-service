# Quick Start Guide

## Get Started in 3 Easy Steps

### 1. Start All Services
```bash
./start-all.sh
```

### 2. Access the Web Interfaces

#### MinIO Console
Open your browser and go to: **http://localhost:9001**
- Username: `minio_access_key`
- Password: `minio_secret_key`

#### RabbitMQ Management
Open your browser and go to: **http://localhost:15672**
- Username: `user`
- Password: `password`

### 3. Stop All Services When Done
```bash
./stop-all.sh
```

## Starting Individual Services

To start only one service:
```bash
./start-service.sh redis      # Start Redis only
./start-service.sh postgres   # Start PostgreSQL only
./start-service.sh minio      # Start MinIO only
./start-service.sh rabbitmq   # Start RabbitMQ only
```

## Manual Docker Commands

If you prefer to use Docker commands directly:

### Start all services:
```bash
docker compose up -d
```

### Stop all services:
```bash
docker compose down
```

### View service status:
```bash
docker compose ps
```

### View logs:
```bash
docker compose logs -f
```

### Start individual service:
```bash
docker compose up -d redis
```

### Stop individual service:
```bash
docker compose stop redis
```

## Connecting to Services

### Redis
```bash
# Using redis-cli inside container
docker exec -it ingestion-redis redis-cli

# From your application
redis://localhost:6379
```

### PostgreSQL
```bash
# Using psql inside container
docker exec -it ingestion-postgres psql -U user -d mydatabase

# Connection string for your application
postgresql://user:password@localhost:5432/mydatabase
```

### MinIO
- Console: http://localhost:9001
- API Endpoint: http://localhost:9000
- Access Key: `minio_access_key`
- Secret Key: `minio_secret_key`

### RabbitMQ
- Management UI: http://localhost:15672
- AMQP Connection: `amqp://user:password@localhost:5672`

## Troubleshooting

### Services won't start?
1. Check if Docker is running: `docker ps`
2. Check if ports are already in use: `lsof -i :6379` (for Redis)
3. View logs: `docker compose logs [service-name]`

### Reset everything?
```bash
docker compose down -v
docker compose up -d
```

## Need More Help?
See the full [README.md](README.md) for detailed documentation.
