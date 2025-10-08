#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DEFAULT_FILE="$SCRIPT_DIR/build-dirs.txt"

if [ $# -ge 1 ]; then
    DOCKER_DIRS_FILE="$1"
    CONFIG_BASE_DIR=$(cd "$(dirname "$1")" && pwd)
else
    DOCKER_DIRS_FILE="$DEFAULT_FILE"
    CONFIG_BASE_DIR="$SCRIPT_DIR"

fi

if [ ! -f "$DOCKER_DIRS_FILE" ]; then
    echo "File '$DOCKER_DIRS_FILE' not found."
    exit 1
fi

# Read docker directories from file into an array
DOCKERFILE_DIRS=()
while IFS= read -r line || [ -n "$line" ]; do
    if [[ ! "$line" =~ ^[[:space:]]*# ]] && [ -n "$line" ]; then
        echo "Registering directory: $line"
        # Add to the array
        DOCKERFILE_DIRS+=("$line")
    fi
done < "$DOCKER_DIRS_FILE"

# Loop through each registered directory
for DIR in "${DOCKERFILE_DIRS[@]}"; do
    if [[ "$DIR" != /* ]]; then
        RESOLVED_DIR="$CONFIG_BASE_DIR/$DIR"
    else
        RESOLVED_DIR="$DIR"
    fi

    echo "Processing directory: $RESOLVED_DIR"
    for dockerfile_path in "$RESOLVED_DIR"/*.dockerfile; do
        # Skip if no dockerfile exists
        [ -e "$dockerfile_path" ] || continue
        
        # Extract base name
        base_name=$(basename "$dockerfile_path" .dockerfile)
        
        # Define image tag
        image_tag="registry.k3s.kube/${base_name}:kube"
        
        echo "Building image: $image_tag from $dockerfile_path"
        sudo nerdctl build \
            --insecure-registry \
            --progress plain \
            -t "$image_tag" -f "$dockerfile_path" \
             "$RESOLVED_DIR"

        echo "Pushing image: $image_tag to registry"

        sudo nerdctl push \
            --insecure-registry \
            "$image_tag"
    done
done

echo "All images built"
