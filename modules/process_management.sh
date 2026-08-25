#!/bin/bash

# ==========================================
# EIAMS - Process Management Module
# ==========================================

# ==========================================
# Show Running Processes
# ==========================================

show_processes() {

    echo
    echo "=========================================="
    echo "          RUNNING PROCESSES"
    echo "=========================================="
    echo

    ps aux --sort=-%cpu | head -15

    echo
}

# ==========================================
# Top CPU Processes
# ==========================================

top_cpu_processes() {

    echo
    echo "=========================================="
    echo "       TOP CPU-CONSUMING PROCESSES"
    echo "=========================================="
    echo

    ps -eo pid,user,%cpu,%mem,stat,comm --sort=-%cpu | head -11

    echo
}

# ==========================================
# Top Memory Processes
# ==========================================

top_memory_processes() {

    echo
    echo "=========================================="
    echo "      TOP MEMORY-CONSUMING PROCESSES"
    echo "=========================================="
    echo

    ps -eo pid,user,%cpu,%mem,stat,comm --sort=-%mem | head -11

    echo
}

# ==========================================
# Process Details
# ==========================================

process_details() {

    echo
    echo "=========================================="
    echo "          PROCESS DETAILS"
    echo "=========================================="
    echo

    read -p "Enter PID: " pid

    if [ -z "$pid" ]; then
        echo "PID cannot be empty."
        return
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo "Invalid PID."
        return
    fi

    if ps -p "$pid" > /dev/null 2>&1; then

        echo
        ps -p "$pid" -o \
        pid,ppid,user,%cpu,%mem,stat,lstart,cmd

        echo

    else
        echo "Process with PID $pid is not running."
    fi

    echo
}

# ==========================================
# Process Count
# ==========================================

process_count() {

    echo
    echo "=========================================="
    echo "          PROCESS STATISTICS"
    echo "=========================================="
    echo

    total=$(ps -e --no-headers | wc -l)
    running=$(ps -e -o stat= | grep -c '^R')
    sleeping=$(ps -e -o stat= | grep -c '^S')
    stopped=$(ps -e -o stat= | grep -c '^T')
    zombie=$(ps -e -o stat= | grep -c 'Z')

    echo "Total Processes:   $total"
    echo "Running:           $running"
    echo "Sleeping:          $sleeping"
    echo "Stopped:           $stopped"
    echo "Zombie:            $zombie"

    echo
}

# ==========================================
# Find Process
# ==========================================

find_process() {

    echo
    echo "=========================================="
    echo "             FIND PROCESS"
    echo "=========================================="
    echo

    read -p "Enter process name: " process_name

    if [ -z "$process_name" ]; then
        echo "Process name cannot be empty."
        return
    fi

    echo
    echo "Matching processes:"
    echo "------------------------------------------"

    pgrep -a -f "$process_name"

    if [ $? -ne 0 ]; then
        echo "No matching process found."
    fi

    echo
}

# ==========================================
# Process Management Menu
# ==========================================

while true; do

    clear

    echo "=========================================="
    echo "        EIAMS PROCESS MANAGEMENT"
    echo "=========================================="
    echo
    echo "1. Show Running Processes"
    echo "2. Top CPU Processes"
    echo "3. Top Memory Processes"
    echo "4. Process Details"
    echo "5. Process Statistics"
    echo "6. Find Process"
    echo "7. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            show_processes
            read -p "Press Enter to continue..."
            ;;

        2)
            top_cpu_processes
            read -p "Press Enter to continue..."
            ;;

        3)
            top_memory_processes
            read -p "Press Enter to continue..."
            ;;

        4)
            process_details
            read -p "Press Enter to continue..."
            ;;

        5)
            process_count
            read -p "Press Enter to continue..."
            ;;

        6)
            find_process
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

