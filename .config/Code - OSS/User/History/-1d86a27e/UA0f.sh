#!/bin/bash

# Docker Services Startup Script
# Starts all services in the correct order

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "=================================================="
echo "  Starting Docker Services Stack"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if networks exist, create if needed
echo -e "${YELLOW}Checking networks...${NC}"
if ! docker network ls | grep -q "services-internal"; then
    echo "Creating services-internal network..."
    docker network create services-internal
fi

if ! docker network ls | grep -q "monitoring"; then
    echo "Creating monitoring network..."
    docker network create monitoring
fi
echo ""

# Start services in order
echo -e "${BLUE}Starting infrastructure services...${NC}"

# 1. Build NVIDIA exporter if needed
if [ -d "nvidia-exporter" ]; then
    echo "  → Building NVIDIA GPU exporter..."
    docker-compose -f docker-compose.monitoring.yml build nvidia-smi-exporter
fi

# 2. Monitoring stack (base infrastructure)
echo "  → Starting Prometheus & monitoring stack..."
docker-compose -f docker-compose.monitoring.yml up -d

# 3. SearXNG (search engine)
echo "  → Starting SearXNG..."
docker-compose -f docker-compose.searxng.yml up -d

# 4. Ollama (LLM backend)
echo "  → Starting Ollama..."
docker-compose -f docker-compose.ollama.yml up -d

# Wait a bit for Ollama to initialize
sleep 3

# 5. OpenWebUI (depends on Ollama)
echo "  → Starting OpenWebUI..."
docker-compose -f docker-compose.openwebui.yml up -d

# 6. Homarr (dashboard)
echo "  → Starting Homarr dashboard..."
docker-compose -f docker-compose.homarr.yml up -d

echo ""
echo -e "${GREEN}All services started!${NC}"
echo ""

# Wait for services to be healthy
echo "Waiting for services to become healthy..."
sleep 5

echo ""
echo "=================================================="
echo "  Service URLs"
echo "=================================================="
echo ""
echo -e "${GREEN}AI & Chat:${NC}"
echo "  • OpenWebUI:        http://localhost:10001"
echo "  • Ollama API:       http://localhost:11434"
echo ""
echo -e "${GREEN}Search:${NC}"
echo "  • SearXNG:          http://localhost:10000"
echo ""
echo -e "${GREEN}Dashboards:${NC}"
echo "  • Homarr:           http://localhost:10002"
echo "  • Uptime Kuma:      http://localhost:10003"
echo "  • Portainer:        http://localhost:10004"
echo "  • Grafana:          http://localhost:10009"
echo ""
echo -e "${GREEN}Monitoring:${NC}"
echo "  • Prometheus:       http://localhost:10005"
echo "  • NVIDIA Exporter:  http://localhost:10006"
echo "  • Node Exporter:    http://localhost:10007"
echo "  • cAdvisor:         http://localhost:10008"
echo ""
echo "=================================================="
echo ""

# Show running containers
echo "Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|ollama|openwebui|searxng|homarr|grafana|prometheus|portainer|uptime-kuma|cadvisor|node_exporter|nvidia"

echo ""
echo -e "${YELLOW}Tip: Use 'docker logs <container-name>' to view logs${NC}"
echo -e "${YELLOW}Tip: Use './scripts/stop.sh' to stop all services${NC}"
echo ""