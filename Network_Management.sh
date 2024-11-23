#!/bin/bash

# Function to monitor latency and packet loss
monitor_network() {
    local target=$1
    local log_file="/var/log/network_monitor.log"

    echo "$(date): Monitoring $target" >> "$log_file"
    
    # Ping the target 10 times
    ping_result=$(ping -c 10 "$target")
    
    # Extract average latency
    latency=$(echo "$ping_result" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
    
    # Calculate packet loss
    packet_loss=$(echo "$ping_result" | grep -oP '\d+(?=% packet loss)')
    
    echo "Latency: ${latency}ms, Packet Loss: ${packet_loss}%" >> "$log_file"
    
    # Perform traceroute
    echo "Traceroute:" >> "$log_file"
    traceroute "$target" >> "$log_file"
    
    echo "--------------------" >> "$log_file"
}

# Function to update /etc/hosts
update_hosts() {
    local node_name=$1
    local new_ip=$2
    local hosts_file="/etc/hosts"
    
    # Check if the node already exists in the hosts file
    if grep -q "$node_name" "$hosts_file"; then
        # Update the existing entry
        sudo sed -i "s/.*$node_name/$new_ip $node_name/" "$hosts_file"
    else
        # Add a new entry
        echo "$new_ip $node_name" | sudo tee -a "$hosts_file" > /dev/null
    fi
    
    echo "Updated $hosts_file for $node_name with IP $new_ip"
}

# Function to setup VPN
setup_vpn() {
    local server_ip=$1
    local client_name=$2
    
    # Install OpenVPN if not already installed
    if ! command -v openvpn &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y openvpn
    fi
    
    # Generate server and client certificates (simplified for demonstration)
    # In a real-world scenario, you'd use a proper PKI system
    sudo openvpn --genkey --secret /etc/openvpn/static.key
    
    # Create server config
    cat << EOF | sudo tee /etc/openvpn/server.conf > /dev/null
dev tun
ifconfig 10.8.0.1 10.8.0.2
secret /etc/openvpn/static.key
EOF

    # Create client config
    cat << EOF | sudo tee /etc/openvpn/$client_name.ovpn > /dev/null
remote $server_ip
dev tun
ifconfig 10.8.0.2 10.8.0.1
secret /etc/openvpn/static.key
EOF

    # Start OpenVPN server
    sudo systemctl start openvpn@server
    
    echo "VPN setup complete. Client config is at /etc/openvpn/$client_name.ovpn"
}

# Main execution
main() {
    echo "Network Management Script"
    echo "1. Monitor Network"
    echo "2. Update Hosts"
    echo "3. Setup VPN"
    read -p "Enter your choice (1-3): " choice

    case $choice in
        1)
            read -p "Enter target to monitor: " target
            monitor_network "$target"
            ;;
        2)
            read -p "Enter node name: " node_name
            read -p "Enter new IP address: " new_ip
            update_hosts "$node_name" "$new_ip"
            ;;
        3)
            read -p "Enter server IP: " server_ip
            read -p "Enter client name: " client_name
            setup_vpn "$server_ip" "$client_name"
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

# Run the main function
main