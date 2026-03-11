#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Opening Service Web Interfaces...      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Detect the OS and use appropriate open command
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    OPEN_CMD="open"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open &> /dev/null; then
        OPEN_CMD="xdg-open"
    elif command -v gnome-open &> /dev/null; then
        OPEN_CMD="gnome-open"
    else
        echo "No suitable open command found. Please open URLs manually."
        OPEN_CMD="echo"
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows
    OPEN_CMD="start"
else
    echo "Unsupported OS. Please open URLs manually."
    OPEN_CMD="echo"
fi

echo -e "${GREEN}Opening RabbitMQ Management UI...${NC}"
echo "  URL: http://localhost:15672"
echo "  Username: user"
echo "  Password: password"
$OPEN_CMD http://localhost:15672 2>/dev/null &

sleep 1

echo ""
echo -e "${GREEN}Opening MinIO Console...${NC}"
echo "  URL: http://localhost:9001"
echo "  Username: minio_access_key"
echo "  Password: minio_secret_key"
$OPEN_CMD http://localhost:9001 2>/dev/null &

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Services Info                      ║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║ Services with Web Interfaces:              ║${NC}"
echo -e "${BLUE}║                                            ║${NC}"
echo -e "${BLUE}║ ✓ RabbitMQ: http://localhost:15672        ║${NC}"
echo -e "${BLUE}║ ✓ MinIO:    http://localhost:9001         ║${NC}"
echo -e "${BLUE}║                                            ║${NC}"
echo -e "${BLUE}║ Services without Web Interfaces:           ║${NC}"
echo -e "${BLUE}║                                            ║${NC}"
echo -e "${BLUE}║ • PostgreSQL: localhost:5432               ║${NC}"
echo -e "${BLUE}║ • Redis:      localhost:6379               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
