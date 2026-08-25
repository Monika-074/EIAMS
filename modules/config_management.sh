#!/bin/bash

# ==========================================
# EIAMS - Configuration Management Module
# ==========================================

PROJECT_DIR="/mnt/d/AWSProject/EIAMS"
CONFIG_FILE="$PROJECT_DIR/config/config.conf"

# ==========================================
# Display Configuration
# ==========================================

show_configuration() {

    echo
    echo "=========================================="
    echo "       EIAMS CONFIGURATION"
    echo "=========================================="
    echo

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file not found."
        return
    fi

    cat "$CONFIG_FILE"

    echo
}

# ==========================================
# Validate Configuration
# ==========================================

validate_configuration() {

    echo
    echo "=========================================="
    echo "      CONFIGURATION VALIDATION"
    echo "=========================================="
    echo

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Status: CRITICAL"
        echo "Configuration file does not exist."
        return
    fi

    source "$CONFIG_FILE"

    validation_failed=0

    # CPU validation
    if [ "$CPU_WARNING" -ge "$CPU_CRITICAL" ]; then
        echo "CPU thresholds: INVALID"
        validation_failed=1
    else
        echo "CPU thresholds: OK"
    fi

    # Memory validation
    if [ "$MEMORY_WARNING" -ge "$MEMORY_CRITICAL" ]; then
        echo "Memory thresholds: INVALID"
        validation_failed=1
    else
        echo "Memory thresholds: OK"
    fi

    # Disk validation
    if [ "$DISK_WARNING" -ge "$DISK_CRITICAL" ]; then
        echo "Disk thresholds: INVALID"
        validation_failed=1
    else
        echo "Disk thresholds: OK"
    fi

    # Range validation
    if [ "$CPU_CRITICAL" -gt 100 ] || [ "$MEMORY_CRITICAL" -gt 100 ] || [ "$DISK_CRITICAL" -gt 100 ]; then
        echo "Threshold range: INVALID"
        validation_failed=1
    else
        echo "Threshold range: OK"
    fi

    # Service configuration
    if [ "${#MONITORED_SERVICES[@]}" -gt 0 ]; then
        echo "Monitored services: OK"
        echo "Services configured: ${#MONITORED_SERVICES[@]}"
    else
        echo "Monitored services: WARNING - None configured"
    fi

    echo

    if [ "$validation_failed" -eq 0 ]; then
        echo "Configuration Status: VALID"
    else
        echo "Configuration Status: INVALID"
    fi

    echo
}

# ==========================================
# Configuration Summary
# ==========================================

configuration_summary() {

    echo
    echo "=========================================="
    echo "       CONFIGURATION SUMMARY"
    echo "=========================================="
    echo

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file not found."
        return
    fi

    source "$CONFIG_FILE"

    echo "Configuration File:"
    echo "$CONFIG_FILE"

    echo
    echo "CPU:"
    echo "  Warning:  $CPU_WARNING%"
    echo "  Critical: $CPU_CRITICAL%"

    echo
    echo "Memory:"
    echo "  Warning:  $MEMORY_WARNING%"
    echo "  Critical: $MEMORY_CRITICAL%"

    echo
    echo "Disk:"
    echo "  Warning:  $DISK_WARNING%"
    echo "  Critical: $DISK_CRITICAL%"

    echo
    echo "Maximum Failed Services:"
    echo "  $MAX_FAILED_SERVICES"

    echo
    echo "Monitored Services:"

    for service in "${MONITORED_SERVICES[@]}"; do
        echo "  - $service"
    done

    echo
}

# ==========================================
# Configuration Menu
# ==========================================

while true; do

    clear

    echo "=========================================="
    echo "       EIAMS CONFIGURATION MANAGEMENT"
    echo "=========================================="
    echo
    echo "1. View Configuration"
    echo "2. Validate Configuration"
    echo "3. Configuration Summary"
    echo "4. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            show_configuration
            read -p "Press Enter to continue..."
            ;;

        2)
            validate_configuration
            read -p "Press Enter to continue..."
            ;;

        3)
            configuration_summary
            read -p "Press Enter to continue..."
            ;;

        4)
            break
            ;;

        *)
            echo
            echo "Invalid option."
            sleep 2
            ;;

    esac

done
