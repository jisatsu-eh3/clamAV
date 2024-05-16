# ClamAV Scan Script

## Description

This script automates the process of running a ClamAV scan on a system, moving infected files to a quarantine directory, logging the scan and quarantined file details, and securely transferring the log and quarantine details files to a remote server. 
It also includes functionality to delete log files older than 30 days. 
The script is meant to be run from cron for scheduled scans, but can be run manually with './scan.sh'.

## Usage

1. Ensure ClamAV is installed on your system and the `clamscan` command is available.
2. Create a '.creds' text file with just the password for sshpass, and lock it down to just the user running the script to access.
2. Set up the script by configuring the following placeholders:
   - `<hostname>` in `QUARANTINE_OUTPUT_FILE`: Replace with a relevant identifier (e.g., hostname, system name).
   - `<user>` and `<dest IP>` in `sshpass` commands: Replace with the SSH username and destination IP address of the remote server.
   - `/path/to/destination/` in `sshpass` commands: Replace with the path on the remote server where log files will be transferred.

3. Make the script executable:
   - 'chmod +x scan.sh'

## ClamAV Scan Options

    --recursive /: Perform a recursive scan starting from the root directory.
    --log="$LOG_FILE": Specify the output log file for the ClamAV scan.
    --move="$QUARANTINE_DIR": Move infected files to the specified quarantine directory.
    --exclude-dir="^/sys"
