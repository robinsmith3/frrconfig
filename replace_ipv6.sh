#!/bin/bash

# Backup directory and log file
BACKUP_DIR="backups_$(date +%Y%m%d_%H%M%S)"
LOGFILE="replace_log_$(date +%Y%m%d_%H%M%S).txt"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to display and log changes
log_change() {
    local file="$1"
    local old_text="$2"
    local new_text="$3"
    echo "Changing in $file: $old_text -> $new_text"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $file: $old_text -> $new_text" >> "$LOGFILE"
}

# Function to process replacement in a file
process_file() {
    local file="$1"
    local old_pattern="2a00:23c6:9c79:3201:"
    local new_pattern="2001:db8::"
    
    # Create backup
    local backup_file="$BACKUP_DIR/$(basename "$file")"
    cp "$file" "$backup_file"
    echo "Created backup: $backup_file"
    
    # Check if file contains the pattern
    if grep -q "$old_pattern" "$file"; then
        # Perform replacement and log each change
        while IFS= read -r line; do
            if [[ "$line" =~ $old_pattern ]]; then
                log_change "$file" "$old_pattern" "$new_pattern"
            fi
        done < "$file"
        
        # Actually perform the replacement
        sed -i "s|$old_pattern|$new_pattern|g" "$file"
        echo "Processed: $file"
    else
        echo "No matches found in: $file"
    fi
}

# Get list of matching files
mapfile -t files < <(ls frr.conf.frr-* 2>/dev/null)

if [ ${#files[@]} -eq 0 ]; then
    echo "No files matching 'frr.conf.frr-*' found in current directory"
    exit 1
fi

echo "Found ${#files[@]} matching files:"
for i in "${!files[@]}"; do
    echo "$((i+1)). ${files[i]}"
done

echo -e "\nOptions:"
echo "1. Process a single file"
echo "2. Process multiple specific files"
echo "3. Process all files"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        read -p "Enter file number (1-${#files[@]}): " filenum
        if [[ "$filenum" =~ ^[0-9]+$ ]] && [ "$filenum" -ge 1 ] && [ "$filenum" -le "${#files[@]}" ]; then
            process_file "${files[$((filenum-1))]}"
        else
            echo "Invalid file number"
            exit 1
        fi
        ;;
    2)
        read -p "Enter file numbers separated by spaces (1-${#files[@]}): " -a filenums
        for num in "${filenums[@]}"; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#files[@]}" ]; then
                process_file "${files[$((num-1))]}"
            else
                echo "Invalid file number: $num"
            fi
        done
        ;;
    3)
        for file in "${files[@]}"; do
            process_file "$file"
        done
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo -e "\nChanges have been logged to $LOGFILE"
echo "Backups stored in: $BACKUP_DIR"