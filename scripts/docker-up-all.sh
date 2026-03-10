#!/bin/bash
# Run docker compose up -d in all docker project folders automatically
# For pp2-Mimir

set -e  # Exit immediately on any error

DOCKER_BASE="$HOME/pp2-mimir/docker"

echo "=== 🚀 Preparing required directories ==="

# Internet monitoring stack paths
MONITORING_DIR="$DOCKER_BASE/internet-monitoring"
PROM_DATA="$MONITORING_DIR/data/prometheus"
GRAF_DATA="$MONITORING_DIR/data/grafana"

# Create directories if missing
mkdir -p "$PROM_DATA"
mkdir -p "$GRAF_DATA"

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

echo "✅ Directory preparation complete"

echo "=== 🚀 Auto-starting all Docker Compose stacks under: $DOCKER_BASE ==="

# Find directories containing docker-compose.yml or compose.yml
mapfile -t dirs < <(find "$DOCKER_BASE" -type f \( -name "docker-compose.yml" -o -name "compose.yml" \) -exec dirname {} \; | sort)

if [ ${#dirs[@]} -eq 0 ]; then
  echo "⚠️  No docker-compose.yml files found under $DOCKER_BASE"
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