#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Ingestion Service - Start All Services  ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Starting all services...${NC}"
docker compose up -d

echo ""
echo -e "${GREEN}✓ Services starting up!${NC}"
echo ""
echo -e "${BLUE}Waiting for services to be healthy...${NC}"
sleep 5

echo ""
echo -e "${BLUE}Service Status:${NC}"
docker compose ps

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Services Access Information        ║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║ Redis:                                     ║${NC}"
echo -e "${GREEN}║   Port: 6379                               ║${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}║ PostgreSQL:                                ║${NC}"
echo -e "${GREEN}║   Port: 5432                               ║${NC}"
echo -e "${GREEN}║   User: user / Password: password          ║${NC}"
echo -e "${GREEN}║   Database: mydatabase                     ║${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}║ MinIO:                                     ║${NC}"
echo -e "${GREEN}║   Console: http://localhost:9001           ║${NC}"
echo -e "${GREEN}║   API: http://localhost:9000               ║${NC}"
echo -e "${GREEN}║   User: minio_access_key                   ║${NC}"
echo -e "${GREEN}║   Password: minio_secret_key               ║${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}║ RabbitMQ:                                  ║${NC}"
echo -e "${GREEN}║   Management: http://localhost:15672       ║${NC}"
echo -e "${GREEN}║   AMQP Port: 5672                          ║${NC}"
echo -e "${GREEN}║   User: user / Password: password          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}To view logs: ${NC}docker compose logs -f"
echo -e "${YELLOW}To stop all:  ${NC}docker compose down"
echo ""
