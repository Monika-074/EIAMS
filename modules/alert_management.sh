#!/bin/bash

# ==========================================
# EIAMS - Alert & Incident Management
# ==========================================

ALERT_DIR="/mnt/d/AWSProject/EIAMS/logs"
ALERT_LOG="$ALERT_DIR/alerts.log"

mkdir -p "$ALERT_DIR"
touch "$ALERT_LOG"

# ==========================================
# Generate Alert
# ==========================================

generate_alert() {

    echo
    echo "=========================================="
    echo "          GENERATE SYSTEM ALERT"
    echo "=========================================="
    echo

    echo "1. CPU Alert"
    echo "2. Memory Alert"
    echo "3. Disk Alert"
    echo "4. Network Alert"
    echo "5. Security Alert"
    echo "6. Service Alert"
    echo

    read -p "Select alert type: " alert_type

    case "$alert_type" in

        1)
            category="CPU"
            ;;

        2)
            category="MEMORY"
            ;;

        3)
            category="DISK"
            ;;

        4)
            category="NETWORK"
            ;;

        5)
            category="SECURITY"
            ;;

        6)
            category="SERVICE"
            ;;

        *)
            echo
            echo "Invalid alert type."
            return
            ;;

    esac

    echo
    read -p "Enter alert severity [LOW/MEDIUM/HIGH/CRITICAL]: " severity
    read -p "Enter alert description: " description

    severity=$(echo "$severity" | tr '[:lower:]' '[:upper:]')

    case "$severity" in
        LOW|MEDIUM|HIGH|CRITICAL)
            ;;
        *)
            echo
            echo "Invalid severity."
            echo "Use LOW, MEDIUM, HIGH or CRITICAL."
            return
            ;;
    esac

    if [ -z "$description" ]; then
        echo
        echo "Description cannot be empty."
        return
    fi

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    hostname_value=$(hostname)

    alert_id=$(date '+%Y%m%d%H%M%S')-$RANDOM

    echo "$alert_id|$timestamp|$hostname_value|$category|$severity|ACTIVE|$description" >> "$ALERT_LOG"

    echo
    echo "Alert generated successfully."
    echo
    echo "Alert ID: $alert_id"
    echo "Category: $category"
    echo "Severity: $severity"
    echo "Status: ACTIVE"
    echo

}

# ==========================================
# View Active Alerts
# ==========================================

view_active_alerts() {

    echo
    echo "=========================================="
    echo "             ACTIVE ALERTS"
    echo "=========================================="
    echo

    if [ ! -s "$ALERT_LOG" ]; then
        echo "No alerts recorded."
        return
    fi

    active_count=0

    while IFS='|' read -r id timestamp host category severity status description
    do

        if [ "$status" = "ACTIVE" ]; then

            echo "Alert ID: $id"
            echo "Time:     $timestamp"
            echo "Host:     $host"
            echo "Category: $category"
            echo "Severity: $severity"
            echo "Status:   $status"
            echo "Details:  $description"
            echo "------------------------------------------"

            active_count=$((active_count + 1))

        fi

    done < "$ALERT_LOG"

    if [ "$active_count" -eq 0 ]; then
        echo "No active alerts."
    else
        echo
        echo "Active Alerts: $active_count"
    fi

    echo
}

# ==========================================
# View Alert History
# ==========================================

view_alert_history() {

    echo
    echo "=========================================="
    echo "            ALERT HISTORY"
    echo "=========================================="
    echo

    if [ ! -s "$ALERT_LOG" ]; then
        echo "Alert history is empty."
        return
    fi

    while IFS='|' read -r id timestamp host category severity status description
    do

        echo "Alert ID: $id"
        echo "Time:     $timestamp"
        echo "Host:     $host"
        echo "Category: $category"
        echo "Severity: $severity"
        echo "Status:   $status"
        echo "Details:  $description"
        echo "------------------------------------------"

    done < "$ALERT_LOG"

    echo
}

# ==========================================
# Acknowledge Alert
# ==========================================

