#!/bin/bash
# Copy files necessary to bring up each FRR node from a GNS shutdown
# Check if files exist in current directory
if [ -z "$(ls -A .)" ]; then
    echo "No files found in current directory"
    exit 1
fi

# Get all files ending with frr- followed by any number into an array
mapfile -t FILE_ARRAY < <(ls -1 *.frr-[0-9]* 2>/dev/null)

# Check if any matching files exist
if [ ${#FILE_ARRAY[@]} -eq 0 ]; then
    echo "No files matching pattern *.frr-[0-9]* found"
    exit 1
fi

# Additional files to copy
EXTRA_FILES=("reload.sh" "reload-test.sh")

# Process each file
for file in "${FILE_ARRAY[@]}"; do
    if [ -f "$file" ]; then
        # Extract container name from everything after the last dot
        container_name=$(echo "$file" | sed 's/.*\.\([^.]*frr-[0-9]*\)$/\1/')
        
        if [ -z "$container_name" ] || [ "$container_name" = "$file" ]; then
            echo "Skipping $file - could not determine container name after last dot"
            continue
        fi
        
        echo "Processing container: $container_name"
        
        # Copy the main file
        echo "Copying $file to container: $container_name:/etc/frr"
        docker cp "$file" "$container_name:/etc/frr"
        if [ $? -eq 0 ]; then
            echo "Successfully copied $file to $container_name:/etc/frr"
        else
            echo "Failed to copy $file to $container_name:/etc/frr"
        fi
        
        # Copy additional files
        for extra_file in "${EXTRA_FILES[@]}"; do
            if [ -f "$extra_file" ]; then
                echo "Copying $extra_file to container: $container_name:/etc/frr"
                docker cp "$extra_file" "$container_name:/etc/frr"
                if [ $? -eq 0 ]; then
                    echo "Successfully copied $extra_file to $container_name:/etc/frr"
                else
                    echo "Failed to copy $extra_file to $container_name:/etc/frr"
                fi
            else
                echo "Skipping $extra_file - file not found"
            fi
        done
    fi
done
