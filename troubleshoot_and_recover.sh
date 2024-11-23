#!/bin/bash

# Function to parse and analyze error logs
parse_error_logs() {
    local log_file=$1
    local output_file="/tmp/error_analysis.txt"

    echo "Analyzing error logs from $log_file..."
    
    # Count occurrences of each unique error message
    sort "$log_file" | uniq -c | sort -rn > "$output_file"

    echo "Top 5 most frequent errors:"
    head -n 5 "$output_file"

    echo "Full analysis saved to $output_file"
}

# Function to restart a service
restart_service() {
    local service_name=$1

    echo "Attempting to restart $service_name..."
    if sudo systemctl restart "$service_name"; then
        echo "$service_name restarted successfully."
    else
        echo "Failed to restart $service_name. Attempting to start..."
        if sudo systemctl start "$service_name"; then
            echo "$service_name started successfully."
        else
            echo "Failed to start $service_name. Please check the service manually."
        fi
    fi
}

# Function for crash recovery
crash_recovery() {
    local service_list="/etc/crash_recovery_services.txt"
    
    if [ ! -f "$service_list" ]; then
        echo "Service list file not found. Creating a sample file..."
        echo -e "nginx\napache2\nmysql" | sudo tee "$service_list"
    fi

    echo "Checking and recovering services..."
    while read -r service; do
        if ! systemctl is-active --quiet "$service"; then
            echo "$service is down. Attempting to restart..."
            restart_service "$service"
        else
            echo "$service is running."
        fi
    done < "$service_list"
}

# Function to check and repair filesystem
check_repair_filesystem() {
    local device=$1
    
    echo "Checking filesystem on $device..."
    
    # Unmount the device if it's mounted
    if mount | grep -q "$device"; then
        echo "Unmounting $device..."
        sudo umount "$device"
    fi

    # Run fsck to check and repair the filesystem
    if sudo fsck -y "$device"; then
        echo "Filesystem check and repair completed successfully."
    else
        echo "Filesystem check failed. Manual intervention may be required."
    fi

    # Remount the device if it was originally mounted
    if mount | grep -q "$device"; then
        echo "Remounting $device..."
        sudo mount "$device"
    fi
}

# Main menu function
main_menu() {
    echo "Troubleshooting and Recovery Script"
    echo "1. Parse Error Logs"
    echo "2. Perform Crash Recovery"
    echo "3. Check and Repair Filesystem"
    echo "4. Exit"
    read -p "Enter your choice (1-4): " choice

    case $choice in
        1)
            read -p "Enter the path to the error log file: " log_file
            parse_error_logs "$log_file"
            ;;
        2)
            crash_recovery
            ;;
        3)
            read -p "Enter the device to check (e.g., /dev/sda1): " device
            check_repair_filesystem "$device"
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

    echo
    main_menu
}

# Start the script
main_menu