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
GRAPH_DATA="$MONITORING_DIR/data/graphite"

# Nginx stack path
NGINX_DIR="$DOCKER_BASE/nginx"
NGINX_DATA="$NGINX_DIR/code"

# Function to create directory and report status
create_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo mkdir -p "$dir"
        else
            mkdir -p "$dir"
        fi
        echo "✅ Created: $dir"
    else
        echo "ℹ️ Already exists: $dir"
    fi
}

# Create directories
create_dir "$PROM_DATA"
create_dir "$GRAF_DATA"
create_dir "$GRAPH_DATA"
create_dir "$NGINX_DATA"

# Function to change ownership safely
set_owner() {
    local dir="$1"
    local uid="$2"
    local gid="$3"
    if command -v sudo >/dev/null 2>&1; then
        sudo chown -R "$uid:$gid" "$dir"
    else
        chown -R "$uid:$gid" "$dir"
    fi
    echo "🔧 Set ownership: $dir → $uid:$gid"
}

# Set container ownerships
set_owner "$GRAF_DATA" 472 472
set_owner "$PROM_DATA" 65534 65534
set_owner "$NGINX_DATA" 33 33

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