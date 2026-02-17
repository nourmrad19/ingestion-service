# How to Access Servers from Docker Interface

This guide shows you how to view and access your running servers using Docker Desktop and other Docker interfaces.

## Using Docker Desktop (Recommended for Beginners)

### 1. View Running Containers

1. **Open Docker Desktop** application on your computer
2. Click on the **Containers** tab in the left sidebar
3. You'll see all your running containers:
   - `ingestion-redis`
   - `ingestion-postgres`
   - `ingestion-minio`
   - `ingestion-rabbitmq`

### 2. Access Web Interfaces

From Docker Desktop, you can directly open web interfaces:

1. Find the container (e.g., `ingestion-rabbitmq`)
2. Look at the **PORT(S)** column
3. Click on the port number link (e.g., `15672:15672`)
4. Your browser will open to the service's web interface!

#### Quick Links from Docker Desktop:

**RabbitMQ Management UI:**
- Container: `ingestion-rabbitmq`
- Click on port: `15672:15672`
- Or manually go to: http://localhost:15672
- Login: username=`user`, password=`password`

**MinIO Console:**
- Container: `ingestion-minio`
- Click on port: `9001:9001`
- Or manually go to: http://localhost:9001
- Login: username=`minio_access_key`, password=`minio_secret_key`

### 3. View Container Logs

1. In Docker Desktop, click on a container name (e.g., `ingestion-redis`)
2. The **Logs** tab opens automatically
3. You can see real-time logs from the service
4. Use the search box to find specific messages

### 4. Inspect Container Details

1. Click on a container name
2. Click the **Inspect** tab to see:
   - Environment variables
   - Network settings
   - Volume mounts
   - Port mappings

### 5. Start/Stop Individual Containers

1. Find the container in the list
2. Click the **⏸️ Pause**, **▶️ Start**, or **⏹️ Stop** button
3. The container will change state immediately

## Using Portainer (Advanced Docker UI)

If you want a more powerful web-based Docker interface:

### Install Portainer:
```bash
docker volume create portainer_data

docker run -d -p 9000:9000 -p 8000:8000 \
  --name portainer --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce
```

### Access Portainer:
1. Open http://localhost:9000 in your browser
2. Create an admin account
3. Select "Docker" environment
4. View all containers, images, volumes, and networks
5. Click on containers to manage them

## Using Command Line with Docker Desktop

Even with Docker Desktop, you can use terminal commands:

### See All Running Containers:
```bash
docker ps
```

### Open Service Web Interfaces:

**Open RabbitMQ Management:**
```bash
# On macOS/Linux:
open http://localhost:15672

# On Windows:
start http://localhost:15672
```

**Open MinIO Console:**
```bash
# On macOS/Linux:
open http://localhost:9001

# On Windows:
start http://localhost:9001
```

### View Logs:
```bash
docker logs ingestion-rabbitmq    # RabbitMQ logs
docker logs ingestion-minio       # MinIO logs
docker logs ingestion-postgres    # PostgreSQL logs
docker logs ingestion-redis       # Redis logs

# Follow logs in real-time:
docker logs -f ingestion-rabbitmq
```

### Execute Commands Inside Containers:
```bash
# Connect to Redis:
docker exec -it ingestion-redis redis-cli

# Connect to PostgreSQL:
docker exec -it ingestion-postgres psql -U user -d mydatabase

# Open a bash shell in any container:
docker exec -it ingestion-redis bash
```

## Service Access Summary

| Service | Web Interface | Direct Access | Docker Desktop Port |
|---------|---------------|---------------|---------------------|
| **RabbitMQ** | ✅ http://localhost:15672<br>User: `user`<br>Pass: `password` | AMQP: localhost:5672 | Click `15672:15672` |
| **MinIO** | ✅ http://localhost:9001<br>User: `minio_access_key`<br>Pass: `minio_secret_key` | API: http://localhost:9000 | Click `9001:9001` |
| **PostgreSQL** | ❌ No web interface | psql: localhost:5432<br>User: `user`<br>Pass: `password`<br>DB: `mydatabase` | Use terminal |
| **Redis** | ❌ No web interface | redis-cli: localhost:6379 | Use terminal |

## Troubleshooting Docker Desktop

### Can't see containers?
1. Make sure Docker Desktop is running
2. Check if services are started:
   ```bash
   docker compose ps
   ```
3. Start services if needed:
   ```bash
   ./start-all.sh
   ```

### Port link doesn't work in Docker Desktop?
1. Manually type the URL in your browser:
   - RabbitMQ: http://localhost:15672
   - MinIO: http://localhost:9001

### Container shows as "unhealthy"?
1. Click on the container
2. View the **Logs** tab
3. Look for error messages
4. Restart the container using the restart button

## Video Walkthrough (Steps)

### For RabbitMQ:
1. ✅ Open Docker Desktop
2. ✅ Click "Containers" in sidebar
3. ✅ Find `ingestion-rabbitmq` container
4. ✅ Click on `15672:15672` port link
5. ✅ Browser opens to http://localhost:15672
6. ✅ Login with user=`user`, password=`password`
7. ✅ See RabbitMQ Management Dashboard!

### For MinIO:
1. ✅ Open Docker Desktop
2. ✅ Click "Containers" in sidebar
3. ✅ Find `ingestion-minio` container
4. ✅ Click on `9001:9001` port link
5. ✅ Browser opens to http://localhost:9001
6. ✅ Login with user=`minio_access_key`, password=`minio_secret_key`
7. ✅ See MinIO Console!

## Quick Access Script

Create this script to open all web interfaces at once:

**For macOS/Linux** (`open-services.sh`):
```bash
#!/bin/bash
open http://localhost:15672  # RabbitMQ
open http://localhost:9001   # MinIO
```

**For Windows** (`open-services.bat`):
```batch
start http://localhost:15672
start http://localhost:9001
```

Make it executable and run:
```bash
chmod +x open-services.sh
./open-services.sh
```

## Need More Help?

- See [README.md](README.md) for full documentation
- See [QUICKSTART.md](QUICKSTART.md) for quick commands
- Check Docker Desktop documentation: https://docs.docker.com/desktop/
