# Admin Scripts

This repository contains a set of Bash scripts to automate common system administration tasks, including:

- **Cleanup of old log files**
- **Backup of important data**
- **System updates and cleanup**

## Scripts Overview

### 1. `cleanup_logs.sh`
This script cleans up log files older than 30 days and compresses those older than 7 days. It targets log files in the `/var/log` directory by default.

#### Usage:
```bash
./cleanup_logs.sh
```

### 2. `backup_data.sh`
This script creates a backup of important data located in `/home/user/important_data` (by default) and stores the backup as a `.tar.gz` archive in the `/mnt/backup` directory.

#### Usage:
```bash
./backup_data.sh
```

### 3. `update_system.sh`
This script performs a system update by running the following actions:

- Update package lists
- Upgrade installed packages
- Remove unnecessary packages
- Clean up package cache

#### Usage:
```bash
./backup_data.sh
```

### 4. `admin_tasks.sh`
This is a helper script to automate the execution of the above tasks. You can run individual tasks or all tasks at once.

#### Usage:

- Run all tasks:
```bash
./admin_tasks.sh -a
```

- Clean up logs:
```bash
./admin_tasks.sh -l
```

- Backup data:
```bash
./admin_tasks.sh -b
```

- Update System:
```bash 
./admin_tasks.sh -u
```

## Requirements 

- Bash shell
- `tar` and `gzip` installed for backup and compressed tasks
- `sudo` access for the system update script.

## How to run

1. Clone the repository:

```
git clone https://github.com/Shashi2504/Bash_Scripts_for_Automation.git
```

2. Change directory into project folder:

```
cd admin-scripts
```

3. Make the scritps executable:

```
chmod +x *.sh
```

4. Run any of the scripts according to your needs

5. Folder Structure

To keep things organized, you can structure your repository like this:

```
admin-scripts/
├── cleanup_logs.sh
├── backup_data.sh
├── update_system.sh
├── admin_tasks.sh
├── README.md
```
