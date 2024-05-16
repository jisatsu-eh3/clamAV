#!/bin/bash
###############################################################################
# Script Name: scan.sh
# Description: This script runs a ClamAV scan, moves infected files to a 
#              quarantine directory, logs the details of the scan and 
#              quarantined files, and transfers the log and quarantine details files to a remote 
#              server. It also deletes log files older than 30 days.
# Author: jisatsu-eh3
# Date: 05/15/2024
# Version: 1.0
# Usage: ./clam.sh
# Replace the place holders between < > on lines: 21, 44, 51
###############################################################################

# Set variables for log and quarantine directories
LOG_DIR="/opt/clamAV/logs"
QUARANTINE_DIR="/opt/clamAV/quarantined"

# Define log and quarantine file path (use timestamp for unique log file)
LOG_FILE="$LOG_DIR/scan_$(date +'%d-%m-%Y').log"
QUARANTINE_OUTPUT_FILE="$LOG_DIR/quarantine_details_<hostname>_$(date +'%d-%m-%Y').log"

# Execute clamscan with recursive option
/usr/bin/clamscan --recursive / --log="$LOG_FILE" --move="$QUARANTINE_DIR" --exclude-dir="^/sys"

# Check if the log file exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Log file $LOG_FILE does not exist."
    exit 1
fi

# Check if any files were moved to quarantine
if grep -q ' moved to ' "$LOG_FILE"; then
    # Output file details to the quarantine log file
    echo "Files moved to quarantine:" > "$QUARANTINE_OUTPUT_FILE"
    grep ' moved to ' "$LOG_FILE" | while read -r line; do
        # Extract original file path
        original_file=$(echo "$line" | awk -F': ' '{print $1}')
        echo "Original location: $original_file" >> "$QUARANTINE_OUTPUT_FILE"
    done
    echo "Quarantine details written to: $QUARANTINE_OUTPUT_FILE"
    
    # Securely transfer the quarantined detail files to the remote server
    sshpass -f /opt/clamAV/.creds scp -o StrictHostKeyChecking=no /opt/clamAV/logs/$QUARANTINE_OUTPUT_FILE <user>@<dest IP>:/path/to/destination/.
else
    echo "No files were moved to quarantine."
fi

# Securely transfer the log files to the remote server
# The StrictHostKeyChecking is only required the first time running with a service account.
sshpass -f /opt/clamAV/.creds scp -o StrictHostKeyChecking=no /opt/clamAV/logs/$LOG_FILE <user>@<dest IP>:/path/to/destination/.

# Delete log files older than 30 days
find /opt/clamAV/logs/ -type f -mtime +30 -delete
