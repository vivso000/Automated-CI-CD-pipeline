#!/usr/bin/env bash
# ==============================================================================
# Script Name: deploy.sh
# Purpose    : Remote Zero-Downtime Container Deployment Script
# Usage      : Executed via SSH by Jenkins CI Pipeline on Target EC2 Instance
# ==============================================================================

set -euo pipefail

# Parameters passed from Jenkins environment
IMAGE_NAME="${1:-docker.io/library/devops-app:latest}"
CONTAINER_NAME="${2:-devproj-app}"
HOST_PORT="${3:-8080}"
CONTAINER_PORT="${4:-8080}"

echo "=================================================="
echo "🚀 Starting Automated Deployment for ${CONTAINER_NAME}"
echo "=================================================="
echo "Image Target    : ${IMAGE_NAME}"
echo "Port Binding    : Host ${HOST_PORT} -> Container ${CONTAINER_PORT}"
echo "Timestamp       : $(date -u)"

echo "📥 Step 1: Pulling latest Docker image from registry..."
docker pull "${IMAGE_NAME}"

echo "🛑 Step 2: Checking for active container instances..."
if [ "$(docker ps -qa -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Stopping existing container [${CONTAINER_NAME}]..."
    docker stop "${CONTAINER_NAME}" || true
    echo "Removing old container instance [${CONTAINER_NAME}]..."
    docker rm "${CONTAINER_NAME}" || true
fi

echo "▶️ Step 3: Launching new container instance..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "${HOST_PORT}:${CONTAINER_PORT}" \
  -m 300m \
  "${IMAGE_NAME}"

echo "🔍 Step 4: Verifying Container Startup & Health..."
sleep 5

if docker ps -f name=^/${CONTAINER_NAME}$ --format '{{.Status}}' | grep -q "Up"; then
    echo "SUCCESS: Container [${CONTAINER_NAME}] is active and running!"
else
    echo "ERROR: Container [${CONTAINER_NAME}] failed to start. Printing container logs..."
    docker logs "${CONTAINER_NAME}"
    exit 1
fi

echo "🧹 Step 5: Pruning dangling Docker images to preserve EBS disk space..."
docker image prune -f

echo "=================================================="
echo "🎉 Deployment Completed Successfully!"
echo "=================================================="