acknowledge_alert() {

    echo
    echo "=========================================="
    echo "           ACKNOWLEDGE ALERT"
    echo "=========================================="
    echo

    if [ ! -s "$ALERT_LOG" ]; then
        echo "No alerts available."
        return
    fi

    read -p "Enter Alert ID: " alert_id

    if [ -z "$alert_id" ]; then
        echo "Alert ID cannot be empty."
        return
    fi

    if ! grep -q "^${alert_id}|" "$ALERT_LOG"; then
        echo
        echo "Alert not found."
        return
    fi

    sed -i "s/^${alert_id}|\([^|]*\)|\([^|]*\)|\([^|]*\)|\([^|]*\)|ACTIVE|/${alert_id}|\1|\2|\3|\4|ACKNOWLEDGED|/" "$ALERT_LOG"

    echo
    echo "Alert acknowledged successfully."
    echo
}

# ==========================================
# Clear Resolved Alerts
# ==========================================

clear_resolved_alerts() {

    echo
    echo "=========================================="
    echo "          CLEAR RESOLVED ALERTS"
    echo "=========================================="
    echo

    if [ ! -s "$ALERT_LOG" ]; then
        echo "No alerts available."
        return
    fi

    before_count=$(wc -l < "$ALERT_LOG")

    sed -i '/|RESOLVED|/d' "$ALERT_LOG"

    after_count=$(wc -l < "$ALERT_LOG")

    removed=$((before_count - after_count))

    echo "Resolved alerts removed: $removed"
    echo
}

# ==========================================
# Alert Statistics
# ==========================================

alert_statistics() {

    echo
    echo "=========================================="
    echo "            ALERT STATISTICS"
    echo "=========================================="
    echo

    total=0
    active=0
    acknowledged=0
    resolved=0
    critical=0
    high=0
    medium=0
    low=0

    if [ -s "$ALERT_LOG" ]; then

        while IFS='|' read -r id timestamp host category severity status description
        do

            total=$((total + 1))

            case "$status" in
                ACTIVE)
                    active=$((active + 1))
                    ;;
                ACKNOWLEDGED)
                    acknowledged=$((acknowledged + 1))
                    ;;
                RESOLVED)
                    resolved=$((resolved + 1))
                    ;;
            esac

            case "$severity" in
                CRITICAL)
                    critical=$((critical + 1))
                    ;;
                HIGH)
                    high=$((high + 1))
                    ;;
                MEDIUM)
                    medium=$((medium + 1))
                    ;;
                LOW)
                    low=$((low + 1))
                    ;;
            esac

        done < "$ALERT_LOG"

    fi

    echo "Total Alerts:       $total"
    echo
    echo "By Status:"
    echo "  Active:           $active"
    echo "  Acknowledged:     $acknowledged"
    echo "  Resolved:         $resolved"
    echo
    echo "By Severity:"
    echo "  Critical:         $critical"
    echo "  High:             $high"
    echo "  Medium:           $medium"
    echo "  Low:              $low"
    echo
}

# ==========================================
# Main Menu
# ==========================================

while true; do

    clear

    echo "=========================================="
    echo "       EIAMS ALERT MANAGEMENT"
    echo "=========================================="
    echo
    echo "1. View Active Alerts"
    echo "2. Generate System Alert"
    echo "3. View Alert History"
    echo "4. Acknowledge Alert"
    echo "5. Clear Resolved Alerts"
    echo "6. Alert Statistics"
    echo "7. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            view_active_alerts
            read -p "Press Enter to continue..."
            ;;

        2)
            generate_alert
            read -p "Press Enter to continue..."
            ;;

        3)
            view_alert_history
            read -p "Press Enter to continue..."
            ;;

        4)
            acknowledge_alert
            read -p "Press Enter to continue..."
            ;;

        5)
            clear_resolved_alerts
            read -p "Press Enter to continue..."
            ;;

        6)
            alert_statistics
            read -p "Press Enter to continue..."
            ;;

        7)
            break
            ;;

        *)
            echo
            echo "Invalid option."
            sleep 2
            ;;

    esac

done
