#!/bin/bash
# check all frr config files and ask user if they want to update
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

# Check if test-reload.sh exists and is executable
if [ ! -f "test-reload.sh" ]; then
    echo "Error: test-reload.sh not found in current directory"
    exit 1
fi
if [ ! -x "test-reload.sh" ]; then
    echo "Error: test-reload.sh is not executable"
    exit 1
fi

# Run test-reload.sh for each extension individually
for ext in "${extensions[@]}"; do
    echo "Running test-reload.sh with extension: $ext"
    ./test-reload.sh "$ext"
done

# Ask if user wants to run do-reload.sh with the same arguments
echo -n "Would you like to run do-reload.sh with the same arguments? (y/n): "
read -r response

# Convert response to lowercase for easier checking
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [ "$response" = "y" ] || [ "$response" = "yes" ]; then
    # Check if do-reload.sh exists and is executable
    if [ ! -f "do-reload.sh" ]; then
        echo "Error: do-reload.sh not found in current directory"
        exit 1
    fi
    if [ ! -x "do-reload.sh" ]; then
        echo "Error: do-reload.sh is not executable"
        exit 1
    fi
    
    # Run do-reload.sh for each extension individually
    for ext in "${extensions[@]}"; do
        echo "Running do-reload.sh with extension: $ext"
        ./do-reload.sh "$ext"
    done
else
    echo "Skipping do-reload.sh execution"
fi
