#!/bin/bash

# ==========================================
# EIAMS - Log Management Module
# ==========================================

LOG_DIR="/mnt/d/AWSProject/EIAMS/logs"
EIAMS_LOG="$LOG_DIR/eiams.log"
CRON_LOG="$LOG_DIR/cron.log"
SECURITY_LOG="$LOG_DIR/security.log"

# ==========================================
# Create Required Log Files
# ==========================================

initialize_logs() {

    mkdir -p "$LOG_DIR"

    touch "$EIAMS_LOG"
    touch "$CRON_LOG"
    touch "$SECURITY_LOG"
}

# ==========================================
# View EIAMS Logs
# ==========================================

view_eiams_logs() {

    echo
    echo "=========================================="
    echo "             EIAMS LOGS"
    echo "=========================================="
    echo

    if [ -s "$EIAMS_LOG" ]; then
        tail -30 "$EIAMS_LOG"
    else
        echo "EIAMS log is empty."
    fi

    echo
}

# ==========================================
# View Cron Logs
# ==========================================

view_cron_logs() {

    echo
    echo "=========================================="
    echo "             CRON LOGS"
    echo "=========================================="
    echo

    if [ -s "$CRON_LOG" ]; then
        tail -30 "$CRON_LOG"
    else
        echo "Cron log is empty."
    fi

    echo
}

# ==========================================
# View Security Logs
# ==========================================

view_security_logs() {

    echo
    echo "=========================================="
    echo "           SECURITY LOGS"
    echo "=========================================="
    echo

    if [ -s "$SECURITY_LOG" ]; then
        tail -30 "$SECURITY_LOG"
    else
        echo "No EIAMS security events recorded yet."
    fi

    echo
}

# ==========================================
# View Recent System Logs
# ==========================================

view_system_logs() {

    echo
    echo "=========================================="
    echo "        RECENT SYSTEM LOGS"
    echo "=========================================="
    echo

    if command -v journalctl &>/dev/null; then

        journalctl -n 30 --no-pager

    else

        echo "journalctl is not available."

    fi

    echo
}

# ==========================================
# Search Logs
# ==========================================

search_logs() {

    echo
    echo "=========================================="
    echo "             SEARCH LOGS"
    echo "=========================================="
    echo

    read -p "Enter search keyword: " keyword

    if [ -z "$keyword" ]; then
        echo "Search keyword cannot be empty."
        return
    fi

    echo
    echo "Searching EIAMS logs for: $keyword"
    echo "------------------------------------------"

    grep -in -- "$keyword" "$EIAMS_LOG" 2>/dev/null

    echo
    echo "Searching Cron logs for: $keyword"
    echo "------------------------------------------"

    grep -in -- "$keyword" "$CRON_LOG" 2>/dev/null

    echo
    echo "Searching Security logs for: $keyword"
    echo "------------------------------------------"

    grep -in -- "$keyword" "$SECURITY_LOG" 2>/dev/null

    echo
}

# ==========================================
# Log Statistics
# ==========================================

log_statistics() {

    echo
    echo "=========================================="
    echo "            LOG STATISTICS"
    echo "=========================================="
    echo

    echo "EIAMS Log:"
    echo "  File: $EIAMS_LOG"
    echo "  Lines: $(wc -l < "$EIAMS_LOG" 2>/dev/null)"
    echo "  Size: $(du -h "$EIAMS_LOG" 2>/dev/null | cut -f1)"

    echo

    echo "Cron Log:"
    echo "  File: $CRON_LOG"
    echo "  Lines: $(wc -l < "$CRON_LOG" 2>/dev/null)"
    echo "  Size: $(du -h "$CRON_LOG" 2>/dev/null | cut -f1)"

    echo

    echo "Security Log:"
    echo "  File: $SECURITY_LOG"
    echo "  Lines: $(wc -l < "$SECURITY_LOG" 2>/dev/null)"
    echo "  Size: $(du -h "$SECURITY_LOG" 2>/dev/null | cut -f1)"

    echo
}

# ==========================================
# Clear Old Logs
# ==========================================

clear_old_logs() {

    echo
    echo "=========================================="
    echo "           LOG CLEANUP"
    echo "=========================================="
    echo

    echo "Current log sizes:"
    echo

    du -h "$EIAMS_LOG" "$CRON_LOG" "$SECURITY_LOG" 2>/dev/null

    echo
    echo "This operation will clear the contents"
    echo "of EIAMS-managed logs."
    echo
    echo "The log files themselves will NOT be deleted."
    echo

    read -p "Continue? (yes/no): " confirmation

    if [ "$confirmation" = "yes" ]; then

        : > "$EIAMS_LOG"
        : > "$CRON_LOG"
        : > "$SECURITY_LOG"

        echo
        echo "EIAMS logs cleared successfully."

    else

        echo
        echo "Cleanup cancelled."

    fi

    echo
}

# ==========================================
# Log Management Menu
# ==========================================

initialize_logs

while true; do

    clear

    echo "=========================================="
    echo "          EIAMS LOG MANAGEMENT"
    echo "=========================================="
    echo
    echo "1. View EIAMS Logs"
    echo "2. View Cron Logs"
    echo "3. View Security Logs"
    echo "4. View Recent System Logs"
    echo "5. Search Logs"
    echo "6. Log Statistics"
    echo "7. Clear Old Logs"
    echo "8. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            view_eiams_logs
            read -p "Press Enter to continue..."
            ;;

        2)
            view_cron_logs
            read -p "Press Enter to continue..."
            ;;

        3)
            view_security_logs
            read -p "Press Enter to continue..."
            ;;

        4)
            view_system_logs
            read -p "Press Enter to continue..."
            ;;

        5)
            search_logs
            read -p "Press Enter to continue..."
            ;;

        6)
            log_statistics
            read -p "Press Enter to continue..."
            ;;

        7)
            clear_old_logs
            read -p "Press Enter to continue..."
            ;;

        8)
            break
            ;;

        *)
            echo
            echo "Invalid option."
            sleep 2
            ;;

    esac

done
