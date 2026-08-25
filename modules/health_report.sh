#!/bin/bash

# ==========================================
# EIAMS - Infrastructure Health Report
# ==========================================

# Find EIAMS project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/eiams.log"
CONFIG_FILE="$PROJECT_DIR/config/config.conf"

mkdir -p "$LOG_DIR"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# ==========================================
# Helper Functions
# ==========================================

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk -F',' '
    {
        for (i = 1; i <= NF; i++) {
            if ($i ~ /id/) {
                gsub(/[^0-9.]/, "", $i)
                print int(100 - $i)
                exit
            }
        }
    }'
}

get_memory_usage() {
    free | awk '/Mem:/ {printf "%.0f", ($3/$2) * 100}'
}

get_disk_usage() {
    df / | awk 'NR==2 {gsub("%",""); print $5}'
}

check_status() {
    local value=$1
    local warning=$2
    local critical=$3

    if [ "$value" -ge "$critical" ]; then
        echo "CRITICAL"
    elif [ "$value" -ge "$warning" ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

# ==========================================
# Collect Metrics
# ==========================================

CPU_USAGE=$(get_cpu_usage)
check_services() {
    local failed=0

    echo "Service Health:"
    echo "------------------------------------------"

    for service in "${MONITORED_SERVICES[@]}"; do

        if ! systemctl list-unit-files --type=service | grep -q "^${service}.service"; then
            echo "$service : NOT INSTALLED"
            continue
        fi

        if systemctl is-active --quiet "$service"; then
            echo "$service : OK"
        else
            echo "$service : CRITICAL"
            failed=$((failed + 1))
        fi
    done

    echo "------------------------------------------"

    return "$failed"
}
MEMORY_USAGE=$(get_memory_usage)
DISK_USAGE=$(get_disk_usage)

SERVICE_OUTPUT=$(check_services)
FAILED_SERVICES=$?
CPU_STATUS=$(check_status "$CPU_USAGE" "$CPU_WARNING" "$CPU_CRITICAL")
MEMORY_STATUS=$(check_status "$MEMORY_USAGE" "$MEMORY_WARNING" "$MEMORY_CRITICAL")
DISK_STATUS=$(check_status "$DISK_USAGE" "$DISK_WARNING" "$DISK_CRITICAL")

# ==========================================
# Determine Overall Status
# ==========================================

OVERALL_STATUS="OK"

if [ "$CPU_STATUS" = "CRITICAL" ] || \
   [ "$MEMORY_STATUS" = "CRITICAL" ] || \
   [ "$DISK_STATUS" = "CRITICAL" ] || \
   [ "$FAILED_SERVICES" -gt "$MAX_FAILED_SERVICES" ]; then
    OVERALL_STATUS="CRITICAL"

elif [ "$CPU_STATUS" = "WARNING" ] || \
     [ "$MEMORY_STATUS" = "WARNING" ] || \
     [ "$DISK_STATUS" = "WARNING" ]; then

    OVERALL_STATUS="WARNING"
fi

# ==========================================
# Generate Report
# ==========================================

{
    echo
    echo "=========================================="
    echo "       EIAMS INFRASTRUCTURE HEALTH"
    echo "=========================================="
    echo "Generated: $(date)"
    echo

    echo "Hostname:"
    hostname
    echo

    echo "System Uptime:"
    uptime -p
    echo

    echo "CPU Usage:"
    echo "${CPU_USAGE}%"
    echo "Status: $CPU_STATUS"
    echo

    echo "Memory Usage:"
    echo "${MEMORY_USAGE}%"
    echo "Status: $MEMORY_STATUS"
    echo

    echo "Disk Usage:"
    echo "${DISK_USAGE}%"
    echo "Status: $DISK_STATUS"
    echo

    echo "$SERVICE_OUTPUT"
    echo

    echo "Running Services:"
    systemctl list-units --type=service --state=running --no-pager | head -15
    echo

    echo "Listening Network Ports:"
    ss -tuln
    echo

    echo "Firewall:"
    if command -v ufw &>/dev/null; then
        sudo ufw status
    else
        echo "UFW not installed"
    fi

    echo

    echo "=========================================="
    echo "           OVERALL SYSTEM STATUS"
    echo "=========================================="
    echo
    echo "CPU:       $CPU_STATUS"
    echo "Memory:    $MEMORY_STATUS"
    echo "Disk:      $DISK_STATUS"
    if [ "$FAILED_SERVICES" -gt "$MAX_FAILED_SERVICES" ]; then
    echo "Services:  CRITICAL"
else
    echo "Services:  OK"
fi
    echo
    echo "Overall Health: $OVERALL_STATUS"
    echo
    echo "=========================================="
    echo "           HEALTH REPORT COMPLETE"
    echo "=========================================="
    echo

} | tee -a "$LOG_FILE"
