#!/usr/bin/env sh

cleanup() {
	# w/o this, it'll still show that im recording after rebooting after a elec interrupt or sm
	rm -f /tmp/record.process
	echo "​" > "$REC_STATUS_FILE"
}

cron -f "$BACKUP/cron"
cleanup
