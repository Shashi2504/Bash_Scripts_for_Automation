#!/bin/bash

CPU_TRESHOLD=80
MEMORY_TRESHOLD=80
DISK_TRESHOLD=80
LOAD_TRESHOLD=80

EMAIL_ID="shashireddy0403@gmail.com"
EMAIL_SUBJECT="System Alert"

send_alert() {
	echo "$1" | mail -s "$EMAIL_SUBJECT" "$EMAIL_ID"
}

cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *$$[0-9.]*$$%* id.*/\1/" | awk '{print 100 - $1}')
if (( $(echo "$cpu_usage > $CPU_TRESHOLD" | bc -l))); then
	send_alert "CPU usage is high: $cpu_usage%"
fi

memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
if (($(echo "$memory_usage > MEMORY_TRESHORLD" | bc -l))); then
	send_alert "Memory usage is high: $memory_usage%"
fi

disk_usage=$(df -h | awk '/\// {print $(NF-1)}' | sed 's/%//')
if (( disk_usage > DISK_TRESHOLD )); then
	send_alert "Disk usage is high: $disk_usage%"
fi

load_average=$(uptime | awk -F'load average:' '{print $2}' | CUT -d -f1 | sed 's/ //g')
if (( $(echo "$load_average > LOAD_TRESHOLD" | bc -l) )); then
	send_alert "Load average is high: $load_average%"
fi


echo "Current System Metrics"
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $memory_usage%"
echo "Disk Usae: $disk_usage%"
echo "Load Average: $load_average"
