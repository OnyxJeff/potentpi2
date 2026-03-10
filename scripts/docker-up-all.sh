#!/bin/bash 
# Run docker compose up -d in all docker project folders automatically 
# For pp2-Mimir 
set -e # Exit immediately on any error 

DOCKER_BASE="$HOME/pp2-mimir/docker"

echo "------------------------------------------" 
echo "=== 🚀 Preparing required directories ==="
echo "------------------------------------------" 

# Internet monitoring stack paths
MONITORING_DIR="$DOCKER_BASE/internet-monitoring"
PROM_DATA="$MONITORING_DIR/data/prometheus"
GRAF_DATA="$MONITORING_DIR/data/grafana"

# Create directories if missing
if command -v sudo >/dev/null 2>&1; then 
sudo mkdir -p "$PROM_DATA"
else 
mkdir -p "$PROM_DATA" 
fi

if command -v sudo >/dev/null 2>&1; then 
sudo mkdir -p "$GRAF_DATA" 
else 
mkdir -p "$GRAF_DATA" 
fi

# Grafana runs as UID 472 inside container 
if command -v sudo >/dev/null 2>&1; then 
sudo chown -R 472:472 "$GRAF_DATA" 
else 
chown -R 472:472 "$GRAF_DATA" 
fi 

# Prometheus runs as UID 65534 inside container 
if command -v sudo >/dev/null 2>&1; then 
sudo chown -R 65534:65534 "$PROM_DATA" 
else 
chown -R 65534:65534 "$PROM_DATA"
fi

# Nginx stack path
NGINX_DIR="$DOCKER_BASE/nginx"
NGINX_DATA="$NGINX_DIR/code"

# Nginx runs as UID 33 inside container
if command -v sudo >/dev/null 2>&1; then 
sudo chown -R 33:33 "$NGINX_DATA" 
else 
chown -R 33:33 "$NGINX_DATA"
fi

echo "--------------------------------------" 
echo "✅ Directory preparation complete" 
echo "--------------------------------------" 

echo "=== 🚀 Auto-starting all Docker Compose stacks under: $DOCKER_BASE ===" 

# Find directories containing docker-compose.yml or compose.yml 
mapfile -t dirs < <(find "$DOCKER_BASE" -type f \( -name "docker-compose.yml" -o -name "compose.yml" \) -exec dirname {} \; | sort) 
if [ ${#dirs[@]} -eq 0 ]; then 
echo "⚠️ No docker-compose.yml files found under $DOCKER_BASE" 
exit 0 
fi 

for dir in "${dirs[@]}"; do 
echo "--------------------------------------" 
echo "Bringing up containers in: $dir" 
echo "--------------------------------------" 
cd "$dir" 
docker compose up -d 
echo "✅ Finished: $dir" 
echo
done

echo "=== ✅ All Docker Compose stacks started successfully! ==="