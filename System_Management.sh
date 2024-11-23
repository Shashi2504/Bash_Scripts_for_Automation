#!/bin/bash

# Function to manage users
manage_user() {
    local action=$1
    local username=$2

    case $action in
        create)
            sudo useradd -m "$username"
            echo "User $username created."
            ;;
        modify)
            read -p "Enter new shell for $username: " new_shell
            sudo usermod -s "$new_shell" "$username"
            echo "User $username modified."
            ;;
        delete)
            sudo userdel -r "$username"
            echo "User $username deleted."
            ;;
        *)
            echo "Invalid action for user management."
            ;;
    esac
}

# Function to manage groups
manage_group() {
    local action=$1
    local groupname=$2

    case $action in
        create)
            sudo groupadd "$groupname"
            echo "Group $groupname created."
            ;;
        modify)
            read -p "Enter user to add to $groupname: " username
            sudo usermod -aG "$groupname" "$username"
            echo "User $username added to group $groupname."
            ;;
        delete)
            sudo groupdel "$groupname"
            echo "Group $groupname deleted."
            ;;
        *)
            echo "Invalid action for group management."
            ;;
    esac
}

# Function to synchronize time
sync_time() {
    # Install NTP if not already installed
    if ! command -v ntpd &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y ntp
    fi

    # Stop the NTP service
    sudo systemctl stop ntp

    # Perform a one-time sync
    sudo ntpd -gq

    # Start and enable the NTP service
    sudo systemctl start ntp
    sudo systemctl enable ntp

    echo "Time synchronized with NTP servers."
}

# Function to manage cron jobs
manage_cron() {
    local action=$1
    local job_name=$2
    local cron_file="/etc/cron.d/$job_name"

    case $action in
        deploy)
            read -p "Enter cron schedule (e.g., '0 * * * *'): " schedule
            read -p "Enter command to run: " command
            echo "$schedule root $command" | sudo tee "$cron_file" > /dev/null
            echo "Cron job $job_name deployed."
            ;;
        update)
            if [ -f "$cron_file" ]; then
                read -p "Enter new cron schedule (e.g., '0 * * * *'): " schedule
                read -p "Enter new command to run: " command
                echo "$schedule root $command" | sudo tee "$cron_file" > /dev/null
                echo "Cron job $job_name updated."
            else
                echo "Cron job $job_name does not exist."
            fi
            ;;
        delete)
            if [ -f "$cron_file" ]; then
                sudo rm "$cron_file"
                echo "Cron job $job_name deleted."
            else
                echo "Cron job $job_name does not exist."
            fi
            ;;
        *)
            echo "Invalid action for cron job management."
            ;;
    esac
}

# Function to deploy cron jobs to multiple servers
deploy_cron_to_servers() {
    local job_name=$1
    local cron_file="/etc/cron.d/$job_name"

    if [ ! -f "$cron_file" ]; then
        echo "Cron job $job_name does not exist locally."
        return 1
    fi

    read -p "Enter comma-separated list of server IPs: " server_list
    IFS=',' read -ra servers <<< "$server_list"

    for server in "${servers[@]}"; do
        echo "Deploying cron job to $server..."
        scp "$cron_file" "root@$server:$cron_file"
        ssh "root@$server" "chown root:root $cron_file && chmod 644 $cron_file"
    done

    echo "Cron job $job_name deployed to all specified servers."
}

# Main menu function
main_menu() {
    echo "System Management Script"
    echo "1. Manage Users"
    echo "2. Manage Groups"
    echo "3. Synchronize Time"
    echo "4. Manage Cron Jobs"
    echo "5. Deploy Cron Job to Multiple Servers"
    echo "6. Exit"
    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            read -p "Enter action (create/modify/delete): " action
            read -p "Enter username: " username
            manage_user "$action" "$username"
            ;;
        2)
            read -p "Enter action (create/modify/delete): " action
            read -p "Enter group name: " groupname
            manage_group "$action" "$groupname"
            ;;
        3)
            sync_time
            ;;
        4)
            read -p "Enter action (deploy/update/delete): " action
            read -p "Enter cron job name: " job_name
            manage_cron "$action" "$job_name"
            ;;
        5)
            read -p "Enter cron job name to deploy: " job_name
            deploy_cron_to_servers "$job_name"
            ;;
        6)
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