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

    echo "Hostname:"
    hostname
    echo

    echo "System Uptime:"
    uptime -p
    echo

    echo "CPU Information:"
    lscpu | grep -E "Model name|CPU\(s\)" | head -2
    echo

    echo "Memory Usage:"
    free -h
    echo

    echo "Disk Usage:"
    df -h /
    echo

    echo "Logged-in Users:"
    who
    echo

    echo "Top Running Processes:"
    ps aux --sort=-%cpu | head -6

    echo
    echo "=========================================="
}

show_system_monitoring
