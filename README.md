# File Backup Script Using Bash on CentOS

An automated, reliable Bash shell script designed for CentOS/Linux environments to back up critical data, create compressed timestamped archives, verify data integrity, maintain an rsync mirror, and enforce an automated retention cleanup policy via cron jobs.

## Features
- **Automated Mirroring:** Syncs changes using `rsync` with fallback to `cp`.
- **Gzip Compression:** Packs data into timestamped `.tar.gz` archives.
- **Archive Verification:** Tests archive readability using `tar -tzf` immediately after creation.
- **Automatic Retention:** Deletes archives older than 7 days using `find`.
- **Detailed Logging:** Appends execution logs with timestamps using `tee`.
- **Cron Automation:** Scheduled for unattended daily execution.

## Directory Structure
```text
BackupProject/
├── backup.sh          # Main automation script
├── source_data/       # Source files to back up
├── backups/           # Timestamped .tar.gz archives
├── mirror/            # rsync mirror of source_data
├── logs/              # Execution logs (backup.log)
└── restore_test/      # Directory for restore verification
```

## Installation & Prerequisites

1. Install required packages on CentOS/RHEL:
   ```bash
   sudo dnf install -y rsync cronie tar gzip
   sudo systemctl enable --now crond
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/<your-username>/File-Backup-Script.git
   cd File-Backup-Script
   ```

3. Make the script executable:
   ```bash
   chmod +x backup.sh
   ```

## Usage

### Run Manually
```bash
./backup.sh
```

Check the generated logs and backups:
```bash
cat logs/backup.log
ls -lh backups/
```

### Schedule with Cron
Open crontab:
```bash
crontab -e
```

Add the entry to trigger the backup daily at 2:00 AM:
```cron
0 2 * * * $HOME/BackupProject/backup.sh >> $HOME/BackupProject/logs/cron.log 2>&1
```

## Restoration & Verification

To verify and restore from a specific archive:
```bash
# 1. Test archive contents
tar -tzf backups/backup_<timestamp>.tar.gz

# 2. Extract to restore directory
tar -xzf backups/backup_<timestamp>.tar.gz -C restore_test/

# 3. Compare with original source
diff -r source_data restore_test/source_data
```
If `diff` returns no output, the restored data matches the source completely.

## Author
- **Keshav Kumar** (UID: 26MCC20092)  
- Master of Computer Applications (MCA), Chandigarh University
