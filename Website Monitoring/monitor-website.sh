#!/bin/bash

WEBSITE="https://v0.dev/chat"
EMAIL_ID="shashireddy0403@gmail.com"
EMAIL_SUBJECT="Website Monitoring Alert"
MAX_RETRIES=3
RETRY_INTERVAL=5

# Check if required utilities are installed
if ! command -v curl &>/dev/null || ! command -v mail &>/dev/null; then
    echo "Required utilities 'curl' and 'mail' are not installed. Exiting."
    exit 1
fi

# Function to send email alerts
send_alert() {
    echo "$1" | mail -s "$EMAIL_SUBJECT" "$EMAIL_ID"
}

# Function to check website status
check_website() {
    for ((i=1; i<=$MAX_RETRIES; i++)); do
        if curl -s --head "$WEBSITE" | grep "HTTP/1.[01] [23].." > /dev/null; then
            echo "$(date): Website is running up"
            return 0
        else
            echo "$(date): Attempt $i: Website is down. Retrying in $RETRY_INTERVAL seconds..."
            sleep $RETRY_INTERVAL
        fi
    done

    send_alert "Alert: $WEBSITE is unreachable after $MAX_RETRIES attempts."
    return 1
}

# Main execution
echo "Checking website: $WEBSITE"
check_website

if [ $? -eq 0 ]; then
    echo "$(date): Website check successful" >> ~/website_monitor.log
else
    echo "$(date): Website check failed" >> ~/website_monitor.log
fi
