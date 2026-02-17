# Ingestion Service - Docker Setup

This repository contains Docker configurations for running the ingestion service infrastructure components.

## Services Overview

The ingestion service consists of four main components:

1. **Redis** - In-memory data structure store
2. **PostgreSQL** - Relational database
3. **MinIO** - Object storage service (S3-compatible)
4. **RabbitMQ** - Message broker

## Prerequisites

- Docker installed (version 20.10 or higher)
- Docker Compose installed (version 1.29 or higher)

To check your installation:
```bash
docker --version
docker compose --version
```

## Quick Start

### Running All Services Together

To start all services at once:
```bash
docker compose up -d
```

To view logs:
```bash
docker compose logs -f
```

To stop all services:
```bash
docker compose down
```

To stop all services and remove volumes (⚠️ THIS WILL DELETE ALL DATA):
```bash
docker compose down -v
```

### Running Individual Services

You can start specific services by name:

#### Redis Only
```bash
docker compose up -d redis
```

#### PostgreSQL Only
```bash
docker compose up -d postgres
```

#### MinIO Only
```bash
docker compose up -d minio
```

#### RabbitMQ Only
```bash
docker compose up -d rabbitmq
```

## Accessing Services

### Redis
- **Port:** 6379
- **Connection:** `redis://localhost:6379`
- **Testing Connection:**
  ```bash
  docker exec -it ingestion-redis redis-cli ping
  # Should return: PONG
  ```

### PostgreSQL
- **Port:** 5432
- **Database:** mydatabase
- **Username:** user
- **Password:** password
- **Connection String:** `postgresql://user:password@localhost:5432/mydatabase`
- **Testing Connection:**
  ```bash
  docker exec -it ingestion-postgres psql -U user -d mydatabase -c "SELECT version();"
  ```

### MinIO (S3-Compatible Storage)
- **API Port:** 9000
- **Console Port:** 9001
- **Console URL:** http://localhost:9001
- **Access Key:** minio_access_key
- **Secret Key:** minio_secret_key
- **Testing Connection:**
  ```bash
  curl http://localhost:9000/minio/health/live
  ```

### RabbitMQ
- **AMQP Port:** 5672
- **Management UI Port:** 15672
- **Management UI URL:** http://localhost:15672
- **Username:** user
- **Password:** password
- **Testing Connection:**
  ```bash
  docker exec -it ingestion-rabbitmq rabbitmq-diagnostics ping
  ```

## Service Health Checks

Check the status of all running services:
```bash
docker compose ps
```

View health status:
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

## Viewing Logs

View logs for all services:
```bash
docker compose logs
```

View logs for a specific service:
```bash
docker compose logs redis
docker compose logs postgres
docker compose logs minio
docker compose logs rabbitmq
```

Follow logs in real-time:
```bash
docker compose logs -f [service-name]
```

## Data Persistence

All services use Docker volumes for data persistence:
- `redis_data` - Redis data
- `postgres_data` - PostgreSQL data
- `minio_data` - MinIO object storage
- `rabbitmq_data` - RabbitMQ data

To list volumes:
```bash
docker volume ls
```

## Stopping Services

Stop all services (keeps data):
```bash
docker compose stop
```

Stop a specific service:
```bash
docker compose stop [service-name]
```

Remove stopped containers:
```bash
docker compose rm -f
```

## Restarting Services

Restart all services:
```bash
docker compose restart
```

Restart a specific service:
```bash
docker compose restart [service-name]
```

## Troubleshooting

### Port Already in Use
If you get a port conflict error, another service might be using the same port. You can either:
1. Stop the conflicting service
2. Modify the port mapping in `docker compose.yml`

### Service Won't Start
1. Check the logs: `docker compose logs [service-name]`
2. Ensure Docker is running: `docker ps`
3. Check available disk space: `df -h`

### Reset Everything
To completely reset all services and data:
```bash
docker compose down -v
docker compose up -d
```

## Alternative: Using Individual docker compose Files

Each service also has its own `docker compose.yml` file in its subdirectory:
- `redis/docker compose.yml`
- `postgres/docker compose.yml`
- `minio/docker compose.yml`
- `rabbit/docker compose.yml`

To use them:
```bash
cd redis && docker compose up -d
cd postgres && docker compose up -d
cd minio && docker compose up -d
cd rabbit && docker compose up -d
```

## Network Configuration

All services are connected to a shared bridge network called `ingestion-network`, allowing them to communicate with each other using service names as hostnames.

## Security Notes

⚠️ **WARNING:** The default credentials in this setup are for development purposes only. **DO NOT use these in production!**

For production deployments:
1. Change all default passwords
2. Use environment variables or secrets management
3. Implement proper network security
4. Enable SSL/TLS where applicable
5. Regularly update Docker images

## Web Interfaces

The following services provide web-based management interfaces:

1. **MinIO Console**: http://localhost:9001
   - Username: `minio_access_key`
   - Password: `minio_secret_key`

2. **RabbitMQ Management**: http://localhost:15672
   - Username: `user`
   - Password: `password`

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Redis Documentation](https://redis.io/documentation)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MinIO Documentation](https://min.io/docs/minio/linux/index.html)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)
