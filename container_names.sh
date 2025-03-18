#!/bin/bash
# Change continer names to that of  internal GNS hostname
# Get list of container names and store in array
mapfile -t containers < <(docker ps --format '{{.Names}}')

# Check if there are any containers running
if [ ${#containers[@]} -eq 0 ]; then
    echo "No running containers found."
    exit 1
fi

# Display available containers
echo "Available containers:"
for i in "${!containers[@]}"; do
    echo "$i: ${containers[$i]}"
done

# Ask user to select containers
echo -n "Enter container numbers to work on (space-separated, or 'all' for all containers): "
read -r selection

# Process selection
if [ "$selection" = "all" ]; then
    selected_containers=("${containers[@]}")
else
    IFS=' ' read -r -a selected_indices <<< "$selection"
    selected_containers=()
    for i in "${selected_indices[@]}"; do
        if [[ "$i" =~ ^[0-9]+$ ]] && [ "$i" -ge 0 ] && [ "$i" -lt "${#containers[@]}" ]; then
            selected_containers+=("${containers[$i]}")
        else
            echo "Invalid selection: $i, skipping..."
        fi
    done
fi

# Process each selected container
for container in "${selected_containers[@]}"; do
    echo "Processing container: $container"
    
    # Get hostname from inside the container
    hostname=$(docker exec "$container" hostname)
    
    if [ -n "$hostname" ]; then
        echo "Found hostname: $hostname"
        # Rename container to its hostname
        docker rename "$container" "$hostname"
        echo "Renamed $container to $hostname"
    else
        echo "Could not determine hostname for $container"
    fi
done

echo "Done!"
