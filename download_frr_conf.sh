#!/bin/bash

# Get list of matching containers
containers=$(docker ps -a --format '{{.Names}}' | grep -E '^frr-[0-9]')

# Check if any containers were found
if [ -z "$containers" ]; then
    echo "No containers found matching pattern frr-[0-9]*"
    exit 1
fi

# Convert to array
container_array=($containers)
num_containers=${#container_array[@]}

# Display available containers
echo "Found containers:"
for i in "${!container_array[@]}"; do
    echo "[$i] ${container_array[$i]}"
done

# Prompt user for selection
echo -e "\nEnter container numbers to copy from (space-separated, 'all' for all containers, or press Enter to select first one):"
read selection

# Process selection
if [ -z "$selection" ]; then
    # Default to first container
    selected_containers="${container_array[0]}"
elif [ "$selection" = "all" ]; then
    # Select all containers
    selected_containers="$containers"
else
    # Parse space-separated numbers
    selected_containers=""
    IFS=' ' read -ra indices <<< "$selection"
    for i in "${indices[@]}"; do
        if [[ "$i" =~ ^[0-9]+$ && "$i" -lt "$num_containers" ]]; then
            selected_containers="${selected_containers} ${container_array[$i]}"
        else
            echo "Invalid selection: $i"
            exit 1
        fi
    done
fi

# Copy files from selected containers
for container in $selected_containers; do
    output_file="frr.conf.$container"
    echo "Copying from $container to $output_file"
    docker cp "$container:/etc/frr/frr.conf" "./$output_file"
    if [ $? -eq 0 ]; then
        echo "Successfully copied to $output_file"
    else
        echo "Failed to copy from $container"
    fi
done