#!/bin/bash 
# Run docker compose up -d in all docker project folders automatically 
# For potentpi2 
set -e # Exit immediately on any error 

DOCKER_BASE="$HOME/potentpi2"

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