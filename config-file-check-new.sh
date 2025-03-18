#!/bin/bash

# Get all files beginning with 'frr' in current directory
files=(frr*)

# Check if there are any matching files
if [ ${#files[@]} -eq 0 ] || [ "${files[0]}" = "frr*" ]; then
    echo "Error: No files beginning with 'frr' found in current directory"
    exit 1
fi

# Display matching files with numbers
echo "Available files beginning with 'frr':"
for i in "${!files[@]}"; do
    echo "$((i+1)). ${files[$i]}"
done
echo "0. Select all files"

# Ask for user input
echo -n "Enter file numbers to select (space-separated, 0 for all): "
read -r input

# Array to store selected files
declare -a selected_files

# Function to validate and add a number to selection
validate_number() {
    local num=$1
    if ! [[ "$num" =~ ^[0-9]+$ ]]; then
        echo "Error: '$num' is not a valid number"
        exit 1
    fi
    
    if [ "$num" -eq 0 ]; then
        # Select all files
        selected_files=("${files[@]}")
        return
    fi
    
    # Adjust to array index
    local index=$((num-1))
    if [ "$index" -lt 0 ] || [ "$index" -ge "${#files[@]}" ]; then
        echo "Error: $num is out of range. Please choose numbers between 0 and ${#files[@]}"
        exit 1
    fi
    
    # Add file to selection if not already present
    if [[ ! " ${selected_files[*]} " =~ " ${files[$index]} " ]]; then
        selected_files+=("${files[$index]}")
    fi
}

# Process input
if [ -z "$input" ]; then
    echo "Error: No selection made"
    exit 1
fi

# Split input into array
IFS=' ' read -ra numbers <<< "$input"

# Validate each number and build selection
for num in "${numbers[@]}"; do
    validate_number "$num"
    # If we selected all (0), no need to process further numbers
    if [ ${#selected_files[@]} -eq ${#files[@]} ]; then
        break
    fi
done

# Check if any files were selected
if [ ${#selected_files[@]} -eq 0 ]; then
    echo "Error: No valid files selected"
    exit 1
fi

# Extract extensions and build argument list
declare -a extensions
for file in "${selected_files[@]}"; do
    # Extract everything after the last dot, if it exists
    if [[ "$file" =~ \.([^.]+)$ ]]; then
        ext="${BASH_REMATCH[1]}"
        extensions+=("$ext")
    else
        # If no extension, add empty string
        extensions+=("")
    fi
done

# Display selected files
echo "You selected:"
for file in "${selected_files[@]}"; do
    echo "- $file"
done

# Function to perform test reload (from test-reload.sh)
test_reload() {
    local ext=$1
    echo "Running test reload with extension: $ext"
    docker exec "$ext" /usr/lib/frr/frr-reload.py --test "frr.conf.$ext"
    if [ $? -ne 0 ]; then
        echo "Warning: Test reload failed for extension: $ext"
    fi
}

# Function to perform actual reload (from do-reload.sh)
do_reload() {
    local ext=$1
    echo "Running reload with extension: $ext"
    docker exec "$ext" /usr/lib/frr/frr-reload.py --reload "frr.conf.$ext"
    if [ $? -ne 0 ]; then
        echo "Warning: Reload failed for extension: $ext"
    fi
}

# Run test reload for each extension
for ext in "${extensions[@]}"; do
    test_reload "$ext"
done

# Ask if user wants to run the actual reload with the same arguments
echo -n "Would you like to perform the actual reload with the same arguments? (y/n): "
read -r response

# Convert response to lowercase for easier checking
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [ "$response" = "y" ] || [ "$response" = "yes" ]; then
    # Run do reload for each extension
    for ext in "${extensions[@]}"; do
        do_reload "$ext"
    done
else
    echo "Skipping actual reload execution"
fi