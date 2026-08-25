#!/bin/bash

# ==========================================
# EIAMS - System Information Module
# ==========================================

# ==========================================
# Operating System Information
# ==========================================

os_information() {

    echo
    echo "=========================================="
    echo "      OPERATING SYSTEM INFORMATION"
    echo "=========================================="
    echo

    echo "Hostname:"
    hostname

    echo
    echo "Operating System:"
    if [ -f /etc/os-release ]; then
        grep "^PRETTY_NAME=" /etc/os-release | cut -d= -f2- | tr -d '"'
    else
        echo "OS information unavailable"
    fi

    echo
    echo "Kernel:"
    uname -r

    echo
    echo "Architecture:"
    uname -m

    echo
    echo "Kernel Information:"
    uname -a

    echo
    echo "System Uptime:"
    uptime

    echo
}

# ==========================================
# CPU Information
# ==========================================

cpu_information() {

    echo
    echo "=========================================="
    echo "             CPU INFORMATION"
    echo "=========================================="
    echo

    echo "CPU Model:"
    lscpu | grep "Model name:" | sed 's/^[[:space:]]*//'

    echo
    echo "CPU Architecture:"
    lscpu | grep "Architecture:" | sed 's/^[[:space:]]*//'

    echo
    echo "CPU(s):"
    lscpu | grep "^CPU(s):" | head -1 | sed 's/^[[:space:]]*//'

    echo
    echo "CPU Cores:"
    lscpu | grep "^Core(s) per socket:" | sed 's/^[[:space:]]*//'

    echo
    echo "Threads per Core:"
    lscpu | grep "^Thread(s) per core:" | sed 's/^[[:space:]]*//'

    echo
    echo "CPU Frequency:"
    lscpu | grep "CPU MHz:" | sed 's/^[[:space:]]*//' || echo "Not available"

    echo
}

# ==========================================
# Memory Information
# ==========================================

memory_information() {

    echo
    echo "=========================================="
    echo "            MEMORY INFORMATION"
    echo "=========================================="
    echo

    free -h

    echo
    echo "Memory Details:"
    echo

    if command -v free &>/dev/null; then
        free -h | grep "^Mem:"
    fi

    echo
    echo "Swap Details:"
    echo

    free -h | grep "^Swap:"

    echo
}

# ==========================================
# Disk Information
# ==========================================

disk_information() {

    echo
    echo "=========================================="
    echo "             DISK INFORMATION"
    echo "=========================================="
    echo

    echo "Filesystem Usage:"
    df -h

    echo
    echo "Disk Inodes:"
    df -ih

    echo
    echo "Mounted Filesystems:"
    findmnt --real 2>/dev/null || mount | head -20

    echo
}

# ==========================================
# Network Information
# ==========================================

network_information() {

    echo
    echo "=========================================="
    echo "            NETWORK INFORMATION"
    echo "=========================================="
    echo

    echo "Hostname:"
    hostname

    echo
    echo "IP Addresses:"
    ip -brief address

    echo
    echo "Default Gateway:"
    ip route | grep default || echo "Default gateway not found"

    echo
    echo "Routing Table:"
    ip route

    echo
    echo "DNS Configuration:"
    if [ -f /etc/resolv.conf ]; then
        cat /etc/resolv.conf
    else
        echo "DNS configuration unavailable"
    fi

    echo
    echo "Listening Ports:"
    if command -v ss &>/dev/null; then
        ss -tuln
    else
        echo "ss command is not available"
    fi

    echo
}

# ==========================================
# User Information
# ==========================================

user_information() {

    echo
    echo "=========================================="
    echo "              USER INFORMATION"
    echo "=========================================="
    echo

    echo "Current User:"
    whoami

    echo
    echo "User ID:"
    id

    echo
    echo "Logged-in Users:"
    who

    echo
    echo "Last Login:"
    last -n 5 2>/dev/null || echo "Login history unavailable"

    echo
    echo "Current Shell:"
    echo "$SHELL"

    echo
    echo "Home Directory:"
    echo "$HOME"

    echo
}

# ==========================================
# Complete System Report
# ==========================================

complete_system_report() {

    echo
    echo "=========================================="
    echo "        EIAMS COMPLETE SYSTEM REPORT"
    echo "=========================================="

    os_information
    cpu_information
    memory_information
    disk_information
    network_information
    user_information

    echo
    echo "=========================================="
    echo "       SYSTEM REPORT COMPLETE"
    echo "=========================================="
    echo
}

# ==========================================
# System Information Menu
# ==========================================

while true; do

    clear

    echo "=========================================="
    echo "       EIAMS SYSTEM INFORMATION"
    echo "=========================================="
    echo
    echo "1. Operating System Information"
    echo "2. CPU Information"
    echo "3. Memory Information"
    echo "4. Disk Information"
    echo "5. Network Information"
    echo "6. User Information"
    echo "7. Complete System Report"
    echo "8. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            os_information
            read -p "Press Enter to continue..."
            ;;

        2)
            cpu_information
            read -p "Press Enter to continue..."
            ;;

        3)
            memory_information
            read -p "Press Enter to continue..."
            ;;

        4)
            disk_information
            read -p "Press Enter to continue..."
            ;;

        5)
            network_information
            read -p "Press Enter to continue..."
            ;;

        6)
            user_information
            read -p "Press Enter to continue..."
            ;;

        7)
            complete_system_report
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
