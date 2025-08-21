#!/bin/bash

# A script to build and run a pwncollege/dojo development container.
#
# Usage:
#   ./setup_dojo.sh                  (Uses the 'master' branch by default)
#   ./setup_dojo.sh pull/123/head    (Uses a specific PR branch)

set -e

# Ensure Docker is installed
if command -v docker >/dev/null 2>&1; then
    echo "Docker found: $(docker --version)"
else
    echo "Docker not found. Installing..."
    if ! command -v curl >/dev/null 2>&1; then
        echo "Installing curl..."
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update -y
            apt-get install -y curl
        elif command -v yum >/dev/null 2>&1; then
            yum install -y curl
        else
            echo "Unsupported OS: no apt-get or yum found."
            exit 1
        fi
    fi
    curl -fsSL https://get.docker.com | /bin/sh
    echo "Docker installed: $(docker --version)"
fi

# Try to ensure Docker daemon is running (best-effort)
if ! docker info >/dev/null 2>&1; then
    echo "Attempting to start Docker service..."
    if command -v systemctl >/dev/null 2>&1; then
        systemctl start docker || true
    elif command -v service >/dev/null 2>&1; then
        service docker start || true
    fi
fi

BRANCH="${1:-master}"
PORTS="80:80"

echo "Starting setup for branch: $BRANCH"

TAG="dev-$(printf '%s' "$BRANCH" | tr '/' '-' | tr -c '[:alnum:]' '-')"
IMAGE_NAME="pwncollege/dojo:$TAG"
CONTAINER_NAME="dojo-$TAG"

echo "Using Image: $IMAGE_NAME"
echo "Using Container Name: $CONTAINER_NAME"

echo "Checking for and removing old container..."
if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    docker rm -f "$CONTAINER_NAME"
    echo "Removed existing container."
fi

echo "Building the Docker image... this may take a while."
docker build --build-arg BUILDKIT_CONTEXT_KEEP_GIT_DIR=1 -t "$IMAGE_NAME" .

echo "Running new container with port forwarding ($PORTS)..."
docker run \
    --privileged \
    --name "$CONTAINER_NAME" \
    -p "$PORTS" \
    -d "$IMAGE_NAME"

echo "Success! The container '$CONTAINER_NAME' is running."

docker exec "$CONTAINER_NAME" dojo logs
