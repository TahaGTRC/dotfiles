#!/usr/bin/env sh

cleanup() {
	# In case of a sudden shutdown, this ensures 
	# the removal of record lockfile/status file
	# which if remained, will show that I'm still recording
	rm -f /tmp/record.process
	echo "​" > "$REC_STATUS_FILE"
}

cron -f "$BACKUP/cron"
cleanup
