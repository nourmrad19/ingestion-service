#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo -e "${YELLOW}Usage: $0 <service-name>${NC}"
    echo ""
    echo "Available services:"
    echo "  - redis"
    echo "  - postgres"
    echo "  - minio"
    echo "  - rabbitmq"
    echo ""
    echo "Example: $0 redis"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Starting Service: $SERVICE"
echo -e "${BLUE}╔════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Starting $SERVICE...${NC}"
docker compose up -d $SERVICE

echo ""
echo -e "${GREEN}✓ Service started!${NC}"
echo ""

# Show service-specific information
case $SERVICE in
    redis)
        echo -e "${GREEN}Redis is running on port 6379${NC}"
        echo -e "${YELLOW}Test connection: ${NC}docker exec -it ingestion-redis redis-cli ping"
        ;;
    postgres)
        echo -e "${GREEN}PostgreSQL is running on port 5432${NC}"
        echo -e "${YELLOW}Database: ${NC}mydatabase"
        echo -e "${YELLOW}User: ${NC}user"
        echo -e "${YELLOW}Password: ${NC}password"
        echo -e "${YELLOW}Test connection: ${NC}docker exec -it ingestion-postgres psql -U user -d mydatabase"
        ;;
    minio)
        echo -e "${GREEN}MinIO is running!${NC}"
        echo -e "${YELLOW}Console: ${NC}http://localhost:9001"
        echo -e "${YELLOW}API: ${NC}http://localhost:9000"
        echo -e "${YELLOW}Access Key: ${NC}minio_access_key"
        echo -e "${YELLOW}Secret Key: ${NC}minio_secret_key"
        ;;
    rabbitmq)
        echo -e "${GREEN}RabbitMQ is running!${NC}"
        echo -e "${YELLOW}Management UI: ${NC}http://localhost:15672"
        echo -e "${YELLOW}AMQP Port: ${NC}5672"
        echo -e "${YELLOW}User: ${NC}user"
        echo -e "${YELLOW}Password: ${NC}password"
        ;;
esac

echo ""
echo -e "${YELLOW}To view logs: ${NC}docker compose logs -f $SERVICE"
echo -e "${YELLOW}To stop:      ${NC}docker compose stop $SERVICE"
echo ""
