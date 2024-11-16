#!/bin/bash

usage() {
	echo "Usage: $0 [Options]"
	echo "Options:"
	echo "	-a	Run all tasks"
	echo "	-l	Clean up log files"
	echo "	-b	Backup important data"
	echo "	-u	Update System"
	echo "	-h	Display this help message"
}

run_script() {
	if [ -x "$1" ]; then
		echo "Running $1..."
		"$1"
		if [$? -eq 0]; then 
			echo "$1 Successsfully Completed"
		else
			echo "$1 failed"
		fi
	else
		echo "Error: $1 not found or not executable"
	fi
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi


while getopts "albuh" opt; do
	case $opt in
		a)
			run_script "./cleanup_logs.sh"
			run_script "./backup_data.sh"
			run_script "./update_system.sh"
			;;

		l)
			run_script "./cleanup_log.sh"
			;;

		b)
			run_script "./backup_data.sh"
			;;

		u)
			run_script "./update_system.sh"
			;;

		h)
			usage
			exit 1
			;;

		/?)
			echo "Inavlid Option: -$OPTARG" >&2
			usage
			exit 1
			;;

	esac
done

echo "All requested tasks completed"
