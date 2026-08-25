#!/bin/bash

# ==========================================
# EIAMS - Automation Management Module
# ==========================================

PROJECT_DIR="/mnt/d/AWSProject/EIAMS"
CRON_LOG="$PROJECT_DIR/logs/cron.log"

# ==========================================
# Initialize
# ==========================================

initialize_automation() {

    mkdir -p "$PROJECT_DIR/logs"
    touch "$CRON_LOG"

}

# ==========================================
# View Current Cron Jobs
# ==========================================

view_cron_jobs() {

    echo
    echo "=========================================="
    echo "          CURRENT CRON JOBS"
    echo "=========================================="
    echo

    echo "User Cron Jobs:"
    echo "------------------------------------------"

    crontab -l 2>/dev/null || echo "No user cron jobs configured."

    echo
    echo "System Cron Directories:"
    echo "------------------------------------------"

    echo "/etc/cron.d:"
    ls -la /etc/cron.d 2>/dev/null

    echo
    echo "/etc/cron.hourly:"
    ls -la /etc/cron.hourly 2>/dev/null

    echo
    echo "/etc/cron.daily:"
    ls -la /etc/cron.daily 2>/dev/null

    echo
}

# ==========================================
# Add EIAMS Health Report Cron Job
# ==========================================

add_health_cron() {

    echo
    echo "=========================================="
    echo "       ADD HEALTH REPORT AUTOMATION"
    echo "=========================================="
    echo

    SCRIPT_PATH="$PROJECT_DIR/modules/health_report.sh"

    if [ ! -x "$SCRIPT_PATH" ]; then
        echo "Health report script not found or not executable."
        return
    fi

    CRON_ENTRY="0 * * * * $SCRIPT_PATH >> $CRON_LOG 2>&1"

    if crontab -l 2>/dev/null | grep -Fq "$SCRIPT_PATH"; then

        echo "Health report cron job already exists."

    else

        (
            crontab -l 2>/dev/null
            echo "$CRON_ENTRY"
        ) | crontab -

        echo "Health report automation added successfully."
        echo
        echo "Schedule:"
        echo "Every hour"
        echo
        echo "Cron Entry:"
        echo "$CRON_ENTRY"

    fi

    echo
}

# ==========================================
# Add Daily Backup Automation
# ==========================================

add_backup_cron() {

    echo
    echo "=========================================="
    echo "        ADD BACKUP AUTOMATION"
    echo "=========================================="
    echo

    SCRIPT_PATH="$PROJECT_DIR/modules/backup_management.sh"

    if [ ! -x "$SCRIPT_PATH" ]; then
        echo "Backup management script not found or not executable."
        return
    fi

    echo "Note: backup_management.sh is an interactive"
    echo "menu-based script and should not be directly"
    echo "scheduled by cron."
    echo
    echo "We will therefore create a dedicated"
    echo "non-interactive system backup command."

    echo
    echo "Backup automation will be implemented"
    echo "in the next automation enhancement."

    echo
}

# ==========================================
# View Cron Log
# ==========================================

view_cron_log() {

    echo
    echo "=========================================="
    echo "             CRON ACTIVITY"
    echo "=========================================="
    echo

    if [ -s "$CRON_LOG" ]; then
        tail -30 "$CRON_LOG"
    else
        echo "No cron activity recorded yet."
    fi

    echo
}

# ==========================================
# Test Health Report
# ==========================================

test_health_report() {

    echo
    echo "=========================================="
    echo "        TEST AUTOMATED HEALTH REPORT"
    echo "=========================================="
    echo

    SCRIPT_PATH="$PROJECT_DIR/modules/health_report.sh"

    if [ -x "$SCRIPT_PATH" ]; then

        echo "Running health report..."
        echo

        "$SCRIPT_PATH"

    else

        echo "Health report script not found."

    fi

}

# ==========================================
# Remove EIAMS Health Cron Job
# ==========================================

remove_health_cron() {

    echo
    echo "=========================================="
    echo "       REMOVE HEALTH REPORT AUTOMATION"
    echo "=========================================="
    echo

    SCRIPT_PATH="$PROJECT_DIR/modules/health_report.sh"

    if crontab -l 2>/dev/null | grep -Fq "$SCRIPT_PATH"; then

        crontab -l 2>/dev/null | grep -vF "$SCRIPT_PATH" | crontab -

        echo "Health report cron job removed successfully."

    else

        echo "Health report cron job is not configured."

    fi

    echo
}

# ==========================================
# Automation Summary
# ==========================================

automation_summary() {

    echo
    echo "=========================================="
    echo "          AUTOMATION SUMMARY"
    echo "=========================================="
    echo

    echo "[1] Cron Service:"
    if systemctl is-active --quiet cron 2>/dev/null; then
        echo "Status: RUNNING"
    else
        echo "Status: NOT RUNNING"
    fi

    echo
    echo "[2] EIAMS Health Automation:"

    if crontab -l 2>/dev/null | grep -Fq "$PROJECT_DIR/modules/health_report.sh"; then
        echo "Status: ENABLED"
    else
        echo "Status: NOT CONFIGURED"
    fi

    echo
    echo "[3] Cron Jobs:"
    crontab -l 2>/dev/null || echo "No user cron jobs."

    echo
    echo "=========================================="
}

# ==========================================
# Main Menu
# ==========================================

initialize_automation

while true; do

    clear

    echo "=========================================="
    echo "        EIAMS AUTOMATION MANAGEMENT"
    echo "=========================================="
    echo
    echo "1. View Current Cron Jobs"
    echo "2. Add Health Report Automation"
    echo "3. Add Backup Automation"
    echo "4. View Cron Activity"
    echo "5. Test Health Report"
    echo "6. Remove Health Report Automation"
    echo "7. Automation Summary"
    echo "8. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            view_cron_jobs
            read -p "Press Enter to continue..."
            ;;

        2)
            add_health_cron
            read -p "Press Enter to continue..."
            ;;

        3)
            add_backup_cron
            read -p "Press Enter to continue..."
            ;;

        4)
            view_cron_log
            read -p "Press Enter to continue..."
            ;;

        5)
            test_health_report
            read -p "Press Enter to continue..."
            ;;

        6)
            remove_health_cron
            read -p "Press Enter to continue..."
            ;;

        7)
            automation_summary
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
