#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Ingestion Service - Stop All        ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Stopping all services...${NC}"
docker compose down

echo ""
echo -e "${GREEN}✓ All services stopped!${NC}"
echo ""
echo -e "${YELLOW}Note: Data volumes are preserved.${NC}"
echo -e "${YELLOW}To remove volumes (delete all data), run:${NC}"
echo -e "${YELLOW}  docker compose down -v${NC}"
echo ""
