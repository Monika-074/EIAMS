#!/bin/bash

# ==========================================
# EIAMS - Backup Management Module
# ==========================================

PROJECT_DIR="/mnt/d/AWSProject/EIAMS"
BACKUP_DIR="$PROJECT_DIR/backups"

# ==========================================
# Initialize Backup Directory
# ==========================================

initialize_backup() {

    mkdir -p "$BACKUP_DIR"

}

# ==========================================
# Create System Backup
# ==========================================

create_system_backup() {

    echo
    echo "=========================================="
    echo "          CREATE SYSTEM BACKUP"
    echo "=========================================="
    echo

    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="$BACKUP_DIR/eiams_system_$timestamp.tar.gz"

    echo "Creating system backup..."
    echo

    tar -czf "$backup_file" \
        --exclude="$BACKUP_DIR" \
        --exclude="$PROJECT_DIR/.git" \
        "$PROJECT_DIR/config" \
        "$PROJECT_DIR/modules" \
        "$PROJECT_DIR/scripts" \
        "$PROJECT_DIR/logs" \
        "$PROJECT_DIR/README.md" \
        2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Backup created successfully."
        echo
        echo "Backup file:"
        echo "$backup_file"
        echo
        echo "Backup size:"
        du -h "$backup_file" | cut -f1
    else
        echo "ERROR: Backup creation failed."
    fi

    echo
}

# ==========================================
# Create Configuration Backup
# ==========================================

create_config_backup() {

    echo
    echo "=========================================="
    echo "       CREATE CONFIGURATION BACKUP"
    echo "=========================================="
    echo

    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="$BACKUP_DIR/eiams_config_$timestamp.tar.gz"

    if [ ! -d "$PROJECT_DIR/config" ]; then
        echo "ERROR: Configuration directory not found."
        echo
        return
    fi

    echo "Creating configuration backup..."
    echo

    tar -czf "$backup_file" "$PROJECT_DIR/config" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Configuration backup created successfully."
        echo
        echo "Backup file:"
        echo "$backup_file"
        echo
        echo "Backup size:"
        du -h "$backup_file" | cut -f1
    else
        echo "ERROR: Configuration backup failed."
    fi

    echo
}

# ==========================================
# List Available Backups
# ==========================================

list_backups() {

    echo
    echo "=========================================="
    echo "          AVAILABLE BACKUPS"
    echo "=========================================="
    echo

    backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" | wc -l)

    if [ "$backup_count" -eq 0 ]; then
        echo "No backups available."
    else
        echo "Total backups: $backup_count"
        echo
        printf "%-45s %-10s\n" "BACKUP FILE" "SIZE"
        echo "----------------------------------------------------------"

        for backup in "$BACKUP_DIR"/*.tar.gz; do

            [ -e "$backup" ] || continue

            filename=$(basename "$backup")
            size=$(du -h "$backup" | cut -f1)

            printf "%-45s %-10s\n" "$filename" "$size"

        done
    fi

    echo
}

# ==========================================
# Backup Statistics
# ==========================================

backup_statistics() {

    echo
    echo "=========================================="
    echo "          BACKUP STATISTICS"
    echo "=========================================="
    echo

    total_backups=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" | wc -l)

    if [ "$total_backups" -gt 0 ]; then
        total_size=$(du -ch "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -1 | awk '{print $1}')
    else
        total_size="0"
    fi

    echo "Backup Directory:"
    echo "$BACKUP_DIR"
    echo
    echo "Total Backups:"
    echo "$total_backups"
    echo
    echo "Total Backup Size:"
    echo "$total_size"
    echo

    if [ "$total_backups" -gt 0 ]; then

        latest_backup=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)

        echo "Latest Backup:"
        echo "$(basename "$latest_backup")"

    else

        echo "Latest Backup:"
        echo "None"

    fi

    echo
}

# ==========================================
# Delete Old Backups
# ==========================================

delete_old_backups() {

    echo
    echo "=========================================="
    echo "           BACKUP CLEANUP"
    echo "=========================================="
    echo

    echo "This will delete backups older than 7 days."
    echo
    read -p "Continue? (yes/no): " confirmation

    if [ "$confirmation" != "yes" ]; then
        echo
        echo "Cleanup cancelled."
        echo
        return
    fi

    deleted_count=0

    while IFS= read -r backup; do

        rm -f "$backup"

        if [ $? -eq 0 ]; then
            deleted_count=$((deleted_count + 1))
            echo "Deleted: $(basename "$backup")"
        fi

    done < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" -mtime +7)

    echo
    echo "Old backups deleted: $deleted_count"
    echo
}

# ==========================================
# Backup Menu
# ==========================================

initialize_backup

while true; do

    clear

    echo "=========================================="
    echo "        EIAMS BACKUP MANAGEMENT"
    echo "=========================================="
    echo
    echo "1. Create System Backup"
    echo "2. Create Configuration Backup"
    echo "3. List Available Backups"
    echo "4. Backup Statistics"
    echo "5. Delete Old Backups"
    echo "6. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            create_system_backup
            read -p "Press Enter to continue..."
            ;;

        2)
            create_config_backup
            read -p "Press Enter to continue..."
            ;;

        3)
            list_backups
            read -p "Press Enter to continue..."
            ;;

        4)
            backup_statistics
            read -p "Press Enter to continue..."
            ;;

        5)
            delete_old_backups
            read -p "Press Enter to continue..."
            ;;

        6)
            break
            ;;

        *)
            echo
            echo "Invalid option."
            sleep 2
            ;;

    esac

done

