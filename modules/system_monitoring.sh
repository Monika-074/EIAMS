#!/bin/bash

# ==========================================
# EIAMS - System Monitoring Module
# ==========================================

show_system_monitoring() {

    clear

    echo "=========================================="
    echo "          SYSTEM MONITORING"
    echo "=========================================="
    echo

    # ==========================================
    # System Information
    # ==========================================

    echo "Hostname:"
    hostname
    echo

    echo "System Uptime:"
    uptime -p
    echo

    echo "Load Average:"
    uptime | awk -F'load average:' '{print $2}'
    echo

    # ==========================================
    # CPU Monitoring
    # ==========================================

    echo "=========================================="
    echo "              CPU MONITORING"
    echo "=========================================="
    echo

    echo "CPU Model:"
    lscpu | grep "Model name:" | sed 's/^[[:space:]]*//'

    echo
    echo "CPU Architecture:"
    lscpu | grep "Architecture:" | sed 's/^[[:space:]]*//'

    echo
    echo "CPU Cores:"
    lscpu | grep "Core(s) per socket:" | sed 's/^[[:space:]]*//'

    echo
    echo "CPU Usage:"

    if command -v top &>/dev/null; then

        cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk -F',' '{print $4}' | awk '{print $1}')

        if [ -n "$cpu_idle" ]; then
            cpu_usage=$(awk "BEGIN {printf \"%.0f\", 100 - $cpu_idle}")
            echo "$cpu_usage%"
        else
            echo "Unable to determine CPU usage"
        fi

    else
        echo "top command not available."
    fi

    echo

    # ==========================================
    # Memory Monitoring
    # ==========================================

    echo "=========================================="
    echo "            MEMORY MONITORING"
    echo "=========================================="
    echo

    free -h

    echo

    memory_usage=$(free | awk '/Mem:/ {
        printf "%.0f", ($3/$2)*100
    }')

    echo "Memory Usage: $memory_usage%"

    echo

    # ==========================================
    # Swap Monitoring
    # ==========================================

    echo "Swap Usage:"

    swap_usage=$(free | awk '/Swap:/ {
        if ($2 == 0)
            print "0"
        else
            printf "%.0f", ($3/$2)*100
    }')

    echo "$swap_usage%"

    echo

    # ==========================================
    # Disk Monitoring
    # ==========================================

    echo "=========================================="
    echo "             DISK MONITORING"
    echo "=========================================="
    echo

    echo "Root Filesystem:"
    df -h /

    echo

    disk_usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    echo "Root Disk Usage: $disk_usage%"

    echo

    # ==========================================
    # Logged-in Users
    # ==========================================

    echo "=========================================="
    echo "            USER MONITORING"
    echo "=========================================="
    echo

    echo "Logged-in Users:"
    who

    echo

    user_count=$(who | wc -l)

    echo "Active Sessions: $user_count"

    echo

    # ==========================================
    # Top CPU Processes
    # ==========================================

    echo "=========================================="
    echo "        TOP CPU-CONSUMING PROCESSES"
    echo "=========================================="
    echo

    ps -eo pid,user,%cpu,%mem,stat,comm --sort=-%cpu | head -6

    echo

    # ==========================================
    # Top Memory Processes
    # ==========================================

    echo "=========================================="
    echo "       TOP MEMORY-CONSUMING PROCESSES"
    echo "=========================================="
    echo

    ps -eo pid,user,%cpu,%mem,stat,comm --sort=-%mem | head -6

    echo

    # ==========================================
    # System Resource Summary
    # ==========================================

    echo "=========================================="
    echo "          RESOURCE SUMMARY"
    echo "=========================================="
    echo

    echo "CPU Usage:       $cpu_usage%"
    echo "Memory Usage:    $memory_usage%"
    echo "Swap Usage:      $swap_usage%"
    echo "Disk Usage:      $disk_usage%"
    echo "Active Sessions: $user_count"

    echo

    # ==========================================
    # Overall Resource Status
    # ==========================================

    if [ "$cpu_usage" -ge 90 ] || \
       [ "$memory_usage" -ge 90 ] || \
       [ "$disk_usage" -ge 90 ]; then

        echo "Overall Resource Status: CRITICAL"

    elif [ "$cpu_usage" -ge 70 ] || \
         [ "$memory_usage" -ge 70 ] || \
         [ "$disk_usage" -ge 80 ]; then

        echo "Overall Resource Status: WARNING"

    else

        echo "Overall Resource Status: OK"

    fi

    echo
    echo "=========================================="
    echo "       SYSTEM MONITORING COMPLETE"
    echo "=========================================="
    echo
}

show_system_monitoring
