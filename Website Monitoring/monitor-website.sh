#!/bin/bash

WEBSITE="https://v0.dev/chat"
EMAIL_ID="shashireddy0403@gmail.com"
EMAI_SUBJECT="Website Monitoring Alert"
MAX_RETRIES=3
RETRY_INTERVAL=5

send_alert() {
	echo "$1" | mail -s "$EMAIL_SUBJECT" "$EMAIL_ID"
}

check_website() {
	for ((i=1; i<=$MAX_RETRIES; i++)); do
		if curl -s --head "$WEBSITE" | grep "HTTP/1.[01] [23].." > /dev/null; then
			echo "Website is running up"
			return 0
		else
			echo "Attempt $i: Website is down. Retrying in $RETRY_INTERVAL seconds..."
			sleep $RETRY_INTERVAL
		fi
	done

	send_alert "Alert: $Website is unreachable after $MAX_RETIES attempts."
	return 1
}

echo "Checking website: $WEBSITE"
check_website

if [ $? -eq 0 ]; then
	echo "$(date): Website check successful" >> /var/log/website_monitor.log
else
	echo "$(date): Website check failed" >> /var/log/website_monitor.log
fi
