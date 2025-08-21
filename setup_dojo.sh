#!/bin/bash

# A script to build and run a pwncollege/dojo development container.
#
# Usage:
#   ./setup_dojo.sh                  (Uses the 'master' branch by default)
#   ./setup_dojo.sh pull/123/head    (Uses a specific PR branch)

set -e

apt install curl -y

curl -fsSL https://get.docker.com | /bin/sh

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
    echo "emoved existing container."
fi

echo "uilding the Docker image... this may take a while."
docker build --build-arg BUILDKIT_CONTEXT_KEEP_GIT_DIR=1 -t "$IMAGE_NAME" .

echo "Running new container with port forwarding ($PORTS)..."
docker run \
    --privileged \
    --name "$CONTAINER_NAME" \
    -p "$PORTS" \
    -d "$IMAGE_NAME" # -d runs the container in detached mode (in the background).

echo "🎉 Success! The container '$CONTAINER_NAME' is running."

docker exec $CONTAINER_NAME dojo logs
