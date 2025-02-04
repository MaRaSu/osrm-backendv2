#!/bin/bash

PROFILE=$1
BASENAME="${1}-${2}"
WEEKDAY=$(date +%u)

# Function to retry operations with backoff
retry_operation() {
	local max_attempts=5
	local command=$1
	local attempt=1

	while [ $attempt -le $max_attempts ]; do
		echo "Attempt $attempt of $max_attempts: $command"
		if eval "$command"; then
			return 0
		fi
		attempt=$((attempt + 1))
		echo "Operation failed, waiting 60 seconds before retry..."
		sleep 60
	done
	echo "Operation failed after $max_attempts attempts"
	return 1
}

# Function to handle file download
handle_download() {
	local loop_weekday=$WEEKDAY

	# Try for up to 7 days
	while true; do
		FILE=trailmap/trailmap-internal/${BASENAME}_${loop_weekday}.tar.gz
		echo "Checking for file ${FILE}"
		if mc stat ${FILE} >/dev/null 2>&1; then
			success=false
			for i in {1..5}; do
				mc cp ${FILE} data.tar.gz &&
					{
						success=true
						break
					} || sleep 60
			done
			if [ "$success" = true ]; then
				break
			else
				echo "Error: Failed to copy file after 5 attempts"
				exit 1
			fi
		fi

		# Decrease weekday, wrap around from 1 to 7
		loop_weekday=$((loop_weekday - 1))
		if [ $loop_weekday -eq 0 ]; then
			loop_weekday=7
		fi

		# If we're back to original weekday, no files were found
		if [ $loop_weekday -eq $WEEKDAY ]; then
			echo "Error: No osrm file found for the last 7 days"
			exit 1
		fi
	done
}

handle_archive() {
	local source="data.tar.gz"

	# Untar the file
	if ! retry_operation "tar -xvf $source --transform='s/.*\///'"; then
		echo "Failed to untar files for ${BASENAME}"
		return 1
	fi
}

# Main script
/app/config_minio.sh || exit 1

cd /data || exit 1
handle_download || exit 1
handle_archive || exit 1
