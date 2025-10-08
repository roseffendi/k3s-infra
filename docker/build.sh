#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <docker_dirs_file>"
    exit 1
fi

DOCKER_DIRS_FILE="$1"

if [ ! -f "$DOCKER_DIRS_FILE" ]; then
    echo "File '$DOCKER_DIRS_FILE' not found."
    exit 1
fi

# Read docker directories from file into an array
DOCKERFILE_DIRS=()
while IFS= read -r line || [ -n "$line" ]; do
    echo "Registering directory: $line"
    [ -n "$line" ] && DOCKERFILE_DIRS+=("$line")
done < "$DOCKER_DIRS_FILE"

# Loop through each registered directory
for dir in "${DOCKERFILE_DIRS[@]}"; do
    echo "Processing directory: $dir"
    for dockerfile_path in "$dir"/*.dockerfile; do
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
             "$dir"

        echo "Pushing image: $image_tag to registry"

        sudo nerdctl push \
            --insecure-registry \
            "$image_tag"
    done
done

echo "All images built"
