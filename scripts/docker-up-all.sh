#!/bin/bash
# Run docker compose up -d in multiple folders sequentially

# Exit immediately if a command fails
set -e

# Define your target directories
dirs=(
  "~/pp2-mimir/docker/internet-monitoring"
  "~/pp2-mimir/docker/nginx"
  "~/pp2-mimir/docker/unifi"
  "~/pp2-mimir/docker/uptime-kuma"
)

for dir in "${dirs[@]}"; do
  echo "--------------------------------------"
  echo "Bringing up containers in: $dir"
  echo "--------------------------------------"
  cd "$dir"
  docker compose up -d
  echo "✅ Finished: $dir"
  echo
done

echo "🚀 All Docker Compose stacks are up!"